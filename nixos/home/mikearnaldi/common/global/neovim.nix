{
  config,
  pkgs,
  lib,
  ...
}: let
  # nixified plugins
  mini-base16 = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "mini.base16";
    version = "2023-02-09";
    src = pkgs.fetchFromGitHub {
      owner = "echasnovski";
      repo = "mini.base16";
      rev = "2a29ef2a2742c600137e656a6789514380f630bf";
      sha256 = "sha256-qPOPl0KFOMimiv9f/+/u/AK2VWE8IpCmIiafTLlELu0=";
    };
    meta.homepage = "https://github.com/echasnovski/mini.base16";
  };
  nvim-luaref = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "nvim-luaref";
    version = "2022-02-17";
    src = pkgs.fetchFromGitHub {
      owner = "milisims";
      repo = "nvim-luaref";
      rev = "9cd3ed50d5752ffd56d88dd9e395ddd3dc2c7127";
      sha256 = "sha256-nmsKg1Ah67fhGzevTFMlncwLX9gN0JkR7Woi0T5On34=";
    };
    meta.homepage = "https://github.com/milisims/nvim-luaref";
  };
in {
  home = {
    sessionVariables = {
      # no profile makes it start faster than the speed of light
      EDITOR = "nvim -u NONE";
      VISUAL = "nvim -u NONE";
      GIT_EDITOR = "nvim -u NONE";
    };
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    withPython3 = false;
    withNodeJs = false;
    withRuby = false;
    extraPackages = [
      # this won't be useful globally, so neovim only is fine
      pkgs.shellcheck
    ];
    plugins = with pkgs.unstable.vimPlugins; [
      # dependencies
      plenary-nvim
      nui-nvim
      nvim-web-devicons
      # treesitter
      nvim-treesitter.withAllGrammars
      nvim-treesitter-context
      nvim-treesitter-textobjects
      # completion
      {
        plugin = nvim-cmp;
        optional = false;
      }
      {
        plugin = cmp-buffer;
        optional = false;
      }
      {
        plugin = cmp-nvim-lsp;
        optional = false;
      }
      {
        plugin = cmp-path;
        optional = false;
      }
      {
        plugin = cmp_luasnip;
        optional = false;
      }
      # lsp
      {
        plugin = nvim-lspconfig;
        optional = false;
      }
      {
        plugin = neodev-nvim;
        optional = false;
      }
      {
        plugin = null-ls-nvim;
        optional = false;
      }
      {
        plugin = luasnip;
        optional = false;
      }
      {
        plugin = friendly-snippets;
        optional = false;
      }
      {
        plugin = fidget-nvim;
        optional = false;
      }
      # dap
      {
        plugin = nvim-dap;
        optional = true;
      }
      {
        plugin = nvim-dap-ui;
        optional = true;
      }
      {
        plugin = nvim-dap-virtual-text;
        optional = true;
      }
      # telescope
      {
        plugin = telescope-nvim;
        optional = false;
      }
      {
        plugin = telescope-fzf-native-nvim;
        optional = false;
      }
      # statusline
      lualine-nvim
      nvim-navic
      # misc
      boole-nvim
      comment-nvim
      {
        plugin = diffview-nvim;
        optional = false;
      }
      gitsigns-nvim
      {
        plugin = harpoon;
        optional = false;
      }
      impatient-nvim
      indent-blankline-nvim
      nvim-luaref
      vim-sleuth
      which-key-nvim
      # ui
      {
        plugin = catppuccin-nvim;
        optional = false;
      }
      {
        plugin = mini-base16;
        optional = true;
      }
      dressing-nvim
      {
        plugin = neo-tree-nvim;
        optional = false;
      }
    ];
  };

  xdg = {
    configFile = {
      # "nvim" = {
      #   source = "${pkgs.dotfiles}/neovim";
      #   recursive = true;
      # };
      "nvim/lua/maxwellbrown/nix-colors.lua" = {
        text = let
          c = config.colorscheme.colors;
        in ''
          return {
            slug = "${config.colorscheme.slug}",
            colors = {
              base00 = '#${c.base00}',
              base01 = '#${c.base01}',
              base02 = '#${c.base02}',
              base03 = '#${c.base03}',
              base04 = '#${c.base04}',
              base05 = '#${c.base05}',
              base06 = '#${c.base06}',
              base07 = '#${c.base07}',
              base08 = '#${c.base08}',
              base09 = '#${c.base09}',
              base0A = '#${c.base0A}',
              base0B = '#${c.base0B}',
              base0C = '#${c.base0C}',
              base0D = '#${c.base0D}',
              base0E = '#${c.base0E}',
              base0F = '#${c.base0F}',
            },
          }
        '';
      };
    };
  };
}
