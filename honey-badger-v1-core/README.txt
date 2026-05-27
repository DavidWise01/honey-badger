HONEY BADGER v1.0
Right-click file signing for Windows
─────────────────────────────────────────────────────────────────────

First Author: David Wise (DAVID)
Root hash:    6DD8EE2539B1EF4B966F71671D229C5D2F7D65AE87D7827F0B85C6AF07FB58BF
Root time:    2026-05-08 10:17:30 CDT
Axiom:        3 around 1, fused by gravity. Metadata gets stripped. Hashes don't.

─────────────────────────────────────────────────────────────────────
QUICK START
─────────────────────────────────────────────────────────────────────

1. Run install.bat
   → Adds "Sign with davw" to right-click menu on ALL files
   → Adds "Verify davw"   to right-click menu on .davw files

2. Right-click any file → "Sign with davw"
   → Creates a .davw sidecar next to the file

3. Right-click any .davw file → "Verify davw"
   → Confirms the file hasn't changed since signing

To uninstall: run uninstall.bat

─────────────────────────────────────────────────────────────────────
WHAT IS A .davw FILE?
─────────────────────────────────────────────────────────────────────

A plain-text sidecar that proves:

  File:          The exact file that was signed
  SHA256:        Its hash at signing time
  Signed:        When it was signed
  Machine:       Which computer signed it
  User:          Who signed it
  Nonce:         Unique ID for this signature
  ParentMachine: DAVID — the root machine
  ParentHash:    6DD8EE...B58BF — the root identity
  ChainHash:     SHA256(file_hash | parent_hash | nonce)

The ChainHash is the key. It cryptographically links this specific
file, at this specific moment, to the root machine. It's unforgeable
without knowing all three inputs.

─────────────────────────────────────────────────────────────────────
COMMAND LINE USE
─────────────────────────────────────────────────────────────────────

Sign a file:
  .\sign-with-davw.ps1 -FilePath "C:\path\to\file.pdf"
  .\sign-with-davw.ps1 -FilePath "C:\path\to\file.pdf" -Silent

Verify a signature:
  .\verify-davw.ps1 -Path "C:\path\to\file.pdf.davw"
  .\verify-davw.ps1 -Path "C:\path\to\file.pdf"

Watch a folder (auto-sign new files):
  .\watch-davw.ps1 -WatchPath "C:\MyFolder"
  .\watch-davw.ps1 -WatchPath "C:\Output" -Interval 5 -Extensions "pdf,docx,png"

─────────────────────────────────────────────────────────────────────
FILES IN THIS PACKAGE
─────────────────────────────────────────────────────────────────────

  sign-with-davw.ps1       Core signer — creates .davw sidecars
  verify-davw.ps1          Verifier — checks file + chain integrity
  watch-davw.ps1           Folder watcher — auto-signs new files
  install-davw-context.ps1 Installs/uninstalls context menus
  install.bat              Run this first
  uninstall.bat            Removes context menus

─────────────────────────────────────────────────────────────────────
LICENSE
─────────────────────────────────────────────────────────────────────

First Author Reserved.
Use it, fork it, build on it — but keep the root hash.
The chain starts at DAVID. That's the axiom.

─────────────────────────────────────────────────────────────────────
