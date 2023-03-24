{
  config,
  inputs,
  lib,
  modulesPath,
  pkgs,
  ...
}: {
  imports = [
    "${modulesPath}/installer/scan/not-detected.nix"
    ../common/presets/nixos.nix
    ./hardware-configuration.nix
    ./github-runner.nix
    ./k3s.nix
    ./nginx.nix
  ];

  networking = {
    firewall = {
      enable = true;
      # allowedTCPPorts = [80 443];
    };

    hostName = "devbox";

    # Enables DHCP on each ethernet and wireless interface. In case of scripted
    # networking (the default) this is the recommended approach. When using
    # `systemd-networkd` it's still possible to use this option, but it's
    # recommended to use it in conjunction with explicit per-interface
    # declarations with `networking.interfaces.<interface>.useDHCP`.
    useDHCP = lib.mkDefault true;
    # interfaces.enp9s0.useDHCP = lib.mkDefault true;
  };

  nix = {
    settings = {
      min-free = 10374182400; # ~10GB
      max-free = 327374182400; # 32GB
      cores = 4;
      max-jobs = 8;
    };
  };

  # services = {
  #   nginx = {
  #     enable = true;
  #     recommendedProxySettings = true;
  #     recommendedTlsSettings = true;
  #     commonHttpConfig = let
  #       realIpsFromList = lib.strings.concatMapStringsSep "\n" (x: "set_real_ip_from  ${x};");
  #       fileToList = x: lib.strings.splitString "\n" (builtins.readFile x);
  #       cfipv4 = fileToList (pkgs.fetchurl {
  #         url = "https://www.cloudflare.com/ips-v4";
  #         sha256 = "0ywy9sg7spafi3gm9q5wb59lbiq0swvf0q3iazl0maq1pj1nsb7h";
  #       });
  #       cfipv6 = fileToList (pkgs.fetchurl {
  #         url = "https://www.cloudflare.com/ips-v6";
  #         sha256 = "1ad09hijignj6zlqvdjxv7rjj8567z357zfavv201b9vx3ikk7cy";
  #       });
  #     in ''
  #       ${realIpsFromList cfipv4}
  #       ${realIpsFromList cfipv6}
  #       real_ip_header CF-Connecting-IP;
  #     '';
  #     virtualHosts = {
  #       "effect.website" = {
  #         forceSSL = true;
  #         # sslCertificate =
  #         # sslCertificateKey =
  #         locations = {
  #           "/" = {
  #             proxyPass = "http://127.0.0.1:12345";
  #           };
  #         };
  #         extraConfig = ''
  #           ssl_client_certificate
  #           ssl_client_verify on;
  #         '';
  #       };
  #     };
  #   };
  # };
}
