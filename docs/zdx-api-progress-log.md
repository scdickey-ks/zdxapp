# ZDX API progress log (living)

## 2026-03-26

- Steve emailed Himani on case **06193646** requesting a quick session and clarification on:
  - whether **test** and **production** use the same API access host/FQDN,
  - API **key** vs API **client** differences, when to use each, and test availability.
- Proposed meeting window sent: **today 2:00 PM to 3:30 PM ET**.
- Awaiting Himani response before finalizing test/prod URL assumptions in implementation defaults.
- Bill relayed guidance from a Zscaler call: preference is to use **API Client in Zidentity** for better customization; he also reported hearing that ZDX API-key path may be more limited for key multiplicity (still being validated).
- Bill confirmed his machine is on **UAT/Test** with live telemetry visible, enabling immediate smoke validation once auth model is confirmed.

## 2026-03-25

- Ingested meeting notes with Bill into `docs/meeting-notes-2026-03-25-bill-zscaler-architecture.md` (ZIA/ZPA/ZDX split, tunnels, Azure cloud connector, follow-ups for Himani).
- Relocated ad-hoc screenshots to `docs/assets/2026-03-25/` (renamed for clarity).
- Merged **test** Zscaler API client credentials from a root-level JSON export into **`.env`** as `ZDX_CLIENT_ID_TEST` / `ZDX_CLIENT_SECRET_TEST`; removed the plaintext JSON from the workspace and added ignore rules for `*-Read-Only.json` exports.
- Removed duplicate support-case PDF from repo root (same content as `docs/support-cases/case-06193646-zdx-api-key-auth-thread.pdf`).

## Latest — Zscaler Support (Himani update received)

- Case **06193646** now includes concrete auth routing details from Himani.
- Unified OneAPI endpoint pattern: **`api.zsapi.net`**.
- Token endpoint provided: **`https://api.zsapi.net/zdx/v1/oauth/token`**.
- Support referenced the **ZDX API Authentication Guide** for full call sequence and curl examples.
- Himani offered live support if Steve shares 2-3 available time slots.
- Working-hours escalation path reiterated: [phone support](https://help.zscaler.com/phone-support), [contact support](https://help.zscaler.com/contact-support).

## 2026-03-20

- Consolidated support/case context into app repo docs.
- Captured test-first env-toggle implementation pattern.
- Confirmed immediate blocker list:
  - API FQDN/base URL
  - token endpoint/auth specifics
  - first known-good call example
- Support case `06193646` remains source of truth for those details.

## Next log entry template

- **Date:**
- **What changed:**
- **Endpoint tested:**
- **Result (HTTP/status):**
- **Role/permission observations:**
- **Action items:**

