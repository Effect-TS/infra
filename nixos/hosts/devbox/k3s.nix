{
  config,
  pkgs,
  ...
}: {
  environment = {
    systemPackages = [
      pkgs.unstable.k3s
    ];
  };

  networking = {
    firewall = {
      allowedTCPPorts = [6443];
      trustedInterfaces = ["cni0"];
    };
  };

  services = {
    k3s = {
      enable = true;
      role = "server";
      extraFlags = toString [
        "--container-runtime-endpoint unix:///run/containerd/containerd.sock"
        "--flannel-backend host-gw"
        "--kube-apiserver-arg 'authorization-mode=Node,RBAC'"
        "--secrets-encryption"
      ];
    };
  };

  systemd = {
    services = {
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
