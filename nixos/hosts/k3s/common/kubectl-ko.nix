{
  lib,
  fetchFromGitHub,
  buildGoModule,
  pkgs,
}:
pkgs.stdenv.mkDerivation {
  name = "kubectl-ko";
  version = "1.11.3";

  phases = ["installPhase" "patchPhase"];

  src = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/mikearnaldi/kube-ovn/master/dist/images/kubectl-ko";
    sha256 = "sha256-dZ6rKsBOnxzqzIDveg8QGKF80cbCpzvFqy2DunWupcI=";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/kubectl-ko
    chmod +x $out/bin/kubectl-ko
    sed -i "1 s/.*/#!\/usr\/bin\/env bash/" $out/bin/kubectl-ko
  '';
}