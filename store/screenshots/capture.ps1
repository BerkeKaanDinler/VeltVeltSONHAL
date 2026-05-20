# VELT Android screenshot helper.
#
# Usage: pwsh capture.ps1 <name>
# Example: pwsh capture.ps1 01_home
#
# Saves to store/screenshots/android/<name>.png
# Make sure the emulator is showing the screen you want before running.

param([string]$Name = "shot")

$ts = Get-Date -Format "yyyyMMdd_HHmmss"
$dir = Join-Path $PSScriptRoot "android"
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
$out = Join-Path $dir ("{0}.png" -f $Name)

# Capture via adb (works on any connected device/emulator)
& adb exec-out screencap -p > $out

if (Test-Path $out) {
  $size = (Get-Item $out).Length
  Write-Host ("Saved: {0} ({1:N0} bytes)" -f $out, $size) -ForegroundColor Green
} else {
  Write-Host "Capture failed. Is the emulator running and adb on PATH?" -ForegroundColor Red
}
