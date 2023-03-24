let
  flakeLock = builtins.fromJSON (builtins.readFile ./flake.lock);
  nixpkgsLock = flakeLock.nodes.nixpkgs.locked;
  lockedNixpkgs =
    import
    (fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/${nixpkgsLock.rev}.tar.gz";
      sha256 = nixpkgsLock.narHash;
    })
    {};
in
  {pkgs ? lockedNixpkgs}:
    with pkgs;
      mkShell {
        name = "nixos-shell";

        # Enable experimental features without having to specify the argument
        NIX_CONFIG = "extra-experimental-features = nix-command flakes repl-flake";

        nativeBuildInputs = [
          git
          nix
          nil
          alejandra
          deploy-rs
          home-manager
          # https://discourse.nixos.org/t/how-to-run-nixos-rebuild-target-host-from-darwin/9488/3
          nixos-rebuild
          age
          sops
          ssh-to-age
        ];
      }
