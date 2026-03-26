# Delivery strategy — context & recommendations

Personal / org context: migration-focused role expanding into automation (Webex→Teams precedent); strong architecture & data background; modern GUI/agentic tooling is newer. Law firm: **security first**; engineering may be skeptical of AI-generated code.

## 1. How to frame your role with leadership & devs

| Frame | Why it helps |
|-------|----------------|
| **Product / technical owner for the spike** | You own *problem*, *requirements*, *integrations*, *acceptance* — not necessarily every line of production code. |
| **Feasibility + specification** | Output is **evidence** (API works, roles, data shape) + **docs** devs can implement in their standard stack. |
| **Bridge** | You translate ZDX/ServiceNow/network ops needs into **interfaces and security constraints** they already understand. |

Avoid positioning as “I shipped prod with Cursor alone” unless that’s explicitly wanted; position as **“I proved the path; engineering hardens and owns runtime.”**

## 2. Documentation pack (what “spot on” often means)

Deliverables traditional teams respect:

1. **Problem & outcomes** — UC-01, stakeholders (network/desktop), success metrics.
2. **High-level architecture** — diagram: ZDX API → **your service** → webhook → workflow; phase 2 ServiceNow. No secrets on diagrams.
3. **Data flow & classification** — what PII/corporate data transits (device id, user, timestamps); **retention**; where logs live.
4. **Threat model (lightweight)** — STRIDE-style bullets: credential theft, webhook abuse, SN API abuse, insider misuse; mitigations (vault, mTLS, IP allowlist, least privilege).
5. **Authentication & device trust** — how operators access the **admin UI** (see below); how **runtime** authenticates to ZDX/SN (keys, managed identity, app registration).
6. **API & role matrix** — ZDX endpoints used, ZDX role lines, ServiceNow scopes (phase 2).
7. **ADR-style decisions** — e.g. “Webhook first; SN second”; “Read-only ZDX key”; “Pluggable alert sinks.”
8. **Handoff spec** — language/runtime **open** if devs prefer .NET/Java over Python; **contracts** (env vars, webhook JSON schema, error handling).

Use **human-reviewed** diagrams (Draw.io, Mermaid in repo, Visio) — not only LLM prose.

## 3. Security narrative (law firm)

- **Secrets:** Key vault / enterprise secret store; **never** repo or chat; rotate keys; RO ZDX role.
- **Network:** Internal hosting or approved cloud; webhook URL **authenticated** (shared secret, OAuth client credential to workflow, or IP restriction).
- **Audit:** Who changed tuning/silence rules; immutable log of alerts sent.
- **Dependency risk:** If code was AI-assisted, **dependency scan + SCA**, **human code review**, pinned versions — state that explicitly in the pack.

## 4. SSO / MFA / “firm device”

| Layer | Typical pattern |
|-------|------------------|
| **Humans using the app UI** | **Azure AD (Entra ID)** SSO for the web app; **Conditional Access** (MFA + **compliant/hybrid joined device**) so only managed PCs reach the UI. |
| **Service → ZDX** | API key or OAuth **client credentials** (service principal) — not end-user SSO. |
| **Service → ServiceNow** | OAuth or integration user — per InfoSec. |

“Know I’m on an authenticated firm device” = **Conditional Access** on the app registration + optional **Private Access / VPN** — not something you reinvent in the app.

## 5. Agentic coding & skeptical developers

- **Own the design; treat AI output as draft.** Require **peer review** before merge; same as any junior contribution.
- **Keep prompts and chat out of the audit story** unless policy asks — the artifact is **repo + ADRs + review record**.
- If policy **blocks Cursor** on firm machines: do spike on **personal/approved sandbox**, export **spec + OpenAPI-ish notes + sample scripts**; engineering reimplements in **approved IDE** (VS + Copilot if allowed).
- **Copilot vs Cursor:** Different surfaces; if only Copilot is approved, devs may implement while you maintain **requirements and acceptance tests**.

## 6. Harvey / firm LLMs

Harvey and similar are tuned for **legal work**, not general IDE automation. Unlikely to replace Cursor for **coding**; separate from **your** deliverable. Don’t conflate “approved legal LLM” with “approved development toolchain.”

## Collaboration with engineering (ongoing)

You may **continue to develop** the app while **interfacing with developers**—exact ownership (repos, CI/CD, production runbooks) is TBD. Useful frames:

- **You:** spike, requirements, ZDX proof, webhook/SN contracts, stakeholder demos.
- **Them:** stack choice, hardening, vault, Entra integration, operational ownership—or joint ownership if agreed.

See **[risk-posture-and-scope.md](./risk-posture-and-scope.md)** for **low-risk / telemetry-only** language that supports continued involvement and firm-managed paths vs **personal device as last resort**.

## 7. Practical next steps

1. Align with **InfoSec + engineering manager** on: allowed tooling, hosting, vault, and whether **you** vs **team** owns production deployment.
2. Freeze **requirements** (`requirements.md`, `integrations.md`) and grow **architecture + threat model** as you validate ZDX API.
3. Produce **one** architecture diagram + **webhook payload example** for network workflow owners early — builds trust.
4. If LLM use is restricted, budget time for **handoff-heavy** documentation so the team can reject “black box” concerns.

---

*Update this doc as firm policies and ownership become clear.*
