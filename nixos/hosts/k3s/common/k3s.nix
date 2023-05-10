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
in {
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "k3s-reset-node" (builtins.readFile ./k3s-reset-node))
    pkgs.wireguard-tools
  ];

  services = {
    k3s = {
      enable = true;
      package = pkgs.unstable.k3s;
      role = "server";
      extraFlags = toString [
        "--container-runtime-endpoint=unix:///run/containerd/containerd.sock"
        "--disable=traefik"
        "--flannel-backend=none"
        "--disable=coredns"
        "--secrets-encryption"
        "--node-ip=${networkingConfig.ipv4Address}"
        "--cluster-cidr=10.32.0.0/11"
        "--service-cidr=10.64.0.0/12"
        "--disable-network-policy"
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
        preStart = ''
          if [[ ! -d "${cniConfDir}" ]]; then
            ${pkgs.coreutils}/bin/mkdir -p "${cniConfDir}"
          fi
          if [[ ! -d "${cniBinDir}" ]]; then
            ${pkgs.coreutils}/bin/mkdir -p /opt/cni/bin
          fi
          ${pkgs.rsync}/bin/rsync -a -L ${cniBinDir} /opt/cni/bin
        '';
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
              bin_dir = "${cniBinDir}";
              conf_dir = "${cniConfDir}";
            };
          };
        };
      };
    };
  };
}
