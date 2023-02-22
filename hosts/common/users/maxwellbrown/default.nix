{
  config,
  inputs,
  pkgs,
  ...
}: {
  home-manager = {
    users = {
      maxwellbrown = import "${inputs.self}/home/maxwellbrown/${config.networking.hostName}.nix";
    };
  };

  users = {
    mutableUsers = false;
    users = {
      maxwellbrown = {
        description = "Maxwell Brown";
        isNormalUser = true;
        openssh = {
          authorizedKeys = {
            keys = config.home-manager.users.maxwellbrown.sshKeys.personal.keys;
          };
        };
        passwordFile = config.sops.secrets.maxwellbrown-password.path;
        shell = pkgs.zsh;
        extraGroups = ["wheel"];
      };
    };
  };

  sops = {
    secrets = {
      maxwellbrown-password = {
        sopsFile = ./secrets.yaml;
        neededForUsers = true;
      };
    };
  };
}
