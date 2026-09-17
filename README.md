# Home Server Base 10

[![stable](https://github.com/home-server-project/home-server-base-10/actions/workflows/build-stable.yml/badge.svg?branch=main)](https://github.com/home-server-project/home-server-base-10/actions/workflows/build-stable.yml)
[![testing](https://github.com/home-server-project/home-server-base-10/actions/workflows/build-testing.yml/badge.svg?branch=testing)](https://github.com/home-server-project/home-server-base-10/actions/workflows/build-testing.yml)
[![next](https://github.com/home-server-project/home-server-base-10/actions/workflows/build-next.yml/badge.svg?branch=next)](https://github.com/home-server-project/home-server-base-10/actions/workflows/build-next.yml)

Home Server Base 10 is the common EL10 bootc foundation for Home Server Project systems.

The stable channel is built from AlmaLinux 10 using our own Minimal Plus rootfs composition and provides the production foundation consumed by downstream Home Server Project systems.

## Channels

| Channel | Purpose | Image |
| --- | --- | --- |
| Stable | Production foundation | `ghcr.io/home-server-project/home-server-base-10:stable` |
| Testing | Development and validation | `ghcr.io/home-server-project/home-server-base-10:testing` |
| Next | AlmaLinux Kitten compatibility canary | `ghcr.io/home-server-project/home-server-base-10:next` |

## Image

`ghcr.io/home-server-project/home-server-base-10:stable`

Published images are signed with Cosign. Immutable dated/SHA build tags are also published.

## Downstream projects

- [Home Server Rose](https://github.com/home-server-project/home-server-rose)
- [JustVoxel](https://github.com/home-server-project/justvoxel)
- [Pasiv Black Box](https://github.com/highwaytoit/pasiv-black-box)

Base owns the OS foundation; downstream projects own the appliance-specific features.

## Upstream

Home Server Base is an independent downstream project built using software from AlmaLinux OS. It is not an official AlmaLinux image and is not affiliated with or endorsed by AlmaLinux.
