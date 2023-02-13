{
  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-22.11";
    };

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-22.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    deploy-rs,
    home-manager,
    nixpkgs,
  }: let
    # Helper for generating a nixosSystem configuration
    mkNixOsSystem = import "${inputs.self}/lib/mkNixOsSystem.nix";

    # Helper generating outputs for each desired system
    forAllSystems = nixpkgs.lib.genAttrs [
      "x86_64-darwin"
      "x86_64-linux"
      "aarch64-darwin"
      "aarch64-linux"
    ];

    # Import nixpkgs' package set for each system.
    nixpkgsFor = forAllSystems (system:
      import nixpkgs {
        inherit system;
      });
  in {
    # Formatters to use by system for `nix fmt`
    formatter = forAllSystems (system: nixpkgsFor.${system}.alejandra);

    # Shell environments for each system
    devShells = forAllSystems (system: {
      default = nixpkgsFor.${system}.mkShell {
        buildInputs = with nixpkgsFor.${system}; [
          deploy-rs.defaultPackage.${system}
        ];
      };
    });

    # NixOS configurations
    nixosConfigurations = {
      # On actual machine:
      #   sudo nixos-rebuild switch --flake .#devbox
      # On other machine:
      #   deploy --targets .#devbox
      # On other machine with dry activation:
      #   deploy --targets .#devbox --dry-activate
      devbox = mkNixOsSystem {
        inherit inputs;
        hostname = "devbox";
        system = "x86_64-linux";
        users = [
          {name = "maxwellbrown";}
          {name = "mikearnaldi";}
        ];
        version = "22.11";
      };
      # devbox = nixpkgs.lib.nixosSystem {
      #   system = "x86_64-linux";
      #   specialArgs = {
      #     inherit inputs;
      #     common = self.common;
      #     pkgs = nixpkgs.legacyPackages.x86_64-linux;
      #   };
      #   modules = [
      #     ./hosts/devbox/configuration.nix
      #   ];
      # };
    };

    deploy = {
      sshUser = "root";

      nodes = {
        devbox = {
          hostname = "142.132.148.217";
          profiles = {
            system = {
              path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.devbox;
            };
          };
          remoteBuild = true;
        };
      };
    };
  };
}
