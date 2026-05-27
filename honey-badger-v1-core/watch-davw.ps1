<#
.SYNOPSIS
    Honey Badger v1.0 — folder watcher / autonomous attestation bot

.DESCRIPTION
    Watches a folder and automatically signs new files as they appear.
    Any file dropped into the watch folder that doesn't already have a
    .davw sidecar gets signed immediately.

    This is the MAKER_BOT — it runs in the background and proves
    everything that lands in the folder.

.PARAMETER WatchPath
    Folder to watch. Defaults to current directory.

.PARAMETER Interval
    Poll interval in seconds. Default: 10.

.PARAMETER LogFile
    Path to write activity log. Default: <WatchPath>\watch-davw.log

.PARAMETER Extensions
    Comma-separated list of extensions to sign. Default: all files.
    Example: "pdf,docx,jpg,png"

.EXAMPLE
    .\watch-davw.ps1
    .\watch-davw.ps1 -WatchPath "C:\MyDocs" -Interval 5
    .\watch-davw.ps1 -WatchPath "C:\Output" -Extensions "pdf,png,docx"
#>

param(
    [string]$WatchPath  = (Get-Location).Path,
    [int]   $Interval   = 10,
    [string]$LogFile    = "",
    [string]$Extensions = ""
)

Set-StrictMode -Version Latest

$WatchPath = [System.IO.Path]::GetFullPath($WatchPath)
if (-not (Test-Path -LiteralPath $WatchPath -PathType Container)) {
    Write-Error "Watch path not found: $WatchPath"
    exit 1
}

if (-not $LogFile) {
    $LogFile = Join-Path $WatchPath "watch-davw.log"
}

$scriptDir  = $PSScriptRoot
$signerPath = Join-Path $scriptDir "sign-with-davw.ps1"

if (-not (Test-Path -LiteralPath $signerPath)) {
    Write-Error "sign-with-davw.ps1 not found at: $signerPath"
    exit 1
}

# Parse extensions filter
$extFilter = @()
if ($Extensions) {
    $extFilter = $Extensions.Split(",") | ForEach-Object { "." + $_.Trim().TrimStart(".").ToLower() }
}

function Write-Log($msg) {
    $ts   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "[$ts] $msg"
    Write-Host $line -ForegroundColor DarkCyan
    Add-Content -Path $LogFile -Value $line -Encoding ASCII
}

function Should-Sign($file) {
    # Skip .davw sidecars themselves
    if ($file.Extension -eq ".davw") { return $false }
    # Skip the log file
    if ($file.FullName -eq $LogFile)  { return $false }
    # Skip already-signed files
    if (Test-Path -LiteralPath "$($file.FullName).davw") { return $false }
    # Apply extension filter if set
    if ($extFilter.Count -gt 0) {
        if ($extFilter -notcontains $file.Extension.ToLower()) { return $false }
    }
    return $true
}

Write-Host ""
Write-Host " HONEY BADGER — watch-davw v1.0" -ForegroundColor Cyan
Write-Host " Watching: $WatchPath" -ForegroundColor White
Write-Host " Interval: every $Interval seconds" -ForegroundColor DarkGray
Write-Host " Log:      $LogFile" -ForegroundColor DarkGray
if ($extFilter.Count -gt 0) {
    Write-Host " Filter:   $($extFilter -join ', ')" -ForegroundColor DarkGray
} else {
    Write-Host " Filter:   all files" -ForegroundColor DarkGray
}
Write-Host " Press Ctrl+C to stop." -ForegroundColor DarkGray
Write-Host ""

Write-Log "Watcher started. Path=$WatchPath Interval=$Interval"

$signed = 0
$errors = 0

try {
    while ($true) {
        $files = Get-ChildItem -LiteralPath $WatchPath -File -ErrorAction SilentlyContinue

        foreach ($file in $files) {
            if (Should-Sign $file) {
                Write-Log "Signing: $($file.Name)"
                try {
                    & pwsh -NoProfile -ExecutionPolicy Bypass -File $signerPath -FilePath $file.FullName -Silent
                    if ($LASTEXITCODE -eq 0) {
                        Write-Log "Signed:  $($file.Name) [OK]"
                        $signed++
                    } else {
                        Write-Log "Skipped: $($file.Name) [exit $LASTEXITCODE]"
                    }
                } catch {
                    Write-Log "ERROR:   $($file.Name) — $_"
                    $errors++
                }
            }
        }

        Start-Sleep -Seconds $Interval
    }
} finally {
    Write-Log "Watcher stopped. Signed=$signed Errors=$errors"
    Write-Host ""
    Write-Host " Watcher stopped. Signed $signed file(s)." -ForegroundColor Yellow
}
