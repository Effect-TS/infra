{
  inputs,
  version,
  ...
}: {
  home = {
    # Provide home-manager with the information it needs to find the user
    username = "maxwellbrown";
    homeDirectory = "/home/maxwellbrown";

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
