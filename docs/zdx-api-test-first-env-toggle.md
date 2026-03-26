# ZDX API implementation pattern — test-first env toggle

## Goal

Start all development and smoke tests against **test tenant** by default, with explicit switching to production only when approved.

## Config contract

- `ZDX_ENV=test|prod` (default `test`)
- `ZDX_BASE_URL_TEST`, `ZDX_BASE_URL_PROD`
- `ZDX_CLIENT_ID_TEST`, `ZDX_CLIENT_SECRET_TEST`
- `ZDX_CLIENT_ID_PROD`, `ZDX_CLIENT_SECRET_PROD`
- `ZDX_TOKEN_ENDPOINT_TEST`, `ZDX_TOKEN_ENDPOINT_PROD`

## Runtime behavior

1. Read `ZDX_ENV`; fail closed if unset/invalid.
2. Resolve env-specific values.
3. Log active env and selected base URL host (no secrets).
4. If env is `prod`, require explicit confirmation flag in command/runtime args.

## Security posture

- Keep all access read-only for current phase.
- Store secrets only in approved secret storage or local `.env` (never in docs/repo).
- Add minimal telemetry logs for troubleshooting (status code, endpoint family, timestamp), no token dumps.

## Immediate use

Use this pattern in pilot script and first app scaffold so moving from test to prod is a config change, not code rewrite.

