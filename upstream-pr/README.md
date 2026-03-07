# OpenClaw upstream PR kit

This folder contains the smallest practical docs-first PR package for the official `openclaw/openclaw` repository.

## Files

- `PR_TITLE.txt`: suggested PR title
- `PR_BODY.md`: copy-pasteable PR description
- `FILE_PLAN.md`: where the upstream docs changes should go
- `SUBMIT_AND_NOTIFY_CN.md`: how to submit and how to receive GitHub notifications
- `docs/gateway/windows-no-docker-hardening.md`: the new docs page draft

## Why this route

This project is still a standalone Windows distribution project.

What fits upstream cleanly right now is not the whole installer, but the portable part:

- a Windows no-Docker hardening fallback guide
- clear limitations
- reproducible verify / rollback commands

## How to use

1. Fork `openclaw/openclaw`
2. Create a branch
3. Add the docs page from this folder into the official repo
4. Add the two small cross-links listed in `FILE_PLAN.md`
5. Open the PR using `PR_TITLE.txt` and `PR_BODY.md`
