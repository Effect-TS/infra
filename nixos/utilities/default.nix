{
  nixosSystem,
  nixpkgs,
  ...
}: let
  inherit (nixpkgs.lib) fixedWidthString lists;

  mkK3sCluster = {
    modules ? [],
    nodes,
  }: let
    clusterInitializer = builtins.head nodes;

    machines =
      lists.imap1 (index: node: let
        nodeIndex = fixedWidthString 2 "0" (toString index);
        machineName = "k3s-node-${nodeIndex}";
        nodeConfig = {
          boot.loader.grub.devices = node.biosBootDevices;

          fileSystems."/boot/efi" = {
            device = node.espDevice;
            fsType = "vfat";
          };

          networking = {
            hostName = machineName;
            hostId = node.hostId;
          };

          nixos.profiles.k3s-node = {
            k3sServerAddr =
              if index == 1
              then ""
              else "https://${clusterInitializer.ipv4.address}:6443";
            ipv4 = node.ipv4;
            ipv6 = node.ipv6;
            wireguard = node.wireguard;
          };
        };
      in {
        name = machineName;
        value = nixosSystem {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          modules =
            modules
            ++ [
              ../profiles/k3s-node/configuration.nix
              nodeConfig
            ];
        };
      })
      nodes;
  in
    builtins.listToAttrs machines;
in {
  inherit mkK3sCluster;
}
