{
  config,
  lib,
  ...
}: {
  boot = {
    # A list of additional packages supplying kernel modules.
    extraModulePackages = [];

    initrd = {
      # The set of kernel modules in the initial ramdisk used during the boot
      # process. This set must include all modules necessary for mounting the
      # root device. That is, it should include modules for the physical device
      # (e.g., SCSI drivers) and for the file system (e.g., ext3).
      availableKernelModules = ["ahci" "nvme" "xhci_pci"];
      # List of modules that are always loaded by the initrd.
      kernelModules = [];
    };

    # The set of kernel modules to be loaded in the second stage of the boot
    # process. Note that modules that are needed to mount the root file system
    # should be added to `boot.initrd.availableKernelModules` or
    # `boot.initrd.kernelModules`.
    kernelModules = ["kvm-amd"];

    # Parameters added to the kernel command line.
    kernelParams = [
      "cgroup_memory=1"
      "cgroup_enable=memory"
    ];

    loader = {
      grub = {
        # Whether or not to enable the GNU GRUB boot loader.
        enable = true;
        # The device on which the GRUB boot loader will be installed.
        device = "/dev/nvme0n1";
        # Whether GRUB should be built with EFI support. EFI support is only
        # available for GRUB v2. This option is ignored for GRUB v1.
        efiSupport = false;
        # The version of GRUB to use: 1 for GRUB Legacy (versions 0.9x), or 2
        # (the default) for GRUB 2.
        version = 2;
      };
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/nvme0n1p2";
      fsType = "btrfs";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/4cdd5804-d112-4e27-92ae-13bf7fd57f1e";
      fsType = "ext2";
    };
  };

  hardware = {
    cpu = {
      amd = {
        # Whether or not to update the CPU microcode for AMD processors.
        updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
      };
    };
  };

  nixpkgs = {
    # Specifies the platform where the NixOS configuration will run.
    hostPlatform = lib.mkDefault "x86_64-linux";
  };

  # system = {
  #   # This value determines the NixOS release from which the default
  #   # settings for stateful data, like file locations and database versions
  #   # on your system were taken. It’s perfectly fine and recommended to leave
  #   # this value at the release version of the first install of this system.
  #   # Before changing this value read the documentation for this option
  #   # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  #   stateVersion = lib.mkDefault "23.05"; # Did you read the comment?
  # };

  # The swap devices and swap files. These must have been initialised using
  # `mkswap`. Each element should be an attribute set specifying either the path
  # of the swap device or file (device) or the label of the swap device (label,
  # see `mkswap -L`). Using a label is recommended.
  swapDevices = [];
}
