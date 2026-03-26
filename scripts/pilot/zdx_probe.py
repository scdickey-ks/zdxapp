#!/usr/bin/env python3
"""
Minimal ZDX API pilot probe — stdlib only (no pip).
1. Set PILOT_URL below from Zscaler ZDX API docs for your tenant (v2 or legacy).
2. Fix build_request() if your key uses something other than HTTP Basic (id:secret).

Run:  python3 zdx_probe.py
Env:  ZDX_KEY_ID, ZDX_KEY_SECRET  OR  values in repo-root ../../.env
"""
from __future__ import annotations

import base64
import json
import os
import ssl
import sys
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen

# --- EDIT after reading Zscaler docs (placeholder — will 404 until replaced) ---
PILOT_URL = os.environ.get(
    "ZDX_PILOT_URL",
    "https://REPLACE_HOST_FROM_DOCS/replace/path/from/documentation",
)


def load_env_file(path: Path) -> None:
    if not path.is_file():
        return
    for line in path.read_text(encoding="utf-8", errors="replace").splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, _, val = line.partition("=")
        key, val = key.strip(), val.strip().strip('"').strip("'")
        if key and key not in os.environ:
            os.environ[key] = val


def basic_auth_header(key_id: str, secret: str) -> str:
    raw = f"{key_id}:{secret}".encode("utf-8")
    return "Basic " + base64.b64encode(raw).decode("ascii")


def build_request(url: str, key_id: str, secret: str) -> Request:
    """If docs specify Bearer or custom headers, change this function."""
    req = Request(url, method="GET")
    req.add_header("Authorization", basic_auth_header(key_id, secret))
    req.add_header("Accept", "application/json")
    return req


def main() -> int:
    root = Path(__file__).resolve().parents[2]
    load_env_file(root / ".env")

    key_id = os.environ.get("ZDX_KEY_ID", "").strip()
    secret = os.environ.get("ZDX_KEY_SECRET", "").strip()

    if not key_id or not secret:
        print("Set ZDX_KEY_ID and ZDX_KEY_SECRET (env or .env at repo root).", file=sys.stderr)
        return 1

    if "REPLACE" in PILOT_URL:
        print(
            "Edit zdx_probe.py: set PILOT_URL (or env ZDX_PILOT_URL) to a real endpoint from Zscaler docs.",
            file=sys.stderr,
        )
        return 1

    req = build_request(PILOT_URL, key_id, secret)
    ctx = ssl.create_default_context()

    try:
        with urlopen(req, timeout=60, context=ctx) as resp:
            body = resp.read()
            print("Status:", resp.status)
            try:
                data = json.loads(body.decode("utf-8"))
                print(json.dumps(data, indent=2)[:8000])
            except json.JSONDecodeError:
                print(body[:4000].decode("utf-8", errors="replace"))
    except HTTPError as e:
        print("HTTP error:", e.code, e.reason, file=sys.stderr)
        err_body = e.read().decode("utf-8", errors="replace")[:2000]
        if err_body:
            print(err_body, file=sys.stderr)
        return 1
    except URLError as e:
        print("URL error:", e.reason, file=sys.stderr)
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
