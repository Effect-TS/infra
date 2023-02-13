{
  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-22.11";
    };

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    deploy-rs,
    nixpkgs,
  }: let
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
    # checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;

    formatter = forAllSystems (system: nixpkgsFor.${system}.alejandra);

    devShells = forAllSystems (system: {
      default = nixpkgsFor.${system}.mkShell {
        buildInputs = with nixpkgsFor.${system}; [
          deploy-rs
        ];
      };
    });

    nixosConfigurations = {
      # On actual machine:
      #   sudo nixos-rebuild switch --flake .#devbox
      # On other machine:
      #   deploy --targets .#devbox
      devbox = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
          common = self.common;
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
        };
        modules = [
          ./hosts/devbox/configuration.nix
        ];
      };
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
