<#
.SYNOPSIS
    Honey Badger v1.0 — Windows context menu installer / uninstaller

.DESCRIPTION
    Installs (or uninstalls) two right-click context menu entries:

    On ALL files:
      "Sign with davw"    — creates a .davw sidecar for any file

    On .davw files:
      "Verify davw"       — verifies the sidecar against its source file

    Installation is per-user (HKCU) — no admin required.

.PARAMETER Uninstall
    Remove the context menu entries instead of installing.

.EXAMPLE
    .\install-davw-context.ps1
    .\install-davw-context.ps1 -Uninstall
#>

param(
    [switch]$Uninstall
)

Set-StrictMode -Version Latest

$scriptDir  = $PSScriptRoot
$installDir = "$env:LOCALAPPDATA\davw"
$signerSrc  = Join-Path $scriptDir "sign-with-davw.ps1"
$verifySrc  = Join-Path $scriptDir "verify-davw.ps1"
$signerDst  = Join-Path $installDir "sign-with-davw.ps1"
$verifyDst  = Join-Path $installDir "verify-davw.ps1"

# Prefer pwsh (PowerShell 7+), fall back to powershell.exe
$psExe = if (Get-Command pwsh -ErrorAction SilentlyContinue) { "pwsh.exe" } else { "powershell.exe" }

$signRegPath  = "HKCU:\Software\Classes\*\shell\davw-sign"
$verifyRegPath = "HKCU:\Software\Classes\.davw\shell\davw-verify"

function Write-Step($msg, $ok = $true) {
    $color = if ($ok) { "Green" } else { "Red" }
    $icon  = if ($ok) { "[OK]" } else { "[!!]" }
    Write-Host "$icon $msg" -ForegroundColor $color
}

if ($Uninstall) {
    Write-Host ""
    Write-Host " Uninstalling davw context menus..." -ForegroundColor Yellow

    foreach ($regPath in @($signRegPath, "$signRegPath\command", $verifyRegPath, "$verifyRegPath\command")) {
        if (Test-Path $regPath) {
            Remove-Item -Path $regPath -Recurse -Force -ErrorAction SilentlyContinue
            Write-Step "Removed registry: $regPath"
        }
    }

    if (Test-Path $installDir) {
        Remove-Item -Path $installDir -Recurse -Force -ErrorAction SilentlyContinue
        Write-Step "Removed install dir: $installDir"
    }

    Write-Host ""
    Write-Host " davw uninstalled. Right-click entries removed." -ForegroundColor Yellow
    Write-Host ""
    exit 0
}

# ── Install ───────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host " Honey Badger v1.0 — davw installer" -ForegroundColor Cyan
Write-Host " ─────────────────────────────────────" -ForegroundColor DarkGray
Write-Host " Root: 6DD8EE2539B1EF4B966F71671D229C5D2F7D65AE87D7827F0B85C6AF07FB58BF" -ForegroundColor DarkGray
Write-Host ""

# Validate source files
foreach ($src in @($signerSrc, $verifySrc)) {
    if (-not (Test-Path -LiteralPath $src)) {
        Write-Step "Missing source file: $src" $false
        exit 1
    }
}

# Create install dir and copy scripts
New-Item -ItemType Directory -Force -Path $installDir | Out-Null
Copy-Item -LiteralPath $signerSrc -Destination $signerDst -Force
Copy-Item -LiteralPath $verifySrc -Destination $verifyDst -Force
Write-Step "Scripts installed to: $installDir"

# ── "Sign with davw" on all files ────────────────────────────────────────────
$signCmd = "`"$psExe`" -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$signerDst`" `"%1`""

New-Item -Path $signRegPath          -Force | Out-Null
New-Item -Path "$signRegPath\command" -Force | Out-Null
Set-ItemProperty -Path $signRegPath            -Name "(Default)" -Value "Sign with davw"
Set-ItemProperty -Path $signRegPath            -Name "Icon"      -Value "shell32.dll,-153"
Set-ItemProperty -Path "$signRegPath\command"  -Name "(Default)" -Value $signCmd
Write-Step "Context menu added: 'Sign with davw' (all files)"

# ── "Verify davw" on .davw files ──────────────────────────────────────────────
$verifyCmd = "`"$psExe`" -NoProfile -ExecutionPolicy Bypass -File `"$verifyDst`" `"%1`""

# Register .davw extension if not already known
if (-not (Test-Path "HKCU:\Software\Classes\.davw")) {
    New-Item -Path "HKCU:\Software\Classes\.davw" -Force | Out-Null
    Set-ItemProperty -Path "HKCU:\Software\Classes\.davw" -Name "(Default)" -Value "davw.sidecar"
}

New-Item -Path $verifyRegPath           -Force | Out-Null
New-Item -Path "$verifyRegPath\command"  -Force | Out-Null
Set-ItemProperty -Path $verifyRegPath           -Name "(Default)" -Value "Verify davw"
Set-ItemProperty -Path $verifyRegPath           -Name "Icon"      -Value "shell32.dll,-238"
Set-ItemProperty -Path "$verifyRegPath\command" -Name "(Default)" -Value $verifyCmd
Write-Step "Context menu added: 'Verify davw' (.davw files)"

# ── Done ──────────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host " Installation complete." -ForegroundColor Green
Write-Host " Right-click any file → 'Sign with davw'" -ForegroundColor White
Write-Host " Right-click any .davw file → 'Verify davw'" -ForegroundColor White
Write-Host ""
Write-Host " To uninstall: .\install-davw-context.ps1 -Uninstall" -ForegroundColor DarkGray
Write-Host ""
