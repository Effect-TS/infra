{
  pkgs,
  lib,
  ...
}: {
  home.packages = with pkgs; [
    age
    curl
    dig
    git
    jq
    moreutils
    unzip
    yq
  ];
}
