# Upstream Compatibility Log

This document records compatibility changes discovered through the `next` channel before they reach the stable AlmaLinux 10 base.

The purpose is operational: when `testing` or `stable` fails after an upstream change, check this log first for the same error, package, or subsystem. A fix proven on Kitten is a candidate for testing on stable AlmaLinux, not an automatic promotion.

## How to use this log

For each upstream compatibility issue, record:

- Date discovered
- Channel and upstream
- Failure or symptom
- Compatibility action
- Files changed
- Stable AlmaLinux 10 status
- Promotion status
- Removal condition, when applicable
- Relevant commits, workflow runs, and upstream references

When stable AlmaLinux later fails in a similar way:

1. Compare the stable failure with entries here.
2. Reproduce or test the known compatibility action on `testing`.
3. Promote the change only if stable actually requires it and validation passes.
4. Update the entry with the stable result.

---

## 2026-09-17 — Explicit `zstd` runtime dependency

**Channel:** `next`

**Upstream:** AlmaLinux Kitten 10

**Observed failure:** The Kitten Minimal Plus root filesystem composed successfully and the Home Server Base identity checks passed, but final `bootc container lint --fatal-warnings` failed because `zstd` was not present in the completed image.

**Compatibility action:** Added `zstd` explicitly to the Kitten Minimal Plus package manifest.

**Files changed:** `build_files/almalinux-10-kitten-minimal-plus.yaml`

**Result:** The following `next` build passed image composition, fatal bootc lint, rechunking, completed-image validation, GHCR publication, Cosign signing, and Cosign verification.

**Stable AlmaLinux 10 status:** Not required at discovery time. The normal AlmaLinux 10 Minimal Plus image already passed final fatal bootc validation without this explicit package.

**Promotion status:** Kitten-only compatibility change. Do not copy to `testing` or `stable` unless the stable channel later demonstrates the same requirement.

**Removal condition:** Remove the explicit dependency only if a future Kitten build no longer requires it and the completed image passes fatal bootc validation without it.

**References:**

- Failed `next` workflow run: 35277323359
- Fix commit: `ba7c4986de11e6d5969813a917b5f201ad51b797`
- Successful `next` workflow run: 35277796476
