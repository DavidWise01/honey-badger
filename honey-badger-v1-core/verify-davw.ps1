<#
.SYNOPSIS
    Honey Badger v1.0 — davw signature verifier

.DESCRIPTION
    Verifies a .davw sidecar against its source file.
    Checks:
      1. Source file still exists
      2. SHA256 of file matches stored hash (file integrity)
      3. ChainHash recomputes correctly (sidecar integrity)
      4. Reports full provenance chain

.PARAMETER Path
    Either the .davw sidecar file OR the original signed file.
    If you pass the original file, verify-davw will look for <file>.davw beside it.

.EXAMPLE
    .\verify-davw.ps1 -Path "C:\myfile.pdf.davw"
    .\verify-davw.ps1 -Path "C:\myfile.pdf"
#>

param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$Path
)

Set-StrictMode -Version Latest

# ── Resolve paths ─────────────────────────────────────────────────────────────
$Path = [System.IO.Path]::GetFullPath($Path)

if ($Path.EndsWith(".davw")) {
    $sidecarPath  = $Path
    $originalPath = $Path.Substring(0, $Path.Length - 5)   # strip .davw
} else {
    $originalPath = $Path
    $sidecarPath  = "$Path.davw"
}

function Write-Result($label, $value, $ok) {
    $color = if ($ok -eq $true) { "Green" } elseif ($ok -eq $false) { "Red" } else { "Cyan" }
    $icon  = if ($ok -eq $true) { "[PASS]" } elseif ($ok -eq $false) { "[FAIL]" } else { "     " }
    Write-Host "$icon  $label" -ForegroundColor $color -NoNewline
    if ($value) { Write-Host ": $value" -ForegroundColor DarkGray } else { Write-Host "" }
}

Write-Host ""
Write-Host " HONEY BADGER — davw verify v1.0" -ForegroundColor Cyan
Write-Host " ─────────────────────────────────" -ForegroundColor DarkGray

# ── Check sidecar exists ──────────────────────────────────────────────────────
if (-not (Test-Path -LiteralPath $sidecarPath)) {
    Write-Result "Sidecar" "not found: $sidecarPath" $false
    Write-Host ""
    exit 1
}

# ── Parse sidecar ─────────────────────────────────────────────────────────────
$lines = Get-Content -LiteralPath $sidecarPath -Encoding ASCII
$fields = @{}
foreach ($line in $lines) {
    if ($line -match '^([A-Za-z0-9]+):\s+(.+)$') {
        $fields[$Matches[1].Trim()] = $Matches[2].Trim()
    }
}

$storedHash  = $fields["SHA256"]
$storedChain = $fields["ChainHash"]
$storedNonce = $fields["Nonce"]
$storedRoot  = $fields["ParentHash"]
$storedFile  = $fields["File"]
$storedUser  = $fields["User"]
$storedMach  = $fields["Machine"]
$storedSigned = $fields["Signed"]
$davwVersion = $fields["DAVW"] # first line won't parse as field, that's fine

Write-Host ""
Write-Host " Source:   $storedFile" -ForegroundColor White
Write-Host " Signed:   $storedSigned by $storedUser on $storedMach" -ForegroundColor DarkGray
Write-Host " Parent:   $($fields['ParentMachine']) — $storedRoot" -ForegroundColor DarkGray
Write-Host ""

$allPass = $true

# ── Check 1: source file exists ───────────────────────────────────────────────
$sourceExists = Test-Path -LiteralPath $originalPath -PathType Leaf
Write-Result "File exists" $originalPath $sourceExists
if (-not $sourceExists) {
    Write-Host ""
    Write-Host " Source file is missing. Cannot verify hash." -ForegroundColor Red
    Write-Host " The .davw is still valid as a historical record." -ForegroundColor DarkGray
    Write-Host ""
    exit 2
}

# ── Check 2: file hash ────────────────────────────────────────────────────────
$actualHash = (Get-FileHash -LiteralPath $originalPath -Algorithm SHA256).Hash
$hashMatch  = ($actualHash -eq $storedHash)
Write-Result "File hash" $actualHash $hashMatch
if (-not $hashMatch) {
    Write-Host "   Expected: $storedHash" -ForegroundColor DarkGray
    $allPass = $false
}

# ── Check 3: chain hash (v1.0 sidecars only) ──────────────────────────────────
if ($storedChain -and $storedNonce -and $storedRoot) {
    # Use actualHash (recomputed from file) to verify chain — consistent with how it was signed
    $chainInput    = "$actualHash|$storedRoot|$storedNonce"
    $chainBytes    = [System.Text.Encoding]::UTF8.GetBytes($chainInput)
    $sha256obj     = [System.Security.Cryptography.SHA256]::Create()
    $recomputeHash = [BitConverter]::ToString($sha256obj.ComputeHash($chainBytes)).Replace("-","")
    $sha256obj.Dispose()

    $chainMatch = ($recomputeHash -eq $storedChain)
    Write-Result "Chain hash" $storedChain $chainMatch
    if (-not $chainMatch) {
        Write-Host "   Recomputed: $recomputeHash" -ForegroundColor DarkGray
        Write-Host "   The sidecar file may have been tampered with." -ForegroundColor Red
        $allPass = $false
    }
} else {
    Write-Result "Chain hash" "v0.x sidecar — chain not present" $null
}

# ── Final verdict ─────────────────────────────────────────────────────────────
Write-Host ""
if ($allPass) {
    Write-Host " ══ VERIFIED — file matches sidecar, chain intact ══" -ForegroundColor Green
} else {
    Write-Host " ══ FAILED — one or more checks did not pass ══" -ForegroundColor Red
}
Write-Host ""

exit $(if ($allPass) { 0 } else { 1 })
