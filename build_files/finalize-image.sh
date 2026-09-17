#!/usr/bin/bash
set -ouex pipefail

: "${IMAGE_CHANNEL:?IMAGE_CHANNEL must be set}"

OS_RELEASE_USR=/usr/lib/os-release
OS_RELEASE_ETC=/etc/os-release

[[ -r "${OS_RELEASE_USR}" ]] || {
    echo "ERROR: ${OS_RELEASE_USR} is missing." >&2
    exit 1
}

# Capture the true upstream foundation before replacing the visible product
# identity. AlmaLinux remains package/platform provenance, not the resulting OS
# product identity.
# shellcheck disable=SC1090
source "${OS_RELEASE_USR}"
BASE_ID="${ID:-}"
BASE_PRETTY_NAME="${PRETTY_NAME:-}"
BASE_VERSION_ID="${VERSION_ID:-}"
BASE_PLATFORM_ID="${PLATFORM_ID:-}"
BASE_CPE_NAME="${CPE_NAME:-}"

[[ "${BASE_ID}" == "almalinux" ]] || {
    echo "ERROR: expected AlmaLinux upstream ID, got '${BASE_ID}'." >&2
    exit 1
}
[[ "${BASE_VERSION_ID%%.*}" == "10" ]] || {
    echo "ERROR: expected AlmaLinux major version 10, got '${BASE_VERSION_ID}'." >&2
    exit 1
}
[[ "${BASE_PLATFORM_ID}" == "platform:el10" ]] || {
    echo "ERROR: expected platform:el10, got '${BASE_PLATFORM_ID}'." >&2
    exit 1
}
[[ "${IMAGE_CHANNEL}" == "testing" ]] || {
    echo "ERROR: testing branch must build IMAGE_CHANNEL=testing, got '${IMAGE_CHANNEL}'." >&2
    exit 1
}

OS_RELEASE_FILES=("${OS_RELEASE_USR}")
if [[ -e "${OS_RELEASE_ETC}" ]] && ! [[ "${OS_RELEASE_ETC}" -ef "${OS_RELEASE_USR}" ]]; then
    OS_RELEASE_FILES+=("${OS_RELEASE_ETC}")
fi

osr_set() {
    local key="$1" value="$2" file
    for file in "${OS_RELEASE_FILES[@]}"; do
        sed -i "/^${key}=/d" "${file}"
        printf '%s="%s"\n' "${key}" "${value}" >> "${file}"
    done
}

osr_unset() {
    local key="$1" file
    for file in "${OS_RELEASE_FILES[@]}"; do
        sed -i "/^${key}=/d" "${file}"
    done
}

osr_set NAME "Home Server Base"
osr_set PRETTY_NAME "Home Server Base 10 Testing"
osr_set ID "home-server-base"
osr_set ID_LIKE "almalinux rhel centos fedora"
osr_set VERSION "${BASE_VERSION_ID}"
osr_set VARIANT "Testing"
osr_set VARIANT_ID "testing"
osr_set IMAGE_ID "home-server-base"
osr_set IMAGE_VERSION "10"
osr_set HOME_URL "https://github.com/home-server-project/home-server-base-10"
osr_set DOCUMENTATION_URL "https://github.com/home-server-project/home-server-base-10"
osr_set SUPPORT_URL "https://github.com/home-server-project/home-server-base-10/issues"
osr_set BUG_REPORT_URL "https://github.com/home-server-project/home-server-base-10/issues"
osr_set VENDOR_NAME "Home Server Project"
osr_set VENDOR_URL "https://github.com/home-server-project"
osr_set CPE_NAME "cpe:/o:home-server-project:home-server-base:10"

# Preserve exact upstream provenance under Home Server Project-owned fields.
osr_set HOME_SERVER_BASE_UPSTREAM_ID "${BASE_ID}"
osr_set HOME_SERVER_BASE_UPSTREAM_PRETTY_NAME "${BASE_PRETTY_NAME}"
osr_set HOME_SERVER_BASE_UPSTREAM_VERSION_ID "${BASE_VERSION_ID}"
osr_set HOME_SERVER_BASE_UPSTREAM_PLATFORM_ID "${BASE_PLATFORM_ID}"
osr_set HOME_SERVER_BASE_UPSTREAM_CPE_NAME "${BASE_CPE_NAME}"
osr_set HOME_SERVER_BASE_PROFILE "almalinux-10-minimal-plus"
osr_set HOME_SERVER_BASE_CHANNEL "${IMAGE_CHANNEL}"

# These fields identify/support the upstream AlmaLinux product itself and must
# not describe this modified downstream image.
for key in \
    ALMALINUX_MANTISBT_PROJECT \
    ALMALINUX_MANTISBT_PROJECT_VERSION \
    REDHAT_SUPPORT_PRODUCT \
    REDHAT_SUPPORT_PRODUCT_VERSION \
    SUPPORT_END \
    LOGO; do
    osr_unset "${key}"
done

chmod 0644 "${OS_RELEASE_FILES[@]}"

install -d -m0755 /usr/libexec/home-server-base/health
install -m0755 /ctx/build_files/validate/identity.sh \
    /usr/libexec/home-server-base/health/identity

# Keep only the minimal bootc /var skeleton. Runtime state belongs to deployed
# machines, not this immutable base image.
dnf clean all
rm -rf /var
install -d -m0755 /var
install -d -m1777 /var/tmp
test "$(stat -c '%a %U %G' /var/tmp)" = "1777 root root"
