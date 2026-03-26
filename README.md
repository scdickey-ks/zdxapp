# ZDX API feasibility spike

Exploratory work to assess interfacing with **Zscaler ZDX** via their API (and optionally MCP in Cursor). **Primary goal:** support **proactive detection** of **dock / wired ↔ Wi‑Fi flapping** on Windows (see [`docs/use-case-network-flap.md`](docs/use-case-network-flap.md)) — pending confirmation that ZDX API exposes the right signals and roles.

## Setup

1. Edit **`.env`** (gitignored): set `ZDX_KEY_ID` and `ZDX_KEY_SECRET` from ZDX API Key Management. See comments in `.env` for webhook/SN placeholders.
2. Never commit `.env` or share key values in chat/tickets.

## Layout

| Path        | Purpose                                      |
|------------|-----------------------------------------------|
| `src/`     | Reusable client code, small app entrypoints   |
| `scripts/` | One-off probes; **[`scripts/pilot/`](scripts/pilot/)** for minimal API PoC |
| `docs/`    | Notes; start with [`docs/references.md`](docs/references.md) for links |
| `tests/`   | Tests when you add them                       |

## Rules

Project-specific Cursor guidance lives in **`.cursorrules`** at the repo root.
"# zdxapp" 
