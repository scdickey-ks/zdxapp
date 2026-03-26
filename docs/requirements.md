# App / script — requirements (living doc)

Edit as scope firms up. Link to [`zdx-api-capabilities.md`](./zdx-api-capabilities.md) for API/MCP detail. Primary scenario: **[use-case-network-flap.md](./use-case-network-flap.md)**.

## Environment strategy (test-first)

- Default runtime target is **`test`**, with explicit switch for **`prod`**.
- Use a single env key `ZDX_ENV=test|prod` and separate env-scoped values (base URL, client ID/secret, token endpoint).
- Runtime logs must print active environment on each run; production execution should require explicit confirmation.

## Primary objective

**Proactively detect** Windows clients that are **flapping between wired (dock/Ethernet) and Wi‑Fi**, causing degraded experience **before** users report or file tickets. ZDX is suspected to **retain relevant signals** that the **Admin UI does not expose as alertable** — this app/spike must **confirm via API** which data exists and what **role** is required, then enable **custom detection + alerting**.

## Security & access

| ID | Requirement | Status / notes |
|----|-------------|----------------|
| R-SEC-01 | Integrate using **read-only** access: **ZDX Add Role** — **Read Only** (or **None**) per module (Users, Devices, Apps, Alerts, etc.); avoid **Full** unless required. Zidentity View Only may apply in other setups. | Bill: local ZDX role is the path that works here. |
| R-SEC-02 | **Least privilege:** after key issuance, map failed calls → missing RO line; support ticket only if still ambiguous. | Validate empirically with key. |
| R-SEC-03 | **Secrets:** API credentials only in `.env` or org-approved secret store; never committed or pasted into tickets/chat with real values. | Ongoing. |
| R-SEC-04 | **Writes (POST/mutate):** out of scope unless explicitly added later; spike assumes **GET/read** patterns only. | — |

## Functional (to refine)

| ID | Requirement | Priority |
|----|-------------|----------|
| R-FUNC-01 | Prove connectivity to **ZDX API v2** (or documented read endpoints) from this codebase. | P0 |
| R-FUNC-02 | **UC-01 — Data proof:** Identify API response fields (or gaps) for **link/path/interface instability** or **wired vs Wi‑Fi transitions** on a device over time; record endpoint paths + sample payloads (sanitized). | P0 |
| R-FUNC-03 | **UC-01 — Role proof:** Document minimum **ZDX Add Role** Read Only lines needed for those endpoints. | P0 |
| R-FUNC-04 | **UC-01 — Detection (future):** Given available data, define **flap detection** (windows, counts). Treat **any flapping interface** as in-scope; expect **iteration/tuning**. | P1 |
| R-FUNC-05 | **App UI — tuning & silence:** Operators can **adjust thresholds**, **suppress** noisy devices/interfaces/patterns, and **silence** alerts for a period without code changes. | P1 |
| R-FUNC-06 | **Alerts — phase 1:** **Workflow webhook** (POST). **Network** is the typical first line (matches current ticketing); payload/workflow should allow **Desktop/IT Support** to be looped in—many resolutions are **Layer 1** (cable, dock) handled by desktop, not core network design. Configurable routing (env → later UI). | P1 |
| R-FUNC-07 | **Alerts — phase 2 (ServiceNow):** **Link** to existing incidents and/or **create** tickets via ServiceNow API; design detection output so adding SN does not rewrite core logic (see [`integrations.md`](./integrations.md)). | P2 |
| R-FUNC-08 | Document which v2 resources are used for UC-01 vs general exploration. | P1 |
| R-FUNC-09 | Optional: **Zscaler MCP** in Cursor for ad-hoc analysis vs scripted app. | P2 |

## Non-functional

| ID | Requirement | Notes |
|----|-------------|-------|
| R-NF-01 | Spike should run locally / in approved dev context without production blast radius. | |
| R-NF-02 | README or docs updated when Bill shares final **role name + portal URL** patterns (no secrets). | |

## Open items

- [ ] List **ZDX Add Role** lines set to Read Only vs None (redacted screenshot or table).
- [ ] Bill’s credential / key handoff process (process only, not values in this file).
- [ ] **UC-01:** Confirm with Zscaler docs or support whether **explicit adapter/link events** exist in API v2 vs **inferred** from Deep Trace / metrics only.
- [x] **UC-01 — Alert transport (phase 1):** **Workflow webhook** → network team; desktop optional / same pipeline.
- [ ] **UC-01:** **Webhook URL** approval + sample payload sign-off with network/desktop.
- [ ] **Phase 2:** ServiceNow auth pattern (OAuth app, integration user) and **create vs link** workflow.
- [ ] Support-confirmed **API FQDN/base URL** (test + prod if different).
- [ ] Support-confirmed **token endpoint/auth details** for current client type.
- [ ] One known-good first successful API call (endpoint + headers/auth shape).

## Clarifications (fill when decided)

| Topic | Question | Answer |
|-------|----------|--------|
| Signal scope | **Any** interface flapping is potentially interesting; fine-tune via **UI** (suppress/silence/thresholds). | Captured |
| Flap definition | Default thresholds TBD; **operator-tunable** in app. | TBD defaults |
| Latency | Max acceptable delay from real-world flap to alert? | TBD |
| Cohort | All enrolled vs pilot group; UI may allow **per-device or pattern** suppression. | TBD |
