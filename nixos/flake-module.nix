{
  self,
  inputs,
  ...
}: let
  inherit (inputs.nixpkgs) lib;
  inherit (inputs) nixpkgs;

  nixosSystem = args:
    (lib.makeOverridable lib.nixosSystem)
    (lib.recursiveUpdate args {
      modules =
        args.modules
        ++ [
          {
            config.nixpkgs.pkgs = lib.mkDefault args.pkgs;
            config.nixpkgs.localSystem = lib.mkDefault args.pkgs.stdenv.hostPlatform;
          }
        ];
    });

  defaultModules = [
    # make flake inputs accessiable in NixOS
    {
      _module.args.self = self;
      _module.args.inputs = self.inputs;
    }
    ({...}: {
      imports = [
        inputs.sops-nix.nixosModules.sops

        # https://numtide.github.io/srvos
        inputs.srvos.nixosModules.server
        inputs.srvos.nixosModules.hardware-hetzner-online-amd
        inputs.srvos.nixosModules.mixins-terminfo
        inputs.srvos.nixosModules.mixins-trusted-nix-caches

        ./modules/nix-daemon.nix
        ./modules/nix-path.nix
        ./modules/packages.nix
        ./modules/users/admins.nix # Additional users added per-machine
        ./modules/zsh.nix
      ];
    })
  ];

  utilities = import ./utilities {inherit nixosSystem nixpkgs;};
  inherit (utilities) mkK3sCluster;

  wireguardPeers = [
    {
      PublicKey = "QGra1fNdvJEGSgqwv9ct8ACBAlrRFoaqH3kR+Ummcw4=";
      AllowedIPs = ["10.0.0.1"];
      Endpoint = "213.239.207.149:51820";
    }
    {
      PublicKey = "CCQV0QdzkbYtyBdzEeY0kUhsyxGmUB2yIiWczxP5N2E=";
      AllowedIPs = ["10.0.0.2"];
      Endpoint = "167.235.103.220:51820";
    }
    {
      PublicKey = "GzkKo/SbRSUPe9EVhBORVHsGcF8Ih2qon1rnclmiyC8=";
      AllowedIPs = ["10.0.0.3"];
      Endpoint = "65.109.94.140:51820";
    }
  ];

  k3sCluster = mkK3sCluster {
    modules = defaultModules;

    nodes = [
      {
        biosBootDevices = [
          "/dev/disk/by-id/nvme-SAMSUNG_MZVL2512HCJQ-00B00_S675NX0T570867"
          "/dev/disk/by-id/nvme-SAMSUNG_MZVL2512HCJQ-00B00_S675NX0T570972"
        ];

        clusterInit = true;

        espDevice = "/dev/disk/by-uuid/47E9-DEC3";

        hostId = "e0f5a143";

        ipv4 = {
          address = "213.239.207.149";
          prefixLength = 24;
        };

        ipv6 = {
          address = "2a01:4f8:a0:8485::1";
          prefixLength = 64;
        };

        wireguard = {
          publicKey = "QGra1fNdvJEGSgqwv9ct8ACBAlrRFoaqH3kR+Ummcw4=";
          ipv4 = {
            address = "10.0.0.1";
            prefixLength = 24;
          };
          peers = wireguardPeers;
        };
      }

      {
        biosBootDevices = [
          "/dev/disk/by-id/nvme-KXG60ZNV512G_TOSHIBA_Y9ES11F9T9LM"
          "/dev/disk/by-id/nvme-KXG60ZNV512G_TOSHIBA_Y9ES11FKT9LM"
        ];

        espDevice = "/dev/disk/by-uuid/A28D-9ED3";

        hostId = "bbb7d16a";

        ipv4 = {
          address = "167.235.103.220";
          prefixLength = 24;
        };

        ipv6 = {
          address = "2a01:4f8:2200:141e::1";
          prefixLength = 64;
        };

        wireguard = {
          publicKey = "CCQV0QdzkbYtyBdzEeY0kUhsyxGmUB2yIiWczxP5N2E=";
          ipv4 = {
            address = "10.0.0.2";
            prefixLength = 24;
          };
          peers = wireguardPeers;
        };
      }

      {
        biosBootDevices = [
          "/dev/disk/by-id/nvme-SAMSUNG_MZVL2512HCJQ-00B00_S675NE0T501629"
          "/dev/disk/by-id/nvme-SAMSUNG_MZVL2512HCJQ-00B00_S675NE0T501620"
        ];

        espDevice = "/dev/disk/by-uuid/4894-1D27";

        hostId = "c0bb415f";

        ipv4 = {
          address = "65.109.94.140";
          prefixLength = 24;
        };

        ipv6 = {
          address = "2a01:4f9:3051:48cd::1";
          prefixLength = 64;
        };

        wireguard = {
          publicKey = "GzkKo/SbRSUPe9EVhBORVHsGcF8Ih2qon1rnclmiyC8=";
          ipv4 = {
            address = "10.0.0.3";
            prefixLength = 24;
          };
          peers = wireguardPeers;
        };
      }
    ];
  };
in {
  flake.nixosConfigurations = k3sCluster;
}
