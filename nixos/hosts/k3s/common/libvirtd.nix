{pkgs, ...}: {
  environment = {
    systemPackages = with pkgs; [virtiofsd];
  };

  security = {
    polkit = {
      enable = true;
    };
  };

  virtualisation = {
    libvirtd = {
      enable = true;
      onBoot = "start";
      onShutdown = "suspend";
      qemu = {
        ovmf = {
          enable = true;
          packages = [pkgs.OVMFFull.fd pkgs.pkgsCross.aarch64-multiplatform.OVMF.fd];
        };
      };
    };
  };
}
