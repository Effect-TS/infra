{
  lib,
  fetchFromGitHub,
  buildGoModule,
  pkgs,
}:
buildGoModule rec {
  pname = "kubectl-rook-ceph";
  version = "v0.5.2";

  src = fetchFromGitHub {
    owner = "rook";
    repo = "kubectl-rook-ceph";
    rev = "${version}";
    sha256 = "sha256-fRkC1rr+jFZ6xp1aU1vxqLqW1OTeZgyJPwC+FIeKFcc=";
  };

  vendorSha256 = "sha256-D1k4+1PsBMtGwYVDacrLOSKUhWLOIY/KIooIt7Qo/QE=";

  postInstall = ''
    mv $out/bin/{cmd,kubectl-rook_ceph}
  '';

  doCheck = false;

  meta = with lib; {
    description = "A plugin to run kubectl commands with rook-ceph";
    homepage = "https://github.com/rook/kubectl-rook-ceph/blob/master/README.md";
    license = licenses.asl20;
    platforms = platforms.linux;
  };
}
