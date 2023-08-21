{
  config,
  inputs,
  pkgs,
  ...
}: {
  home-manager = {
    users = {
      mikearnaldi = import "${inputs.self}/nixos/home/mikearnaldi/${config.networking.hostName}.nix";
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
            keys =
              config.home-manager.users.mikearnaldi.sshKeys.personal.keys
              ++ [
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBY2vg6JN45hpcl9HH279/ityPEGGOrDjY3KdyulOUmX"
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ4R7xrSS+QLuEVqFGgdsIRSc+KINQ2nCJpTTBYfEq8t michaelarnaldi@MacBook-Pro.station"
              ];
          };
        };
        shell = pkgs.zsh;
        extraGroups = ["wheel" "docker"];
      };
    };
  };
}
