{
  config,
  inputs,
  pkgs,
  ...
}: {
  home-manager = {
    users = {
      mikearnaldi = import "${inputs.self}/home/mikearnaldi/${config.networking.hostName}.nix";
    };
  };

  users = {
    mutableUsers = false;
    users = {
      mikearnaldi = {
        description = "Michael Arnaldi";
        isNormalUser = true;
        openssh = {
          authorizedKeys = {
            keys = config.home-manager.users.mikearnaldi.sshKeys.personal.keys;
          };
        };
        shell = pkgs.zsh;
        extraGroups = ["wheel"];
      };
    };
  };
}
