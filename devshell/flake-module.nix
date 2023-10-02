{inputs, ...}: {
  imports = [
    inputs.pre-commit-hooks.flakeModule
    inputs.treefmt-nix.flakeModule
  ];

  perSystem = {
    config,
    lib,
    pkgs,
    ...
  }: {
    pre-commit = {
      check = {
        enable = true;
      };

      settings = {
      };
    };

    treefmt = {
      # Used to find the project root
      projectRootFile = "flake.lock";

      programs = {
        terraform = {
          enable = true;
        };
      };

      settings = {
        formatter = {
          nix = {
            command = "sh";
            options = [
              "-eucx"
              ''
                export PATH=${lib.makeBinPath [pkgs.coreutils pkgs.findutils pkgs.deadnix pkgs.alejandra]}
                deadnix --edit "$@"
                alejandra "$@"
              ''
              "--"
            ];
            includes = ["*.nix"];
            excludes = [""];
          };

          shell = {
            command = "sh";
            options = [
              "-eucx"
              ''
                # First shellcheck
                ${pkgs.lib.getExe pkgs.shellcheck} --external-sources --source-path=SCRIPTDIR "$@"
                # Then format
                ${pkgs.lib.getExe pkgs.shfmt} -i 2 -s -w "$@"
              ''
              "--"
            ];
            includes = ["*.sh"];
            excludes = ["nixos/modules/k3s/k3s-reset-node"];
          };

          python = {
            command = "sh";
            options = [
              "-eucx"
              ''
                ${pkgs.lib.getExe pkgs.ruff} --fix "$@"
                ${pkgs.lib.getExe pkgs.python3.pkgs.black} "$@"
              ''
              "--" # this argument is ignored by bash
            ];
            includes = ["*.py"];
            excludes = [
              "gdb/*"
              "zsh/*"
            ];
          };

          yaml = let
            settingsFormat = pkgs.formats.yaml {};
            conf = settingsFormat.generate "yamlfmt-conf" {
              formatter = {
                include_document_start = true;
                retain_line_breaks = true;
              };
            };
          in {
            command = "sh";
            options = [
              "-eucx"
              ''
                ${pkgs.lib.getExe pkgs.yamlfmt} --conf ${conf} "$@"
              ''
            ];
            includes = ["*.yaml"];
            excludes = ["manifests/**/charts/**/templates/*.yaml"];
          };
        };
      };
    };

    # Definitions like this are entirely equivalent to the ones
    # you may have directly in flake.nix.
    devShells.default = pkgs.mkShellNoCC {
      # sopsPGPKeyDirs = ["./nixos/secrets/keys"];
      # sopsCreateGPGHome = true;
      nativeBuildInputs = [
        # inputs'.sops-nix.packages.sops-import-keys-hook

        pkgs.python3.pkgs.deploykit
        pkgs.python3.pkgs.invoke

        config.treefmt.build.wrapper
      ];

      buildInputs = with pkgs; [
        # Pre-commit
        config.pre-commit.settings.package
        # K8s
        kubernetes-helm
        kubectl
        # Python
        python3.pkgs.black
        ruff
        # SOPS
        age
        sops
        ssh-to-age
        # Utilities
        findutils
        jq
        yq-go
      ];

      # Required because `nixos-rebuild` does not seem to respect `~/.ssh/config`
      # which means that on MacOS the Unix socket length for the SSH control
      # path is too long
      NIX_SSHOPTS = "-o ControlPath=/tmp/%r@%h:%p";

      shellHook = ''
        ${config.pre-commit.installationScript}
      '';
    };
  };
}
