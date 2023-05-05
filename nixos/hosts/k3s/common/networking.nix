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
  # vlan,
  vlanPrivateIPv4,
  ...
}: {
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
  };
}
