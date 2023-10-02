{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: {
  # The check below determines if this configuration is home-manager applied or
  # NixOS/nix-darwin applied (these options do not exist in home-manager)
  nix =
    {
      package = pkgs.nixVersions.nix_2_17;
    }
    // lib.optionalAttrs (builtins.hasAttr "nixPath" config.nix) {
      # Add each flake input as a registry - this becomes
      # `registry.nixpkgs.flake = inputs.nixpkgs etc. for all flake inputs
      registry = lib.mapAttrs (_: value: {flake = value;}) inputs;
    };
}
