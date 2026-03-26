# Agent Handoff — ZDX API Auth/Test Status (2026-03-26)

## Goal

Validate ZDX API access in **TEST/UAT** first, determine which auth model is valid for this tenant, then prove at least one successful read endpoint call (`/zdx/v1/devices`).

## Current Situation

- Two credential models exist in the portal:
  - **Legacy API Key** (ZDX-style hashed secret/timestamp flow).
  - **API Client** (OAuth-style `client_credentials` flow).
- Support (Himani) shared:
  - host pattern `api.zsapi.net`
  - token URL `https://api.zsapi.net/zdx/v1/oauth/token`
- Bill shared:
  - TEST/UAT has live data
  - preference guidance from call: API Client in Zidentity is more customizable
  - a TEST API Client ID/Secret was provided and placed in local `.env`
- Latest validated tests show:
  - **Legacy path:** `api.zscalerthree.net` is not resolvable on firm laptop path, so legacy auth cannot proceed there.
  - **API Client/OAuth path:** using vanity `https://kinp.zslogin.net/oauth2/v1/token` with `audience=https://api.zscaler.com` returns token successfully.
  - **Downstream ZDX call still fails:** `GET https://api.zsapi.net/zdx/v1/devices` returns **HTTP 400** with valid vanity-issued token.
  - Conclusion: network + basic credential validity are proven; likely blocker is **scope/resource mapping or token acceptability for ZDX service**.

## Files Added/Updated for Testing

- `scripts/pilot/windows/zdx-smoke.ps1`
  - API Client/OAuth-style diagnostics and token tests
  - optional devices probe
- `scripts/pilot/windows/zdx-smoke-legacy.ps1`
  - legacy hashed-secret token test
  - optional devices probe
- `scripts/pilot/zdx_api_smoke.py`
  - mode-based Python smoke (`legacy`, `api_client`, `himani`, `auto`)
- `.env`
  - structured for test/prod + legacy/api_client
  - `ZDX_AUTH_MODE` currently set to `api_client`

## Most Recent Firm-Laptop Proof (authoritative)

From firm laptop PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File .\zdx-smoke.ps1 -Hours 2
```

Observed:

- `api.zsapi.net` resolves.
- `kinp.zslogin.net` resolves (CNAME to `zs-us1.zslogin.net`).
- Token test:
  - `vanity_oauth` endpoint (`https://kinp.zslogin.net/oauth2/v1/token`) => **SUCCESS**
- Devices probe:
  - `GET https://api.zsapi.net/zdx/v1/devices?from=<ts>&to=<ts>` => **HTTP 400**

This is the current strongest signal and should be included in all support follow-ups.

## What To Run on Firm Laptop (No Admin Needed)

From repo root in PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\pilot\windows\zdx-smoke.ps1 -SkipDevices
powershell -ExecutionPolicy Bypass -File .\scripts\pilot\windows\zdx-smoke.ps1 -Hours 2
powershell -ExecutionPolicy Bypass -File .\scripts\pilot\windows\zdx-smoke-legacy.ps1 -SkipDevices
```

If `.env` is elsewhere:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\pilot\windows\zdx-smoke.ps1 -EnvPath "C:\path\to\.env" -SkipDevices
```

## How to Interpret Results Quickly

- **Token 200 + devices 200**: auth model confirmed, proceed with endpoint/use-case validation.
- **Token 200 + devices 403**: credentials valid but role/scope insufficient for endpoint.
- **Token 401 on OAuth endpoint**: likely credential/flow mismatch, client binding/scope issue, wrong tenant/client context, or wrong token endpoint for this client type.
- **DNS/TLS/proxy errors**: network path issue (not API logic issue).

## Open Questions for Himani/Zscaler

1. For this tenant, do **test** and **prod** both use same OneAPI host/token URL, or is there a separate test host?
2. Exact differences between **API Key** vs **API Client** for ZDX in this environment (recommended model, limits, lifecycle, multiplicity).
3. Confirm canonical token URL and required params for this specific API Client type (we are using vanity `zslogin` + `audience=https://api.zscaler.com` and receiving token successfully).
4. Confirm why vanity-issued token is rejected by ZDX endpoint (`HTTP 400` on `/zdx/v1/devices`) and what additional claims/resource mapping are required.
5. Provide one known-good curl sequence for this exact tenant/client: token call + successful `GET /zdx/v1/devices`.

## Security Notes

- Do not commit `.env` or JSON key dumps.
- Do not paste raw secrets/tokens in chat, tickets, or docs.
- Rotate any credential that was exposed outside secure channels.
