{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
buildGoModule rec {
  pname = "multus-cni";
  version = "4.0.1";

  src = fetchFromGitHub {
    owner = "k8snetworkplumbingwg";
    repo = "multus-cni";
    rev = "v${version}";
    sha256 = "AYFECNwoajd4mGAwNnFSBhfXjLfmJEtt1Iuv1xyMqbY=";
  };

  subPackages = ["multus"];

  vendorSha256 = lib.fakeSha256;

  doCheck = false;

  ldflags = [
    "-w"
    "-s"
    "-extldflags '-z now'"
    "-X github.com/k8snetworkplumbingwg/multus-cni/versions.COMMIT=s1061123"
    "-X github.com/k8snetworkplumbingwg/multus-cni/versions.VERSION=v${version}"
    "-X github.com/k8snetworkplumbingwg/multus-cni/versions.BUILDDATE=2023-05-06_10:08:08"
  ];

  meta = with lib; {
    description = "A CNI meta-plugin for multi-homed pods in Kubernetes";
    homepage = "https://github.com/k8snetworkplumbingwg/multus-cni";
    license = licenses.asl20;
    platforms = platforms.linux;
  };
}
