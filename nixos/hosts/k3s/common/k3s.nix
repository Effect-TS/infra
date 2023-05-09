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
  multusConf = (pkgs.formats.json {}).generate "02-multus.conf" {
    name = "multus-cni-network";
    type = "multus";
    capabilities = {
      portMappings = true;
    };
    delegates = [
      {
        name = "kube-ovn";
        cniVersion = "0.3.1";
        plugins = [
          {
            type = "kube-ovn";
            server_socket = "/run/openvswitch/kube-ovn-daemon.sock";
          }
          {
            type = "portmap";
            capabilities = {
              portMappings = true;
            };
          }
        ];
      }
    ];
    kubeconfig = "/etc/rancher/k3s/k3s.yaml";
  };
  cniBinDir = pkgs.runCommand "cni-bin-dir" {} ''
    mkdir -p $out
    ln -sf ${pkgs.cni-plugins}/bin/* ${pkgs.cni-plugin-flannel}/bin/* $out
    ln -sf ${kubeovn}/bin/cmd $out/kube-ovn
    ln -sf ${multuscni}/bin/* $out
  '';
  cniConfDir = "/var/lib/rancher/k3s/agent/etc/cni/net.d";
in {
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "k3s-reset-node" (builtins.readFile ./k3s-reset-node))
    pkgs.wireguard-tools
    (pkgs.callPackage ./kubectl-ko.nix {})
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
        "--node-ip=${networkingConfig.vlanPrivateIPv6},${networkingConfig.vlanPrivateIPv4}"
        "--node-external-ip=${networkingConfig.ipv6Address},${networkingConfig.ipv4Address}"
        "--cluster-cidr=fdc9:d2b1:7bc2:08e7::/64,10.32.0.0/11"
        "--service-cidr=fdbc:eb0a:5189:84e2::/108,10.64.0.0/12"
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
          # Setup CNI Config
          if [[ ! -d "${cniConfDir}" ]]; then
            ${pkgs.coreutils}/bin/mkdir -p "${cniConfDir}"
          fi
          if [[ ! -f "${cniConfDir}/02-multus.conf" ]]; then
            ${pkgs.coreutils}/bin/touch "${cniConfDir}/02-multus.conf"
          fi
          ${pkgs.coreutils}/bin/ln -sf ${multusConf} "${cniConfDir}/02-multus.conf"
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
        preStart = ''
          if [[ ! -d /opt/cni/bin ]]; then
            ${pkgs.coreutils}/bin/mkdir -p /opt/cni/bin
          fi
          ${pkgs.coreutils}/bin/ln -sf ${cniBinDir}/* /opt/cni/bin
        '';
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
