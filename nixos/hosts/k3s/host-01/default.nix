{
  config,
  inputs,
  lib,
  modulesPath,
  pkgs,
  ...
}: let
  hardwareConfig = {
    bootLoaderDevices = [
      "/dev/disk/by-id/nvme-SAMSUNG_MZVL2512HCJQ-00B00_S675NX0T570867"
      "/dev/disk/by-id/nvme-SAMSUNG_MZVL2512HCJQ-00B00_S675NX0T570972"
    ];

    fileSystems = {
      "/" = {
        device = "zroot/root/nixos";
        fsType = "zfs";
      };

      "/boot/efi" = {
        device = "/dev/disk/by-uuid/CC28-2324";
        fsType = "vfat";
      };

      "/home" = {
        device = "zroot/home";
        fsType = "zfs";
      };
    };
  };

  k3sConfig = {
    clusterInit = true;
    nodeIPv4 = networkingConfig.vlanPrivateIPv4;
  };

  networkingConfig = {
    hostName = "host-01";
    hostId = "e0f5a143";

    networkInterface = "enp41s0";

    ipv4Address = "213.239.207.149";
    ipv6Address = "2a01:4f8:a0:8485::1";
    defaultGateway = "213.239.207.129";
    defaultGatewayIPv6 = "fe80::1";

    vlanPrivateIPv4 = "10.0.0.1";
  };
in {
  imports = [
    inputs.sops-nix.nixosModules.sops

    "${modulesPath}/installer/scan/not-detected.nix"
    (import ../common/hardware.nix ({inherit config lib;} // hardwareConfig))
    (import ../common/k3s.nix ({inherit config lib pkgs;} // k3sConfig))
    (import ../common/networking.nix ({inherit lib pkgs config;} // networkingConfig))
    ../common/nixos.nix
  ];

  environment = {
    etc = {
      "mdadm.conf" = {
        text = ''
          MAILADDR root
        '';
      };
    };
    sessionVariables = {
      KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";
    };
  };

  services = {
    openssh = {
      enable = true;
      permitRootLogin = "prohibit-password";
    };
    openiscsi = {
      enable = true;
      name = "iqn.2020-08.org.linux-iscsi.initiatorhost:host-01";
    };
    kubernetes = {
      apiserver = {
        allowPrivileged = true;
      };
    };
  };

  sops = {
    age = {
      sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    };
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system = {
    stateVersion = "22.11"; # Did you read the comment?
  };

  users = {
    users = {
      root = {
        # Initial empty root password for easy login:
        initialHashedPassword = "";

        openssh = {
          authorizedKeys = {
            keys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPsBd6asppvftBGAxsu2MutHRiFKQIsyMakAheN/2GzK"
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEzPT600TtIVU+Ch+sbkB2GuJb+ZScNkOHKhPb6Q8AHv ma@matechs.com"
            ];
          };
        };
      };
    };
  };
}
