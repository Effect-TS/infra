{
  bootLoaderDevices,
  config,
  fileSystems,
  lib,
  modulesPath,
  ...
}: {
  imports = [
    "${modulesPath}/installer/scan/not-detected.nix"
  ];

  inherit fileSystems;

  # Use GRUB2 as the boot loader - don't use `systemd-boot` because Hetzner uses
  # BIOS legacy boot
  boot = {
    extraModulePackages = [];

    initrd = {
      availableKernelModules = ["nvme" "ahci"];
      kernelModules = [];
    };

    kernelModules = ["kvm-amd"];

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

      supportedFilesystems = ["zfs"];
    };
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

  swapDevices = [];
}
