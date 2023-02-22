{
  config,
  inputs,
  lib,
  modulesPath,
  ...
}: {
  imports = [
    "${modulesPath}/installer/scan/not-detected.nix"
    ../common/presets/nixos.nix
    ./hardware-configuration.nix
  ];

  networking = {
    firewall = {
      enable = true;
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
}
