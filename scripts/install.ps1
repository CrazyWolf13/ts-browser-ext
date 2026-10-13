# Installs the latest ts-browser-ext helper and Firefox extension for the current user (no admin needed).
#   irm https://raw.githubusercontent.com/CrazyWolf13/ts-browser-ext/main/scripts/install.ps1 | iex
$ErrorActionPreference = "Stop"
$repo = "CrazyWolf13/ts-browser-ext"
$addonId = "ts-browser-ext@crazywolf.dev"
$arch = if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") { "arm64" } else { "amd64" }
$base = "https://github.com/$repo/releases/latest/download"
$dir = Join-Path $env:TEMP "ts-browser-ext-install"
New-Item -ItemType Directory -Force $dir | Out-Null

Invoke-WebRequest "$base/ts-browser-ext_windows_$arch.exe" -OutFile "$dir\ts-browser-ext.exe"
Invoke-WebRequest "$base/ts-browser-ext-firefox.xpi" -OutFile "$dir\ts-browser-ext-firefox.xpi"

# Copies the helper to a per-user folder and registers it for Firefox.
& "$dir\ts-browser-ext.exe" "--install=F$addonId"

# Firefox shows its normal "add extension" prompt for the signed .xpi.
Start-Process firefox.exe -ArgumentList "`"$dir\ts-browser-ext-firefox.xpi`""
