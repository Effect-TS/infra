{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./users
  ];

  # NixOS configuration option reference:
  # https://nixos.org/manual/nixos/stable/options.html
  config = {
    boot = {
      # Delete all files in `/tmp` during boot
      cleanTmpDir = true;
    };

    environment = {
      # The set of packages that appear in `/run/current-system/sw` - these
      # packages are automatically available to all users, and are automatically
      # updated every time you rebuild the system configuration (The latter is
      # the main difference with installing them in the default profile,
      # `/nix/var/nix/profiles/default`)
      systemPackages = with pkgs; [
        pkgs.git
        pkgs.vim
      ];
    };

    nix = {
      # Additional text appended to `nix.conf`
      extraOptions = ''
        experimental-features = nix-command flakes
      '';

      settings = {
        # Automatically optimise the Nix store
        auto-optimise-store = true;
        # Perform builds in a sandboxed environment
        # See https://nixos.org/manual/nixos/stable/options.html#opt-nix.settings.sandbox
        sandbox = true;
        # Users trusted to operate the Nix daemon
        trusted-users = ["root" "maxbrown" "mikearnaldi"];
      };

      # Specifies the Nix package instance to use throughout the system
      package = pkgs.nixVersions.stable;
    };

    nixpkgs = {
      config = {
        # https://nixos.org/manual/nixpkgs/stable/#sec-allow-unfree
        allowUnfree = true;
      };
    };
  };
}
