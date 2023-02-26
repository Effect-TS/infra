{...}: {
  imports = [
    "${fetchTarball {
      url = "https://github.com/msteen/nixos-vscode-server/tarball/master";
      sha256 = "0ahgyd2swkapimvf70ah2y55wpn2hdh1wymfh6492xrkv5x91sqz";
    }}/modules/vscode-server/home.nix"
  ];

  services = {
    vscode-server = {
      enable = true;
    };
  };
}
