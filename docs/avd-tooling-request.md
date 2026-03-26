# AVD / VM — **master tooling request** (submit once)

**Purpose:** One consolidated list for **Risk Management / IT** so you avoid repeated “can you also install…” tickets.  
**Project:** ZDX **read-only** API integration — proactive **network/interface** health signals → internal alerts (webhook; ServiceLater optional). **No client or matter data.**

**Routing (Bill Verdon):** Generic request → assign **Risk Management**; note **collaboration with Bill Verdon** on ZDX.

**Do not put API keys or secrets in this document.**

---

## Cover text (paste into ticket)

> Request provisioning of a **dedicated Azure Virtual Desktop (AVD)** session (or approved managed VM) for **ZDX API integration development**, sponsored in coordination with **Bill Verdon**. Please approve/install the items in the attached **master tooling list** in one pass where possible. Outbound **HTTPS to Zscaler ZDX API** endpoints and **CLI proxy/certificate** configuration are required for API testing (corporate laptops often hang on `curl` without proxy—same may apply until configured).

---

## 1. Core runtime & version control

| Item | Request | Why |
|------|---------|-----|
| **Git for Windows** | Latest stable; include **Git Credential Manager** | Clone/push project; Entra-backed auth if standard |
| **Python** | **64-bit Python 3.11 or 3.12**; “Add python to PATH”; include **pip** and **venv** | ZDX official/SDK examples; scripts; future small service |
| **.NET SDK** | *Optional / defer* unless **engineering mandates** their stack | Alternative to Python; omit if Python is approved |

---

## 2. Editor / terminal

| Item | Request | Why |
|------|---------|-----|
| **Visual Studio Code** | User- or machine-level install | Primary editor; Python debugging |
| **Python extension** (VS Code) | Microsoft Python + Pylance (or firm bundle) | Lint/run |
| **Windows Terminal** | If not on base image | Better shell/tabs |
| **PowerShell 7** (`pwsh`) | Side-by-side install | Newer scripting; cross-platform parity |

| Item | Request | Why |
|------|---------|-----|
| **Cursor** | *Optional — policy dependent* | If **not** approved, VS Code + firm Copilot policy is enough |

---

## 3. PowerShell script policy

| Item | Request | Why |
|------|---------|-----|
| **ExecutionPolicy** | **`RemoteSigned` for `CurrentUser`** (or org equivalent) | Run local `.ps1` helpers without bypassing security |

---

## 4. Network — **outbound HTTPS** (often why `curl` hangs on corp PC)

On some firm laptops, **browser** traffic works but **curl/Python/Git** **hang** or fail until proxy/TLS is set for **non-browser** tools. Ask IT to **preconfigure AVD** for:

| Item | Request | Why |
|------|---------|-----|
| **ZDX API reachability** | Allow **outbound HTTPS** from AVD to **Zscaler ZDX API hostnames** for your cloud (Bill / Zscaler docs — e.g. `*.zscaler.*` / tenant-specific API hosts) | Without this, PoC cannot run |
| **Corporate proxy for CLI** | If required: **system or user** `HTTP_PROXY` / `HTTPS_PROXY` (and `NO_PROXY` for internal hosts), **or** WinHTTP proxy aligned with browser | **curl**, **pip**, **git**, **Python** need same path as approved corporate access |
| **TLS inspection** | Install **corporate root CA** for **machine + Python cert store**, **or** documented exception for ZDX API targets | Avoid certificate verify failures |
| **DNS** | Resolve public Zscaler / PyPI / GitHub if pip/git used | Build pipeline |

**Phase 2 (note only):** HTTPS to **ServiceNow** instance — separate firewall/credential work.

---

## 5. Package installs (Python)

| Item | Request | Why |
|------|---------|-----|
| **pip / PyPI** | Allow `pip install` from AVD to **pypi.org** (or **internal PyPI mirror**) | `requests`, official **Zscaler Python SDK** if used |
| **GitHub** | If installs pull from GitHub | Some deps resolve there |

*If PyPI is blocked:* request **pre-approved wheel bundle** or **internal mirror** listing: `requests`, `python-dotenv` (optional), `zscaler-sdk-python` (if engineering agrees).

---

## 6. Secrets (no values in ticket)

| Item | Request | Why |
|------|---------|-----|
| **API key storage** | Approved method: **Key Vault**, **CyberArk**, or **encrypted user store** per policy | ZDX Key ID + Secret must not live in repo or plain OneDrive |

---

## 7. Optional (lower priority — add if you want fewer follow-ups)

| Item | Request | Why |
|------|---------|-----|
| **Postman** | Desktop or portable | Manual API exploration alongside curl |
| **7-Zip** / archive tool | If not on image | Occasional extracts |
| **WSL2** | *Only if you want Linux on AVD* | Not required if Windows + Python is enough |

---

## 8. Explicitly **not** requesting (unless IT suggests)

- **Local Administrator** — not required if IT installs the above  
- **Docker Desktop** — defer until needed  
- **Personal cloud sync** (Dropbox, personal OneDrive) for code — prefer **firm Git** only  

---

## 9. Validation checklist (after build)

Ask IT or test yourself:

- [ ] `python --version` → 3.11+  
- [ ] `git --version`  
- [ ] `curl -sSI https://<ZDX-or-test-host-from-docs>` returns headers within **10 seconds** (not hang)  
- [ ] `pip install requests` (or firm mirror equivalent) succeeds  

---

## Contacts

- **Sponsor:** Bill Verdon (ZDX / network)  
- **Manager:** Arnold Slaughter, Network Engineering  
- **Requestor:** *(you)*  

---

## Related docs

[`pilot-poc.md`](./pilot-poc.md) — why **proxy/TLS** matters if `curl` never returns on current laptop.
