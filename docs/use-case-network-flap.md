# Use case UC-01 — Proactive detection: wired ↔ Wi‑Fi flapping (dock scenario)

## Problem

- User on a **docking station** with **Ethernet**; **Windows** sometimes **flaps** the active interface (up/down, **wired vs Wi‑Fi**), hurting throughput and latency.
- By the time the user opens a ticket, flapping has often been going on for **some time** — reactive support is late.

## Objective

**Detect this pattern proactively** and **raise an internal alert** (or workflow) **before** the user is heavily impacted or before they file a ticket.

## Operational reality (today)

- When users **do** report, the ticket often lands with **Network** first.
- Investigation **frequently** finds **Layer 1 / physical** causes—**bad cable**, dock, or similar—or work that **Desktop / IT Support** resolves (swap cable, reseat dock, Wi‑Fi vs Ethernet guidance).
- **Proactive signal** still helps **both** teams: Network sees the pattern early; routing or ticket text can **flag likely L1/desktop follow-up** so the right group acts before weeks of silent flapping.

## Working hypothesis

- **ZDX may already collect** telemetry or events that reflect **path / link / interface instability** (or strong proxies: path changes, DNS/PFT anomalies, session-quality drops tied to network transitions).
- The **ZDX Admin UI may not offer** a built-in alert rule for this specific signal — so **API (or v2) access** might be required to **query history** and drive **custom logic + alerting**.

## What must be validated (not assumed)

| # | Question | Outcome |
|---|----------|---------|
| 1 | Does **any documented API** (v2 preferred) return **time-series or events** that distinguish or correlate with **wired vs wireless** or **default route / adapter changes**? | Yes / partial / no → pivot |
| 2 | If not explicit, can we infer flapping from **Deep Trace**, **device metrics**, **session** data, or **application path** metrics at useful granularity? | Document which fields & lag |
| 3 | Which **ZDX Add Role** lines (**Devices**, **Deep Tracing**, **Reports**, **Users**, etc.) must be **Read Only** (or higher) for those endpoints? | Map after key test |
| 4 | **Retention** — how far back can we query? (Matches “had been occurring for a while.”) | Sets detection window |

## Out of scope (until defined)

- Default **thresholds** — operators will **tune** via app UI; spike proves data first.
- **Phase 1 alerts:** **Workflow webhook** — primary consumer **Network**; workflow may **notify or assign Desktop/IT Support** when appropriate (matches common **L1 resolution** path). **Phase 2:** **ServiceNow** create/link — see [`integrations.md`](./integrations.md).

## Related docs

- [`requirements.md`](./requirements.md) — traceable requirements and open items.
- [`zdx-api-capabilities.md`](./zdx-api-capabilities.md) — API investigation notes.
