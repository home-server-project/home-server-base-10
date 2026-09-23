#!/usr/bin/bash
set -ouex pipefail

# Home Server Base 10 owns the shared EL10 VPN client layer. Downstream EL10
# appliances inherit these clients instead of reinstalling or overriding them.

# ---------------------------------------------------------------------------
# Tailscale
# ---------------------------------------------------------------------------
# Use Tailscale's official EL10 repository. Keep the repo disabled in deployed
# images so VPN client updates arrive through normal image rebuilds.
curl -fsSL \
    https://pkgs.tailscale.com/stable/rhel/10/tailscale.repo \
    -o /etc/yum.repos.d/tailscale.repo
sed -ri 's/^enabled=1/enabled=0/' /etc/yum.repos.d/tailscale.repo || true

dnf --enablerepo=tailscale-stable install -y tailscale

# Match normal Tailscale host behavior: the daemon is enabled at boot but the
# image carries no account enrollment or connection state.
systemctl enable tailscaled.service

# ---------------------------------------------------------------------------
# NetBird
# ---------------------------------------------------------------------------
# NetBird's RPM post-install tries to install and start its systemd service.
# Starting a live daemon during OCI/bootc composition is wrong, so install the
# RPM payload without scriptlets and then use NetBird's supported service
# installer in systemd offline mode. This installs and enables the unit without
# starting the daemon in the build environment.
cat > /etc/yum.repos.d/netbird.repo <<'REPO'
[netbird]
name=NetBird
baseurl=https://pkgs.netbird.io/yum/
enabled=0
gpgcheck=1
gpgkey=https://pkgs.netbird.io/yum/repodata/repomd.xml.key
repo_gpgcheck=1
REPO

dnf --setopt=tsflags=noscripts --enablerepo=netbird install -y netbird
SYSTEMD_OFFLINE=1 netbird service install

# Package, command, service, enablement, and no-enrollment-state validation is
# intentionally centralized in the final Base contract test.
