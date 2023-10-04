{
  config,
  lib,
  options,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkOption types;

  cfg = config.modules.k3s;

  addonsFormat = pkgs.formats.yaml {};

  mkAddons = lib.mapAttrsToList (name: addon: addonsFormat.generate "${name}.yaml" addon);

  addons = pkgs.runCommand "k3s-user-addons" {} ''
    mkdir -p $out
    ${lib.concatMapStringsSep ";" (addon: "${pkgs.coreutils}/bin/cp -a ${addon} $out/") (mkAddons cfg.addons)}
  '';

  extraFlags = toString [
    "--container-runtime-endpoint=unix:///run/containerd/containerd.sock"
    "--flannel-backend=none"
    "--disable=traefik"
    "--node-ip=${config.nixos.profiles.k3s-node.wireguard.ipv4.address}"
    "--cluster-cidr=10.32.0.0/11"
    "--service-cidr=10.64.0.0/12"
    "--disable-network-policy"
    "--secrets-encryption"
    "--kube-apiserver-arg 'authorization-mode=Node,RBAC'"
    "--kube-apiserver-arg 'allow-privileged=true'"
  ];

  kubeovn-cni = pkgs.callPackage ../../packages/kube-ovn {};
  kubectl-ko = pkgs.callPackage ../../packages/kubectl-ko {};
  kubectl-rook-ceph = pkgs.callPackage ../../packages/kubectl-rook-ceph {};
  kubectl-virt = pkgs.callPackage ../../packages/kubectl-virt {};

  cni-conf-dir = "/etc/cni/net.d";
  cni-bin-dir = "/opt/cni/bin";
in {
  options.modules.k3s = {
    inherit (options.services.k3s) enable clusterInit role serverAddr;

    addons = mkOption {
      type = types.attrsOf types.attrs;
      description = ''
        K3s user addons (any kind of Kubernetes resource can be an addon). See:
        https://docs.k3s.io/installation/packaged-components#user-addons
      '';
      default = {};
    };
  };

  config = mkIf cfg.enable {
    boot.kernel.sysctl = {
      "net.ipv4.ip_forward" = true;
      "net.ipv4.conf.all.proxy_arp" = true;
      "net.ipv6.conf.all.forwarding" = true;
    };

    environment.sessionVariables = {
      KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";
    };

    environment.systemPackages = [
      (pkgs.writeShellScriptBin "k3s-reset-node" (builtins.readFile ./k3s-reset-node))
      pkgs.kubectl
      pkgs.kubernetes-helm
      kubectl-ko
      kubectl-rook-ceph
      kubectl-virt
    ];

    networking.firewall = {
      allowedTCPPorts =
        [2379 2380] # Required for HA setup with embedded etcd
        ++ [6081] # KubeOVN: ovs-ovn -- tunnel ports
        ++ [6443] # K3s Supervisor and Kubernetes API Server
        ++ [6641 6642 6643 6644] # KubeOVN: ovn-central -- ovn-db and raft server listen ports
        ++ [10250] # Kubelet Metrics Server
        ++ [10660 10661 10665]; # KubeOVN: kube-ovn-controller, kube-ovn-monitor, kube-ovn-daemon metrics
    };

    services.k3s = {
      inherit (cfg) enable role clusterInit serverAddr;
      inherit extraFlags;
      tokenFile = lib.mkDefault config.sops.secrets.k3s-server-token.path;
    };

    sops = {
      secrets = {
        k3s-server-token = {
          sopsFile = ./secrets.yaml;
        };
      };
    };

    systemd.services.cni-setup = {
      serviceConfig.Type = "oneshot";
      script = ''
        ${pkgs.coreutils}/bin/rm -rf ${cni-conf-dir}
        ${pkgs.coreutils}/bin/mkdir -p ${cni-conf-dir}
        ${pkgs.coreutils}/bin/rm -rf ${cni-bin-dir}
        ${pkgs.coreutils}/bin/mkdir -p ${cni-bin-dir}
        # Symlink all CNI plugins to the CNI bin directory
        ${pkgs.coreutils}/bin/ln -sf ${pkgs.cni-plugins}/bin/* ${cni-bin-dir}
        ${pkgs.coreutils}/bin/ln -sf ${pkgs.multus-cni}/bin/* ${cni-bin-dir}
        ${pkgs.coreutils}/bin/ln -sf ${kubeovn-cni}/bin/cni ${cni-bin-dir}/kube-ovn
      '';
    };

    systemd.services.k3s = {
      wants = ["containerd.service"];
      after = ["containerd.service"];
      serviceConfig = {
        ExecStartPre = [
          "${pkgs.coreutils}/bin/rm -rf /var/lib/rancher/k3s/server/manifests"
          "${pkgs.coreutils}/bin/mkdir -p /var/lib/rancher/k3s/server/manifests"
        ];
        ExecStartPost = [
          "${pkgs.coreutils}/bin/cp -a ${addons}/. /var/lib/rancher/k3s/server/manifests/"
        ];
      };
    };

    systemd.services.containerd = {
      wants = ["cni-setup.service"];
      after = ["cni-setup.service"];
      serviceConfig = {
        ExecStartPre = [
          "-${pkgs.zfs}/bin/zfs create -o mountpoint=/var/lib/containerd/io.containerd.snapshotter.v1.zfs zroot/containerd"
        ];
      };
    };

    virtualisation.containerd = {
      enable = true;
      settings = {
        version = 2;
        plugins = {
          "io.containerd.grpc.v1.cri" = {
            cni = {
              conf_dir = cni-conf-dir;
              bin_dir = cni-bin-dir;
            };
          };
        };
      };
    };
  };
}
