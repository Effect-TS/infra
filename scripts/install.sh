#!/usr/bin/env bash

set -euo pipefail

DISK1="${}"
DISK2="${}"
SSH_PUB_KEY="${}"
MY_HOSTNAME="${}"
MY_HOSTID="${}"

cat > /etc/apt/preferences.d/90_zfs <<EOF
Package: libnvpair1linux libuutil1linux libzfs2linux libzpool2linux spl-dkms zfs-dkms zfs-test zfsutils-linux zfsutils-linux-dev zfs-zed
Pin: release n=buster-backports
Pin-Priority: 990
EOF

apt update -y
apt install -y dpkg-dev "linux-headers-$(uname -r)" linux-image-amd64 sudo parted zfs-dkms zfsutils-linux

# Prevent mdadm from auto-assembling arrays.
# Otherwise, as soon as we create the partition tables below, it will try to
# re-assemple a previous RAID if any remaining RAID signatures are present,
# before we even get the chance to wipe them.
# From:
#     https://unix.stackexchange.com/questions/166688/prevent-debian-from-auto-assembling-raid-at-boot/504035#504035
# We use `>` because the file may already contain some detected RAID arrays,
# which would take precedence over our `<ignore>`.
echo 'AUTO -all
ARRAY <ignore> UUID=00000000:00000000:00000000:00000000' > /etc/mdadm/mdadm.conf

parted --script --align optimal "/dev/disk/by-id/${DISK1}" -- \
  mklabel gpt \
  mkpart 'BIOS-boot' 1MiB 2MiB set 1 bios_grub on \
  mkpart 'boot' 2MiB 512MiB set 2 esp on \
  mkpart 'zfs-pool' 512MiB '100%'

parted --script --align optimal "/dev/disk/by-id/nvme-SAMSUNG_MZVL2512HCJQ-00B00_S675NE0T501620" -- \
  mklabel gpt \
  mkpart 'BIOS-boot' 1MiB 2MiB set 1 bios_grub on \
  mkpart 'boot' 2MiB 512MiB set 2 esp on \
  mkpart 'data' 512MiB '100%'

mdadm --zero-superblock --force
mdadm --zero-superblock --force

# Reload partitions
partprobe

zpool create -O mountpoint=none \
    -O atime=off \
    -O compression=lz4 \
    -O xattr=sa \
    -O acltype=posixacl \
    -o ashift=12 \
    -f \
    zroot "${DISK1}-part3" "${DISK2}-part3"

zfs create -o mountpoint=legacy zroot/root
zfs create -o mountpoint=legacy zroot/root/nixos
zfs create -o mountpoint=legacy zroot/home
zfs create -o refreservation=1G -o mountpoint=none zroot/reserved
zfs create zroot/longhorn

mount -t zfs zroot/root/nixos /mnt
mkdir /mnt/home
mount -t zfs zroot/home /mnt/home

# Create a raid mirror for the efi boot
# see https://docs.hetzner.com/robot/dedicated-server/operating-systems/efi-system-partition/
# TODO check this though the following article says it doesn't work properly
# https://outflux.net/blog/archives/2018/04/19/uefi-booting-and-raid1/
mdadm --create --run --verbose /dev/md127 \
    --level 1 \
    --raid-disks 2 \
    --metadata 1.0 \
    --homehost=host-01 \
    --name=boot_efi \
    "/dev/disk/by-id/nvme-SAMSUNG_MZVL2512HCJQ-00B00_S675NE0T501629-part2" "/dev/disk/by-id/nvme-SAMSUNG_MZVL2512HCJQ-00B00_S675NE0T501620-part2"

# Assembling the RAID can result in auto-activation of previously-existing LVM
# groups, preventing the RAID block device wiping below with
# `Device or resource busy`. So disable all VGs first.
vgchange -an

# Wipe filesystem signatures that might be on the RAID from some
# possibly existing older use of the disks (RAID creation does not do that).
# See https://serverfault.com/questions/911370/why-does-mdadm-zero-superblock-preserve-file-system-information
wipefs -a /dev/md127

# Disable RAID recovery. We don't want this to slow down machine provisioning
# in the rescue mode. It can run in normal operation after reboot.
echo 0 > /proc/sys/dev/raid/speed_limit_max

# Filesystems (-F to not ask on preexisting FS)
mkfs.vfat -F 32 /dev/md127

