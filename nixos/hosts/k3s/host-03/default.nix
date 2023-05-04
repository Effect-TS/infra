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
      "/dev/disk/by-id/nvme-SAMSUNG_MZVL2512HCJQ-00B00_S675NE0T501620"
      "/dev/disk/by-id/nvme-SAMSUNG_MZVL2512HCJQ-00B00_S675NE0T501629"
    ];

    fileSystems = {
      "/" = {
        device = "zroot/root/nixos";
        fsType = "zfs";
      };

      "/boot/efi" = {
        device = "/dev/disk/by-uuid/6D25-6AA4";
        fsType = "vfat";
      };

      "/home" = {
        device = "zroot/home";
        fsType = "zfs";
      };
    };
  };

  k3sConfig = {
    nodeIPv4 = networkingConfig.vlanPrivateIPv4;
    serverAddr = "https://10.0.0.1:6443";
  };

  networkingConfig = {
    hostName = "host-03";
    hostId = "c0bb415f";

    networkInterface = "enp41s0";

    ipv4Address = "65.109.94.140";
    ipv6Address = "2a01:4f9:3051:48cd::1";
    defaultGateway = "65.109.94.129";
    defaultGatewayIPv6 = "fe80::1";

    vlanPrivateIPv4 = "0.1.0.3";
  };
in {
  imports = [
    inputs.sops-nix.nixosModules.sops

    "${modulesPath}/installer/scan/not-detected.nix"
    (import ../common/hardware.nix ({inherit config lib;} // hardwareConfig))
    # (import ../common/k3s.nix ({inherit config lib pkgs;} // k3sConfig))
    (import ../common/networking.nix ({inherit lib;} // networkingConfig))
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
  };

  services = {
    openssh = {
      enable = true;
      permitRootLogin = "prohibit-password";
    };
    openiscsi = {
      enable = true;
      name = "iqn.2020-08.org.linux-iscsi.initiatorhost:host-03";
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
