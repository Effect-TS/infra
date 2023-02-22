{pkgs, ...}: {
  imports = [
    "${fetchTarball {
      url = "https://github.com/msteen/nixos-vscode-server/tarball/master";
      sha256 = "1vgq7141mv67r7xgdpgg54hy41kbhlgp3870kyrh6z5fn4zyb74p";
    }}/modules/vscode-server/home.nix"
  ];

  home = {
    packages = with pkgs; [
      alejandra
      nil
    ];
  };

  programs = {
    vscode = {
      enable = true;

      extensions = with pkgs.vscode-extensions; [
        dbaeumer.vscode-eslint
        github.copilot
        jnoortheen.nix-ide
        ms-vscode-remote.remote-ssh
        vscodevim.vim
        yzhang.markdown-all-in-one
      ];

      userSettings = {
        # Breadcrumbs Settings
        "breadcrumbs.enabled" = true;
        # Editor Settings
        "editor.codeActionsOnSave" = {
          "source.fixAll.eslint" = true;
          "source.fixAll.shellcheck" = true;
        };
        "editor.cursorBlinking" = "solid";
        "editor.cursorWidth" = 3;
        "editor.cursorSurroundingLines" = 10;
        "editor.fontFamily" = "Hack Nerd Font Mono";
        "editor.fontSize" = 14;
        "editor.formatOnSave" = false;
        "editor.inlineSuggest.enabled" = true;
        "editor.multiCursorModifier" = "ctrlCmd";
        "editor.minimap.enabled" = false;
        "editor.acceptSuggestionOnCommitCharacter" = true;
        "editor.acceptSuggestionOnEnter" = "on";
        "editor.suggestOnTriggerCharacters" = true;
        "editor.tabCompletion" = "off";
        "editor.suggest.localityBonus" = true;
        "editor.quickSuggestions" = {
          "other" = true;
          "comments" = false;
          "strings" = false;
        };
        "editor.quickSuggestionsDelay" = 10;
        "editor.rulers" = [80 100];
        "editor.suggestSelection" = "first";
        "editor.tabSize" = 2;
        "editor.wordBasedSuggestions" = true;
        "editor.wordWrap" = "on";
        # Explorer Settings
        "explorer.confirmDragAndDrop" = false;
        "explorer.compactFolders" = false;
        "extensions.ignoreRecommendations" = false;
        # File Settings
        "files.autoSave" = "afterDelay";
        "files.autoSaveDelay" = 1000;
        "files.watcherExclude" = {
          "**/.bloop" = true;
          "**/.metals" = true;
          "**/.ammonite" = true;
        };
        "files.exclude" = {
          "**/.classpath" = true;
          "**/.project" = true;
          "**/.settings" = true;
          "**/.factorypath" = true;
        };
        "files.trimTrailingWhitespace" = true;
        # TERMINAL SETTINGS
        "terminal.integrated.fontFamily" = "Hack Nerd Font Mono";
        "terminal.integrated.fontSize" = 14;
        "terminal.integrated.shellIntegration.enabled" = true;
        # Window Settings
        "window.title" = "\${dirty} \${activeEditorMedium}\${separator}\${rootName}";
        "workbench.editor.tabSizing" = "shrink";
        "workbench.colorTheme" = "Atom One Dark";
        "workbench.iconTheme" = "vscode-icons";
        "workbench.startupEditor" = "newUntitledFile";
        # Shellcheck Settings
        "shellcheck.customArgs" = ["-x"];
        "shellformat.effectLanguages" = [
          "shellscript"
          "dotenv"
          "hosts"
          "jvmoptions"
          "ignore"
          "gitignore"
          "properties"
          "spring-boot-properties"
          "azcli"
        ];
        "shellcheck.useWorkspaceRootAsCwd" = true;
        # Emmet Settings
        "emmet.includeLanguages" = {
          "javascript" = "javascriptreact";
        };
        "emmet.showExpandedAbbreviation" = "never";
        "emmet.syntaxProfiles" = {
          "javascript" = "jsx";
        };
        "emmet.triggerExpansionOnTab" = true;
        # Eslint Settings
        "eslint.alwaysShowStatus" = true;
        "eslint.packageManager" = "yarn";
        "eslint.validate" = [
          "javascript"
          "javascriptreact"
          "typescript"
          "typescriptreact"
        ];
        # GitHub Copilot Settings
        "github.copilot.enable" = {
          "*" = true;
          "yaml" = false;
          "plaintext" = true;
          "markdown" = true;
        };
        # JavaScript Settings
        "javascript.updateImportsOnFileMove.enabled" = "never";
        # Jupyter Notebook Settings
        "notebook.cellToolbarLocation" = {
          "default" = "right";
          "jupyter-notebook" = "left";
        };
        # Nix Settings
        "nix.enableLanguageServer" = true;
        "nix.formatterPath" = ["nix" "fmt" "--" "-"];
        "nix.serverPath" = "nil";
        "nix.serverSettings" = {
          "nil" = {
            "diagnostics" = {
              "ignored" = ["unused_binding" "unused_with"];
            };
            "formatting" = {
              "command" = ["alejandra"];
            };
          };
        };
        # Python Settings
        "autoDocstring.docstringFormat" = "numpy";
        "python.formatting.provider" = "black";
        "python.linting.flake8Args" = [
          "--config=.flake8"
        ];
        "python.linting.flake8Enabled" = true;
        "python.linting.enabled" = true;
        "python.insidersChannel" = "weekly";
        # TypeScript Settings
        "typescript.tsserver.log" = "off";
        "typescript.updateImportsOnFileMove.enabled" = "never";
        "typescript.tsdk" = "./node_modules/typescript/lib";
        # Vim Settings
        "vim.easymotion" = true;
        "vim.hlsearch" = true;
        "vim.incsearch" = true;
        "vim.useSystemClipboard" = true;
        "vim.useCtrlKeys" = true;
        "vim.surround" = true;
        "vim.insertModeKeyBindings" = [
          {
            "before" = ["j" "j"];
            "after" = ["<Esc>"];
          }
        ];
        "vim.normalModeKeyBindingsNonRecursive" = [
          {
            "before" = ["<leader>" "d"];
            "after" = ["d" "d"];
          }
          {
            "before" = ["<C-n>"];
            "commands" = [":nohl"];
          }
        ];
        "vim.leader" = "<space>";
        "vim.handleKeys" = {
          "<C-a>" = false;
          "<C-f>" = false;
        };
        # VS Intellicode Settings
        "vsintellicode.modify.editor.suggestSelection" = "choseToUpdateConfiguration";
        # LANGUAGE SETTINGS
        "[csharp]" = {
          "editor.tabSize" = 4;
        };
        "[dockerfile]" = {
          "editor.defaultFormatter" = "dbaeumer.vscode-eslint";
          "editor.formatOnSave" = true;
        };
        "[html]" = {
          "editor.defaultFormatter" = "dbaeumer.vscode-eslint";
        };
        "[javascript]" = {
          "editor.formatOnSave" = true;
        };
        "[javascriptreact]" = {
          "editor.formatOnSave" = true;
        };
        "[json]" = {
          "editor.defaultFormatter" = "vscode.json-language-features";
        };
        "[jsonc]" = {
          "editor.defaultFormatter" = "vscode.json-language-features";
        };
        "[markdown]" = {
          "editor.formatOnSave" = true;
          "editor.defaultFormatter" = "yzhang.markdown-all-in-one";
        };
        "[nix]" = {
          "editor.formatOnSave" = true;
        };
        "[python]" = {
          "editor.formatOnSave" = true;
          "editor.tabSize" = 4;
        };
        "[typescript]" = {
          "editor.defaultFormatter" = "dbaeumer.vscode-eslint";
        };
        "[yaml]" = {
          "editor.tabSize" = 2;
          "editor.formatOnSave" = true;
        };
        # Miscellaneous Settings
        "diffEditor.ignoreTrimWhitespace" = false;
        "vsicons.dontShowNewVersionMessage" = true;
      };
    };
  };

  services = {
    vscode-server = {
      enable = true;
    };
  };
}
