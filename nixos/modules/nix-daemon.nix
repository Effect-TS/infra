{
  config,
  lib,
  ...
}: {
  nix =
    {
      gc = {
        automatic = true;
        dates = "03:15";
        options = "--delete-older-than 14d";
        persistent = true;
      };

      optimise = {
        automatic = true;
        dates = ["03:15"];
      };

      settings = {
        # For nix-direnv
        keep-outputs = true;
        keep-derivations = true;

        max-jobs = lib.mkDefault "auto";

        # In ZFS we trust
        fsync-metadata = lib.boolToString (!config.boot.isContainer or config.fileSystems."/".fsType != "zfs");

        # Remote builds
        system-features = ["benchmark" "big-parallel" "kvm" "nixos-test"];
      };
    }
    # The check below determines if this configuration is home-manager applied or
    # NixOS/nix-darwin applied (these options do not exist in home-manager)
    // lib.optionalAttrs (builtins.hasAttr "nixPath" config.nix) {
      nrBuildUsers = lib.mkDefault 32;
    };
}
