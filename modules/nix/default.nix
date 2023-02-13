{pkgs, ...}: {
  nix = {
    settings = {
      # Automatically optimise the Nix store
      auto-optimise-store = true;
      experimental-features = ["nix-command" "flakes"];
      # Perform builds in a sandboxed environment
      # See https://nixos.org/manual/nixos/stable/options.html#opt-nix.settings.sandbox
      sandbox = true;
      # Users trusted to operate the Nix daemon
      trusted-users = ["root" "maxbrown" "mikearnaldi"];
    };
    # Specifies the Nix package instance to use throughout the system
    package = pkgs.nixVersions.stable;
  };
}
