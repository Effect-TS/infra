{...}: let
  maxwellbrownKeys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPsBd6asppvftBGAxsu2MutHRiFKQIsyMakAheN/2GzK"];
  michaelarnaldiKeys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEzPT600TtIVU+Ch+sbkB2GuJb+ZScNkOHKhPb6Q8AHv ma@matechs.com"];
  adminKeys = maxwellbrownKeys ++ michaelarnaldiKeys;
  extraGroups = ["wheel"];
in {
  boot.initrd.network.ssh.authorizedKeys = adminKeys;

  security.sudo.wheelNeedsPassword = false;

  users.users = {
    maxwellbrown = {
      inherit extraGroups;
      isNormalUser = true;
      home = "/home/maxwellbrown";
      shell = "/run/current-system/sw/bin/zsh";
      uid = 1000;
      openssh.authorizedKeys.keys = maxwellbrownKeys;
    };

    michaelarnaldi = {
      inherit extraGroups;
      isNormalUser = true;
      home = "/home/michaelarnaldi";
      shell = "/run/current-system/sw/bin/zsh";
      uid = 1001;
      openssh.authorizedKeys.keys = michaelarnaldiKeys;
    };

    root = {
      openssh.authorizedKeys.keys = adminKeys;
    };
  };
}
