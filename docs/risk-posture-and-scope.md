# Risk posture & scope — narrative for security / management

Use or adapt the language below in architecture reviews, exception requests, or handoff discussions.

---

## 1. Collaboration model (you + engineering)

**Intent:** Continued development of this capability is expected to **overlap with** the firm’s engineering organization. The exact split of work—who maintains production code, pipelines, and infrastructure—will be determined in partnership with engineering leadership. Regardless of split, the **problem definition, ZDX data validation, and operational requirements** remain grounded in network/desktop stakeholder needs.

*One sentence for email:*  
*“I expect to keep building the feasibility path and specifications; engineering will help align implementation with firm standards—we’re still working out how ownership and repos split.”*

---

## 2. Low-risk posture — suggested verbiage

### Short (elevator)

*This integration uses **read-only access** to **Zscaler ZDX telemetry** already collected from managed endpoints—think device and digital-experience metrics, not document stores or email. The application does **not** require access to matter data, HR systems, financial systems, or user content. **Scope is intentionally narrow:** query ZDX APIs, apply logic to detect unhealthy patterns (e.g. network interface instability), and notify internal teams via approved channels (e.g. workflow webhook; optional ServiceNow in a later phase).*

### Medium (security / architecture review)

| Topic | Statement |
|-------|-----------|
| **Data category** | Data accessed is **endpoint operational telemetry** exposed by ZDX (e.g. device identity, connectivity/experience signals, timestamps). This is **infrastructure and operations data**, comparable to other IT monitoring tools already in use. |
| **Sensitivity** | The solution is **not** designed to access **legal work product**, **client matter content**, **mailboxes**, **file shares**, or **business applications holding confidential client data**. No such APIs are in scope. |
| **Access model** | **Least privilege:** ZDX API credentials are scoped to **read-only** roles tied solely to the telemetry needed for the use case. **No write or administrative actions** to ZDX (or other platforms) are required for the core scenario. |
| **Data movement** | Outputs are **aggregated alerts and correlation metadata** (e.g. device identifier, summary of condition) sent to **firm-controlled** destinations (workflow automation, and optionally ServiceNow). **No bulk export** of raw telemetry for unrelated purposes is a design goal. |
| **Residual risk** | As with any monitoring integration, **device/user identifiers** in alerts are **internal IT context**—appropriate handling (access control on the app, webhook auth, audit) matches standard ops tooling. |
| **User & device identity (intentional)** | **User ID and machine/device identity are operationally necessary**—they connect an alert to the **affected endpoint and person** so network/desktop can respond. This is not “extra” sensitive data collection; it is the same class of correlation used in standard ITSM and monitoring. It remains **firm-internal confidential** (not client/matter content). |

### One-line rebuttal to “this could touch sensitive data”

*“The app only consumes **ZDX endpoint telemetry APIs** under a **read-only** key; it does **not** integrate with systems that hold client or matter data.”*

---

## 3. Preferred dev environment — AVD / managed VM (Bill Verdon)

**Sponsor direction:** Prefer a **dedicated Azure Virtual Desktop (AVD)** or equivalent **firm-managed VM** for building and running the tool—not an unmanaged laptop. User already accesses separate VMs (e.g. telecom vs network); a machine where **approved tools can be installed** under governance is the target.

**Approval path (Bill):** Submit a **generic request** to add required **applications/tools** to the VM, **assign to Risk Management**, and **note collaboration with Bill Verdon**—intended to **expedite** routing. Prepare a short **requirements list** (IDE/runtime, Git, Python or stack TBD, any ZDX testing utilities—no secrets in that doc).

See **[avd-tooling-request.md](./avd-tooling-request.md)** for a draft checklist you can attach to the request.

---

## 4. Personal device + API key — last resort

**Preferred:** Development and testing on **firm-managed** equipment (see **§3 AVD/VM** above) and **firm-approved** secret storage (e.g. vault), with credentials issued and rotated per InfoSec.

**Last resort (precedent: prior Webex automation work):** If firm policy or tooling delays block progress, **exploratory development on a personal machine** using the **same class of credential** (API key with read-only scope) may be used **only** with explicit **manager and/or InfoSec acknowledgment**. Risks to call out:

- Key on a non-managed device increases **exposure** if the device is compromised; **rotation** if the key ever touched personal storage is prudent.
- **No client or matter data** should be processed on personal equipment; ZDX telemetry still identifies **internal** users/devices—treat as **confidential to the firm**.

*Suggested commitment:*  
*“Personal device is a **time-boxed spike** path only; production and ongoing use will follow firm hosting and identity standards.”*

---

## 5. What “continuing to build” implies (for approvers)

- **Narrow API surface** + **read-only** + **no client systems** = **lower risk class** than typical application integrations.
- Formal engineering engagement **improves** posture (standard SDLC, scanning, vault, SSO for any UI)—it does not require expanding scope to sensitive data sources.

*Update this document as InfoSec or engineering adds conditions.*
