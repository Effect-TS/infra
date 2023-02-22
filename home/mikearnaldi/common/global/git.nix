{...}: {
  programs = {
    git = {
      enable = true;
      userName = "Michael Arnaldi";
      userEmail = "ma@matechs.com";

      delta = {
        enable = true;
        options = {
          dark = true;
          features = "side-by-side";
          hyperlinks = false;
          line-numbers = true;
          navigate = true;
          syntax-theme = "Dracula";
        };
      };

      extraConfig = {
        color = {
          ui = true;
        };

        core = {
          editor = "nvim -u NONE";
          filemode = false;
          ignorecase = false;
        };

        github = {
          user = "mikearnaldi";
        };

        init = {
          defaultBranch = "main";
        };

        pull = {
          rebase = "merges";
        };

        push = {
          autoSetupRemote = true;
        };

        url = {
          "git@github.com:" = {
            insteadOf = "https://github.com/";
          };
        };
      };

      lfs = {
        enable = true;
      };
    };
  };
}
