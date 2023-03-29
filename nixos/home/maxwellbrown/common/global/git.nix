{...}: {
  programs = {
    git = {
      enable = true;
      userName = "Maxwell Brown";
      userEmail = "maxwellbrown1990@gmail.com";

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

        commit = {
          gpgsign = true;
        };

        core = {
          editor = "nvim -u NONE";
          filemode = false;
          ignorecase = false;
        };

        github = {
          user = "imax153";
        };

        gpg = {
          format = "ssh";
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

        user = {
          signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKJIc1bHUtLpYcNYSQGD8nGFl/G5P3ZmBlM9s3QhDzCU";
        };
      };

      lfs = {
        enable = true;
      };
    };
  };
}
