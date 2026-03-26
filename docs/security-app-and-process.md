# Security — app and development process

**Purpose:** Define and document **robust security protections** for the ZDX app and the **entire development lifecycle** so the effort withstands detailed scrutiny from Security (Bill) and engineering.

**Audience:** Bill Verdon (Security), Arnold Slaughter, Risk Management, engineering reviewers.

---

## 1. Cursor / AI-assisted development — what goes where

### What you told Bill (and how to keep it accurate)

| Your statement | Accuracy | Nuance to add |
|----------------|----------|---------------|
| **"Cursor engages with tools outside the firm"** | **Correct.** Cursor uses cloud-based AI (code completion, chat, agents) — requests and context are sent to AI providers. | Confirm Cursor’s current terms and whether the firm has Cursor Enterprise or different policies. |
| **"Used to develop code/architecture"** | **Correct.** Code, file contents, and architecture docs you put in chat become context for the model. | That context **is sent** to the provider. So: **code and architecture** = in scope of what leaves the firm; **secrets and PII** = must **never** be pasted. |
| **"Data can be kept local and secure/private"** | **Conditional.** It’s true **only if** you enforce strict discipline: **never paste** API keys, secrets, raw ZDX responses with user/device IDs, or any PII into Cursor chat. `.env` is local and gitignored — good. But **anything you type or paste into chat** can be sent. | The separation is **usage discipline**, not a technical guarantee. Document that discipline and enforce it. |

### Recommended one-liner for Bill

*"Cursor uses cloud AI for code and architecture help. We keep **secrets and PII out of chat** — credentials in `.env`, no pasting of API responses or user identifiers. We use the **ZDX test tenant** with non-production data for development where possible."*

### Mitigations already in place

- `.env` gitignored; no keys in repo or docs
- ZDX **test tenant** (`zscalerthree.net-64754664`) for development
- Read-only API key; no write access

### Open question for Zscaler support

**Can we populate the ZDX test API with firm historical data where PII is encrypted (e.g. with an app-level encryption key) before ingestion?**  
— Track in [Questions for Zscaler](#questions-for-zscaler-support) below.

---

## 2. Data handling — design principles

| Principle | Implementation |
|-----------|----------------|
| **Minimize** | Only pull ZDX fields needed for flap detection; no bulk export. |
| **Retention** | Define retention for alerts, logs, and any cached telemetry; document in architecture. |
| **Encryption** | Secrets at rest (vault, encrypted config); TLS in transit; consider encryption for stored alert payloads if they contain identifiers. |
| **Access control** | App runs with least-privilege identity; operators use SSO/MFA; audit who changed tuning/silence rules. |
| **No client/matter data** | ZDX telemetry only; no integration with matter management, email, or file shares. |

---

## 3. Development process — security controls

| Control | Description |
|---------|-------------|
| **Secrets** | Never in repo, chat, or tickets. Use `.env` locally; vault in production. Rotate keys if ever exposed. |
| **Code review** | All changes reviewed before merge; AI-generated code treated as draft, not trusted by default. |
| **Dependency hygiene** | Pin versions; run `pip audit` / SCA; document AI-assisted dependencies explicitly. |
| **Environment separation** | Test-first; prod requires explicit switch and confirmation. |
| **Audit trail** | Log env used, endpoints called (no secrets); immutable log of alerts sent. |

---

## 4. Runtime security (app)

| Area | Requirement |
|------|-------------|
| **Authentication** | ZDX API key or OAuth client credentials from vault; no hardcoding. |
| **Network** | Outbound only to approved ZDX/SN/webhook hosts; document allowlist. |
| **Input validation** | Validate all API responses and config; fail closed on malformed data. |
| **Output** | Webhook payloads to firm-controlled URLs only; authenticate outbound calls (shared secret, OAuth, or IP allowlist). |
| **Logging** | No secrets or PII in logs; redact device/user IDs in debug if required by policy. |

---

## 5. Cursor rules / project conventions (for developer and security review)

Suggested additions to `.cursorrules` or project conventions so reviewers see explicit security thinking:

- **Never suggest or accept** code that commits secrets, logs credentials, or hardcodes API keys.
- **Never suggest** pasting real API responses, keys, or PII into chat — use sanitized examples only.
- **Prefer** least-privilege patterns: read-only where possible; explicit prod confirmation.
- **Flag** when generated code touches auth, secrets, or PII handling — recommend review.
- **Document** data flow and retention in architecture; call out any external calls.

See [§6](#6-suggested-cursorrules-content) for draft content to add.

---

## 6. Suggested .cursorrules content

Add the following (or equivalent) to `.cursorrules` so it’s visible to anyone opening the project:

```
## Security and privacy (non-negotiable)

- **Secrets:** Never commit, log, or paste API keys, tokens, or credentials. Use .env (gitignored) or vault.
- **PII / identifiers:** Do not paste raw ZDX responses containing user/device IDs into chat. Use sanitized examples only.
- **AI context:** Assume anything in chat may be sent to the AI provider. Keep sensitive data out of Cursor context.
- **Code review:** Treat AI-generated code as draft. Require human review before merge, especially for auth, secrets, or data handling.
- **Environment:** Default to test; require explicit confirmation for production execution.
- **External calls:** Document all outbound endpoints (ZDX, webhook, ServiceNow) in architecture; no undocumented egress.
```

---

## 7. Questions for Zscaler support

| # | Question | Status |
|---|----------|--------|
| 1 | **Can we populate the ZDX test API with firm historical data where PII (user/device identifiers) is encrypted with an app-level key before ingestion?** Enables realistic testing without exposing real identifiers. | Open — add to case 06193646 or separate ticket |

---

## 8. Checklist for Security review

- [ ] Cursor usage and data-flow narrative documented (this doc)
- [ ] Secrets handling (vault, rotation, no-repo) documented
- [ ] Test vs prod separation and prod confirmation documented
- [ ] ZDX data category and “no client/matter” scope documented
- [ ] External endpoints and allowlist documented
- [ ] `.cursorrules` or equivalent includes security conventions
- [ ] Dependency/SCA process documented
- [ ] Audit and logging approach documented

---

*Update as Bill or engineering add requirements.*
