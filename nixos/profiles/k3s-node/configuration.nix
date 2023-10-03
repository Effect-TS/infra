{
  config,
  lib,
  options,
  pkgs,
  ...
}: let
  inherit (lib) concatStringsSep mapAttrsToList mkOption types;

  cfg = config.nixos.profiles.k3s-node;

  mkUplinkAddr = route: concatStringsSep "/" (mapAttrsToList (_: v: toString v) route);

  routeOpts = v: {
    address = mkOption {
      type = types.str;
      description = "IPv${toString v} address of the network.";
    };

    prefixLength = mkOption {
      type = types.addCheck types.int (n:
        n
        >= 0
        && n
        <= (
          if v == 4
          then 32
          else 128
        ));
      description = ''
        Subnet mask of the network, specified as the number of
        bits in the prefix (`${
          if v == 4
          then "24"
          else "64"
        }`).
      '';
    };
  };
in {
  imports = [
    ./hardware-configuration.nix

    ../../modules/k3s
    ../../modules/kata-containers
    ../../modules/libvirtd
    ../../modules/wireguard
  ];

  options = {
    nixos.profiles.k3s-node = {
      # K3s
      k3sServerAddr = options.modules.k3s.serverAddr;

      # Networking
      ipv4 = routeOpts 4;
      ipv6 = routeOpts 6;

      # Wireguard
      wireguard = mkOption {
        type = types.submodule {
          options = {
            publicKey = mkOption {
              type = types.str;
              description = ''
                The public key for the Wireguard peer connection.
              '';
            };

            ipv4 = routeOpts 4;

            peers = mkOption {
              type = types.listOf (types.submodule {
                options = {
                  PublicKey = mkOption {
                    type = types.str;
                    description = "The public key for the Wireguard peer";
                  };
                  AllowedIPs = mkOption {
                    type = types.listOf types.str;
                    description = "List of allowed IPs";
                  };
                  Endpoint = mkOption {
                    type = types.str;
                    description = "The Wireguard server endpoint";
                  };
                };
              });
              description = ''
                The list of point-to-point Wireguard peers.
              '';
            };
          };
        };
        description = ''
          The options used to configure Wireguard to allow K3s nodes to communicate.
        '';
      };
    };
  };

  config = {
    environment.systemPackages = with pkgs; [
      kubevirt
    ];

    modules.kata-containers = {
      enable = true;
      version = "3.1.3";
    };

    modules.k3s = {
      enable = true;
      clusterInit = cfg.k3sServerAddr == "";
      serverAddr = cfg.k3sServerAddr;
    };

    modules.libvirtd = {
      enable = true;
    };

    modules.wireguard = {
      enable = true;
      address = ["${cfg.wireguard.ipv4.address}/${toString cfg.wireguard.ipv4.prefixLength}"];
      privateKeyFile = config.sops.secrets."wireguard/${config.networking.hostName}".path;
      peers = cfg.wireguard.peers;
    };

    networking = {
      nameservers = ["8.8.8.8"];
    };

    services.openssh.settings = {
      PermitRootLogin = "prohibit-password";
    };

    # Make sure network interface is named consistently
    services.udev = {
      extraRules = ''
        SUBSYSTEM="net", ACTION="add", KERNEL=="enp*", NAME="eth0"
      '';
    };

    sops = {
      age = {
        sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
      };

      secrets = {
        "wireguard/${config.networking.hostName}" = {
          sopsFile = ../../secrets.yaml;
          owner = config.users.users.systemd-network.name;
        };
      };
    };

    systemd.network = {
      enable = true;
      networks = {
        "10-uplink" = {
          networkConfig = {
            Address = mkUplinkAddr cfg.ipv6;
          };
        };
      };
    };

    systemd.services.systemd-networkd = {
      serviceConfig = {
        SupplementaryGroups = [config.users.groups.keys.name];
      };
    };

    # This value determines the NixOS release with which your system is to be
    # compatible, in order to avoid breaking some software such as database
    # servers. You should change this only after NixOS release notes say you
    # should.
    system.stateVersion = "23.05"; # Did you read the comment?

    time.timeZone = lib.mkDefault "UTC";

    # Enable OpenVSwitch
    virtualisation.vswitch = {
      enable = true;
      resetOnStart = true;
    };
  };
}
