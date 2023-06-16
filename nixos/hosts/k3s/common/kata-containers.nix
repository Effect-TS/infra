{
  config,
  lib,
  pkgs,
  ...
}: let
  kata-runtime = pkgs.callPackage ./kata-runtime.nix {};
  kata-images = pkgs.callPackage ./kata-images.nix {};
  settingsFormat = pkgs.formats.toml {};
  cfg = config.virtualisation.kata-containers;
  configFile = settingsFormat.generate "configuration.toml" cfg.settings;
in {
  options = {
    virtualisation = {
      kata-containers = {
        settings = lib.mkOption {
          type = settingsFormat.type;
          default = {};
          description = ''
            Settings for kata's configuration.toml
          '';
        };
      };
    };
  };

  config = {
    systemd = {
      services = {
        containerd = {
          serviceConfig = {
            ExecStartPre = [
              "${pkgs.coreutils}/bin/cp -a ${kata-images}/share/kata-containers/. /var/lib/kata-containers/"
            ];
          };
          path = [kata-runtime];
        };
      };
    };

    virtualisation = {
      containerd = {
        settings = {
          version = 2;
          debug.level = "debug";
          plugins = {
            "io.containerd.grpc.v1.cri" = {
              containerd = {
                untrusted_workload_runtime = {
                  runtime_type = "io.containerd.kata-qemu.v2";
                  privileged_without_host_devices = true;
                };
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
                    options = {
                      ConfigPath = configFile.path;
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
