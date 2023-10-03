import json
import os
import subprocess

from pathlib import Path

from deploykit import DeployGroup, DeployHost
from invoke import Context, task


ROOT = Path(__file__).parent.resolve()
os.chdir(ROOT)

k3s_host_01 = DeployHost(
    host="213.239.207.149",
    user="root",
    meta={"flake_attr": "k3s-node-01"},
)

k3s_host_02 = DeployHost(
    host="167.235.103.220",
    user="root",
    meta={"flake_attr": "k3s-node-02"},
)

k3s_host_03 = DeployHost(
    host="65.109.94.140",
    user="root",
    meta={"flake_attr": "k3s-node-03"},
)


def deploy_nixos(hosts: list[DeployHost]) -> None:
    group = DeployGroup(hosts)

    res = subprocess.run(
        ["nix", "flake", "metadata", "--json"],  # noqa: S603, S607
        check=True,
        text=True,
        stdout=subprocess.PIPE,
    )

    data = json.loads(res.stdout)
    path = data["path"]

    def deploy(host: DeployHost) -> None:
        target = f"{host.user or 'root'}@{host.host}"
        flake_path = host.meta.get("flake_path", "/etc/nixos")

        host.run_local(
            f"rsync --checksum -vaF --delete -e ssh {path}/ {target}:{flake_path}"
        )

        flake_attr = host.meta.get("flake_attr", "")
        if flake_attr:
            flake_attr = "#" + flake_attr

        build_host = host.meta.get("build_host")
        if build_host:
            build_user = host.meta.get("build_user")
            if build_user:
                build_host = f"{build_user}@{build_host}"

        target_host = host.meta.get("target_host")
        if target_host:
            target_user = host.meta.get("target_user")
            if target_user:
                target_host = f"{target_user}@{target_host}"

        extra_args = host.meta.get("extra_args", [])

        cmd = [
            "nixos-rebuild",
            "switch",
            "--fast",
            "--option",
            "keep-going",
            "true",
            "--option",
            "accept-flake-config",
            "true",
            "--flake",
            f"{flake_path}{flake_attr}",
            *extra_args,
        ]

        if build_host:
            cmd.extend(["--build-host", build_host])

        if target_host:
            cmd.extend(["--target-host", target_host])

        ret = host.run(cmd, check=False)

        # Retry switch if the first time fails
        if ret.returncode != 0:
            host.run(cmd)

    group.run_function(deploy)


def make_relabel_command(selector: str, label: str) -> str:
    return f"kubectl label node -l{selector} {label} --overwrite"


@task
def deploy_k3s(_: Context) -> None:
    # Deploy the server initializing the highly-available cluster first
    deploy_nixos([k3s_host_01])
    # Then deploy the other servers
    deploy_nixos([k3s_host_02, k3s_host_03])


@task
def deploy_kubeovn(_: Context) -> None:
    manifest_path = "/etc/nixos/manifests/kube-ovn"
    output_file = "kubeovn"
    # Relabel the K3s nodes
    k3s_host_01.run(
        make_relabel_command("beta.kubernetes.io/os=linux", "kubernetes.io/os=linux")
    )
    k3s_host_01.run(
        make_relabel_command(
            "node-role.kubernetes.io/control-plane", "kube-ovn/role=master"
        )
    )
    k3s_host_01.run(
        ["kubectl", "kustomize", manifest_path, "--enable-helm", "-o", output_file]
    )
    k3s_host_01.run(["kubectl", "apply", "-f", output_file])
    k3s_host_01.run(["rm", "-f", output_file])


@task
def deploy_multus(_: Context) -> None:
    manifest_path = "/etc/nixos/manifests/multus"
    output_file = "multus"
    k3s_host_01.run(["kubectl", "kustomize", manifest_path, "-o", output_file])
    k3s_host_01.run(["kubectl", "apply", "-f", output_file])
    k3s_host_01.run(["rm", "-f", output_file])


@task
def reset_k3s(_: Context) -> None:
    group = DeployGroup([k3s_host_01, k3s_host_02, k3s_host_03])

    def reset(host: DeployHost) -> None:
        host.run("k3s-reset-node")

    group.run_function(reset)


@task
def update_sops_files(c: Context) -> None:
    """
    Update all sops yaml and json files according to .sops.yaml rules
    """
    c.run(
        """
        find . -regex $(yq -r '[.creation_rules[] // [] | "./" + .path_regex] | join("|")' "$(pwd)/.sops.yaml") | \
        xargs -i sops updatekeys -y {}
        """
    )
