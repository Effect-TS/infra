{
  config,
  inputs,
  lib,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    "${inputs.self}/modules/cli"
    "${inputs.self}/modules/nix"
    "${inputs.self}/modules/ssh"
  ];

  boot = {
    # Delete all files in `/tmp` during boot
    cleanTmpDir = true;

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

  networking = {
    # Enables DHCP on each ethernet and wireless interface. In case of scripted
    # networking (the default) this is the recommended approach. When using
    # `systemd-networkd` it's still possible to use this option, but it's
    # recommended to use it in conjunction with explicit per-interface
    # declarations with `networking.interfaces.<interface>.useDHCP`.
    useDHCP = lib.mkDefault true;
    # interfaces.enp9s0.useDHCP = lib.mkDefault true;
  };

  nixpkgs = {
    # Specifies the platform where the NixOS configuration will run.
    hostPlatform = "x86_64-linux";
  };

  # The swap devices and swap files. These must have been initialised using
  # `mkswap`. Each element should be an attribute set specifying either the path
  # of the swap device or file (device) or the label of the swap device (label,
  # see `mkswap -L`). Using a label is recommended.
  swapDevices = [];

  system = {
    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It’s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    stateVersion = "23.05"; # Did you read the comment?
  };

  time = {
    timeZone = "UTC";
  };

  # TODO: move this elsewhere
  users = {
    users = {
      root = {
        openssh = {
          authorizedKeys = {
            keys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO9KP6DOk19QDQ/AKMDWyVeE7Nu2KzH3pKS/z33dNRfs"
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEzPT600TtIVU+Ch+sbkB2GuJb+ZScNkOHKhPb6Q8AHv ma@matechs.com"
            ];
          };
        };
      };
    };
  };
}
