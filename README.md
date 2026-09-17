# Home Server Base 10 — Testing

[![Build testing](https://github.com/home-server-project/home-server-base-10/actions/workflows/build-testing.yml/badge.svg?branch=testing)](https://github.com/home-server-project/home-server-base-10/actions/workflows/build-testing.yml)

Home Server Base 10 is the common EL10 bootc foundation for Home Server Project systems.

The `testing` channel is built from AlmaLinux 10 using our own Minimal Plus rootfs composition. It is the development and validation channel for changes intended for the stable Home Server Base.

> [!NOTE]
> `testing` is not the production base. Changes are validated here before promotion to `main`.

## Image

`ghcr.io/home-server-project/home-server-base-10:testing`

Published images are signed with Cosign. Immutable dated/SHA build tags are also published.

## Downstream projects

- [Home Server Rose](https://github.com/home-server-project/home-server-rose)
- [JustVoxel](https://github.com/home-server-project/justvoxel)
- [Pasiv Black Box](https://github.com/highwaytoit/pasiv-black-box)

Base owns the OS foundation; downstream projects own the appliance-specific features.

## Upstream

Home Server Base is an independent downstream project built using software from AlmaLinux OS. It is not an official AlmaLinux image and is not affiliated with or endorsed by AlmaLinux.
