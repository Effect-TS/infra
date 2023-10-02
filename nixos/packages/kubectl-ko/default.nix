{pkgs}:
pkgs.stdenv.mkDerivation {
  name = "kubectl-ko";
  version = "v1.12.0";

  phases = ["installPhase"];

  src = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/kubeovn/kube-ovn/master/dist/images/kubectl-ko";
    sha256 = "sha256-5MVY2RW9lYo0hiGXVWklgm342GZf6SMgBrRsUDLGq1I=";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/kubectl-ko
    chmod +x $out/bin/kubectl-ko
    sed -i "1 s/.*/#!\/usr\/bin\/env bash/" $out/bin/kubectl-ko
  '';
}
