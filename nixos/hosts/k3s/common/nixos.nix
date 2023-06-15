{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  ifUsersExist = users: builtins.filter (user: builtins.hasAttr user config.users.users) users;
  getAuthorizedKeys = users: builtins.map (user: config.users.users.${user}.openssh.authorizedKeys.keys) users;
in {
  nix =
    {
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

      package = pkgs.nixVersions.nix_2_16;

      # Add each flake input as a registry
      # To make nix3 commands consistent with the flake
      # this becomes registry.nixpkgs.flake = inputs.nixpkgs etc. for all inputs
      registry = lib.mapAttrs (_: value: {flake = value;}) inputs;

      settings = {
        auto-optimise-store = true;
        experimental-features = ["nix-command" "flakes" "repl-flake"];
        keep-derivations = true;
        keep-outputs = true;
        trusted-users =
          ["root"]
          ++ lib.optional pkgs.stdenvNoCC.isLinux "@wheel"
          ++ lib.optional pkgs.stdenvNoCC.isDarwin "@admin";
        min-free = lib.mkDefault (10 * 1000 * 1000 * 1000); # 10gb
        cores = lib.mkDefault 0;
        max-jobs = lib.mkDefault "auto";
      };

      sshServe = {
        enable = true;
        keys = lib.flatten (getAuthorizedKeys (ifUsersExist ["maxwellbrown" "mikearnaldi"]));
        write = true;
      };
    } # below checks if this is home-manager-applied or nixos/nix-darwin-applied
    # (those options do not exist in home-manager)
    // lib.optionalAttrs (builtins.hasAttr "nixPath" config.nix) {
      # should be >= max-jobs
      nrBuildUsers = 16;
      # Map registries to channels
      # Very useful when using legacy commands
      nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
    };

  nixpkgs = {
    overlays = [
      # Any additional overlays can be placed here
      (final: prev: {
        unstable = import inputs.nixpkgs-unstable {
          system = final.system;
          config = final.config;
        };

        master = import inputs.nixpkgs-master {
          system = final.system;
          config = final.config;
        };
      })
    ];
    config = {
      allowUnfree = true;
    };
  };
}
