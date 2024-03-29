# Effect Infrastructure <!-- omit in toc -->

- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
- [Directory Structure](#directory-structure)
  - [NixOS](#nixos)
    - [Home Manager](#home-manager)
    - [Modules](#modules)
  - [Terraform](#terraform)
    - [Bootstrapping](#bootstrapping)
    - [GitHub](#github)
  - [Troubleshooting](#troubleshooting)
- [Secret Management](#secret-management)
  - [Updating Secrets](#updating-secrets)
  - [NixOS](#nixos-1)
  - [Terraform](#terraform-1)
  - [Adding a Public Key](#adding-a-public-key)

## Getting Started

### Prerequisites

This project works best if the following tools are installed:

- [Nix](https://nixos.org/download.html)
- [direnv](https://direnv.net/)

If you use `nix` and `direnv` on your host machine, then all required tooling and packages will be automatically installed for you in your development shell.

In addition, this project uses [`pre-commit`](https://pre-commit.com/). If you are not using Nix + `direnv`, you can install the Git hooks manually in your project by installing `pre-commit` and running:

```bash
pre-commit install
```

## Directory Structure

### NixOS

The directory structure of this project is optimized for sharing configuration as much as possible.

The `/hosts` directory contains all systems that are managed by NixOS. Each host has its own directory (with the same name as the machine's hostname).

In addition, the `/hosts` directory contains a `/common` subdirectory. This directory contains configuration that can be shared across all hosts. Within the `/common` subdirectory, we have the following:

- `/common/global` -> global configuration that is shared between all hosts
- `/common/presets` -> presets that are applied to specific host types (i.e. `nixos`, `darwin`, `desktop`, etc.)
- `/common/users` -> user-specific configuration that is shared between hosts

#### Home Manager

The `/home` directory contains per-user, per-host Home Manager configurations. The directory hierarchy corresponds to the user-specific Home Manager configurations for a particular host.

```
/home/<username>/<hostname>
```

In addition, the `/home` directory contains a `/common` subdirectory. This directory contains Home Manager configurations that can be shared across all hosts. Within the `/common` subdirectory, we have the following:

- `/common/global` -> global configuration that is shared between all hosts
- `/common/presets` -> presets that are applied to specific host types (i.e. `nixos`, `darwin`, `desktop`, etc.)

#### Modules

The `/modules` directory contains shared NixOS and Home Manager modules.

### Terraform

For infrastructure that is unable to be maintained by Nix (i.e. external services such as GitHub), we leverage HashiCorp Terraform.

#### Bootstrapping

You can provision the infrastructure in AWS required to host Terraform state using the [`boostrap.sh`](./scripts/bootstrap.sh) script:

```bash
./terraform/scripts/bootstrap.sh --bucket <bucket-name> --region <aws-region> --table <dynamodb-table>
```

#### GitHub

```bash
cd terraform/github
terraform init
terraform plan
```

### Troubleshooting

To lock provider versions for different operating systems / architectures:

```bash
terraform providers lock -platform=linux_amd64 -platform=darwin_amd64 -platform=linux_arm64 -platform=darwin_arm64
```

## Secret Management

This project makes use of [Mozilla SOPS (Secrets OPerationS)](https://github.com/mozilla/sops)

The [`.sops.yaml`](./.sops.yaml) file at the root of the repository defines creation rules for secrets to be encrypted with `sops`. Any files matching the defined creation rule paths will be encrypted with the specified public keys.

### Updating Secrets

To update secret files after making changes to the `.sops.yaml` file, run the snippet below:

```bash
find . -regex $(yq -r '[.creation_rules[] | "./" + .path_regex] | join("\\|")' "$(pwd)/.sops.yaml") | \
xargs -i sops updatekeys -y {}
```

### NixOS

The project uses [`sops-nix`](https://github.com/Mic92/sops-nix) for automatically decrypting and injecting secrets into our NixOS configurations.

### Terraform

The project uses the [`carlpett/sops`] Terraform provider for automatically decrypting and injecting secrets into our Terraform configurations.

### Adding a Public Key

The easiest way to add new machines is by using SSH host keys (this requires OpenSSH to be enabled).

We use `age` to encrypt secrets. To obtain an `age` public key, you can use the `ssh-to-age` tool to convert a host SSH Ed25519 key to the age format.

```bash
nix run nixpkgs#ssh-to-age -- ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub
```

Then add the `age` public key to the `.sops.yaml` file, apply it to the desired key groups, and then re-encrypt the secret files (see [Updating Secrets](#updating-secrets)).
