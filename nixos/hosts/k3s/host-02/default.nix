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
      "/dev/disk/by-id/nvme-KXG60ZNV512G_TOSHIBA_Y9ES11F9T9LM"
      "/dev/disk/by-id/nvme-KXG60ZNV512G_TOSHIBA_Y9ES11FKT9LM"
    ];

    fileSystems = {
      "/" = {
        device = "zroot/root/nixos";
        fsType = "zfs";
      };

      "/boot/efi" = {
        device = "/dev/disk/by-uuid/257C-AC50";
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
    hostName = "host-02";
    hostId = "bbb7d16a";

    networkInterface = "enp5s0";

    ipv4Address = "167.235.103.220";
    ipv6Address = "2a01:4f8:2200:141e::1";
    defaultGateway = "167.235.103.193";
    defaultGatewayIPv6 = "fe80::1";

    vlanPrivateIPv4 = "0.1.0.2";
  };
in {
  imports = [
    inputs.sops-nix.nixosModules.sops

    "${modulesPath}/installer/scan/not-detected.nix"
    (import ../common/hardware.nix ({inherit config lib;} // hardwareConfig))
    # (import ../common/k3s.nix ({inherit config lib pkgs;} // k3sConfig))
    (import ../common/networking.nix ({inherit lib pkgs;} // networkingConfig))
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
      name = "iqn.2020-08.org.linux-iscsi.initiatorhost:host-02";
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

  networking = {
    firewall = {
      allowedUDPPorts = [51820];
      allowedTCPPorts = [2379 2380 6443 10250];
      trustedInterfaces = [];
    };

    wireguard = {
      interfaces = {
        gw0 = {
          ips = [ "${networkingConfig.vlanPrivateIPv4}/16" ];
          listenPort = 51820;
          privateKeyFile = "/root/wireguard-keys/private";
          peers = [
            {
              publicKey = "1YdF6SByNDgtOIvRVBisPS4szmKCd71+khLUFDzywmI=";
              allowedIPs = ["0.1.0.0/16"];
              endpoint = "213.239.207.149:51820";
              persistentKeepalive = 25;
            }
          ];
        };
      };
    };

    localCommands = ''
      ${pkgs.procps}/bin/sysctl net.ipv4.ip_forward=1
      ${pkgs.procps}/bin/sysctl net.ipv4.conf.all.proxy_arp=1
    '';
  };
}
