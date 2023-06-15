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
      qemu = {
        ovmf = {
          enable = true;
        };
      };
    };
  };
}
