## Summary

This PR adds a docs-first fallback for native Windows environments where Docker/WSL sandboxing is unavailable or impractical.

It documents a practical host hardening pattern:

- run OpenClaw under a dedicated low-privilege local user
- keep workspace/state in dedicated directories
- apply NTFS ACL allowlists to those directories
- verify and rollback with repeatable PowerShell commands

This is intentionally non-breaking and does not change runtime defaults.

## Why

The current docs recommend WSL2 for Windows and Docker for sandboxing, which is the right default.

However, some Windows users cannot reliably use WSL2 or Docker on their machines. Today, those users often fall back to running OpenClaw directly on the host with no meaningful boundary at all.

This guide gives them a more honest fallback:

- clearly weaker than container sandboxing
- still materially better than running the gateway as an unrestricted day-to-day user

## Scope

This PR only adds documentation and cross-links.

Included:

- a new gateway docs page for Windows no-Docker hardening
- related-doc links from existing sandboxing / Windows docs
- explicit limitations and non-goals

Not included:

- no runtime behavior changes
- no new config defaults
- no claim of container-grade isolation
- no GUI / installer / Feishu-specific workflow

## Validation

The guide was validated against a working Windows reference implementation using:

- dedicated local user
- NTFS ACL allowlist on workspace/state paths
- smoke-test, forbidden-path, and rollback steps

Reference implementation:

- https://github.com/fantasyengineercdream/claw_windowsguide

## Notes for review

The intent is to keep the official recommendation unchanged:

1. Prefer Docker sandboxing when available.
2. Prefer WSL2 for Windows installs.
3. Use this guide only as a documented fallback for native Windows hosts.
