# install-davw-context.ps1
$scriptPath = Join-Path $PSScriptRoot "sign-with-davw.ps1"
if (-not (Test-Path $scriptPath)) { Write-Error "sign-with-davw.ps1 not found"; exit 1 }
$installDir = "$env:ProgramFiles\davw"
New-Item -ItemType Directory -Force -Path $installDir | Out-Null
Copy-Item $scriptPath "$installDir\sign-with-davw.ps1" -Force
$psExe = "powershell.exe"
$command = "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$installDir\sign-with-davw.ps1`" `"%1`""
$regPath = "HKCU:\Software\Classes\*\shell\davw"
New-Item -Path $regPath -Force | Out-Null
Set-ItemProperty -Path $regPath -Name "(Default)" -Value "Sign with davw"
Set-ItemProperty -Path $regPath -Name "Icon" -Value "imageres.dll,-78"
New-Item -Path "$regPath\command" -Force | Out-Null
Set-ItemProperty -Path "$regPath\command" -Name "(Default)" -Value "$psExe $command"
Write-Host "[OK] Sign with davw v0.3 installed"
Write-Host "Parent root: 6DD8EE2539B1EF4B966F71671D229C5D2F7D65AE87D7827F0B85C6AF07FB58BF"
