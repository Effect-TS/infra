{
  lib,
  fetchFromGitHub,
  buildGoModule,
  pkgs,
}:
pkgs.stdenv.mkDerivation {
  name = "calicoctl";
  version = "latest";

  phases = ["installPhase" "patchPhase"];

  src = pkgs.fetchurl {
    url = "https://github.com/projectcalico/calico/releases/latest/download/calicoctl-linux-amd64";
    sha256 = "0j7yfqqs2kw6qpsqzjjpc33ncfv2dwp75fpk7nlzm7r00i9mwmhk";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/calicoctl
    chmod +x $out/bin/calicoctl
  '';
}
