{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;

  cfg = config.modules.kata-containers;

  version = cfg.version;

  kata-images = pkgs.fetchzip {
    name = "kata-images-${version}";
    url = "https://github.com/kata-containers/kata-containers/releases/download/${version}/kata-static-${version}-x86_64.tar.xz";
    sha256 = "sha256-uxCid3B9hi03LMHn60caumTZINHt1xp121uPWZD3E5Q=";
    postFetch = ''
      mv $out/kata/share/kata-containers kata-containers
      rm -r $out
      mkdir -p $out/share
      mv kata-containers $out/share/kata-containers
    '';
  };
in
  mkIf cfg.enable {
    systemd.services.containerd = {
      serviceConfig = {
        ExecStartPre = [
          "${pkgs.coreutils}/bin/cp -a ${kata-images}/share/kata-containers/. /var/lib/kata-containers/"
        ];
      };
    };
  }
