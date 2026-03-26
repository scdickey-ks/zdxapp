# External references

Curated links for ZDX / Zscaler API work. Add new rows as colleagues or docs surface them.

| Topic | URL | Notes |
|-------|-----|-------|
| Understanding ZDX API (legacy APIs) | [help.zscaler.com — Understanding ZDX API](https://help.zscaler.com/legacy-apis/understanding-zdx-api) | Shared by Bill Verdon — baseline for how ZDX API fits in Zscaler’s API surface |
| Managing ZDX API keys | [help.zscaler.com — Managing ZDX API keys](https://help.zscaler.com/zdx/managing-zdx-api-keys) | Zscaler Support (Himani) — case **06193646** |
| ZDX API auth routing (support-confirmed) | `api.zsapi.net` and `https://api.zsapi.net/zdx/v1/oauth/token` | Confirmed by Zscaler Support (Himani) in case **06193646**; use the official "ZDX API Authentication Guide" for sequence/examples |
| ZDX release / upgrade summary (2026) | [Release upgrade summary 2026](https://help.zscaler.com/zdx/release-upgrade-summary-2026?applicable_category=zdxcloud.net&deployment_date=2026-02-20&id=1535351) | Shared by Bill Verdon — **v2** and expanded capabilities; URL includes tenant/category (`zdxcloud.net`) and deployment date — adjust query params for your cloud/date if needed |
| Zscaler MCP (product overview) | [Zscaler MCP Server blog](https://www.zscaler.com/blogs/product-insights/zscaler-mcp-server-bringing-unified-security-automation-your-ai-agents) | Official **Zscaler Integrations MCP Server** — ZCC, **ZDX**, ZIA, ZPA, Zidentity via MCP; works with Cursor et al.; built on Zscaler Python SDK / OneAPI |
| Zscaler MCP — PyPI | [zscaler-mcp on PyPI](https://pypi.org/project/zscaler-mcp/) | Installable package (e.g. v0.6.x); **read-only by default**, opt-in for writes — confirm org policy before enabling |
| Zscaler MCP — ZDX tools | [ZDX tools (Read the Docs)](https://zscaler-mcp-server.readthedocs.io/en/stable/tools/zdx/index.html) | MCP tools: apps/scores/metrics/users, devices, departments/locations, alerts, software inventory, deep traces; params include `use_legacy` for API version |
| Zscaler MCP — source / releases | [GitHub: zscaler/zscaler-mcp-server](https://github.com/zscaler/zscaler-mcp-server) | Releases, issues, deployment (Docker/local per their docs) |

---

## MCP (Cursor) — short answer

**Yes — there is an official Zscaler MCP** (integrations server, public preview as of common docs). It exposes **ZDX** among other products. Configure in **Cursor → Settings → MCP → Add server** (stdio/SSE per their install guide). Credentials live in MCP env, not in repo — same hygiene as API keys.

---

## Notes from references (no secrets)

- **API v2:** Bill flagged that v2 adds significant surface area vs legacy/v1 paths. When designing this spike, confirm in Zscaler docs which API version your key and tenant support, and whether legacy + v2 coexist during migration.

---

## Quick paste area

Use bullets for informal links before promoting them to the table above.

- 
