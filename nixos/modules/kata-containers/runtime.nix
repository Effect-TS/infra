{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;

  cfg = config.modules.kata-containers;

  kata-runtime = pkgs.buildGoModule rec {
    pname = "kata-runtime";
    version = cfg.version;

    src = pkgs.fetchFromGitHub {
      owner = "kata-containers";
      repo = "kata-containers";
      rev = version;
      sha256 = "sha256-nzXLqnNrYHZSbu+PX0x7GlleeAfCRGvirj7GGcvdaRU=";
    };

    sourceRoot = "source/src/runtime";

    vendorSha256 = null;

    dontConfigure = true;

    buildInputs = [pkgs.yq-go];

    makeFlags = [
      "PREFIX=${placeholder "out"}"
      "DEFAULT_HYPERVISOR=qemu"
      "HYPERVISORS=qemu"
      "QEMUPATH=${pkgs.qemu_kvm}/bin/qemu-system-x86_64"
    ];

    buildPhase = ''
      runHook preBuild
      HOME=$TMPDIR make ${toString makeFlags}
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      HOME=$TMPDIR make ${toString makeFlags} install
      ln -s $out/bin/containerd-shim-kata-v2 $out/bin/containerd-shim-kata-qemu-v2
      # qemu images don't work on read-only mounts, we need to put it into a mutable directory
      sed -i \
        -e "s!$out/share/kata-containers!/var/lib/kata-containers!" \
        -e "s!^virtio_fs_daemon.*!virtio_fs_daemon=\"${pkgs.virtiofsd}/bin/virtiofsd\"!" \
        -e "s!^valid_virtio_fs_daemon_paths.*!valid_virtio_fs_daemon_paths=[\"${pkgs.virtiofsd}/bin/virtiofsd\"]!" \
        "$out/share/defaults/kata-containers/"*.toml
      runHook postInstall
    '';

    meta = {
      description = "Container runtime based on lightweight virtual machines";
      homepage = "https://github.com/kata-containers/kata-containers";
      license = lib.licenses.asl20;
      platforms = lib.platforms.unix;
    };
  };
in
  mkIf cfg.enable {
    systemd.services.containerd = {
      path = [kata-runtime];
    };
  }
