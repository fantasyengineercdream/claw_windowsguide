# Suggested upstream file changes

## New file

Add:

- `docs/gateway/windows-no-docker-hardening.md`

## Small link updates

Update:

- `docs/gateway/sandboxing.md`
- `docs/platforms/windows.md`

## Suggested link insertions

### `docs/gateway/sandboxing.md`

Add to the `Related docs` section:

- `[Windows hardening without Docker/WSL](/gateway/windows-no-docker-hardening)`

### `docs/platforms/windows.md`

After the opening section, add a short fallback note:

`If you must run OpenClaw on native Windows without WSL2 or Docker, see [Windows hardening without Docker/WSL](/gateway/windows-no-docker-hardening). This is a host hardening fallback, not a sandbox equivalent.`
