# Home Server Base 10

[![stable](https://github.com/home-server-project/home-server-base-10/actions/workflows/build-stable.yml/badge.svg?branch=main)](https://github.com/home-server-project/home-server-base-10/actions/workflows/build-stable.yml)
[![testing](https://github.com/home-server-project/home-server-base-10/actions/workflows/build-testing.yml/badge.svg?branch=testing)](https://github.com/home-server-project/home-server-base-10/actions/workflows/build-testing.yml)
[![next](https://github.com/home-server-project/home-server-base-10/actions/workflows/build-next.yml/badge.svg?branch=next)](https://github.com/home-server-project/home-server-base-10/actions/workflows/build-next.yml)

Home Server Base 10 is the common EL10 bootc foundation for Home Server Project systems.

It composes a deliberately small Minimal Plus root filesystem and keeps appliance-specific features in downstream images.

## Image matrix

All images use the repository `ghcr.io/home-server-project/home-server-base-10`. Append the tag below to select the channel, application container runtime, and CPU baseline.

| Channel | Upstream base | Application runtime | Minimum CPU baseline | Image tag |
| --- | --- | --- | --- | --- |
| Stable | AlmaLinux 10 | Podman | x86-64-v3 | `stable` |
| Stable | AlmaLinux 10 | Podman | x86-64-v2 | `stable-v2` |
| Stable | AlmaLinux 10 | Docker | x86-64-v3 | `stable-docker` |
| Testing | AlmaLinux 10 | Podman | x86-64-v3 | `testing` |
| Testing | AlmaLinux 10 | Podman | x86-64-v2 | `testing-v2` |
| Testing | AlmaLinux 10 | Docker | x86-64-v3 | `testing-docker` |
| Next | AlmaLinux Kitten 10 | Podman | x86-64-v3 | `next` |
| Next | AlmaLinux Kitten 10 | Podman | x86-64-v2 | `next-v2` |
| Next | AlmaLinux Kitten 10 | Docker | x86-64-v3 | `next-docker` |

Stable is the production foundation. Testing validates changes before promotion. Next is the forward-looking Kitten compatibility channel. Each workflow publishes its configured tags only after a successful build and validation.

The `-v2` images use AlmaLinux's `x86_64_v2` package set for older hardware. CPU and runtime variants have explicit tags rather than one combined tag. Docker variants are v3-only; there are no Docker v2 tags.

Docker variants include Docker Engine, CLI, containerd, Compose, and Buildx. Docker and containerd start automatically at boot. Toolbox is excluded. Podman remains installed because bootc requires it, with its system API service and socket disabled.

Existing Podman containers and Quadlets are not automatically converted when switching to a Docker variant. Move workloads explicitly and back up their persistent data before switching.

Each workflow also publishes immutable dated/SHA tags. Published images are signed with Cosign, and the workflow verifies the published digest after signing.

## Build model

All channels use the same Containerfile, finalization logic, identity validation, rechunking, signing, and verification path.

The repository carries both rootfs manifests:

- `almalinux-10-minimal-plus` for Stable and Testing.
- `almalinux-10-kitten-minimal-plus` for Next.

The workflow selects the channel, upstream source, rootfs manifest, application container runtime, and CPU baseline. Channel identity is build metadata rather than a separate branch-specific implementation.

## Promotion model

`next` is used to discover upcoming AlmaLinux Kitten compatibility changes early. Kitten-only work is documented and is not automatically copied into the production base.

Changes intended for production are validated on `testing`. After all Testing runtime and CPU variant jobs pass, the validated source is promoted to `main` through a normal pull request. The Stable workflow then publishes the production images.

This keeps promotion as source promotion instead of manually rebuilding the same change on `main`.

## Shared VPN foundation

Home Server Base 10 provides the common EL10 Tailscale and NetBird clients for downstream Home Server Project appliances.

Both system services are installed and enabled for normal boot-time availability, but the base image contains no VPN account enrollment, authentication keys, or connection state. Deployment-specific identity is configured after installation.

Tailscale uses the official Tailscale EL10 package repository. NetBird uses the official NetBird package repository and its own supported service installer; the daemon is not started during OCI/bootc image composition.

## Downstream projects

- [Home Server Rose](https://github.com/home-server-project/home-server-rose)
- [JustVoxel](https://github.com/home-server-project/justvoxel)
- [Pasiv Black Box](https://github.com/highwaytoit/pasiv-black-box)

Base owns the shared OS foundation; downstream projects own appliance-specific features.

## Documentation

- [Upstream compatibility log](docs/upstream-compatibility.md)

## Upstream

Home Server Base is an independent downstream project built using software from AlmaLinux OS. It is not an official AlmaLinux image and is not affiliated with or endorsed by AlmaLinux.
