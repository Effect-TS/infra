{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkDoc mkEnableOption mkIf mkOption types;

  cfg = config.modules.wireguard;
in {
  options.modules.wireguard = {
    enable = mkEnableOption "wireguard";

    address = mkOption {
      type = types.listOf types.str;
      default = [];
      description = mkDoc ''
        The addresses to assign to the Wireguard interface.
      '';
    };

    privateKeyFile = mkOption {
      type = types.path;
      description = mkDoc ''
        The file containing the Wireguard private key.
      '';
    };

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

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [wireguard-tools];

    networking.firewall.allowedUDPPorts = [51820];

    systemd.network = {
      enable = true;

      netdevs = {
        "wg0" = {
          netdevConfig = {
            Kind = "wireguard";
            Name = "wg0";
            MTUBytes = "1300";
          };
          wireguardConfig = {
            PrivateKeyFile = cfg.privateKeyFile;
            ListenPort = 51820;
          };
          wireguardPeers = builtins.map (peer: {wireguardPeerConfig = peer;}) cfg.peers;
        };
      };

      networks = {
        "40-wg0" = {
          matchConfig.Name = "wg0";
          address = cfg.address;
          DHCP = "no";
          dns = ["fc00::53"];
          ntp = ["fc00::123"];
          gateway = [
            "fc00::1"
          ];
          networkConfig = {
            IPv6AcceptRA = false;
          };
        };
      };
    };
  };
}
