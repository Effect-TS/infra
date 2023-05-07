{
  clusterInit ? false,
  config,
  lib,
  networkingConfig,
  pkgs,
  serverAddr ? "",
  ...
}: let
  kubeovn = pkgs.callPackage ./kube-ovn.nix {};
  multuscni = pkgs.callPackage ./multus-cni.nix {};
  cniBinDir = pkgs.runCommand "cni-bin-dir" {} ''
    mkdir -p $out
    ln -sf ${pkgs.cni-plugins}/bin/* ${pkgs.cni-plugin-flannel}/bin/* $out
    ln -sf ${kubeovn}/bin/cmd $out/kube-ovn
    ln -sf ${multuscni}/bin/* $out
  '';
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
        "--node-ip=${networkingConfig.vlanPrivateIPv4}"
        "--node-external-ip=${networkingConfig.ipv4Address}"
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
        serviceConfig = {
          ExecStartPre = [
            "${pkgs.coreutils}/bin/ln -sf ${cniBinDir} /var/lib/cni"
          ];
        };
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
              conf_dir = "/var/lib/rancher/k3s/agent/etc/cni/net.d/";
            };
          };
        };
      };
    };
  };
}
