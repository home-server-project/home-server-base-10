#!/usr/bin/bash
set -euo pipefail

# One authoritative final package-contract validation for Home Server Base 10.
# This runs only after package installation, VPN installation, finalization,
# and cleanup are complete.

CONTRACT_PACKAGES=(
    bind-utils
    curl
    file
    firewalld
    iperf3
    jq
    lsof
    nano
    NetworkManager
    NetworkManager-tui
    nmap-ncat
    openssh-server
    openssl
    policycoreutils-python-utils
    qemu-guest-agent
    rsync
    selinux-policy-extra
    sudo
    systemd-resolved
    tcpdump
    traceroute
    zram-generator
    open-vm-tools
    hyperv-daemons
    toolbox
    micro
    nm-hsp
    tailscale
    netbird
)

for package in "${CONTRACT_PACKAGES[@]}"; do
    if ! rpm -q "${package}" >/dev/null; then
        echo "ERROR: required package is missing: ${package}" >&2
        exit 1
    fi
done

# epel-release is a capability contract. AlmaLinux x86_64_v2 intentionally
# implements it with epel-release-almalinux-altarch.
rpm -q --whatprovides epel-release >/dev/null

glibc_arch="$(rpm -q --qf '%{ARCH}\n' glibc | head -n1)"
case "${glibc_arch}" in
    x86_64)
        rpm -q epel-release >/dev/null
        ;;
    x86_64_v2)
        rpm -q epel-release-almalinux-altarch >/dev/null
        ;;
    *)
        echo "ERROR: unsupported RPM architecture for EPEL validation: ${glibc_arch}" >&2
        exit 1
        ;;
esac

test -x /usr/bin/nm-hsp
rpm -q --qf '%{ARCH}\n' nm-hsp | grep -Fqx x86_64

command -v tailscale >/dev/null
command -v netbird >/dev/null

test -f /usr/lib/systemd/system/tailscaled.service
test -f /etc/systemd/system/netbird.service

test "$(systemctl is-enabled tailscaled.service)" = "enabled"
test "$(systemctl is-enabled netbird.service)" = "enabled"

# Base owns the complete generic systemd-resolved runtime contract.
test "$(systemctl is-enabled systemd-resolved.service)" = "enabled"

test -f /etc/NetworkManager/conf.d/90-systemd-resolved.conf
grep -Fqx '[main]' /etc/NetworkManager/conf.d/90-systemd-resolved.conf
grep -Fqx 'dns=systemd-resolved' /etc/NetworkManager/conf.d/90-systemd-resolved.conf

test -f /usr/lib/tmpfiles.d/home-server-base-resolved.conf
grep -Fqx 'L+ /etc/resolv.conf - - - - /run/systemd/resolve/stub-resolv.conf' \
    /usr/lib/tmpfiles.d/home-server-base-resolved.conf

# Base owns one shared dynamic zram-generator policy for all downstream images.
test -f /etc/systemd/zram-generator.conf
grep -Fqx '[zram0]' /etc/systemd/zram-generator.conf
if grep -Eq '^[[:space:]]*zram-size[[:space:]]*=' /etc/systemd/zram-generator.conf; then
    echo "ERROR: Base zram policy must use zram-generator dynamic sizing." >&2
    exit 1
fi

# Base images carry the clients and enabled services, but no deployment
# identity or enrollment state.
test ! -e /var/lib/tailscale/tailscaled.state
test ! -e /var/lib/netbird/config.json

echo "Validated Home Server Base package contract: 27 base requirements plus Tailscale and NetBird."
