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
    sha256 = lib.fakeSha256;
  };

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/kubectl-ko
    chmod +x $out/bin/kubectl-ko
  '';
}
