{
  stdenv,
  lib,
  buildGoModule,
  fetchFromGitHub,
  go,
  qemu_kvm,
  makeWrapper,
  yq,
}: let
  yq = buildGoModule rec {
    pname = "yq";
    version = "3.4.1";
    src = fetchFromGitHub {
      owner = "mikefarah";
      repo = "yq";
      rev = version;
      sha256 = lib.faSha256;
    };
    vendorSha256 = lib.faSha256;
  };
in
  buildGoModule rec {
    pname = "kata-runtime";
    version = "3.1.2";

    src = fetchFromGitHub {
      owner = "kata-containers";
      repo = "kata-containers";
      rev = version;
      sha256 = lib.faSha256;
    };

    sourceRoot = "source/src/runtime";

    vendorSha256 = null;

    dontConfigure = true;

    makeFlags = [
      "PREFIX=${placeholder "out"}"
      "DEFAULT_HYPERVISOR=qemu"
      "HYPERVISORS=qemu"
      "QEMUPATH=${qemu_kvm}/bin/qemu-system-x86_64"
    ];

    buildPhase = ''
      runHook preBuild
      mkdir -p $TMPDIR/gopath/bin
      ln -s ${yq}/bin/yq $TMPDIR/gopath/bin/yq
      HOME=$TMPDIR GOPATH=$TMPDIR/gopath make ${toString makeFlags}
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      HOME=$TMPDIR GOPATH=$TMPDIR/gopath make ${toString makeFlags} install
      ln -s $out/bin/containerd-shim-kata-v2 $out/bin/containerd-shim-kata-qemu-v2
      ln -s $out/bin/containerd-shim-kata-v2 $out/bin/containerd-shim-kata-clh-v2

      # qemu images don't work on read-only mounts, we need to put it into a mutable directory
      sed -i \
        -e "s!$out/share/kata-containers!/var/lib/kata-containers!" \
        -e "s!^virtio_fs_daemon.*!virtio_fs_daemon=\"${qemu_kvm}/libexec/virtiofsd\"!" \
        -e "s!^valid_virtio_fs_daemon_paths.*!valid_virtio_fs_daemon_paths=[\"${qemu_kvm}/libexec/virtiofsd\"]!" \
        "$out/share/defaults/kata-containers/"*.toml

      runHook postInstall
    '';

    meta = {
      description = "Container runtime based on lightweight virtual machines";
      homepage = "https://github.com/kata-containers/kata-containers";
      license = lib.licenses.asl20;
      platforms = lib.platforms.unix;
    };
  }