#!/usr/bin/env python3
"""
ZDX API smoke test (stdlib only).

Designed for constrained enterprise laptops (Windows/macOS/Linux) with only Python 3.
Reads repo-root .env and supports explicit auth modes to avoid credential-flow mixing.

Examples:
  python3 scripts/pilot/zdx_api_smoke.py --mode legacy --verbose
  python3 scripts/pilot/zdx_api_smoke.py --mode api_client --skip-devices
  python3 scripts/pilot/zdx_api_smoke.py --mode auto
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import ssl
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path
from typing import Callable


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


def cloud_api_prefix(zdx_cloud: str) -> str:
    c = zdx_cloud.strip().rstrip("/")
    if c.endswith(".net"):
        c = c[: -len(".net")]
    return c


def get_env() -> str:
    env = os.environ.get("ZDX_ENV", "test").strip().lower()
    return "prod" if env == "prod" else "test"


def pick_by_env(base_name: str, env: str, fallback: str = "") -> str:
    suffix = "PROD" if env == "prod" else "TEST"
    return os.environ.get(f"{base_name}_{suffix}", "").strip() or os.environ.get(base_name, "").strip() or fallback


def legacy_base_for_env(env: str) -> str:
    explicit = pick_by_env("ZDX_LEGACY_BASE_URL", env, "")
    if explicit:
        return explicit
    zdx_cloud = os.environ.get("ZDX_CLOUD", "zscalerthree.net").strip()
    return f"https://api.{cloud_api_prefix(zdx_cloud)}.net"


def oneapi_base_for_env(env: str) -> str:
    explicit = pick_by_env("ZDX_ONEAPI_BASE_URL", env, "")
    if explicit:
        return explicit
    cloud = pick_by_env("ZSCALER_CLOUD", env, "")
    if not cloud or cloud.upper() == "PRODUCTION":
        return "https://api.zsapi.net"
    return f"https://api.{cloud.lower()}.zsapi.net"


def oneapi_auth_url_for_env(env: str) -> str:
    vanity = pick_by_env("ZSCALER_VANITY_DOMAIN", env, "")
    if not vanity:
        raise RuntimeError("Missing vanity domain: set ZSCALER_VANITY_DOMAIN_TEST/PROD")
    cloud = pick_by_env("ZSCALER_CLOUD", env, "")
    if not cloud or cloud.upper() == "PRODUCTION":
        return f"https://{vanity}.zslogin.net/oauth2/v1/token"
    return f"https://{vanity}.zslogin{cloud.lower()}.net/oauth2/v1/token"


def pick_legacy_creds(env: str) -> tuple[str, str]:
    key_id = pick_by_env("ZDX_LEGACY_KEY_ID", env, "")
    secret = pick_by_env("ZDX_LEGACY_KEY_SECRET", env, "")
    if not key_id or not secret:
        key_id = os.environ.get("ZDX_KEY_ID", "").strip() or os.environ.get("ZDX_API_KEY_ID", "").strip()
        secret = os.environ.get("ZDX_KEY_SECRET", "").strip() or os.environ.get("ZDX_API_SECRET", "").strip()
    return key_id, secret


def pick_client_creds(env: str) -> tuple[str, str]:
    return pick_by_env("ZDX_CLIENT_ID", env, ""), pick_by_env("ZDX_CLIENT_SECRET", env, "")


def legacy_token(base_api: str, key_id: str, secret: str, ctx: ssl.SSLContext) -> str:
    ts = int(time.time())
    digest = hashlib.sha256(f"{secret}:{ts}".encode("utf-8")).hexdigest()
    body = json.dumps(
        {"key_id": key_id, "key_secret": digest, "timestamp": ts},
        separators=(",", ":"),
    ).encode("utf-8")
    url = f"{base_api.rstrip('/')}/v1/oauth/token"
    req = urllib.request.Request(
        url, data=body, method="POST", headers={"Content-Type": "application/json"}
    )
    with urllib.request.urlopen(req, timeout=60, context=ctx) as resp:
        raw = json.loads(resp.read().decode("utf-8"))
    token = raw.get("token") or raw.get("access_token")
    if not token:
        raise RuntimeError(f"legacy token response missing token field: keys={list(raw.keys())}")
    return str(token)


def himani_token(client_id: str, client_secret: str, ctx: ssl.SSLContext) -> str:
    url = "https://api.zsapi.net/zdx/v1/oauth/token"
    data = urllib.parse.urlencode(
        {
            "grant_type": "client_credentials",
            "client_id": client_id,
            "client_secret": client_secret,
            "audience": "https://api.zscaler.com",
        }
    ).encode("utf-8")
    req = urllib.request.Request(
        url,
        data=data,
        method="POST",
        headers={"Content-Type": "application/x-www-form-urlencoded"},
    )
    with urllib.request.urlopen(req, timeout=60, context=ctx) as resp:
        raw = json.loads(resp.read().decode("utf-8"))
    token = raw.get("access_token") or raw.get("token")
    if not token:
        raise RuntimeError(f"himani token response missing token field: keys={list(raw.keys())}")
    return str(token)


def api_client_token(auth_url: str, client_id: str, client_secret: str, ctx: ssl.SSLContext) -> str:
    data = urllib.parse.urlencode(
        {
            "grant_type": "client_credentials",
            "client_id": client_id,
            "client_secret": client_secret,
            "audience": "https://api.zscaler.com",
        }
    ).encode("utf-8")
    req = urllib.request.Request(
        auth_url,
        data=data,
        method="POST",
        headers={"Content-Type": "application/x-www-form-urlencoded"},
    )
    with urllib.request.urlopen(req, timeout=60, context=ctx) as resp:
        raw = json.loads(resp.read().decode("utf-8"))
    token = raw.get("access_token")
    if not token:
        raise RuntimeError(f"api_client token response missing access_token: keys={list(raw.keys())}")
    return str(token)


def fetch_devices(api_base: str, access_token: str, ctx: ssl.SSLContext, from_ts: int, to_ts: int) -> dict:
    q = urllib.parse.urlencode({"from": str(from_ts), "to": str(to_ts)})
    url = f"{api_base.rstrip('/')}/zdx/v1/devices?{q}"
    req = urllib.request.Request(
        url,
        method="GET",
        headers={"Authorization": f"Bearer {access_token}", "Accept": "application/json"},
    )
    with urllib.request.urlopen(req, timeout=60, context=ctx) as resp:
        return json.loads(resp.read().decode("utf-8"))


def print_http_error(e: urllib.error.HTTPError, verbose: bool, label: str) -> None:
    print(f"{label} HTTP {e.code} {e.reason}", file=sys.stderr)
    if verbose:
        print(e.read().decode("utf-8", errors="replace")[:4000], file=sys.stderr)


def run_mode(mode: str, env: str, verbose: bool, skip_devices: bool, hours: int) -> int:
    ctx = ssl.create_default_context()
    now = int(time.time())
    from_ts = now - (hours * 3600)
    to_ts = now

    token: str
    api_base: str
    info: list[str] = [f"mode={mode}", f"env={env}"]

    try:
        if mode == "legacy":
            key_id, secret = pick_legacy_creds(env)
            if not key_id or not secret:
                print("Missing legacy creds for selected env.", file=sys.stderr)
                return 2
            api_base = legacy_base_for_env(env)
            info.append(f"legacy_base={api_base}")
            token = legacy_token(api_base, key_id, secret, ctx)
        elif mode == "api_client":
            client_id, client_secret = pick_client_creds(env)
            if not client_id or not client_secret:
                print("Missing API client creds for selected env.", file=sys.stderr)
                return 2
            auth_url = oneapi_auth_url_for_env(env)
            api_base = oneapi_base_for_env(env)
            info.append(f"oauth_url={auth_url}")
            info.append(f"oneapi_base={api_base}")
            token = api_client_token(auth_url, client_id, client_secret, ctx)
        elif mode == "himani":
            client_id, client_secret = pick_client_creds(env)
            if not client_id or not client_secret:
                print("Missing API client creds for selected env.", file=sys.stderr)
                return 2
            api_base = oneapi_base_for_env(env)
            info.append("oauth_url=https://api.zsapi.net/zdx/v1/oauth/token")
            info.append(f"oneapi_base={api_base}")
            token = himani_token(client_id, client_secret, ctx)
        else:
            print(f"Unsupported mode: {mode}", file=sys.stderr)
            return 2
    except urllib.error.HTTPError as e:
        print("\n".join(info))
        print_http_error(e, verbose, f"{mode} auth")
        return 1
    except urllib.error.URLError as e:
        print("\n".join(info))
        print(f"{mode} auth network error: {e.reason}", file=sys.stderr)
        return 1
    except (OSError, RuntimeError) as e:
        print("\n".join(info))
        print(f"{mode} auth error: {e}", file=sys.stderr)
        return 1

    print("\n".join(info))
    print(f"token_prefix={token[:12]}... (redacted)")

    if skip_devices:
        return 0

    try:
        data = fetch_devices(api_base, token, ctx, from_ts, to_ts)
    except urllib.error.HTTPError as e:
        print_http_error(e, verbose, f"{mode} devices")
        return 1
    except urllib.error.URLError as e:
        print(f"{mode} devices network error: {e.reason}", file=sys.stderr)
        return 1

    devices = data.get("devices")
    if not isinstance(devices, list):
        print(f"{mode} unexpected response shape; keys={list(data.keys())}", file=sys.stderr)
        if verbose:
            print(json.dumps(data, indent=2)[:4000])
        return 1

    print(f"devices_count={len(devices)} window_hours={hours}")
    if verbose and devices:
        sample = []
        for d in devices[:3]:
            if isinstance(d, dict):
                sample.append({k: d.get(k) for k in ("id", "name") if k in d})
        print("[verbose] sample_devices=", json.dumps(sample))
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description="ZDX API smoke test with explicit auth modes")
    parser.add_argument(
        "--mode",
        choices=["auto", "legacy", "api_client", "himani"],
        default="auto",
        help="Auth mode to test. auto uses ZDX_AUTH_MODE first, then fallback probes.",
    )
    parser.add_argument("--skip-devices", action="store_true", help="Only test token acquisition.")
    parser.add_argument("--hours", type=int, default=2, help="Lookback window for devices call.")
    parser.add_argument("--verbose", action="store_true", help="Print response bodies on HTTP errors.")
    args = parser.parse_args()

    root = Path(__file__).resolve().parents[2]
    load_env_file(root / ".env")
    env = get_env()

    if args.mode != "auto":
        return run_mode(args.mode, env, args.verbose, args.skip_devices, args.hours)

    preferred = os.environ.get("ZDX_AUTH_MODE", "").strip().lower()
    attempts: list[str] = []
    order = ["legacy", "api_client", "himani"]
    if preferred in order:
        order = [preferred] + [m for m in order if m != preferred]

    for mode in order:
        attempts.append(mode)
        rc = run_mode(mode, env, args.verbose, args.skip_devices, args.hours)
        if rc == 0:
            return 0
        print(f"[auto] {mode} failed, trying next mode...\n", file=sys.stderr)

    print(f"auto failed after attempts: {', '.join(attempts)}", file=sys.stderr)
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
