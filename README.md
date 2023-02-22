# NixOS Configurations <!-- omit in toc -->

- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
- [Directory Structure](#directory-structure)
  - [NixOS](#nixos)
  - [Home Manager](#home-manager)
  - [Modules](#modules)
- [Secret Management](#secret-management)
  - [Adding a Public Key](#adding-a-public-key)

## Getting Started

### Prerequisites

This project works best if the following tools are installed:

- [Nix](https://nixos.org/download.html)
- [direnv](https://direnv.net/)

## Directory Structure

The directory structure of this project is optimized for sharing configuration as much as possible.

### NixOS

The `/hosts` directory contains all systems that are managed by NixOS. Each host has its own directory (with the same name as the machine's hostname).

In addition, the `/hosts` directory contains a `/common` subdirectory. This directory contains configuration that can be shared across all hosts. Within the `/common` subdirectory, we have the following:

- `/common/global` -> global configuration that is shared between all hosts
- `/common/presets` -> presets that are applied to specific host types (i.e. `nixos`, `darwin`, `desktop`, etc.)
- `/common/users` -> user-specific configuration that is shared between hosts

### Home Manager

The `/home` directory contains per-user, per-host Home Manager configurations. The directory hierarchy corresponds to the user-specific Home Manager configurations for a particular host.

```
/home/<username>/<hostname>
```

In addition, the `/home` directory contains a `/common` subdirectory. This directory contains Home Manager configurations that can be shared across all hosts. Within the `/common` subdirectory, we have the following:

- `/common/global` -> global configuration that is shared between all hosts
- `/common/presets` -> presets that are applied to specific host types (i.e. `nixos`, `darwin`, `desktop`, etc.)

### Modules

The `/modules` directory contains shared NixOS and Home Manager modules.

## Secret Management

The project uses [`sops-nix`](https://github.com/Mic92/sops-nix) for provisioning secrets. The `sops-nix` tool allows us to store secrets in a Git repository and decrypt them at build time.

The global `sops` configuration can be found in the root of the repository in the `.sops.yaml` file.

### Adding a Public Key

The easiest way to add new machines is by using SSH host keys (this requires OpenSSH to be enabled).

We use `age` to encrypt secrets. To obtain an `age` public key, you can use the `ssh-to-age` tool to convert a host SSH Ed25519 key to the age format.

```bash
nix run nixpkgs#ssh-to-age -- ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub
```

Then add the `age` public key to the `.sops.yaml` file, apply it to the desired key groups, and then re-encrypt the secret files:

```bash
sops updatekeys ./**/secrets.yaml
```
