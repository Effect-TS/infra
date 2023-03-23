{...}: {
  users = {
    mutableUsers = false;
    users = {
      github-runner = {
        description = "GitHub Runner";
        isNormalUser = true;
        extraGroups = ["docker"];
      };
    };
  };
}
