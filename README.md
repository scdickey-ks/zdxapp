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

---

## Working with this repo in AI chat (e.g. GitHub Copilot Chat)

### Referencing the repo without pasting a URL

You **don't need to paste the full URL**. Just tell the assistant the `owner/repo` identifier:

```
scdickey-ks/zdxapp
```

The assistant can look up the repository, browse its files, and read code directly using that short reference. You can also mention:

- **Branch:** `main`
- **Specific file path:** e.g. `src/zdx_client.py`
- **Error text or stack trace:** paste it directly into the chat

### Sharing key context quickly

| What to share | How |
|--------------|-----|
| Repo location | Type `scdickey-ks/zdxapp` (no URL needed) |
| Active branch | `git branch --show-current` → paste the output |
| Remote URL | `git remote -v` → paste the output |
| Recent commits | `git log --oneline -10` → paste the output |
| Error/traceback | Copy the terminal output and paste it into chat |

---

## Troubleshooting: pasting URLs in Microsoft Edge

If you are using **Microsoft Edge** and the chat input box is not accepting a pasted URL:

### Workarounds (no pasting required)

1. **Use `owner/repo` instead of a URL** – Type `scdickey-ks/zdxapp` directly. The AI assistant understands this short form and can access the repo.
2. **Paste `git remote -v` output** – Run `git remote -v` in your terminal and paste the text line (e.g. `origin https://github.com/scdickey-ks/zdxapp.git`). The assistant can parse the repo from that.
3. **Type the URL manually** – Type `github.com/scdickey-ks/zdxapp` without the `https://` prefix to bypass any Edge-specific paste filtering.
4. **Use a different browser** – Chrome, Firefox, or the Edge address-bar "paste & go" flow all handle URL pasting without issue.
5. **Drag-and-drop the URL** – In Edge, you can sometimes drag the URL from the address bar and drop it into the chat input instead of using Ctrl+V.

### Why this happens

Edge has a built-in **Smart Paste** / clipboard-sanitization feature that can strip or block pasting URLs into certain text inputs. Workarounds 1–3 above sidestep the issue entirely without needing to change any browser settings.

