{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
buildGoModule rec {
  pname = "kube-ovn";
  version = "chore/modifications";

  src = fetchFromGitHub {
    owner = "mikearnaldi";
    repo = "kube-ovn";
    rev = "${version}";
    sha256 = "sha256-Nj5ewMJWKpS5jBMGA6cmVkuzckAndjjOn64uVhhOg1k=";
  };

  vendorSha256 = lib.fakeSha256;

  doCheck = false;

  ldflags = [
    "-w"
    "-s"
    "-extldflags '-z now'"
    "-X github.com/mikearnaldi/kube-ovn/versions.COMMIT=c0125a5"
    "-X github.com/mikearnaldi/kube-ovn/versions.VERSION=${version}"
    "-X github.com/mikearnaldi/kube-ovn/versions.BUILDDATE=2023-11-05_10:08:08"
  ];

  meta = with lib; {
    description = "A Bridge between SDN and Cloud Native (Project under CNCF)";
    homepage = "https://kubeovn.github.io/docs/en/";
    license = licenses.asl20;
    platforms = platforms.linux;
  };
}
