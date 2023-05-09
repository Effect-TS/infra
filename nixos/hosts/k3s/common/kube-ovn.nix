{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
buildGoModule rec {
  pname = "kube-ovn";
  version = "master";

  src = fetchFromGitHub {
    owner = "mikearnaldi";
    repo = "kube-ovn";
    rev = "${version}";
    sha256 = "sha256-gkrQSDyd5V/XLY/9cRWH5pCZSGDoBjqZ7zwRceNkmT8=";
  };

  vendorSha256 = "sha256-hu23/IN8FN6lSSsgMv2ZBVjvHXWNlnidoNEEuqkMMHE=";

  doCheck = false;

  ldflags = [
    "-w"
    "-s"
    "-extldflags '-z now'"
    "-X github.com/mikearnaldi/kube-ovn/versions.COMMIT=a2b789c"
    "-X github.com/mikearnaldi/kube-ovn/versions.VERSION=v${version}"
    "-X github.com/mikearnaldi/kube-ovn/versions.BUILDDATE=2023-05-09_23:12:00"
  ];

  meta = with lib; {
    description = "A Bridge between SDN and Cloud Native (Project under CNCF)";
    homepage = "https://kubeovn.github.io/docs/en/";
    license = licenses.asl20;
    platforms = platforms.linux;
  };
}
