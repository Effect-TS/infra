{
  config,
  lib,
  ...
}: let
  ifTheyExist = users: builtins.filter (user: builtins.hasAttr user config.users.users) users;
  theirAuthorizedKeys = users: builtins.map (user: config.users.users.${user}.openssh.authorizedKeys.keys) users;
in {
  imports = [./shared.nix];
  nix = {
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 14d";
      persistent = true;
    };

    optimise = {
      automatic = true;
      dates = ["daily"];
    };

    sshServe = {
      enable = true;
      keys = lib.flatten (theirAuthorizedKeys (ifTheyExist ["maxwellbrown" "mikearnaldi"]));
      write = true;
    };
  };
}
