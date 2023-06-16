{
  clusterInit ? false,
  config,
  lib,
  networkingConfig,
  pkgs,
  serverAddr ? "",
  ...
}: let
  cniBinDir = "/opt/cni/bin";
  cniConfDir = "/etc/cni/net.d";
  # kubeovn = pkgs.callPackage ./kube-ovn-cni.nix {};
  # multusConf = (pkgs.formats.json {}).generate "00-multus.conf" {
  #   name = "multus-cni-network";
  #   type = "multus";
  #   capabilities = {
  #     portMappings = true;
  #   };
  #   delegates = [
  #     {
  #       name = "kube-ovn";
  #       cniVersion = "0.3.1";
  #       plugins = [
  #         {
  #           type = "kube-ovn";
  #           server_socket = "/run/openvswitch/kube-ovn-daemon.sock";
  #         }
  #         {
  #           type = "portmap";
  #           capabilities = {
  #             portMappings = true;
  #           };
  #         }
  #       ];
  #     }
  #   ];
  #   kubeconfig = "/etc/rancher/k3s/k3s.yaml";
  # };
  # cniOriginalBin = pkgs.runCommand "cni-bin-dir" {} ''
  #   mkdir -p $out
  #   ln -sf ${pkgs.cni-plugins}/bin/* $out
  #   ln -sf ${kubeovn}/bin/cmd $out/kube-ovn
  # '';
  # cniOriginalBin = pkgs.runCommand "cni-bin-dir" {} ''
  #   mkdir -p $out
  #   ln -sf ${pkgs.cni-plugins}/bin/* ${pkgs.cni-plugin-flannel}/bin/* $out
  # '';
in {
  imports = [
    ./kata-containers.nix
  ];

  environment.systemPackages = with pkgs.unstable; [
    (writeShellScriptBin "k3s-reset-node" (builtins.readFile ./k3s-reset-node))
    (callPackage ./kubectl-ko.nix {})
    cri-tools
    kubevirt
    wireguard-tools
  ];

  services = {
    k3s = {
      enable = true;
      package = pkgs.unstable.k3s;
      role = "server";
      extraFlags = toString [
        "--container-runtime-endpoint=unix:///run/containerd/containerd.sock"
        # "--disable=traefik"
        # "--disable=coredns"
        # "--flannel-backend=none"
        "--flannel-backend=host-gw"
        "--secrets-encryption"
        # "--node-ip=${networkingConfig.vlanPrivateIPv4},${networkingConfig.vlanPrivateIPv6}"
        # "--cluster-cidr=10.32.0.0/11,fd01:c26e:7c96:4a4c::/64"
        # "--service-cidr=10.64.0.0/12,fdb6:5037:f7b9:190a::/108"
        # "--disable-network-policy"
        "--kube-apiserver-arg 'allow-privileged=true'"
        "--kube-apiserver-arg 'authorization-mode=Node,RBAC'"
      ];
      tokenFile = lib.mkDefault config.sops.secrets.k3s-server-token.path;
      inherit clusterInit serverAddr;
    };
  };

  sops = {
    secrets = {
      k3s-server-token = {
        sopsFile = ./secrets.yaml;
      };
    };
  };

  systemd = {
    services = {
      containerd = {
        # preStart = ''
        #   if [[ ! -d "${cniConfDir}" ]]; then
        #     ${pkgs.coreutils}/bin/mkdir -p "${cniConfDir}"
        #   fi
        #   if [[ ! -d "${cniBinDir}" ]]; then
        #     ${pkgs.coreutils}/bin/mkdir -p /opt/cni/bin
        #   fi
        #   ${pkgs.coreutils}/bin/ln -sf ${multusConf} "${cniConfDir}/00-multus.conf"
        #   ${pkgs.rsync}/bin/rsync -a -L ${cniOriginalBin}/ /opt/cni/bin/
        # '';
        # preStart = ''
        #   if [[ ! -d "${cniConfDir}" ]]; then
        #     ${pkgs.coreutils}/bin/mkdir -p "${cniConfDir}"
        #   fi
        #   if [[ ! -d "${cniBinDir}" ]]; then
        #     ${pkgs.coreutils}/bin/mkdir -p /opt/cni/bin
        #   fi
        # '';
        serviceConfig = {
          ExecStartPre = [
            "-${pkgs.zfs}/bin/zfs create -o mountpoint=/var/lib/containerd/io.containerd.snapshotter.v1.zfs zroot/containerd"
          ];
        };
      };
      k3s = {
        wants = ["containerd.service"];
        after = ["containerd.service"];
      };
    };
  };

  virtualisation = {
    containerd = {
      enable = true;
      settings = {
        version = 2;
        plugins = {
          "io.containerd.grpc.v1.cri" = {
            cni = {
              # bin_dir = "${cniBinDir}";
              # conf_dir = "${cniConfDir}";
              # conf_dir = "/var/lib/rancher/k3s/agent/etc/cni/net.d/";
              bin_dir = "${pkgs.runCommand "cni-bin-dir" {} ''
                mkdir -p $out
                ln -sf ${pkgs.cni-plugins}/bin/* ${pkgs.cni-plugin-flannel}/bin/* $out
              ''}";
            };
          };
        };
      };
    };
  };
}
