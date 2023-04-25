{
  hostName,
  hostId,
  networkInterface,
  ipv4Address,
  ipv6Address,
  defaultGateway,
  defaultGatewayIPv6,
  vlan,
  vlanPrivateIPv4,
  vlanBroadcastIPv4,
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

    localCommands = ''
      ip link add link ${networkInterface} name ${vlan} type vlan id 4000
      ip link set ${vlan} mtu 1400
      ip link set dev ${vlan} up
      ip addr add ${vlanPrivateIPv4}/24 brd ${vlanBroadcastIPv4} dev ${vlan}
    '';

    nameservers = ["1.1.1.1" "8.8.8.8"];

    # Network (Hetzner uses static IP assignments, and we don't use DHCP here)
    useDHCP = false;
  };
}
