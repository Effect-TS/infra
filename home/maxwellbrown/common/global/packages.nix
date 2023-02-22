{
  pkgs,
  lib,
  ...
}: {
  home.packages = with pkgs; [
    age
    curl
    dig
    jq
    moreutils
    unzip
    yq
  ];
}
