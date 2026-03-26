# zdx-smoke-legacy.ps1
# Legacy ZDX API-key smoke test (hashed secret + timestamp).
# No admin rights required.
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File .\zdx-smoke-legacy.ps1
#   powershell -ExecutionPolicy Bypass -File .\zdx-smoke-legacy.ps1 -EnvPath .\.env -SkipDevices

param(
  [string]$EnvPath = ".\.env",
  [int]$Hours = 2,
  [switch]$SkipDevices
)

function Load-DotEnv {
  param([string]$Path)
  if (!(Test-Path $Path)) { return @{} }
  $map = @{}
  Get-Content $Path | ForEach-Object {
    $line = $_.Trim()
    if ($line -eq "" -or $line.StartsWith("#")) { return }
    $idx = $line.IndexOf("=")
    if ($idx -lt 1) { return }
    $k = $line.Substring(0, $idx).Trim()
    $v = $line.Substring($idx + 1).Trim().Trim("'").Trim('"')
    if ($k) { $map[$k] = $v }
  }
  return $map
}

function Get-Val {
  param([hashtable]$EnvMap, [string]$Name, [string]$Default = "")
  if ($EnvMap.ContainsKey($Name) -and $EnvMap[$Name]) { return $EnvMap[$Name] }
  if (Test-Path "Env:$Name" -PathType Leaf) {
    $tmp = (Get-Item "Env:$Name").Value
    if ($tmp) { return $tmp }
  }
  return $Default
}

function Cloud-Prefix {
  param([string]$Cloud)
  $c = $Cloud.Trim().TrimEnd("/")
  if ($c.ToLower().EndsWith(".net")) { $c = $c.Substring(0, $c.Length - 4) }
  return $c
}

function Read-ErrorBody {
  param($Response)
  try {
    $sr = New-Object IO.StreamReader($Response.GetResponseStream())
    return $sr.ReadToEnd()
  } catch {
    return ""
  }
}

$envMap = Load-DotEnv -Path $EnvPath
$zdxEnv = (Get-Val -EnvMap $envMap -Name "ZDX_ENV" -Default "test").ToLower()
if ($zdxEnv -ne "prod") { $zdxEnv = "test" }
$suffix = if ($zdxEnv -eq "prod") { "PROD" } else { "TEST" }

$legacyKeyId = Get-Val -EnvMap $envMap -Name ("ZDX_LEGACY_KEY_ID_" + $suffix)
$legacyKeySecret = Get-Val -EnvMap $envMap -Name ("ZDX_LEGACY_KEY_SECRET_" + $suffix)
if (-not $legacyKeyId) { $legacyKeyId = Get-Val -EnvMap $envMap -Name "ZDX_KEY_ID" }
if (-not $legacyKeySecret) { $legacyKeySecret = Get-Val -EnvMap $envMap -Name "ZDX_KEY_SECRET" }

$legacyBase = Get-Val -EnvMap $envMap -Name ("ZDX_LEGACY_BASE_URL_" + $suffix)
if (-not $legacyBase) {
  $zdxCloud = Get-Val -EnvMap $envMap -Name "ZDX_CLOUD" -Default "zscalerthree.net"
  $legacyBase = "https://api.$(Cloud-Prefix -Cloud $zdxCloud).net"
}
$legacyBase = $legacyBase.TrimEnd("/")

if (-not $legacyKeyId -or -not $legacyKeySecret) {
  Write-Host "Missing legacy credentials." -ForegroundColor Red
  Write-Host "Set ZDX_LEGACY_KEY_ID_* and ZDX_LEGACY_KEY_SECRET_* (or ZDX_KEY_ID/ZDX_KEY_SECRET)."
  exit 2
}

Write-Host "Environment: $zdxEnv"
Write-Host "Legacy base: $legacyBase"
Write-Host ""

