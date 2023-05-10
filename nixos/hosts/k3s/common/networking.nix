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
  vlanPrivateIPv6,
  vlanPrivateIPv4,
  config,
  ...
}: {
  environment = {
    etc = {
      "vpp/contiv-vswitch.conf" = {
        text = ''
          unix {
              nodaemon
              cli-listen /run/vpp/cli.sock
              cli-no-pager
              coredump-size unlimited
              full-coredump
              poll-sleep-usec 100
          }
          nat {
              endpoint-dependent
              translation hash buckets 1048576
              translation hash memory 268435456
              user hash buckets 1024
              max translations per user 10000
          }
          acl-plugin {
            use tuple merge 0
          }
          dpdk {
              dev 0000:29:00.0
          }
          api-trace {
            on
            nitems 5000
          }
          socksvr {
            default
          }
          statseg {
            default
          }
        '';
      };
    };
  };

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
      trustedInterfaces = ["gw0"];
    };

    wireguard = {
      interfaces = {
        gw0 = {
          ips = ["${vlanPrivateIPv6}/128" "${vlanPrivateIPv4}/32"];
          listenPort = 51821;
          privateKeyFile = "${config.sops.secrets."wireguard/${hostName}".path}";
          peers = [
            {
              publicKey = "1YdF6SByNDgtOIvRVBisPS4szmKCd71+khLUFDzywmI=";
              allowedIPs = ["fd24:d191:5c51:b4b6::1/128" "10.0.0.1"];
              endpoint = "2a01:4f8:a0:8485::1:51821";
              persistentKeepalive = 5;
            }
            {
              publicKey = "KEpjawqDUrxMQv88totW51SAOOpA/K0srCncUPOjdiE=";
              allowedIPs = ["fd24:d191:5c51:b4b6::2/128" "10.0.0.2"];
              endpoint = "2a01:4f8:2200:141e::1:51821";
              persistentKeepalive = 5;
            }
            {
              publicKey = "9/wGoxeVz8F3yXqx1KYapmHRgvV0OkKeLBSthYvc1nw=";
              allowedIPs = ["fd24:d191:5c51:b4b6::3/128" "10.0.0.3"];
              endpoint = "2a01:4f9:3051:48cd::1:51821";
              persistentKeepalive = 5;
            }
          ];
        };
      };
    };
  };
}
