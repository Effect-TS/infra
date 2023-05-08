{
  lib,
  fetchFromGitHub,
  buildGoModule,
  pkgs,
}:
pkgs.stdenv.mkDerivation rec {
  name = "kubectl-ko";
  version = "1.11.3";

  phases = ["installPhase" "patchPhase"];

  src = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/kubeovn/kube-ovn/v1.11.3/dist/images/kubectl-ko";
    sha256 = "sha256-y0qavhhPpkHKuZHhiysmI1v9mkH83KNNYeLc0fgNQ0A=";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/kubectl-ko
    chmod +x $out/bin/kubectl-ko
    sed -i "1 s/.*/#!\/usr\/bin\/env bash/" $out/bin/kubectl-ko
  '';
}
