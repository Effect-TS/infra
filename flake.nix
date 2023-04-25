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
    supportedSystems = [
      "x86_64-darwin"
      "x86_64-linux"
      "aarch64-darwin"
      "aarch64-linux"
    ];

    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

    pkgsFor = system: nixpkgs.legacyPackages.${system};
    unstablePkgsFor = system: nixpkgs-unstable.legacyPackages.${system};

    inherit (self) outputs;
    specialArgs = {inherit inputs outputs;};
  in {
    homeManagerModules = import "${self}/nixos/modules/home-manager";

    formatter = forAllSystems (
      system: let
        pkgs = pkgsFor system;
      in
        pkgs.alejandra
    );

    devShells = forAllSystems (system: let
      pkgs = unstablePkgsFor system;
    in {
      default = pkgs.callPackage "${self}/shell.nix" {inherit pkgs;};
    });

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

      k3s-host-02 = nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        modules = ["${self}/nixos/hosts/k3s/host-02"];
      };
    };
  };
}
