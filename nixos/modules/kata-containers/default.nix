{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkDoc mkEnableOption mkIf mkOption types;

  settingsFormat = pkgs.formats.toml {};
  cfg = config.modules.kata-containers;
  configFile = settingsFormat.generate "configuration.toml" cfg.settings;
in {
  imports = [
    ./images.nix
    ./runtime.nix
  ];

  options = {
    modules.kata-containers = {
      enable = mkEnableOption "kata-containers";

      version = mkOption {
        type = types.str;
        description = mkDoc ''
          The version of Kata Containers to install.

          See the [GitHub releases page](https://github.com/kata-containers/kata-containers/releases)
          for a list of released versions.
        '';
      };

      settings = mkOption {
        type = types.nullOr settingsFormat.type;
        default = null;
        description = ''
          Settings for kata's configuration.toml
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    virtualisation.containerd = {
      enable = true;
      settings = {
        version = 2;
        plugins = {
          "io.containerd.grpc.v1.cri" = {
            containerd = {
              runtimes = {
                runc = {
                  runtime_type = "io.containerd.runc.v2";
                  privileged_without_host_devices = false;
                };
                kata-qemu = {
                  runtime_type = "io.containerd.kata-qemu.v2";
                  privileged_without_host_devices = true;
                  pod_annotations = ["io.katacontainers.*"];
                  container_annotations = ["io.katacontainers.*"];
                  options = lib.optionalAttrs (cfg.settings != null) {
                    ConfigPath = "${configFile}";
                  };
                };
                untrusted = {
                  runtime_type = "io.containerd.kata-qemu.v2";
                  privileged_without_host_devices = true;
                };
              };
            };
          };
        };
      };
    };
  };
}
