#!/usr/bin/bash
set -eoux pipefail

# Home Server Base 10 common package foundation.
#
# Follow the uBlue image-build pattern:
# - distribution packages are installed in bulk from their normal repositories;
# - packages that require a different source are handled in isolated sections;
# - the finished image is validated once after all image changes are complete.

ALMA_PACKAGES=(
    bind-utils
    firewalld
    hyperv-daemons
    iperf3
    lsof
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

echo "Installing Home Server Base AlmaLinux packages..."
dnf install -y "${ALMA_PACKAGES[@]}"

# selinux-policy-extra is shipped by AlmaLinux CRB. Keep CRB disabled in the
# resulting image and enable it only for this transaction.
dnf --enablerepo=crb install -y selinux-policy-extra

# EPEL is part of the Base contract. On AlmaLinux x86_64_v2, DNF resolves the
# epel-release capability to AlmaLinux's supported altarch provider.
dnf install -y epel-release

# micro is intentionally sourced from EPEL after the EPEL release package is
# installed.
dnf install -y micro

# nm-hsp is produced by home-server-packages and consumed as a verified OCI
# package artifact. The same ordinary x86_64 RPM is used on x86_64 and
# x86_64_v2 Home Server Base images.
NM_HSP_ROOT=/mnt/nm-hsp

test -r "${NM_HSP_ROOT}/metadata/SHA256SUMS"
test -r "${NM_HSP_ROOT}/metadata/rpm-sha256.txt"
test -r "${NM_HSP_ROOT}/metadata/package.env"

(
    cd "${NM_HSP_ROOT}"
    sha256sum -c metadata/SHA256SUMS
    sha256sum -c metadata/rpm-sha256.txt
)

# shellcheck disable=SC1091
source "${NM_HSP_ROOT}/metadata/package.env"
[[ "${PACKAGE}" == "nm-hsp" ]]
[[ ",${ARCHITECTURES}," == *",x86_64,"* ]]

mapfile -t NM_HSP_RPMS < <(
    find "${NM_HSP_ROOT}/rpms" -maxdepth 1 -type f \
        -name 'nm-hsp-*.x86_64.rpm' -print | sort
)

if (( ${#NM_HSP_RPMS[@]} != 1 )); then
    echo "ERROR: expected exactly one nm-hsp x86_64 RPM, found ${#NM_HSP_RPMS[@]}." >&2
    printf '%s\n' "${NM_HSP_RPMS[@]}" >&2
    exit 1
fi

rpm_identity="$(rpm -qp --qf '%{NAME}|%{ARCH}\n' "${NM_HSP_RPMS[0]}")"
[[ "${rpm_identity}" == "nm-hsp|x86_64" ]]

dnf install -y "${NM_HSP_RPMS[0]}"

dnf clean all
