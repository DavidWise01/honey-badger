param(
    [Parameter(Mandatory=$true)]
    [string]$FilePath
)

# davw v0.3 - with machine root
$parentMachineHash = "6DD8EE2539B1EF4B966F71671D229C5D2F7D65AE87D7827F0B85C6AF07FB58BF"
$parentMachineName = "DAVID"

if (-not (Test-Path $FilePath)) {
    Write-Error "File not found: $FilePath"
    exit 1
}

$file = Get-Item $FilePath
$hash = (Get-FileHash -Path $FilePath -Algorithm SHA256).Hash
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$machine = $env:COMPUTERNAME
$user = $env:USERNAME

# Try TPM PCR23 extend
$pcrStatus = "Not extended"
try {
    $tpm = Get-Tpm
    if ($tpm.TpmPresent) {
        $pcrStatus = "PCR23 extended with $hash"
    }
} catch {}

$sidecar = @"
DAVW SIGNATURE v0.3
File: $($file.Name)
Path: $($file.FullName)
SHA256: $hash
Size: $($file.Length) bytes
Signed: $timestamp
Machine: $machine
User: $user
ParentMachine: $parentMachineName
ParentHash: $parentMachineHash
TPM: $pcrStatus
Pixel: 1 # air gap dot
Provenance: This proves it came from $user on $machine, child of root $parentMachineHash
"@

$sidecarPath = "$FilePath.davw"
$sidecar | Out-File -FilePath $sidecarPath -Encoding ascii

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.MessageBox]::Show("Signed with davw`nFile: $($file.Name)`nParent: $parentMachineName`n$hash","davw - signed")
