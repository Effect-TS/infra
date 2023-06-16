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
  flannel = builtins.toJSON {
    name = "cbr0";
    cniVersion = "1.0.0";
    plugins = [
      {
        type = "flannel";
        delegate = {
          hairpinMode = true;
          forceAddress = true;
          isDefaultGateway = true;
        };
      }
      {
        type = "portmap";
        capabilities = {
          portMappings = true;
        };
      }
    ];
  };
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
              cni = {
                conf_dir = "${pkgs.writeTextDir "net.d/10-flannel.conflist" flannel}/net.d";
              };
              containerd = {
                untrusted_workload_runtime = {
                  runtime_type = "io.containerd.kata.v2";
                  privileged_without_host_devices = true;
                };
                runtimes = {
                  runc = {
                    runtime_type = "io.containerd.runc.v2";
                    privileged_without_host_devices = false;
                  };
                  kata = {
                    runtime_type = "io.containerd.kata.v2";
                    privileged_without_host_devices = true;
                    pod_annotations = ["io.katacontainers.*"];
                    container_annotations = ["io.katacontainers.*"];
                    options = {
                      ConfigPath = "${configFile}";
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
