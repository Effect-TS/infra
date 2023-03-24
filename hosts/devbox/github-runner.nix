{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../common/users/github-runner
  ];

  services = {
    github-runner = {
      enable = true;
      ephemeral = true;
      extraLabels = ["devbox"];
      tokenFile = config.sops.secrets.github-pat.path;
      url = "https://github.com/Effect-TS";
      user = "github-runner";
      extraPackages = with pkgs; [
        config.virtualisation.docker.package
      ];
    };
  };

  sops = {
    secrets = {
      github-pat = {
        sopsFile = ./secrets.yaml;
      };
    };
  };

  systemd = {
    services = {
      github-runner = {
        serviceConfig = {
          SupplementaryGroups = ["docker"];
        };
      };
    };
  };
}
