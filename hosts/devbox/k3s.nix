{pkgs, ...}: {
  environment = {
    systemPackages = [
      pkgs.k3s
    ];
  };

  networking = {
    firewall = {
      allowedTCPPorts = [6443];
    };
  };

  services = {
    k3s = {
      enable = true;
      role = "server";
      extraFlags = toString [
        "--container-runtime-endpoint unix:///run/containerd/containerd.sock"
      ];
    };
  };

  virtualisation = {
    containerd = {
      enable = true;
      settings = let
        fullCNIPlugins = pkgs.buildEnv {
          name = "full-cni";
          paths = with pkgs; [
            cni-plugins
            cni-plugin-flannel
          ];
        };
      in {
        plugins."io.containerd.grpc.v1.cri".cni = {
          bin_dir = "${fullCNIPlugins}/bin";
          conf_dir = "/var/lib/rancher/k3s/agent/etc/cni/net.d/";
        };
      };
    };
  };
}
