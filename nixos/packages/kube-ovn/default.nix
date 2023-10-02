{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
buildGoModule rec {
  pname = "kube-ovn";
  version = "v1.12.0";

  src = fetchFromGitHub {
    owner = "kubeovn";
    repo = "kube-ovn";
    rev = "${version}";
    sha256 = "sha256-fmnfRS/BchUGQRGGzbskAi5d5MP5cedDb4Bxo+MC7TI=";
  };

  vendorSha256 = "sha256-aiADxQP8WfgHxq5QvQ+73WXUG+44+ibFAxENwFI4KVQ=";

  doCheck = false;

  ldflags = [
    "-w"
    "-s"
    "-extldflags '-z now'"
    "-X github.com/kubeovn/kube-ovn/versions.COMMIT=1586141"
    "-X github.com/kubeovn/kube-ovn/versions.VERSION=${version}"
    "-X github.com/kubeovn/kube-ovn/versions.BUILDDATE=2023-08-28_09:26:00"
  ];

  meta = with lib; {
    description = "A Bridge between SDN and Cloud Native (Project under CNCF)";
    homepage = "https://kubeovn.github.io/docs/en";
    license = licenses.asl20;
    platforms = platforms.linux;
  };
}
