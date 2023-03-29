{
  config,
  pkgs,
  lib,
  inputs,
  outputs,
  ...
}: {
  imports =
    [
      inputs.nix-colors.homeManagerModule

      ./bat.nix
      ./bottom.nix
      ./fzf.nix
      ./git.nix
      ./neovim.nix
      ./packages.nix
      ./shells.nix
      ./ssh-ingress.nix
      ./ssh-keys.nix
      ./starship.nix
      ./vscode.nix
    ]
    ++ (builtins.attrValues outputs.homeManagerModules);

  colorscheme = {
    slug = "catppuccin-macchiato";
    name = "Catppuccin Macchiato";
    author = "https://github.com/catppuccin/catppuccin";
    kind = "dark";
    colors = {
      base00 = "24273A"; # base
      base01 = "1E2030"; # mantle
      base02 = "363A4F"; # surface0
      base03 = "494D64"; # surface1
      base04 = "5B6078"; # surface2
      base05 = "CAD3F5"; # text
      base06 = "F4DBD6"; # rosewater
      base07 = "B7BDF8"; # lavender
      base08 = "ED8796"; # red
      base09 = "F5A97F"; # peach
      base0A = "EED49F"; # yellow
      base0B = "A6DA95"; # green
      base0C = "8BD5CA"; # teal
      base0D = "8AADF4"; # blue
      base0E = "C6A0F6"; # mauve
      base0F = "F0C6C6"; # flamingo
    };
  };

  home = {
    username = lib.mkDefault "mikearnaldi";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    stateVersion = lib.mkDefault "22.11";

    sessionVariables = {
      LANG = "en_US.UTF-8";
      LC_CTYPE = "en_US.UTF-8";
    };
  };

  programs = {
    home-manager = {
      enable = true;
    };
  };

  xdg = {
    enable = true;
    configHome = "${config.home.homeDirectory}/.config";
    cacheHome = "${config.home.homeDirectory}/.cache";
    dataHome = "${config.home.homeDirectory}/.local/share";
    stateHome = "${config.home.homeDirectory}/.local/state";
  };
}
