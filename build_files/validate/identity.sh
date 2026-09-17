#!/usr/bin/bash
set -euo pipefail

pass() { printf 'PASS  %s\n' "$*"; }
fail() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

OS_RELEASE_USR=/usr/lib/os-release
OS_RELEASE_ETC=/etc/os-release
[[ -r "${OS_RELEASE_USR}" ]] || fail "${OS_RELEASE_USR} is missing"

# shellcheck disable=SC1090
source "${OS_RELEASE_USR}"

[[ "${ID:-}" == "home-server-base" ]] || fail "ID=${ID:-unset}; expected home-server-base"
[[ "${NAME:-}" == "Home Server Base" ]] || fail "NAME=${NAME:-unset}; expected Home Server Base"
[[ "${PRETTY_NAME:-}" == "Home Server Base 10 Testing" ]] || fail "PRETTY_NAME=${PRETTY_NAME:-unset}; expected Home Server Base 10 Testing"
[[ "${VERSION_ID%%.*}" == "10" ]] || fail "VERSION_ID=${VERSION_ID:-unset}; expected EL10 major version"
[[ "${PLATFORM_ID:-}" == "platform:el10" ]] || fail "PLATFORM_ID=${PLATFORM_ID:-unset}; expected platform:el10"

for family in almalinux rhel centos fedora; do
    [[ " ${ID_LIKE:-} " == *" ${family} "* ]] || fail "ID_LIKE=${ID_LIKE:-unset}; missing ${family}"
done

[[ "${VARIANT:-}" == "Testing" ]] || fail "VARIANT=${VARIANT:-unset}; expected Testing"
[[ "${VARIANT_ID:-}" == "testing" ]] || fail "VARIANT_ID=${VARIANT_ID:-unset}; expected testing"
[[ "${IMAGE_ID:-}" == "home-server-base" ]] || fail "IMAGE_ID=${IMAGE_ID:-unset}; expected home-server-base"
[[ "${IMAGE_VERSION:-}" == "10" ]] || fail "IMAGE_VERSION=${IMAGE_VERSION:-unset}; expected 10"
[[ "${VENDOR_NAME:-}" == "Home Server Project" ]] || fail "VENDOR_NAME=${VENDOR_NAME:-unset}; expected Home Server Project"
[[ "${VENDOR_URL:-}" == "https://github.com/home-server-project" ]] || fail "VENDOR_URL=${VENDOR_URL:-unset}"
[[ "${HOME_URL:-}" == "https://github.com/home-server-project/home-server-base-10" ]] || fail "HOME_URL=${HOME_URL:-unset}"
[[ "${SUPPORT_URL:-}" == "https://github.com/home-server-project/home-server-base-10/issues" ]] || fail "SUPPORT_URL=${SUPPORT_URL:-unset}"
[[ "${BUG_REPORT_URL:-}" == "https://github.com/home-server-project/home-server-base-10/issues" ]] || fail "BUG_REPORT_URL=${BUG_REPORT_URL:-unset}"
[[ "${CPE_NAME:-}" == "cpe:/o:home-server-project:home-server-base:10" ]] || fail "CPE_NAME=${CPE_NAME:-unset}"

[[ "${HOME_SERVER_BASE_UPSTREAM_ID:-}" == "almalinux" ]] || fail "upstream ID metadata is not almalinux"
[[ "${HOME_SERVER_BASE_UPSTREAM_VERSION_ID%%.*}" == "10" ]] || fail "upstream VERSION_ID metadata is not AlmaLinux 10"
[[ "${HOME_SERVER_BASE_UPSTREAM_PLATFORM_ID:-}" == "platform:el10" ]] || fail "upstream PLATFORM_ID metadata is not platform:el10"
[[ "${HOME_SERVER_BASE_UPSTREAM_CPE_NAME:-}" == cpe:/o:almalinux:* ]] || fail "upstream CPE metadata does not identify AlmaLinux"
[[ "${HOME_SERVER_BASE_PROFILE:-}" == "almalinux-10-minimal-plus" ]] || fail "base profile metadata is incorrect"
[[ "${HOME_SERVER_BASE_CHANNEL:-}" == "testing" ]] || fail "base channel metadata is not testing"

for key in ALMALINUX_MANTISBT_PROJECT ALMALINUX_MANTISBT_PROJECT_VERSION REDHAT_SUPPORT_PRODUCT REDHAT_SUPPORT_PRODUCT_VERSION SUPPORT_END LOGO; do
    if grep -q "^${key}=" "${OS_RELEASE_USR}"; then
        fail "upstream product field ${key} remains in Home Server Base os-release"
    fi
done

if [[ -e "${OS_RELEASE_ETC}" ]] && ! [[ "${OS_RELEASE_ETC}" -ef "${OS_RELEASE_USR}" ]]; then
    for key in ID NAME PRETTY_NAME VARIANT VARIANT_ID IMAGE_ID IMAGE_VERSION VENDOR_NAME CPE_NAME HOME_SERVER_BASE_UPSTREAM_ID HOME_SERVER_BASE_CHANNEL; do
        usr_value="$(grep -E "^${key}=" "${OS_RELEASE_USR}" | head -n1 || true)"
        etc_value="$(grep -E "^${key}=" "${OS_RELEASE_ETC}" | head -n1 || true)"
        [[ "${usr_value}" == "${etc_value}" ]] || fail "${key} differs between /usr/lib/os-release and /etc/os-release"
    done
fi

pass "Home Server Base 10 Testing identity and AlmaLinux 10 upstream metadata"
printf 'HOME SERVER BASE IDENTITY: PASS\n'