Write-Host "== DNS / reachability =="
$legacyHost = ([System.Uri]$legacyBase).Host
try {
  Resolve-DnsName $legacyHost -ErrorAction Stop | Select-Object -First 3
} catch {
  Write-Host "Resolve-DnsName failed for ${legacyHost}: $($_.Exception.Message)"
}
try {
  $r = Invoke-WebRequest -Method Head -Uri $legacyBase -TimeoutSec 15
  Write-Host "$legacyBase HEAD status: $($r.StatusCode)"
} catch {
  if ($_.Exception.Response) {
    Write-Host "$legacyBase HEAD status: $($_.Exception.Response.StatusCode.value__)"
  } else {
    Write-Host "$legacyBase HEAD error: $($_.Exception.Message)"
  }
}

Write-Host ""
Write-Host "== Legacy token test =="

$ts = [int][double]::Parse((Get-Date -UFormat %s))
$toHash = "$legacyKeySecret`:$ts"
$sha = [System.Security.Cryptography.SHA256]::Create()
$bytes = [System.Text.Encoding]::UTF8.GetBytes($toHash)
$hashedSecret = ($sha.ComputeHash($bytes) | ForEach-Object { $_.ToString("x2") }) -join ""

$body = @{
  key_id = $legacyKeyId
  key_secret = $hashedSecret
  timestamp = $ts
} | ConvertTo-Json -Compress

$tokenUrl = "$legacyBase/v1/oauth/token"
$token = $null
try {
  $t = Invoke-RestMethod -Method Post -Uri $tokenUrl -ContentType "application/json" -Body $body -TimeoutSec 30
  if ($t.token) { $token = $t.token }
  elseif ($t.access_token) { $token = $t.access_token }

  if ($token) {
    $prefixLen = [Math]::Min(12, $token.Length)
    Write-Host "Token SUCCESS. Prefix: $($token.Substring(0, $prefixLen))..."
  } else {
    Write-Host "Token call returned, but no token field:"
    $t | ConvertTo-Json -Depth 5
    exit 1
  }
}
catch {
  $resp = $_.Exception.Response
  if ($resp) {
    $code = $resp.StatusCode.value__
    Write-Host "Legacy token FAILED HTTP $code" -ForegroundColor Yellow
    $respBody = Read-ErrorBody -Response $resp
    if ($respBody) { Write-Host $respBody }
  } else {
    Write-Host "Legacy token FAILED: $($_.Exception.Message)" -ForegroundColor Yellow
  }
  Write-Host "Interpretation:"
  Write-Host "- DNS failure: legacy host is not resolvable in this network path."
  Write-Host "- 401/403: key exists but auth shape, key status, or role mapping is not accepted."
  exit 1
}

if ($SkipDevices) {
  Write-Host "SkipDevices set; legacy token test complete."
  exit 0
}

Write-Host ""
Write-Host "== Devices probe (legacy token) =="
$to = [int][double]::Parse((Get-Date -UFormat %s))
$from = $to - (3600 * $Hours)
$devicesUrl = "$legacyBase/zdx/v1/devices?from=$from&to=$to"
Write-Host "GET $devicesUrl"
try {
  $d = Invoke-RestMethod -Method Get `
    -Uri $devicesUrl `
    -Headers @{ Authorization = "Bearer $token"; Accept = "application/json" } `
    -TimeoutSec 45
  if ($d.devices) {
    Write-Host "Devices SUCCESS. Count: $($d.devices.Count)"
  } else {
    Write-Host "Devices response has no .devices list. Top-level keys:"
    ($d | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name) -join ", "
  }
} catch {
  $resp = $_.Exception.Response
  if ($resp) {
    $code = $resp.StatusCode.value__
    Write-Host "Devices FAILED HTTP $code" -ForegroundColor Yellow
    $respBody = Read-ErrorBody -Response $resp
    if ($respBody) { Write-Host $respBody }
    if ($code -eq 403) {
      Write-Host "Interpretation: token valid, but role/scope may not permit devices endpoint."
    }
  } else {
    Write-Host "Devices FAILED: $($_.Exception.Message)" -ForegroundColor Yellow
  }
  exit 1
}

Write-Host "Result: legacy token + devices probe completed."
