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

    nat = {
      enable = true;
      externalInterface = "${networkInterface}";
      internalInterfaces = [ "wg0" ];
    };

    firewall = {
      allowedUDPPorts = [51820];
      allowedTCPPorts = [2379 2380 6443 10250];
      trustedInterfaces = [];
    };

    wireguard = {
      interfaces = {
        wg0 = {
          ips = [ "${vlanPrivateIPv4}/16" ];
          listenPort = 51820;
          postSetup = ''
            ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 0.1.0.0/16 -o ${networkInterface} -j MASQUERADE
          '';
          postShutdown = ''
            ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 0.1.0.0/16 -o ${networkInterface} -j MASQUERADE
          '';
          privateKeyFile = "/root/wireguard-keys/private";
          peers = [
            {
              publicKey = "KEpjawqDUrxMQv88totW51SAOOpA/K0srCncUPOjdiE=";
              allowedIPs = ["0.1.0.0/16"];
              endpoint = "167.235.103.220:51820";
              persistentKeepalive = 25;
            }
            {
              publicKey = "1YdF6SByNDgtOIvRVBisPS4szmKCd71+khLUFDzywmI=";
              allowedIPs = ["0.1.0.0/16"];
              endpoint = "213.239.207.149:51820";
              persistentKeepalive = 25;
            }
            {
              publicKey = "9/wGoxeVz8F3yXqx1KYapmHRgvV0OkKeLBSthYvc1nw=";
              allowedIPs = ["0.1.0.0/16"];
              endpoint = "65.109.94.140:51820";
              persistentKeepalive = 25;
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
