# zdx-smoke.ps1
# API Client / OAuth-style ZDX smoke test.
# No admin rights required.
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File .\zdx-smoke.ps1
#   powershell -ExecutionPolicy Bypass -File .\zdx-smoke.ps1 -EnvPath .\.env -SkipDevices

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

# Preferred: API Client creds from .env
$ClientId = Get-Val -EnvMap $envMap -Name ("ZDX_CLIENT_ID_" + $suffix)
$ClientSecret = Get-Val -EnvMap $envMap -Name ("ZDX_CLIENT_SECRET_" + $suffix)

# Fallback: legacy key vars (if user only has those)
if (-not $ClientId) { $ClientId = Get-Val -EnvMap $envMap -Name ("ZDX_LEGACY_KEY_ID_" + $suffix) }
if (-not $ClientSecret) { $ClientSecret = Get-Val -EnvMap $envMap -Name ("ZDX_LEGACY_KEY_SECRET_" + $suffix) }
if (-not $ClientId) { $ClientId = Get-Val -EnvMap $envMap -Name "ZDX_KEY_ID" }
if (-not $ClientSecret) { $ClientSecret = Get-Val -EnvMap $envMap -Name "ZDX_KEY_SECRET" }

if (-not $ClientId -or -not $ClientSecret) {
  Write-Host "Missing credentials." -ForegroundColor Red
  Write-Host "Set in .env (ZDX_CLIENT_ID_* / ZDX_CLIENT_SECRET_*) or edit script placeholders."
  exit 2
}

$baseUrl = Get-Val -EnvMap $envMap -Name ("ZDX_ONEAPI_BASE_URL_" + $suffix)
if (-not $baseUrl) { $baseUrl = "https://api.zsapi.net" }
$baseUrl = $baseUrl.TrimEnd("/")

$vanity = Get-Val -EnvMap $envMap -Name ("ZSCALER_VANITY_DOMAIN_" + $suffix)
$cloud = Get-Val -EnvMap $envMap -Name ("ZSCALER_CLOUD_" + $suffix) -Default "PRODUCTION"
$cloudUpper = $cloud.ToUpper()
if ($vanity) {
  if ($cloudUpper -eq "PRODUCTION") {
    $oauthUrl = "https://$vanity.zslogin.net/oauth2/v1/token"
  } else {
    $oauthUrl = "https://$vanity.zslogin$($cloud.ToLower()).net/oauth2/v1/token"
  }
} else {
  $oauthUrl = ""
}
$supportTokenUrl = "https://api.zsapi.net/zdx/v1/oauth/token"

Write-Host "Environment: $zdxEnv"
Write-Host "OneAPI base: $baseUrl"
Write-Host "Support token URL: $supportTokenUrl"
if ($oauthUrl) { Write-Host "OAuth URL (vanity): $oauthUrl" }
else { Write-Host "OAuth URL (vanity): <not configured>" }
Write-Host ""

Write-Host "== DNS / reachability matrix =="
try {
  Resolve-DnsName api.zsapi.net -ErrorAction Stop | Select-Object -First 3
} catch {
  Write-Host "Resolve-DnsName failed:" $_.Exception.Message
}
if ($oauthUrl) {
  try {
    $oauthHost = ([System.Uri]$oauthUrl).Host
    Resolve-DnsName $oauthHost -ErrorAction Stop | Select-Object -First 1
  } catch {
    Write-Host "Resolve-DnsName failed for oauth host: $($_.Exception.Message)"
  }
}

try {
  $r = Invoke-WebRequest -Method Head -Uri "https://api.zsapi.net" -TimeoutSec 15
  Write-Host "api.zsapi.net HEAD status:" $r.StatusCode
} catch {
  if ($_.Exception.Response) {
    Write-Host "api.zsapi.net HEAD status:" $_.Exception.Response.StatusCode.value__
  } else {
    Write-Host "api.zsapi.net HEAD error:" $_.Exception.Message
  }
}
if ($oauthUrl) {
  try {
    $r = Invoke-WebRequest -Method Head -Uri $oauthUrl -TimeoutSec 15
    Write-Host "$oauthUrl HEAD status:" $r.StatusCode
  } catch {
    if ($_.Exception.Response) {
      Write-Host "$oauthUrl HEAD status:" $_.Exception.Response.StatusCode.value__
    } else {
      Write-Host "$oauthUrl HEAD error:" $_.Exception.Message
    }
  }
}

Write-Host ""
Write-Host "== Token tests =="
$token = $null
$tokenSource = $null
$tokenTests = @()
if ($oauthUrl) { $tokenTests += @{ Name = "vanity_oauth"; Url = $oauthUrl; Audience = "https://api.zscaler.com" } }
$tokenTests += @{ Name = "support_endpoint"; Url = $supportTokenUrl; Audience = "https://api.zscaler.com" }

foreach ($test in $tokenTests) {
  $tokenBody = @{
    grant_type    = "client_credentials"
    client_id     = $ClientId
    client_secret = $ClientSecret
  }
  if ($test.Audience) { $tokenBody["audience"] = $test.Audience }
  Write-Host "Testing token endpoint [$($test.Name)]: $($test.Url)"
  try {
    $t = Invoke-RestMethod -Method Post `
      -Uri $test.Url `
      -ContentType "application/x-www-form-urlencoded" `
      -Body $tokenBody `
      -TimeoutSec 30
    if ($t.access_token -or $t.token) {
      $token = if ($t.access_token) { $t.access_token } else { $t.token }
      $tokenSource = $test.Name
      $prefixLen = [Math]::Min(12, $token.Length)
      Write-Host "Token SUCCESS via [$tokenSource]. Prefix: $($token.Substring(0, $prefixLen))..."
      break
    } else {
      Write-Host "Token call returned, but no token field:"
      $t | ConvertTo-Json -Depth 5
    }
  } catch {
    $resp = $_.Exception.Response
    if ($resp) {
      $code = $resp.StatusCode.value__
      Write-Host "Token FAILED [$($test.Name)] HTTP $code" -ForegroundColor Yellow
      $body = Read-ErrorBody -Response $resp
      if ($body) { Write-Host $body }
    } else {
      Write-Host "Token FAILED [$($test.Name)]: $($_.Exception.Message)" -ForegroundColor Yellow
    }
  }
}

Write-Host ""
if (-not $token) {
  Write-Host "Result: no OAuth token acquired." -ForegroundColor Yellow
  Write-Host "Interpretation:"
  Write-Host "- 401 at reachable endpoint usually means credential/flow mismatch (API Key used as API Client, wrong scopes, or wrong tenant/client binding)."
  Write-Host "- DNS/TLS errors indicate local network trust/proxy path issue."
  exit 1
}

if ($SkipDevices) {
  Write-Host "SkipDevices set; token test complete."
  exit 0
}

Write-Host "== Devices probe =="
$to = [int][double]::Parse((Get-Date -UFormat %s))
$from = $to - (3600 * $Hours)
$devicesUrl = "$baseUrl/zdx/v1/devices?from=$from&to=$to"
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
    $body = Read-ErrorBody -Response $resp
    if ($body) { Write-Host $body } else { Write-Host "<no response body returned>" }
    if ($code -eq 403) {
      Write-Host "Interpretation: token valid, but role/scope lacks required ZDX permission for devices endpoint."
    }
  } else {
    Write-Host "Devices FAILED: $($_.Exception.Message)" -ForegroundColor Yellow
  }
  exit 1
}

Write-Host "Result: OAuth token + devices probe completed."
