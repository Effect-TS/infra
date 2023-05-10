{
  bootLoaderDevices,
  config,
  fileSystems,
  lib,
  pkgs,
  ...
}: {
  inherit fileSystems;

  # Use GRUB2 as the boot loader - don't use `systemd-boot` because Hetzner uses
  # BIOS legacy boot
  boot = {
    extraModulePackages = [];

    initrd = {
      availableKernelModules = ["nvme" "ahci"];
      kernelModules = [];
    };

    kernelPackages = pkgs.linuxPackages_5_4;

    kernel = {
      sysctl = {
        "net.ipv4.ip_forward" = true;
        "net.ipv4.conf.all.proxy_arp" = true;
        "net.ipv6.conf.all.forwarding" = true;
        "vm.nr_hugepages" = 512;
      };
    };

    kernelModules = ["kvm-amd" "vfio-pci"];

    loader = {
      grub = {
        enable = true;
        efiSupport = false;
        devices = bootLoaderDevices;
        copyKernels = true;
      };

      systemd-boot = {
        enable = false;
      };
    };

    supportedFilesystems = ["zfs" "nfs" "xfs" "ext4"];
  };

  hardware = {
    cpu = {
      amd = {
        updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
      };
    };
  };

  nixpkgs = {
    hostPlatform = lib.mkDefault "x86_64-linux";
  };

  powerManagement = {
    cpuFreqGovernor = lib.mkDefault "ondemand";
  };

  services.udev.extraRules = ''
    KERNEL=="enp*", NAME="eth0"
  '';

  swapDevices = [];
}
