# Home Server Base 10

[![stable](https://github.com/home-server-project/home-server-base-10/actions/workflows/build-stable.yml/badge.svg?branch=main)](https://github.com/home-server-project/home-server-base-10/actions/workflows/build-stable.yml)
[![testing](https://github.com/home-server-project/home-server-base-10/actions/workflows/build-testing.yml/badge.svg?branch=testing)](https://github.com/home-server-project/home-server-base-10/actions/workflows/build-testing.yml)
[![next](https://github.com/home-server-project/home-server-base-10/actions/workflows/build-next.yml/badge.svg?branch=next)](https://github.com/home-server-project/home-server-base-10/actions/workflows/build-next.yml)

Home Server Base 10 is the common EL10 bootc foundation for Home Server Project systems.

It composes a deliberately small Minimal Plus root filesystem and keeps appliance-specific features in downstream images.

## Channels

| Channel | Upstream | Purpose | Moving tags |
| --- | --- | --- | --- |
| Stable | AlmaLinux 10 | Production foundation | `stable`, `stable-v2` |
| Testing | AlmaLinux 10 | Development and validation before promotion | `testing`, `testing-v2` |
| Next | AlmaLinux Kitten 10 | Forward-looking compatibility canary | `next`, `next-v2` |

The default images follow the normal AlmaLinux 10 x86-64 baseline. The `-v2` images use the AlmaLinux `x86_64_v2` package set for hardware that requires the older x86-64-v2 CPU baseline.

The architecture variants are intentionally published as explicit tags rather than hidden behind one combined tag. Downstream projects can therefore select the required CPU baseline deliberately.

## Build model

All channels use the same Containerfile, finalization logic, identity validation, rechunking, signing, and verification path.

The repository carries both rootfs manifests:

- `almalinux-10-minimal-plus` for Stable and Testing.
- `almalinux-10-kitten-minimal-plus` for Next.

The workflow selects the channel, upstream source, rootfs manifest, and CPU baseline. Channel identity is build metadata rather than a separate branch-specific implementation.

## Promotion model

`next` is used to discover upcoming AlmaLinux Kitten compatibility changes early. Kitten-only work is documented and is not automatically copied into the production base.

Changes intended for production are validated on `testing`. After both Testing architecture jobs pass, the validated source is promoted to `main` through a normal pull request. The Stable workflow then publishes the production images.

This keeps promotion as source promotion instead of manually rebuilding the same change on `main`.

## Images

Moving tags:

- `ghcr.io/home-server-project/home-server-base-10:stable`
- `ghcr.io/home-server-project/home-server-base-10:stable-v2`
- `ghcr.io/home-server-project/home-server-base-10:testing`
- `ghcr.io/home-server-project/home-server-base-10:testing-v2`
- `ghcr.io/home-server-project/home-server-base-10:next`
- `ghcr.io/home-server-project/home-server-base-10:next-v2`

Each workflow also publishes immutable dated/SHA tags.

Published images are signed with Cosign and the workflow verifies the published digest after signing.

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
