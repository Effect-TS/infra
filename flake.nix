{
  description = "The infrastructure-as-code for Effect";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    git-hooks.url = "github:cachix/git-hooks.nix";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = inputs.nixpkgs.lib.systems.flakeExposed;

      imports = [
        inputs.git-hooks.flakeModule
      ];

      perSystem =
        {
          config,
          pkgs,
          ...
        }:
        {
          devShells.default = pkgs.mkShell {
            inherit (config.pre-commit.devShell) nativeBuildInputs;

            buildInputs = with pkgs; [
              age
              awscli2
              findutils
              opentofu
              sops
              ssh-to-age
              yq-go
            ];

            shellHook = ''
              ${config.pre-commit.devShell.shellHook}
            '';

            # KUSTOMIZE_PLUGIN_HOME = pkgs.buildEnv {
            #   name = "kustomize-plugins";
            #   paths = [
            #     kustomize-sops
            #   ];
            #   postBuild = ''
            #     mv $out/lib/* $out
            #     rm -r $out/lib
            #   '';
            #   pathsToLink = [ "/lib" ];
            # };
          };

          pre-commit = {
            settings = {
              hooks = {
                # Terraform Hooks
                terraform-format.enable = true;
                # Miscellaneous Hooks
                end-of-file-fixer.enable = true;
              };
            };
          };
        };
    };
}
