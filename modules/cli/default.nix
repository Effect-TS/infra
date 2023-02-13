{pkgs, ...}: {
  environment = {
    # The set of packages that appear in `/run/current-system/sw` - these
    # packages are automatically available to all users, and are automatically
    # updated every time you rebuild the system configuration (The latter is
    # the main difference with installing them in the default profile,
    # `/nix/var/nix/profiles/default`)
    systemPackages = with pkgs; [
      git
      vim
    ];
  };
}
