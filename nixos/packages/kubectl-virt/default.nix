{pkgs}: let
  pkg = builtins.trace pkgs.kubevirt pkgs.kubevirt;
in
pkgs.stdenv.mkDerivation {
  name = "kubectl-virt";

  phases = ["installPhase"];

  installPhase = ''
    mkdir -p $out/bin
    ln -sf ${pkgs.kubevirt}/bin/virtctl $out/bin/kubectl-virt
  '';
}
