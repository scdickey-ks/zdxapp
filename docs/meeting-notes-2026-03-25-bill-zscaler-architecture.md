# Meeting notes — 2026-03-25 (Bill)

## Context

- Separate portal for test vs production.
- **ZDX** is monitoring/telemetry (module on endpoints: app and OS events). It is not where ZIA/ZPA policy lives.
- **ZIA** — internet access; **ZPA** — private access; **endpoint** product — tunnel into one of many Zscaler data centers.
- Deployment uses a consistent policy model (e.g. roaming agent): firewall, IPS, web content, and a subset of advanced features (e.g. encrypt/decrypt). That policy surface is **not** visible inside ZDX.
- **Azure cloud connector** — separate tunnel from servers in Azure to Zscaler cloud with similar inspection/malware posture.
- **ZPA** — similar split tunnel concept: client ↔ app connector, different rules/IP segments; endpoints use the appropriate tunnels.
- ZDX sits on endpoints collecting telemetry across apps and OS.

## Follow-ups for Himani

- **API keys vs API client** — same role; when to prefer one over the other?
- Are there **different base URLs** for the test API environment vs production?
