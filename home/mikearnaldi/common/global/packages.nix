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
    kubectl
    moreutils
    unzip
    yq
  ];
}
