# Pilot / PoC — quick visibility (interface-flap feasibility)

Goal: **prove the read-only API key works** and **see what JSON the API returns** for device/path/session-ish endpoints—**before** investing in a full app, Windows tooling fixes, or AVD.

## Pilot model (what “pilot” means here)

| Aspect | Approach |
|--------|----------|
| **Credential** | Existing **ZDX API key** (Key ID + Secret) — **read-only** role. |
| **Scope** | **Time-boxed** exploration; **no production alerting** until firm-approved hosting. |
| **Machine** | **Windows `curl`** (your build has `-u` for Basic auth) is enough for Step 1—no Python needed. **Mac/Linux** remains an option if Windows is blocked for other reasons—same caveats as [`risk-posture-and-scope.md`](./risk-posture-and-scope.md) §4 for **personal** machines. |
| **Success** | HTTP **200** + JSON body from **one** documented endpoint; then **second** call that might relate to **connectivity/path/device** (for flap hypothesis). |

## Syncing the project (NAS)

- Sync **code + docs** via NAS is fine.
- **Do not** rely on NAS for secrets: keep **`.env` only on the machine that runs the pilot**, or copy **once** over a private channel. If NAS is shared/backed up broadly, **don’t place `.env` there**.
- After PoC, if the key touched a personal machine, ask Bill/InfoSec whether to **rotate** the key.

## Why Windows might be “failing” on open project

Common causes: **Python extension** / **Node** install from Cursor trying to write to a locked path, corporate **AppLocker**, or **OneDrive** sync locks. **Pilot does not require opening the project in Cursor**—**Command Prompt or PowerShell + `curl`** on Windows is enough once you have a real URL from docs.

## Step 0 — Confirm auth shape (5 min)

Keys from **ZDX Admin → API Key Management** may use a different scheme than **OneAPI / ZIdentity OAuth**. Check:

- [Understanding ZDX API](https://help.zscaler.com/legacy-apis/understanding-zdx-api) (legacy)
- Your **v2** / 2026 release docs + **Automation Hub** auth pages if you move to token-based APIs

You need **one working example** from Zscaler: **URL + how Key ID and Secret are sent** (Basic auth, `Authorization: Bearer`, custom headers, etc.).

## Step 1 — `curl` smoke test (fastest)

On **Mac/Linux**, in a terminal:

```bash
cd /path/to/ZDXApp/scripts/pilot
# Export vars (or: source a local file you never commit — do not paste secrets into chat)
export ZDX_KEY_ID="your-key-id"
export ZDX_KEY_SECRET="your-secret"

# EXAMPLE ONLY — replace URL and -u / headers per Zscaler docs for YOUR key type:
# curl -sS -u "$ZDX_KEY_ID:$ZDX_KEY_SECRET" "https://REPLACE_WITH_HOST_FROM_DOCS/v2/REPLACE_PATH" | head -c 2000
```

If you get **401**, auth or host is wrong. If **200** + JSON, pilot is **green**.

### Step 1b — Windows (Command Prompt)

```cmd
set ZDX_KEY_ID=your-key-id
set ZDX_KEY_SECRET=your-secret
curl -sS -u "%ZDX_KEY_ID%:%ZDX_KEY_SECRET%" -H "Accept: application/json" "https://REPLACE_HOST_AND_PATH_FROM_DOCS"
```

If the secret contains **`&` `<` `>` `|`** or spaces, use **PowerShell** below or put credentials in a file only you can read—**don’t** paste secrets into run history on shared machines.

### Step 1b — Windows (PowerShell)

```powershell
$env:ZDX_KEY_ID = "your-key-id"
$env:ZDX_KEY_SECRET = "your-secret"
curl.exe -sS -u "$($env:ZDX_KEY_ID):$($env:ZDX_KEY_SECRET)" -H "Accept: application/json" "https://REPLACE_HOST_AND_PATH_FROM_DOCS"
```

Add **`-i`** to see response headers; **`-v`** for TLS/debug (avoid logging full `-v` output if it might capture auth).

## Step 2 — Python probe (no `pip` required)

Uses **stdlib only** (no `requests`, no `venv` strictly required if system `python3` exists):

```bash
cd /path/to/ZDXApp/scripts/pilot
# Put ZDX_KEY_ID and ZDX_KEY_SECRET in ../../.env OR export them
python3 zdx_probe.py
```

Edit **`zdx_probe.py`** top: set `PILOT_URL` to the **exact** URL from docs after Step 0. Adjust **`build_request`** if docs say something other than HTTP Basic.

## Step 3 — Toward “interface flap” (after Step 1 works)

1. List **device** or **session** or **deep trace** endpoints in v2 docs (Bill’s release summary).
2. Pull **one device** with history or metrics if the API allows.
3. **Document** field names and timestamps—**no need** to detect flaps yet; **visibility** is the win.

## If scripting tools are blocked everywhere

- **Postman** (if allowed) on a firm machine with the same key—import from [Automation Hub Postman examples](https://automate.zscaler.com/docs/tools/postman/example-request-zdx-api) if applicable.
- Ask Bill for **one** sanctioned **example request** (redacted) for your tenant.

## Summary

| You have now | Pilot mechanism |
|--------------|-----------------|
| API key | **curl** or **stdlib Python** against **one documented URL** |
| No Windows tooling | Run on **Mac/Linux**; sync repo via NAS, **not** `.env` |
| One use case | After auth works, aim API calls at **device/path**-related endpoints and **record** whether flap-like signals exist |

---

*Update this doc once you record the real base URL and auth header pattern for your tenant.*
