{
  pkgs,
  lib,
  ...
}: {
  home.packages = with pkgs; [
    age
    curl
    dig
    gh
    jq
    moreutils
    unzip
    yq
  ];
}
