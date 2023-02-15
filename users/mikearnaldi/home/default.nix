{
  inputs,
  version,
  ...
}: {
  imports = [
    "${fetchTarball {
      url = "https://github.com/msteen/nixos-vscode-server/tarball/master";
      sha256 = "1vgq7141mv67r7xgdpgg54hy41kbhlgp3870kyrh6z5fn4zyb74p";
    }}/modules/vscode-server/home.nix"
  ];

  services.vscode-server.enable = true;

  home = {
    # Provide home-manager with the information it needs to find the user
    username = "mikearnaldi";
    homeDirectory = "/home/mikearnaldi";

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = version;
  };

  programs = {
    # Let Home Manager install and manage itself.
    home-manager = {
      enable = true;
    };
  };
}

