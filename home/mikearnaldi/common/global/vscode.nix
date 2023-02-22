{...}: {
  imports = [
    "${fetchTarball {
      url = "https://github.com/msteen/nixos-vscode-server/tarball/master";
      sha256 = "1vgq7141mv67r7xgdpgg54hy41kbhlgp3870kyrh6z5fn4zyb74p";
    }}/modules/vscode-server/home.nix"
  ];

  services = {
    vscode-server = {
      enable = true;
    };
  };
}
