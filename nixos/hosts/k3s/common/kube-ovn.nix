{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
buildGoModule rec {
  pname = "kube-ovn";
  version = "1.11.3";

  src = fetchFromGitHub {
    owner = "kubeovn";
    repo = "kube-ovn";
    rev = "v${version}";
    sha256 = "vFgrBnwVcHbkdUqN1oCUTPbKlDFGZ8dBLQ4Umw/4a2E=";
  };

  vendorSha256 = "sha256-EuguNTSKMmNBATkyvLCmgl55Sv5oaoQQXVY+u2xonCM=";

  doCheck = false;

  ldflags = [
    "-w"
    "-s"
    "-extldflags '-z now'"
    "-X github.com/kubeovn/kube-ovn/versions.COMMIT=9fe900f"
    "-X github.com/kubeovn/kube-ovn/versions.VERSION=v${version}"
    "-X github.com/kubeovn/kube-ovn/versions.BUILDDATE=2023-05-06_10:08:08"
  ];

  subPackages = [
    "cmd"
  ];

  meta = with lib; {
    description = "A Bridge between SDN and Cloud Native (Project under CNCF)";
    homepage = "https://kubeovn.github.io/docs/en/";
    license = licenses.asl20;
    platforms = platforms.linux;
  };
}
