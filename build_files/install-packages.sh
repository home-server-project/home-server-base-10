#!/usr/bin/bash
set -eoux pipefail

# Home Server Base 10 common package foundation.
#
# Follow the proven uBlue/Home Server Project image-build pattern:
# - bootstrap repository inputs first;
# - install the Base-owned package set in one transaction;
# - consume Home Server Packages RPM artifacts through /ctx;
# - validate the finished contract once at the end of the image build.

BASE_PACKAGES=(
    bind-utils
    firewalld
    hyperv-daemons
    iperf3
    lsof
    micro
    nano
    NetworkManager-tui
    nmap-ncat
    open-vm-tools
    openssl
    policycoreutils-python-utils
    qemu-guest-agent
    rsync
    systemd-resolved
    tcpdump
    toolbox
    traceroute
)

# AlmaLinux 10 enables CRB in the repository set used by our proven Rose,
# Pasiv Black Box, and JustVoxel builds. EPEL depends on the CRB SELinux split.
if ! dnf repolist --enabled | grep -Eiq '(^|[[:space:]])crb([[:space:]]|$)'; then
    echo "ERROR: AlmaLinux CRB repository is not enabled." >&2
    exit 1
fi

# On normal x86_64 this installs epel-release. On AlmaLinux x86_64_v2 the same
# request resolves to AlmaLinux's supported epel-release-almalinux-altarch
# provider. In both cases it also supplies selinux-policy-extra as a dependency,
# so Base does not redundantly request selinux-policy-extra itself.
dnf install -y epel-release

echo "Installing Home Server Base package set..."
dnf install -y "${BASE_PACKAGES[@]}"

# nm-hsp is produced and validated by home-server-packages. The workflow
# resolves the stable OCI artifact to an immutable digest before this build.
# The same ordinary x86_64 RPM is intentionally consumed by both Base variants.
mapfile -t NM_HSP_RPMS < <(
    find /ctx/nm-hsp-rpms -maxdepth 1 -type f \
        -name 'nm-hsp-*.x86_64.rpm' -print | sort
)

if (( ${#NM_HSP_RPMS[@]} != 1 )); then
    echo "ERROR: expected exactly one verified nm-hsp x86_64 RPM, found ${#NM_HSP_RPMS[@]}." >&2
    printf '%s\n' "${NM_HSP_RPMS[@]}" >&2
    exit 1
fi

rpm_identity="$(rpm -qp --qf '%{NAME}|%{ARCH}\n' "${NM_HSP_RPMS[0]}")"
[[ "${rpm_identity}" == "nm-hsp|x86_64" ]]

dnf install -y "${NM_HSP_RPMS[0]}"

dnf clean all
