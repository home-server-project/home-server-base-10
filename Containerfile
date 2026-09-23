ARG ALMA_REPOS_IMAGE=quay.io/almalinuxorg/10-base:10
ARG BOOTC_IMAGECTL_IMAGE=quay.io/centos-bootc/centos-bootc:stream10
ARG ALMA_BUILDER_IMAGE=quay.io/almalinuxorg/10-kitten-base:10-kitten
ARG NM_HSP_IMAGE=ghcr.io/home-server-project/nm-hsp:stable
ARG BASE_MANIFEST=almalinux-10-minimal-plus
ARG BASE_PROFILE=almalinux-10-minimal-plus
ARG IMAGE_CHANNEL=stable

FROM ${ALMA_REPOS_IMAGE} AS repos
FROM ${BOOTC_IMAGECTL_IMAGE} AS imagectl
FROM ${ALMA_BUILDER_IMAGE} AS rootfs-builder
FROM --platform=linux/amd64 ${NM_HSP_IMAGE} AS nm-hsp

ARG BASE_MANIFEST

RUN dnf install -y podman bootc ostree rpm-ostree \
    && dnf clean all

COPY --from=imagectl /usr/share/doc/bootc-base-imagectl/ /usr/share/doc/bootc-base-imagectl/
COPY --from=imagectl /usr/libexec/bootc-base-imagectl /usr/libexec/bootc-base-imagectl
RUN chmod +x /usr/libexec/bootc-base-imagectl

RUN rm -rf /etc/yum.repos.d/*
COPY --from=repos /etc/yum.repos.d/*.repo /etc/yum.repos.d/
COPY --from=repos /etc/pki/rpm-gpg/RPM-GPG-KEY-AlmaLinux-10 /etc/pki/rpm-gpg/

COPY build_files/*.yaml /usr/share/doc/bootc-base-imagectl/manifests/

RUN /usr/libexec/bootc-base-imagectl build-rootfs \
    --reinject \
    --manifest="${BASE_MANIFEST}" \
    /target-rootfs

FROM scratch AS ctx
COPY build_files /build_files

FROM scratch
ARG IMAGE_CHANNEL
ARG BASE_PROFILE
COPY --from=rootfs-builder /target-rootfs/ /

LABEL containers.bootc=1 \
      ostree.bootable=1 \
      org.opencontainers.image.title="Home Server Base 10" \
      org.opencontainers.image.description="Generic EL10 minimal-plus-derived bootc base for Home Server Project systems" \
      org.opencontainers.image.source="https://github.com/home-server-project/home-server-base-10" \
      org.opencontainers.image.vendor="Home Server Project" \
      io.home-server-project.base.generation="10" \
      io.home-server-project.base.profile="${BASE_PROFILE}" \
      io.home-server-project.base.channel="${IMAGE_CHANNEL}"

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=bind,from=nm-hsp,source=/,target=/mnt/nm-hsp \
    --mount=type=tmpfs,dst=/tmp \
    bash /ctx/build_files/install-packages.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    bash /ctx/build_files/install-vpn.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    IMAGE_CHANNEL="${IMAGE_CHANNEL}" \
    BASE_PROFILE="${BASE_PROFILE}" \
    bash /ctx/build_files/finalize-image.sh

RUN /usr/libexec/home-server-base/health/packages \
    && /usr/libexec/home-server-base/health/identity \
    && bootc container lint --fatal-warnings

STOPSIGNAL SIGRTMIN+3
CMD ["/sbin/init"]
