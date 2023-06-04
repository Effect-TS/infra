{...}: {
  security = {
    polkit = {
      enable = true;
    };
  };

  virtualisation = {
    libvirtd = {
      enable = true;
    };
  };
}
