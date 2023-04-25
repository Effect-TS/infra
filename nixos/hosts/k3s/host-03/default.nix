{
  config,
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
        device = "/dev/disk/by-uuid/8385-E29B";
        fsType = "vfat";
      };

      "/home" = {
        device = "zroot/home";
        fsType = "zfs";
      };
    };
  };

  networkingConfig = {
    hostName = "host-03";
    hostId = "c0bb415f";

    networkInterface = "enp41s0";

    ipv4Address = "65.109.94.140";
    ipv6Address = "2a01:4f9:3051:48cd::1";
    defaultGateway = "65.109.94.129";
    defaultGatewayIPv6 = "fe80::1";

    vlan = "vlan4000";
    vlanPrivateIPv4 = "192.168.100.3";
    vlanBroadcastIPv4 = "192.168.100.255";
  };
in {
  imports = [
    "${modulesPath}/installer/scan/not-detected.nix"
    (import ../common/hardware.nix ({inherit config lib;} // hardwareConfig))
    (import ../common/networking.nix ({inherit lib;} // networkingConfig))
    ../common/nixos.nix
  ];

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

  services = {
    openssh = {
      enable = true;
      permitRootLogin = "prohibit-password";
    };
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system = {
    stateVersion = "22.11"; # Did you read the comment?
  };
}
