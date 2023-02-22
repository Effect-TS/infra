{
  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-22.11";
    };

    nixpkgs-master = {
      url = "github:NixOS/nixpkgs/master";
    };

    nixpkgs-unstable = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
    };

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-22.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-colors = {
      url = "github:misterio77/nix-colors";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nixpkgs-master,
    nixpkgs-unstable,
    nixos-hardware,
    deploy-rs,
    home-manager,
    nix-colors,
    sops-nix,
    ...
  }: let
    mkNixOsSystem = import "${inputs.self}/lib/mkNixOsSystem.nix";

    supportedSystems = [
      "x86_64-darwin"
      "x86_64-linux"
      "aarch64-darwin"
      "aarch64-linux"
    ];

    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

    pkgsFor = system: nixpkgs.legacyPackages.${system};

    inherit (self) outputs;
    specialArgs = {inherit inputs outputs;};
  in {
    homeManagerModules = import "${self}/modules/home-manager";

    formatter = forAllSystems (
      system: let
        pkgs = pkgsFor system;
      in
        pkgs.alejandra
    );

    devShells = forAllSystems (system: let
      pkgs = pkgsFor system;
    in {
      default = pkgs.callPackage "${self}/shell.nix" {inherit pkgs;};
    });

    nixosConfigurations = {
      # On actual machine:
      #   nixos-rebuild switch --flake .#devbox
      # On other machine:
      #   deploy --targets .#devbox
      # On other machine with dry activation:
      #   deploy --targets .#devbox --dry-activate
      devbox = nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        modules = ["${self}/hosts/devbox"];
      };
    };

    deploy = {
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
