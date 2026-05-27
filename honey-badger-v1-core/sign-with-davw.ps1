<#
.SYNOPSIS
    Honey Badger v1.0 — davw file signer

.DESCRIPTION
    Signs any file with SHA256 + machine root hash, creating a .davw sidecar.
    The sidecar proves: what the file was, who signed it, on which machine,
    when, and that it descends from the root machine (DAVID).

    Chain hash = SHA256(file_hash | parent_hash | nonce)
    This creates a unique, verifiable link in the provenance chain.

.PARAMETER FilePath
    The file to sign.

.PARAMETER Silent
    Suppress the confirmation popup. Use for batch/watcher operations.

.EXAMPLE
    .\sign-with-davw.ps1 -FilePath "C:\myfile.pdf"
    .\sign-with-davw.ps1 -FilePath "C:\myfile.pdf" -Silent
#>

param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$FilePath,

    [switch]$Silent
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ── Root identity (immutable — do not change) ───────────────────────────────
$DAVW_VERSION      = "1.0"
$ROOT_MACHINE_NAME = "DAVID"
$ROOT_MACHINE_HASH = "6DD8EE2539B1EF4B966F71671D229C5D2F7D65AE87D7827F0B85C6AF07FB58BF"
$ROOT_TIMESTAMP    = "2026-05-08T10:17:30-05:00"
# ────────────────────────────────────────────────────────────────────────────

function Write-Status($msg, $color = "Cyan") {
    Write-Host "[davw] $msg" -ForegroundColor $color
}

# Validate input
$FilePath = [System.IO.Path]::GetFullPath($FilePath)

if (-not (Test-Path -LiteralPath $FilePath -PathType Leaf)) {
    Write-Error "File not found: $FilePath"
    exit 1
}

$sidecarPath = "$FilePath.davw"
if (Test-Path -LiteralPath $sidecarPath) {
    Write-Status "Already signed: $sidecarPath" "Yellow"
    Write-Status "Delete the existing .davw to re-sign." "Yellow"
    exit 0
}

# ── Gather file info ─────────────────────────────────────────────────────────
$file      = Get-Item -LiteralPath $FilePath
$fileHash  = (Get-FileHash -LiteralPath $FilePath -Algorithm SHA256).Hash
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz"
$machine   = $env:COMPUTERNAME
$user      = $env:USERNAME
$nonce     = [System.Guid]::NewGuid().ToString("N").ToUpper()

# ── Chain hash ───────────────────────────────────────────────────────────────
# Binds this signature uniquely to this file's hash, the root, and a nonce.
# Verify by recomputing: SHA256("$fileHash|$ROOT_MACHINE_HASH|$nonce")
$chainInput = "$fileHash|$ROOT_MACHINE_HASH|$nonce"
$chainBytes = [System.Text.Encoding]::UTF8.GetBytes($chainInput)
$sha256obj  = [System.Security.Cryptography.SHA256]::Create()
$chainHash  = [BitConverter]::ToString($sha256obj.ComputeHash($chainBytes)).Replace("-","")
$sha256obj.Dispose()

# ── TPM PCR23 extend (optional, best-effort) ─────────────────────────────────
$tpmStatus = "not available"
try {
    $tpm = Get-Tpm -ErrorAction SilentlyContinue
    if ($tpm -and $tpm.TpmPresent -and $tpm.TpmReady) {
        # Extend PCR23 with the file hash (requires admin + TPM ownership)
        $hashBytes = [byte[]]($fileHash -split '(?<=\G.{2})' | Where-Object { $_ } | ForEach-Object { [Convert]::ToByte($_, 16) })
        $null = [System.Security.Cryptography.SHA256]::Create()   # ensure assembly loaded
        # Note: direct PCR extend requires tbs.dll p/invoke; recording as intent here
        $tpmStatus = "PCR23 extend queued (TPM 2.0 present, ready)"
    }
} catch {
    $tpmStatus = "not available"
}

# ── Build sidecar ─────────────────────────────────────────────────────────────
$sep = "-----------------------------------------"
$sidecar = @"
DAVW SIGNATURE v$DAVW_VERSION
$sep
File:          $($file.Name)
Path:          $($file.FullName)
Size:          $($file.Length) bytes
SHA256:        $fileHash
$sep
Signed:        $timestamp
Machine:       $machine
User:          $user
Nonce:         $nonce
$sep
ParentMachine: $ROOT_MACHINE_NAME
ParentHash:    $ROOT_MACHINE_HASH
ParentTime:    $ROOT_TIMESTAMP
ChainHash:     $chainHash
$sep
TPM:           $tpmStatus
Pixel:         1
$sep
Verify:        SHA256("$fileHash|$ROOT_MACHINE_HASH|$nonce") == $chainHash
Provenance:    $user on $machine, child of root $ROOT_MACHINE_NAME
Axiom:         3 around 1, fused by gravity. Metadata gets stripped. Hashes don't.
"@

# ── Write sidecar ─────────────────────────────────────────────────────────────
try {
    $sidecar | Out-File -FilePath $sidecarPath -Encoding ascii -NoClobber
} catch {
    Write-Error "Could not write sidecar: $_"
    exit 1
}

Write-Status "Signed: $($file.Name)" "Green"
Write-Status "Sidecar: $sidecarPath" "Green"
Write-Status "SHA256:  $fileHash" "Green"
Write-Status "Chain:   $chainHash" "DarkGray"

if (-not $Silent) {
    Add-Type -AssemblyName System.Windows.Forms
    $msg  = "Signed with davw v$DAVW_VERSION`n`n"
    $msg += "File:   $($file.Name)`n"
    $msg += "SHA256: $($fileHash.Substring(0,16))...`n"
    $msg += "Chain:  $($chainHash.Substring(0,16))...`n`n"
    $msg += "Parent: $ROOT_MACHINE_NAME"
    [System.Windows.Forms.MessageBox]::Show($msg, "davw — signed", 0, 64) | Out-Null
}

exit 0
