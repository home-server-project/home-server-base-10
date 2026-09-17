# Home Server Base 10 — Next

[![Build next](https://github.com/home-server-project/home-server-base-10/actions/workflows/build-next.yml/badge.svg?branch=next)](https://github.com/home-server-project/home-server-base-10/actions/workflows/build-next.yml)

Home Server Base 10 is the common EL10 bootc foundation for Home Server Project systems.

The `next` channel is built from AlmaLinux Kitten 10 using our own Minimal Plus rootfs composition. It rebuilds daily to surface upcoming upstream changes early, so compatibility fixes can be documented and validated before normal AlmaLinux 10 needs them.

> [!NOTE]
> `next` is a forward-looking compatibility channel, not the production base for downstream systems.

## Image

`ghcr.io/home-server-project/home-server-base-10:next`

Published images are signed with Cosign. Immutable dated/SHA build tags are also published.

## Downstream projects

- [Home Server Rose](https://github.com/home-server-project/home-server-rose)
- [JustVoxel](https://github.com/home-server-project/justvoxel)
- [Pasiv Black Box](https://github.com/highwaytoit/pasiv-black-box)

Base owns the OS foundation; downstream projects own the appliance-specific features.

## Documentation

- [Upstream compatibility log](docs/upstream-compatibility.md)

## Upstream

Home Server Base is an independent downstream project built using software from AlmaLinux OS. It is not an official AlmaLinux image and is not affiliated with or endorsed by AlmaLinux.
