{
  pkgs,
  defaultGateway,
  defaultGatewayIPv6,
  hostName,
  hostId,
  networkInterface,
  ipv4Address,
  ipv6Address,
  lib,
  vlanPrivateIPv4,
  config,
  ...
}: {
  sops = {
    secrets = {
      "wireguard/${hostName}" = {
        sopsFile = ../common/secrets.yaml;
      };
    };
  };

  networking = {
    inherit hostName hostId;

    defaultGateway = "${defaultGateway}";
    defaultGateway6 = {
      address = "${defaultGatewayIPv6}";
      interface = "${networkInterface}";
    };

    interfaces = {
      "${networkInterface}" = {
        ipv4 = {
          addresses = [
            {
              address = "${ipv4Address}";
              prefixLength = 24;
            }
          ];
        };
        ipv6 = {
          addresses = [
            {
              address = "${ipv6Address}";
              prefixLength = 64;
            }
          ];
        };
      };
    };

    nameservers = ["1.1.1.1" "8.8.8.8"];

    # Network (Hetzner uses static IP assignments, and we don't use DHCP here)
    useDHCP = lib.mkDefault false;

    firewall = {
      allowedUDPPorts = [51820];
      allowedTCPPorts = [2379 2380 6443 10250];
      trustedInterfaces = ["cni0"];
    };

    localCommands = ''
      ${pkgs.procps}/bin/sysctl net.ipv4.ip_forward=1
      ${pkgs.procps}/bin/sysctl net.ipv4.conf.all.proxy_arp=1
    '';
  };
}
