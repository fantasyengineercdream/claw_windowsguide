# Feishu Security Checklist

Use this checklist before sharing your deployment publicly.

## 1) Secret Hygiene

- Keep `App Secret` out of Git repositories.
- Keep `App Secret` out of screenshots and docs.
- Rotate `App Secret` immediately if accidental exposure is suspected.

## 2) Minimum Scopes

- Grant only the API scopes you actually use.
- Remove unused scopes after testing.
- Review scopes monthly.

## 3) Callback Verification

- Enable request signature verification on your callback endpoint.
- Validate timestamp/nonce/signature on every callback request.
- Reject requests failing verification.

## 4) Environment Isolation

- Store sensitive values in local config/env only.
- Never hardcode secrets in scripts.
- Use a dedicated low-privilege runtime account when possible.

## 5) Incident Response

- If a secret is leaked:
  - Rotate secret immediately.
  - Invalidate old credentials/tokens.
  - Check access logs for abnormal calls.
  - Re-run this checklist.
