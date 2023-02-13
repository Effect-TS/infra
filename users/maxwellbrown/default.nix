{pkgs, ...}: {
  users = {
    users = {
      maxwellbrown = {
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
    };
  };
}
