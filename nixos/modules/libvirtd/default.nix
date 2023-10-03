{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.modules.libvirtd;
in {
  options.modules.libvirtd = {
    enable = mkEnableOption "libvirtd";
  };

  config = mkIf cfg.enable {
    virtualisation.libvirtd = {
      enable = true;
      qemu.ovmf.enable = true;
    };
  };
}
