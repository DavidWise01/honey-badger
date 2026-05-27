# Honey Badger — Changelog

---

## v1.0 — 2026-05-27

**New files:**
- `verify-davw.ps1` — verifies a .davw sidecar against its source file
  - Checks file exists, recomputes SHA256, recomputes ChainHash
  - PASS/FAIL output with full provenance display
- `watch-davw.ps1` — folder watcher / autonomous attestation bot
  - Polls a folder on an interval (default 10s)
  - Auto-signs any new unsigned file
  - Extension filter support
  - Activity log
- `uninstall.bat` — removes context menu entries cleanly

**Upgraded:**
- `sign-with-davw.ps1` v0.3 → v1.0
  - Added `Nonce` field (GUID) — every signature is unique
  - Added `ChainHash` = SHA256(file_hash | parent_hash | nonce) — verifiable chain link
  - Added `-Silent` switch for batch/watcher use
  - Better TPM detection (presence + readiness check)
  - Sidecar already-exists guard (won't overwrite)
  - Cleaner output format with separator lines
  - `Set-StrictMode -Version Latest` + proper error handling
- `install-davw-context.ps1` v0.3 → v1.0
  - Added `"Verify davw"` context menu on `.davw` files
  - Added `-Uninstall` flag (replaces need for separate uninstall script)
  - Prefers `pwsh.exe` (PowerShell 7+), falls back to `powershell.exe`
  - Installs to `%LOCALAPPDATA%\davw` (no admin required)
  - Registers `.davw` file extension
- `install.bat`
  - Removed "shareware" label
  - Tries `pwsh` first, falls back to `powershell.exe`
  - Cleaner banner

**Docs:**
- `README.md` rewritten for v1.0 — full use cases, verify output example, chain explanation
- `CHANGELOG.md` (this file) added
- `honey-badger-v01-core/` preserved unchanged as historical record

---

## v0.3 — 2026-05-08 (released as v0.1 publicly)

- `sign-with-davw.ps1` — core signer with machine root
  - SHA256 + machine name + user + timestamp
  - ParentMachine + ParentHash fields
  - TPM PCR23 detection (presence only)
  - Windows Forms popup confirmation
- `install-davw-context.ps1` — HKCU registry context menu
- `install.bat` — elevation + PowerShell runner
- `MACHINE.davw` — the root signature (machine DAVID signed itself)
- `FIRST_AUTHOR.json` — root identity declaration

---

## v0.1 — 2026-05-08 (genesis)

Root machine DAVID signed itself at 10:17:30 CDT.
Hash: `6DD8EE2539B1EF4B966F71671D229C5D2F7D65AE87D7827F0B85C6AF07FB58BF`
Pixel: 1.
The chain begins here.
