{
  hostname,
  inputs,
  system,
  users,
  version,
}: let
  overlay-unstable = final: prev: {
    unstable = import inputs.nixpkgs-unstable {
      inherit system;
      config = {
        allowUnfree = true;
      };
    };
  };

  pkgs = import inputs.nixpkgs {
    inherit system;
    config = {
      allowUnfree = true;
    };
    overlays = [
      overlay-unstable
    ];
  };

  # Home manager configuration for the target users
  homeManagerUsers = builtins.listToAttrs (builtins.map (user: {
      name = user.name;
      value = "${inputs.self}/users/${user.name}/home";
    })
    users);

  # System configuration for the target users
  systemUsers = builtins.map (user: "${inputs.self}/users/${user.name}") users;
in
  inputs.nixpkgs.lib.nixosSystem
  {
    inherit system pkgs;
    specialArgs = {inherit hostname inputs version;};
    modules =
      [
        # System configuration for this host
        "${inputs.self}/hosts/${hostname}"

        # Home manager configuration for this host
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager.extraSpecialArgs = { inherit hostname inputs version; };
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users = homeManagerUsers;
        }
      ]
      ++ systemUsers;
  }
