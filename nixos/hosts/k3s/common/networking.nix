{
  defaultGateway,
  defaultGatewayIPv6,
  hostName,
  hostId,
  networkInterface,
  ipv4Address,
  ipv6Address,
  lib,
  # vlan,
  # vlanPrivateIPv4,
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

    # localCommands = ''
    #   # Check if the link already exists, remove it if so
    #   # if ip link show ${vlan} >/dev/null 2>&1; then
    #   #   ip link set dev ${vlan} down
    #   #   ip link delete ${vlan}
    #   # fi
    #   # ip link add link ${networkInterface} name ${vlan} type vlan id 4000
    #   # ip link set ${vlan} mtu 1400
    #   # ip link set dev ${vlan} up
    #   # ip addr add ${vlanPrivateIPv4}/8 dev ${vlan}
    # '';

    nameservers = ["1.1.1.1" "8.8.8.8"];

    # Network (Hetzner uses static IP assignments, and we don't use DHCP here)
    useDHCP = lib.mkDefault false;
  };
}
