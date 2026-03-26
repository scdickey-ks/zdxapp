# Zscaler support case — ZDX API (internal reference)

**Status:** **Himani** provided concrete auth routing details in-thread: unified OneAPI endpoint pattern **`api.zsapi.net`** and token endpoint **`https://api.zsapi.net/zdx/v1/oauth/token`**. She pointed Steve to the official **ZDX API Authentication Guide** for call order and curl examples, and offered a live troubleshooting call (share 2-3 time slots). Same thread: `thread::O8s5t4zjemeRXFMzqGRtsls::`.

**Do not** paste API keys or secrets into tickets or this file.

---

## Case

| Field | Value |
|-------|--------|
| **Case number** | **06193646** |
| **Subject (summary)** | Assistance with ZDX API Key management, authentication, and lifecycle for secure API access |
| **Bill’s ask (summary)** | Confirm backend enablement on test/prod, clarify read-only model, and provide practical first-call guidance (endpoint/auth/docs). |

---

## Tenant identifiers (K&S — internal)

| Environment | Tenant reference |
|-------------|------------------|
| **Production** | `zscalerthree.net-11262725` |
| **Test** | `zscalerthree.net-64754664` |

**Cloud marker:** `zscalerthree.net` (tenant context).

### Test vs production — same API URLs?

**Working assumption (from Himani’s reply in this case):** OneAPI uses a **single** host pattern — **`api.zsapi.net`** — and the token path she gave (**`/zdx/v1/oauth/token`**) was **not** qualified as “production only.” That is consistent with **test and production using the same access URLs**, while **different API clients (keys)** and **tenant / org context** (e.g. `zscalerthree.net-64754664` vs `zscalerthree.net-11262725`) determine **which** environment’s data the token and calls apply to.

**Not fully proven from that email alone:** Zscaler’s older materials and SDKs sometimes distinguish **`zdxcloud`** vs **`zdxbeta`** for URL selection on **legacy** ZDX API paths; Himani’s direction was specifically the **OneAPI** pattern. Edge cases (dedicated beta stacks, gov clouds, or org-specific overrides) could still exist.

**One-line confirmation to paste to Himani:** *“For our ZDX OneAPI clients: do **test** and **production** keys both use **`https://api.zsapi.net`** (same token URL **`…/zdx/v1/oauth/token`**), with only client credentials and tenant identifiers differing — or is there a separate test hostname?”*

**Firewall allowlist:** treat **`api.zsapi.net`** (HTTPS) as required unless support supplies additional hosts for your tenancy.

---

## Thread chronology (condensed)

1. **Himani initial response:** acknowledged case, linked [Managing ZDX API keys](https://help.zscaler.com/zdx/managing-zdx-api-keys), asked for specific questions.
2. **Bill follow-up:** requested backend enablement help for test/prod and clarity on read-only vs integrated ZIA/ZDX model.
3. **Himani follow-up (earlier):** investigating internally; promised update by 1:00 PM PST (next business day window).
4. **Current handoff understanding (before latest reply):** licensing/access path appears enabled; blocked on exact call details (FQDN/token/first example).
5. **Steve → Himani:** Steve sent a detailed explanation of open questions; Himani acknowledged and committed a Monday update window.
6. **Himani update (new):** confirmed unified endpoint pattern **`api.zsapi.net`** and token endpoint **`https://api.zsapi.net/zdx/v1/oauth/token`**; directed the team to the **ZDX API Authentication Guide** for exact call sequence and example curl usage; offered to schedule a support call.
7. **2026-03-26 Steve follow-up:** requested a quick working session and asked two explicit clarifications:
   - whether **test** API environment uses the same access host/FQDN as **production**,
   - API **key** vs API **client** differences, rationale, and whether both are available for test.
   - shared availability: **2:00 PM to 3:30 PM ET** (today).
8. **2026-03-26 Bill call notes:** Zscaler guidance on a live call was to prefer **Zidentity API Client** configuration for higher customization and potential multi-key/client flexibility; Bill also noted conflicting statements about whether ZDX API-key path permits only one key, while he was able to create multiple keys (needs official confirmation).
9. **Execution context update:** Bill indicated his machine is currently on **UAT/Test** and has live data, so K&S can run immediate smoke tests once auth path and endpoint model are finalized.

---

## Contacts

### Firm

| Name | Role | Contact |
|------|------|---------|
| **Bill Verdon** | Sr Security Engineer (case owner/sponsor) | `bverdon@kslaw.com`, `+1 404 572 4926` |
| **Arnold Slaughter** | Network Engineering Manager | Internal manager/stakeholder |
| **Steve Dickey** | Active on case thread | Sent **detailed queries** to Himani; she acknowledged and committed **Monday 1:00 PM PST** update |
| **Brandon (K&S)** | Pending environment decision | Discuss where/how app runs in secured environment |

### Zscaler

| Name | Role | Contact / note |
|------|------|----------------|
| **Himani** | Support Engineer (case responder) | Via `support@zscaler.com`; hours 4:00 AM-1:00 PM PST (Mon-Fri) |
| **Jacob Toothman** | Commercial Sales Engineer | `jtoothman@zscaler.com`; OOO noted through 2026-03-23 in thread period |

Support links: [Phone support](https://help.zscaler.com/phone-support), [Contact support](https://help.zscaler.com/contact-support)

---

## Questions to ask Zscaler (add to thread when appropriate)

- **Test data population:** Can we populate the ZDX test API with firm historical data where PII (user/device identifiers) is **encrypted with an app-level key** before ingestion? Enables realistic testing without exposing real identifiers. *(Tracked in [`security-app-and-process.md`](./security-app-and-process.md) §7.)*

---

## Open outcomes

- [x] Backend enablement/licensing confirmed for **test** + **production** (per handoff notes)
- [x] Read-only setup path identified (local ZDX role + mapping/client)
- [x] **API base URL / FQDN pattern** identified: `api.zsapi.net` (validate any tenant-specific exceptions)
- [x] **Token endpoint** identified: `https://api.zsapi.net/zdx/v1/oauth/token`
- [ ] Confirm official recommendation and limits: **ZDX API Key** vs **Zidentity API Client** (customization, multiplicity, lifecycle controls, and test-env availability)
- [ ] One known-good **first call** example validated by K&S in tenant context (support says examples are in auth guide)
- [ ] Canonical docs URL + notes for this exact auth model (secret auth + role mapping) captured in `references.md`

