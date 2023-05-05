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
      allowedUDPPorts = [51820 51821];
      allowedTCPPorts = [2379 2380 6443 10250];
      trustedInterfaces = ["cni0" "gw0"];
    };

    wireguard = {
      interfaces = {
        gw0 = {
          ips = ["${vlanPrivateIPv4}"];
          listenPort = 51821;
          privateKeyFile = "${config.sops.secrets."wireguard/${hostName}".path}";
          peers = [
            {
              publicKey = "1YdF6SByNDgtOIvRVBisPS4szmKCd71+khLUFDzywmI=";
              allowedIPs = ["0.1.0.1/32"];
              endpoint = "213.239.207.149:51821";
              persistentKeepalive = 25;
            }
            {
              publicKey = "KEpjawqDUrxMQv88totW51SAOOpA/K0srCncUPOjdiE=";
              allowedIPs = ["0.1.0.2/32"];
              endpoint = "167.235.103.220:51821";
              persistentKeepalive = 25;
            }
            {
              publicKey = "9/wGoxeVz8F3yXqx1KYapmHRgvV0OkKeLBSthYvc1nw=";
              allowedIPs = ["0.1.0.3/32"];
              endpoint = "65.109.94.140:51821";
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
