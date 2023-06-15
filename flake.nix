{
  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-23.05";
    };

    nixpkgs-master = {
      url = "github:NixOS/nixpkgs/master";
    };

    nixpkgs-unstable = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    flake-utils = {
      url = "github:numtide/flake-utils";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-22.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-colors = {
      url = "github:misterio77/nix-colors";
    };

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nixpkgs-master,
    nixpkgs-unstable,
    flake-utils,
    home-manager,
    nixos-hardware,
    nix-colors,
    sops-nix,
    treefmt-nix,
    ...
  }: let
    inherit (self) outputs;
    specialArgs = {inherit inputs outputs;};
  in
    flake-utils.lib.eachDefaultSystem
    (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      unstablePkgs = nixpkgs-unstable.legacyPackages.${system};
    in {
      formatter = treefmt-nix.lib.mkWrapper pkgs {
        projectRootFile = "flake.nix";
        programs.alejandra.enable = true;
      };

      devShells = {
        default = pkgs.callPackage "${self}/shell.nix" {pkgs = unstablePkgs;};
      };
    })
    // {
      homeManagerModules = import "${self}/nixos/modules/home-manager";

      nixosConfigurations = {
        # On actual machine:
        #   nixos-rebuild switch --flake .#devbox
        # On other machine:
        #   nixos-rebuild --build-host user@host --target-host user@host --use-remote-sudo switch --flake .#devbox
        # On other machine with dry activation:
        #   nixos-rebuild --build-host user@host --target-host user@host --use-remote-sudo dry-activate --flake .#devbox
        devbox = nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          modules = ["${self}/nixos/hosts/devbox"];
        };

        k3s-host-01 = nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          modules = ["${self}/nixos/hosts/k3s/host-01"];
        };

        k3s-host-02 = nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          modules = ["${self}/nixos/hosts/k3s/host-02"];
        };

        k3s-host-03 = nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          modules = ["${self}/nixos/hosts/k3s/host-03"];
        };
      };
    };
}
