{
  config,
  pkgs,
  ...
}: let
  networkingConfig = {
    hostName = "host-02";
    hostId = "bbb7d16a";

    networkInterface = "enp5s0";

    ipv4Address = "167.235.103.220";
    ipv6Address = "2a01:4f8:2200:141e::1";
    defaultGateway = "167.235.103.193";
    defaultGatewayIPv6 = "fe80::1";

    vlan = "vlan4000";
    vlanPrivateIPv4 = "192.168.100.2";
    vlanBroadcastIPv4 = "192.168.100.255";
  };
in {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    (import ../common/networking.nix networkingConfig)
  ];
  # Use GRUB2 as the boot loader.
  # We don't use systemd-boot because Hetzner uses BIOS legacy boot.
  boot.loader.systemd-boot.enable = false;
  boot.loader.grub = {
    enable = true;
    efiSupport = false;
    devices = ["/dev/disk/by-id/nvme-KXG60ZNV512G_TOSHIBA_Y9ES11F9T9LM" "/dev/disk/by-id/nvme-KXG60ZNV512G_TOSHIBA_Y9ES11FKT9LM"];
    copyKernels = true;
  };
  boot.supportedFilesystems = ["zfs"];
  # Initial empty root password for easy login:
  users.users.root.initialHashedPassword = "";
  services.openssh.permitRootLogin = "prohibit-password";
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPsBd6asppvftBGAxsu2MutHRiFKQIsyMakAheN/2GzK"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEzPT600TtIVU+Ch+sbkB2GuJb+ZScNkOHKhPb6Q8AHv ma@matechs.com"
  ];
  services.openssh.enable = true;
  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "22.11"; # Did you read the comment?
}
