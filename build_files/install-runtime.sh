#!/usr/bin/bash
set -euo pipefail

runtime="${CONTAINER_RUNTIME:-podman}"
case "${runtime}" in
    podman) ;;
    docker)
        # This variant is deliberately restricted to the standard EL10 v3 base.
        [[ "$(rpm -q --qf '%{ARCH}' glibc)" == x86_64 ]]
        # bootc requires Podman. Keep its supported runtime and use crun so
        # Docker's bundled runc does not replace a Podman dependency.
        dnf install -y crun
        if rpm -q toolbox >/dev/null 2>&1; then
            dnf remove -y toolbox
        fi
        curl --fail --location --retry 3 \
            https://download.docker.com/linux/rhel/docker-ce.repo \
            -o /etc/yum.repos.d/docker-ce.repo
        dnf install -y --setopt=install_weak_deps=False \
            docker-ce docker-ce-cli containerd.io \
            docker-buildx-plugin docker-compose-plugin
        systemctl enable docker.service containerd.service
        # bootc can invoke Podman directly without an enabled API listener.
        for unit in podman.socket podman.service; do
            if [[ -f "/usr/lib/systemd/system/${unit}" ]]; then
                systemctl disable "${unit}"
            fi
        done
        ;;
    *) echo "ERROR: unsupported container runtime: ${runtime}" >&2; exit 1 ;;
esac
install -d -m0755 /usr/share/home-server-base
printf '%s\n' "${runtime}" > /usr/share/home-server-base/container-runtime
rpm -q bootc podman >/dev/null
dnf clean all
