## Summary

- Problem: native Windows users who cannot use WSL2 or Docker often end up running OpenClaw directly on the host with no meaningful boundary at all.
- Why it matters: this creates a docs gap for a real user segment and pushes them toward less safe host setups instead of a clearly documented fallback.
- What changed: adds a docs-only Windows hardening fallback based on a dedicated low-privilege user, dedicated workspace/state paths, NTFS ACL allowlists, and verify/rollback steps.
- What did NOT change: no runtime behavior, no config defaults, no sandbox claims, no installer/UI/channel-specific workflow.

## Change Type

- [x] Docs
- [x] Security hardening

## Scope

- [x] Gateway / orchestration
- [x] UI / DX

## Why this is worth taking

This PR is valuable even though it is docs-only:

1. It closes a practical gap between the current recommendation and what some Windows users can actually run.
2. It aligns with the repo's stated focus on UX, docs, and runtime hardening.
3. It gives maintainers a safer fallback to point users to instead of informal Discord-only advice.
4. It is low-risk because it is explicit about limitations and does not change product behavior.

## Linked Issue/PR

- Closes: None
- Related: None

## User-visible / Behavior Changes

- New docs page for native Windows hardening without Docker/WSL.
- New cross-links from existing Windows / sandboxing docs.
- No product behavior change.

## Security Impact

- New permissions/capabilities? `No`
- Secrets/tokens handling changed? `No`
- New/changed network calls? `No`
- Command/tool execution surface changed? `No`
- Data access scope changed? `No`
- Risk + mitigation: this PR is docs-only. The page explicitly states that the approach is weaker than Docker sandboxing and must not be presented as an equivalent security boundary.

## Repro + Verification

### Environment

- OS: Windows 11
- Runtime/container: native PowerShell, no Docker/WSL for the tested flow
- Model/provider: OpenClaw with existing model configuration
- Integration/channel (if any): none required for this doc validation
- Relevant config (redacted): dedicated workspace + dedicated state path

### Steps

1. Create a dedicated local user.
2. Grant NTFS ACL access only to the workspace/state paths.
3. Start OpenClaw under the constrained user with isolated `OPENCLAW_STATE_DIR` / `OPENCLAW_CONFIG_PATH`.
4. Run smoke-test and forbidden-path test.
5. Run rollback commands and confirm cleanup path.

### Expected

- Constrained user can operate inside the intended workspace/state paths.
- Constrained user does not retain broad routine access to unrelated paths that were explicitly denied.
- Rollback steps are clear and reversible.

### Actual

- Validated on the reference Windows implementation using dedicated user + ACL allowlist + rollback flow.

## Evidence

- [x] Trace/log snippets
- [x] Screenshot/recording

Reference implementation and validation material:

- https://github.com/fantasyengineercdream/claw_windowsguide

## Human Verification

- Verified scenarios:
  - dedicated user creation
  - workspace/state ACL grant
  - hardening verification script
  - rollback flow
- Edge cases checked:
  - existing user path
  - missing directory handling
  - explicit limitations if the gateway still runs under the normal user
- What I did **not** verify:
  - every possible Windows edition / enterprise policy environment
  - container-equivalent isolation, which this PR does not claim

## Compatibility / Migration

- Backward compatible? `Yes`
- Config/env changes? `No`
- Migration needed? `No`

## Failure Recovery

- How to disable/revert this change quickly: revert the docs page and link additions.
- Files/config to restore: `docs/gateway/sandboxing.md`, `docs/platforms/windows.md`, and the new doc page.
- Known bad symptoms reviewers should watch for:
  - wording that overstates this as sandbox-equivalent
  - wording that appears to replace WSL2/Docker as the primary recommendation

## Risks and Mitigations

- Risk: users may overestimate the security boundary.
- Mitigation: the guide repeatedly states that this is a weaker host hardening fallback, not a container boundary.

- Risk: reviewers may read this as a proposal to bless native Windows as the default path.
- Mitigation: the PR keeps WSL2 and Docker as the primary recommendation and adds this only as a documented fallback.

## AI-assisted transparency

- AI-assisted: `Yes`
- Testing level: `Human-verified on a working Windows reference setup`
- I understand the change and can explain the threat model, limitations, and rollback flow.
