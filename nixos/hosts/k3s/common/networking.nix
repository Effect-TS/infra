{
  pkgs,
  defaultGateway,
  defaultGatewayIPv6,
  hostName,
  hostId,
  ipv4Address,
  ipv6Address,
  vlanPrivateIPv6,
  vlanPrivateIPv4,
  lib,
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
      interface = "eth0";
    };

    interfaces = {
      "eth0" = {
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

    useDHCP = lib.mkDefault false;

    firewall = {
      allowedUDPPorts = [51820 51821];
      allowedTCPPorts = [2379 2380 6443 10250];
      trustedInterfaces = ["gw0"];
    };

    # wireguard = {
    #   interfaces = {
    #     gw0 = {
    #       ips = ["${vlanPrivateIPv6}/128" "${vlanPrivateIPv4}/32"];
    #       listenPort = 51821;
    #       privateKeyFile = "${config.sops.secrets."wireguard/${hostName}".path}";
    #       peers = [
    #         {
    #           publicKey = "1YdF6SByNDgtOIvRVBisPS4szmKCd71+khLUFDzywmI=";
    #           allowedIPs = ["fd8d:d848:4ba5:aa91::1/128" "10.0.0.1"];
    #           endpoint = "2a01:4f8:a0:8485::1:51821";
    #           persistentKeepalive = 5;
    #         }
    #         {
    #           publicKey = "KEpjawqDUrxMQv88totW51SAOOpA/K0srCncUPOjdiE=";
    #           allowedIPs = ["fd8d:d848:4ba5:aa91::2/128" "10.0.0.2"];
    #           endpoint = "2a01:4f8:2200:141e::1:51821";
    #           persistentKeepalive = 5;
    #         }
    #         {
    #           publicKey = "9/wGoxeVz8F3yXqx1KYapmHRgvV0OkKeLBSthYvc1nw=";
    #           allowedIPs = ["fd8d:d848:4ba5:aa91::3/128" "10.0.0.3"];
    #           endpoint = "2a01:4f9:3051:48cd::1:51821";
    #           persistentKeepalive = 5;
    #         }
    #       ];
    #     };
    #   };
    # };
  };
}