# Creating file systems changes their UUIDs.
# Trigger udev so that the entries in /dev/disk/by-uuid get refreshed.
# `nixos-generate-config` depends on those being up-to-date.
# See https://github.com/NixOS/nixpkgs/issues/62444
udevadm trigger

mkdir -p /mnt/boot/efi
mount /dev/md127 /mnt/boot/efi

# Allow installing nix as root, see
#   https://github.com/NixOS/nix/issues/936#issuecomment-475795730
mkdir -p /etc/nix
echo "build-users-group =" > /etc/nix/nix.conf

# warning: installing Nix as root is not supported by this script!
curl -L https://nixos.org/nix/install | sh
set +u +x # sourcing this may refer to unset variables that we have no control over
. "${HOME}/.nix-profile/etc/profile.d/nix.sh"
set -u -x

## TODO

# Follow rest of commands for installing NixOS from here: https://github.com/nix-community/nixos-install-scripts/blob/master/hosters/hetzner-dedicated/zfs-uefi-nvme-nixos.sh.
# Discrepancies will be listed below:

# Use latest NixOS version
nix-channel --add https://nixos.org/channels/nixos-22.11 nixpkgs
nix-channel --update

# Our SSH keys:
# "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPsBd6asppvftBGAxsu2MutHRiFKQIsyMakAheN/2GzK"
# "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEzPT600TtIVU+Ch+sbkB2GuJb+ZScNkOHKhPb6Q8AHv ma@matechs.com"

RESCUE_INTERFACE="eth0"
INTERFACE_DEVICE_PATH="/devices/pci0000:00/0000:00:01.2/0000:02:00.2/0000:20:08.0/0000:29:00.0/net/eth0"
NIXOS_INTERFACE="enp41s0"

IP_V4="213.239.207.149"
IP_V6="2a01:4f8:a0:8485::1"

DEFAULT_GATEWAY="213.239.207.129"

cat > /mnt/etc/nixos/configuration.nix <<EOF
{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use GRUB2 as the boot loader.
  # We don't use systemd-boot because Hetzner uses BIOS legacy boot.
  boot.loader.systemd-boot.enable = false;
  boot.loader.grub = {
    enable = true;
    efiSupport = false;
    devices = ["/dev/disk/by-id/nvme-SAMSUNG_MZVL2512HCJQ-00B00_S675NX0T570867" "/dev/disk/by-id/nvme-SAMSUNG_MZVL2512HCJQ-00B00_S675NX0T570972"];
    copyKernels = true;
  };
  boot.supportedFilesystems = [ "zfs" ];

  networking.hostName = "host-01";
  networking.hostId = "0572b6a9";

  # Network (Hetzner uses static IP assignments, and we don't use DHCP here)
  networking.useDHCP = false;
  networking.interfaces."enp41s0".ipv4.addresses = [
    {
      address = "213.239.207.149";
      prefixLength = 24;
    }
  ];
  networking.interfaces."enp41s0".ipv6.addresses = [
    {
      address = "2a01:4f8:a0:8485::1";
      prefixLength = 64;
    }
  ];
  networking.defaultGateway = "213.239.207.129";
  networking.defaultGateway6 = { address = "fe80::1"; interface = "enp41s0"; };
  networking.nameservers = [ "8.8.8.8" ];

  # Initial empty root password for easy login:
  users.users.root.initialHashedPassword = "";
  services.openssh.permitRootLogin = "prohibit-password";

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPsBd6asppvftBGAxsu2MutHRiFKQIsyMakAheN/2GzK"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEzPT600TtIVU+Ch+sbkB2GuJb+ZScNkOHKhPb6Q8AHv ma@matechs.com"
  ];

  services.openssh.enable = true;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "22.11"; # Did you read the comment?

}
EOF

# https://github.com/nix-community/home-manager/issues/2564#issuecomment-1001050504
export NIX_PATH=${NIX_PATH:+$NIX_PATH:}$HOME/.nix-defexpr/channels:/nix/var/nix/profiles/per-user/root/channels

PATH="$PATH" NIX_PATH="$NIX_PATH" $(which nixos-install) \
  --no-root-passwd --root /mnt --max-jobs 40

nix --extra-experimental-features flakes --extra-experimental-features nix-command shell nixpkgs#speedtest-cli
