{
  lib,
  common,
  config,
  nixpkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  hardware = {
    enableAllFirmware = true;

    opengl = {
      enable = false;
    };
  };

  networking = {
    hostName = "nix-builder";
    useDHCP = lib.mkDefault true;

    firewall = {
      allowedTCPPorts = [22];
    };
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  services = {
    openssh = {
      enable = true;
      permitRootLogin = "yes";
    };

    tailscale = {
      enable = true;
    };
  };

  time = {
    timeZone = "America/New_York";
  };

  users = {
    users = {
      root = {
        initialHashedPassword = "";
        openssh = {
          authorizedKeys = {
            keys =
              common.sshKeys
              ++ [
                (
                  lib.strings.removeSuffix "\n" (
                    builtins.readFile ./ssh/nix-builder.pub
                  )
                )
              ];
          };
        };
      };
    };
  };

  system = {
    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    stateVersion = "21.11"; # Did you read the comment?
  };
}
