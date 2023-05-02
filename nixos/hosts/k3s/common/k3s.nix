{
  clusterInit ? false,
  config,
  lib,
  nodeIPv4,
  pkgs,
  serverAddr ? "",
  ...
}: {
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "k3s-reset-node" (builtins.readFile ./k3s-reset-node))
  ];

  networking = {
    firewall = {
      allowedTCPPorts = [2379 2380 6443 10250 6789];
    };
  };

  services = {
    k3s = {
      enable = true;
      package = pkgs.unstable.k3s;
      role = "server";
      extraFlags = toString [
        "--container-runtime-endpoint=unix:///run/containerd/containerd.sock"
        "--disable=traefik"
        "--disable=coredns"
        "--flannel-backend=host-gw"
        "--flannel-iface=vlan4000"
        "--secrets-encryption"
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
              bin_dir = "${pkgs.runCommand "cni-bin-dir" {} ''
                mkdir -p $out
                ln -sf ${pkgs.cni-plugins}/bin/* ${pkgs.cni-plugin-flannel}/bin/* $out
              ''}";
              conf_dir = "/var/lib/rancher/k3s/agent/etc/cni/net.d/";
            };
          };
        };
      };
    };
  };
}
