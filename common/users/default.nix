{
  config,
  pkgs,
  ...
}: {
  users = {
    users = {
      root = {
        openssh = {
          authorizedKeys = {
            keys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO9KP6DOk19QDQ/AKMDWyVeE7Nu2KzH3pKS/z33dNRfs"
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEzPT600TtIVU+Ch+sbkB2GuJb+ZScNkOHKhPb6Q8AHv ma@matechs.com"
            ];
          };
        };
      };

      maxbrown = {
        extraGroups = ["wheel"];

        isNormalUser = true;

        shell = pkgs.zsh;

        openssh = {
          authorizedKeys = {
            keys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO9KP6DOk19QDQ/AKMDWyVeE7Nu2KzH3pKS/z33dNRfs"
            ];
          };
        };
      };

      mikearnaldi = {
        extraGroups = ["wheel"];

        isNormalUser = true;

        # TODO: specify a shell to use

        openssh = {
          authorizedKeys = {
            keys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEzPT600TtIVU+Ch+sbkB2GuJb+ZScNkOHKhPb6Q8AHv ma@matechs.com"
            ];
          };
        };
      };
    };
  };
}
