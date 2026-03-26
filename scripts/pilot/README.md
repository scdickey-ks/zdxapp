# Pilot scripts (minimal dependencies)

- **`zdx_probe.py`** — Python 3 **stdlib only**; reads `ZDX_KEY_ID` / `ZDX_KEY_SECRET` from environment or `../../.env`.
- **`smoke_curl.template.sh`** — copy to `smoke_curl.sh` (gitignored), fill URL per Zscaler docs, run once.
- **`zdx_api_smoke.py`** — deterministic smoke test with explicit auth modes:
  - `legacy` = ZDX API Key flow
  - `api_client` = Zidentity OAuth client flow (`zslogin`)
  - `himani` = support-cited `api.zsapi.net/zdx/v1/oauth/token`
  - `auto` = try preferred `ZDX_AUTH_MODE`, then fallback modes

## Windows quick run (CMD / locked-down laptop)

From repo root:

1) Confirm DNS/network basics:
   - `nslookup api.zsapi.net`
   - `curl -I --max-time 10 https://api.zsapi.net`

2) PowerShell tests (no Python required):
   - API Client / OAuth style:
     - `powershell -ExecutionPolicy Bypass -File .\\scripts\\pilot\\windows\\zdx-smoke.ps1 -SkipDevices`
   - Legacy API key style:
     - `powershell -ExecutionPolicy Bypass -File .\\scripts\\pilot\\windows\\zdx-smoke-legacy.ps1 -SkipDevices`

3) Full test (token + devices list):
   - `powershell -ExecutionPolicy Bypass -File .\\scripts\\pilot\\windows\\zdx-smoke.ps1 -Hours 2`
   - `powershell -ExecutionPolicy Bypass -File .\\scripts\\pilot\\windows\\zdx-smoke-legacy.ps1 -Hours 2`

4) Python mode-based test (if Python is available):
   - `python scripts\\pilot\\zdx_api_smoke.py --mode auto --verbose`

See **[../../docs/pilot-poc.md](../../docs/pilot-poc.md)** for the full pilot playbook.

**Do not commit** `.env`, `smoke_curl.sh`, or any file containing secrets.
