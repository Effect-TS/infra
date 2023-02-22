{...}: {
  systemd = {
    oomd = {
      enable = true;
      enableRootSlice = true;
      enableSystemSlice = false;
      enableUserServices = true;
    };
  };
}
