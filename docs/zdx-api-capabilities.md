# ZDX API — capabilities (living doc)

Update this as you learn from docs, Bill, and experiments.

## API keys — ZDX Admin (org context)

From Bill / Steve (ZDX portal):

| Topic | Detail |
|-------|--------|
| **Where** | ZDX Admin → **Administration** (gear) → **API Key Management**. URL pattern: `https://admin.<your-cloud>/zdx/admin/api-key-management` (example seen: **`zscalercloud.net`**). |
| **Action** | **+ Create API Key** — table lists **Name**, **Key ID**, **Role**. |
| **Plan** | **ZDX Advanced** appears to expose self-service API key management; generic docs may still say “contact account management,” which may apply to tenants **without** Advanced. |
| **Roles** | Keys are **role-based** — bind the key to a role created in ZDX (see below) unless org standard says otherwise. |
| **Secrets** | Store only in `.env` / secret manager — never in repo or chat logs. |

### ZDX-local roles — **Add Role** (Bill — current path)

Generic **Zidentity** “read only” did **not** behave as expected for this use case; Bill pivoted to a **local role inside ZDX** (**Add Role**), with per-module levers.

| Topic | Detail |
|-------|--------|
| **Where** | ZDX Admin → role UI titled **Add Role** (long checklist of modules × access level). |
| **Levels** | Per line: **Full** | **Read Only** | **None** — spike targets **Read Only** (and **None** where API access isn’t needed). |
| **Modules seen in UI** | **Dashboard**, **Users**, **Devices**, **Applications**, **Alerts**, **Inventory**, **Administration** (incl. sub-areas such as Role Management, User Management), **Deep Tracing**, **Reports** — align RO with the API/MCP calls you’ll make. |
| **Next step** | Create API key assigned to this ZDX role; validate which endpoints succeed at **Read Only** per module (user: “see what I can do once I get a key”). |

### Zidentity roles (earlier thread — v2 / View Only)

Still relevant if org ties API access to **Zidentity** elsewhere: **View Only** on ZDX blocks for **v2 touchpoints**, support ticket for least-privilege. For **this** tenant, Bill’s working model is the **ZDX-local Add Role** screen above.

## Version context

- **Legacy APIs:** See [Understanding ZDX API](https://help.zscaler.com/legacy-apis/understanding-zdx-api) in [`references.md`](./references.md).
- **v2 / 2026 upgrades:** Bill pointed to the [Release upgrade summary 2026](https://help.zscaler.com/zdx/release-upgrade-summary-2026?applicable_category=zdxcloud.net&deployment_date=2026-02-20&id=1535351) — capture **new endpoints, auth changes, and deprecations** here after you read that article.

### To fill in (from release notes + API docs)

| Area | Legacy / v1 | v2 (if applicable) | Notes |
|------|-------------|-------------------|-------|
| Auth (API key vs OAuth, scopes) | | | |
| Apps / experience scores | | | |
| Devices | | | |
| Users / sessions | | | |
| Alerts | | | |
| Deep trace / path analysis | | | **UC-01:** Candidate source for path/connectivity changes; confirm vs explicit NIC events. |
| Admin / config | | | |
| **Link / interface / adapter events** | | | **UC-01:** Hypothesis — data may exist in backend but **not** as an Admin UI alert type; **validate v2 + Deep Trace + device APIs**. |

### UC-01 — Network flap (dock / wired ↔ Wi‑Fi)

See **[use-case-network-flap.md](./use-case-network-flap.md)** for full narrative.

- **Need:** Historical (or near-real-time) signals that correlate with **Ethernet vs Wi‑Fi churn** on Windows clients.
- **UI gap (assumption):** No first-class ZDX alert for this; **API-driven** polling or export may be required.
- **Investigation order (suggested):** API v2 device/session/path docs → **Deep Tracing** endpoints → application-level metrics as fallback proxies.
- **Roles:** Likely **Devices**, **Deep Tracing**, **Reports** (Read Only) — **verify** with Bill’s key after endpoint list is known.

## MCP (Model Context Protocol)

| Item | Detail |
|------|--------|
| **Exists?** | **Yes** — Zscaler’s **[Integrations MCP Server](https://www.zscaler.com/blogs/product-insights/zscaler-mcp-server-bringing-unified-security-automation-your-ai-agents)** (open source; e.g. [`zscaler-mcp` on PyPI](https://pypi.org/project/zscaler-mcp/), [GitHub](https://github.com/zscaler/zscaler-mcp-server)). |
| **ZDX via MCP** | Documented **[ZDX tools](https://zscaler-mcp-server.readthedocs.io/en/stable/tools/zdx/index.html)** — apps (list, score, metrics, users), active devices, administration (depts/locations), alerts + historical alerts, software inventory, deep traces. Tools are **read-only** unless you opt into write behavior (verify release notes). |
| **API version** | MCP ZDX calls may support **`use_legacy`** (or similar) — align with your tenant’s v1/v2 rollout. |
| **vs custom app** | MCP = great for **interactive** agent use in Cursor. Your **app/script** spike may still call the **HTTP API** directly for automation, CI, or locked-down environments where MCP isn’t approved. |

---

## Open questions

- [x] Which API version does our tenant/key target? → **v2 touchpoints** (per Bill); legacy only if needed for gaps.
- [x] MCP available? → **Yes (Zscaler official)** — see table above; confirm v2 parity with MCP release.
- [ ] Is MCP approved for use with production creds in our environment?
- [ ] **UC-01:** Does API expose **adapter/link flapping** explicitly, or only **inferrable** metrics? Retention window sufficient for “had been happening for a while”?
