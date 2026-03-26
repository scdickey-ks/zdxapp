# Integrations roadmap

Supports [**requirements**](requirements.md) and UC-01 (network flap).

## Phase 1 — Workflow webhook

| Topic | Detail |
|-------|--------|
| **Audience** | **Network** usually receives the user ticket today; **Desktop/IT Support** often **closes the loop** (bad cable, dock, physical/L1). Webhook should reach **Network** first or support **fan-out / conditional routing** so Desktop can act on L1-style cases without waiting for user tickets. |
| **Transport** | **HTTP POST** to a **workflow webhook** (e.g. Azure Logic Apps, Power Automate, internal receiver). |
| **Payload** | JSON: device id, user, signal summary, timestamps, link to ZDX deep dive if applicable; optional **suggested_category** (e.g. `interface_flap_l1_candidate`) for workflow rules — **finalize after** API shape is known. |
| **Config** | `ALERT_WEBHOOK_URL` (+ optional headers) in `.env`; later may move to **app UI / DB** for ops-owned URLs without redeploy. |

## Phase 2 — ServiceNow

| Topic | Detail |
|-------|--------|
| **Why** | **Link** alerts to **existing incidents** and/or **create** tickets so work lands in the system of record. |
| **API** | ServiceNow exposes **REST Table API** and OAuth; exact auth pattern is **org-specific** (scoped app, integration user, MID server). |
| **Early design** | Implement detection once, then **pluggable sinks**: `WebhookSink`, `ServiceNowSink` (phase 2). Avoid hard-coding POST logic only for webhook. |
| **Data to carry** | Correlation keys (device, user), suggested short description, optional `incident_number` if updating/linking. |

## Architecture note

Keep a thin **“alert event”** model in code (who, what, when, severity, raw refs). **Emitters** consume that model — webhook first, ServiceNow second — so phase 2 does not rewrite detection.
