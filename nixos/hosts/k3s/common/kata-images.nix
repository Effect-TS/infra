{
  lib,
  fetchzip,
  ...
}: let
  version = "3.1.2";
in
  fetchzip {
    name = "kata-images-${version}";
    url = "https://github.com/kata-containers/kata-containers/releases/download/${version}/kata-static-${version}-x86_64.tar.xz";
    sha256 = lib.fakeSha256;
    extraPostFetch = ''
      mv $out/kata/share/kata-containers kata-containers
      rm -r $out
      mkdir -p $out/share
      mv kata-containers $out/share/kata-containers
    '';
  }