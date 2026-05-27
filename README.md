# Honey Badger v1.0
**the first and last**

First author: David Wise (DAVID)
Root hash: `6DD8EE2539B1EF4B966F71671D229C5D2F7D65AE87D7827F0B85C6AF07FB58BF`
Root timestamp: 2026-05-08 10:17:30 CDT
Pixel: 1

> *3 around 1, fused by gravity. Substrate invariant, infinite, omnipresent.*
> *Metadata gets stripped. Hashes don't. The hash bites back.*

---

## What it is

Honey Badger is a right-click file signing tool for Windows. Every file you sign gets a `.davw` sidecar — a plain-text record that cryptographically ties that file to your root machine identity.

It doesn't need the cloud. It doesn't need an account. It doesn't need a server. It works offline, forever, because it's just math.

**The problem it solves:** AI-generated content, legal documents, creative work — metadata gets stripped when files move. EXIF is gone. Creation dates lie. There's no way to prove a file came from a specific machine at a specific time... unless you hash it first.

Honey Badger hashes first.

---

## How it works

```
Your file
    ↓
SHA256(file) → file hash
    ↓
ChainHash = SHA256(file_hash | root_hash | nonce)
    ↓
.davw sidecar written beside the file
```

The **ChainHash** is the key. It's a unique cryptographic fingerprint that:
- Proves the file's exact content at signing time
- Links it to your root machine identity
- Uses a nonce so no two signatures are identical
- Can be recomputed and verified by anyone, forever

---

## What's in a .davw sidecar

```
DAVW SIGNATURE v1.0
─────────────────────────────────────────
File:          report.pdf
Path:          C:\Users\Dave\Documents\report.pdf
Size:          142871 bytes
SHA256:        A3F9C2...E847
─────────────────────────────────────────
Signed:        2026-05-27 14:32:01 -05:00
Machine:       WORKSTATION-01
User:          Dave
Nonce:         7F3A9C2D1B4E5F68A0C3D2E1F0A9B8C7
─────────────────────────────────────────
ParentMachine: DAVID
ParentHash:    6DD8EE2539B1EF4B966F71671D229C5D2F7D65AE87D7827F0B85C6AF07FB58BF
ParentTime:    2026-05-08T10:17:30-05:00
ChainHash:     B4D7A2...F193
─────────────────────────────────────────
TPM:           PCR23 extend queued (TPM 2.0 present, ready)
Pixel:         1
─────────────────────────────────────────
Verify:        SHA256("A3F9C2...|6DD8EE...|7F3A9C...") == B4D7A2...
Provenance:    Dave on WORKSTATION-01, child of root DAVID
Axiom:         3 around 1, fused by gravity.
```

---

## Install

```
1. Download / unzip honey-badger-v1-core
2. Run install.bat
3. Right-click any file → "Sign with davw"
4. Right-click any .davw file → "Verify davw"
```

No admin required. Installs per-user.

---

## Command line

```powershell
# Sign a file
.\sign-with-davw.ps1 -FilePath "C:\path\to\file.pdf"

# Sign silently (no popup — good for scripts)
.\sign-with-davw.ps1 -FilePath "C:\path\to\file.pdf" -Silent

# Verify a signature
.\verify-davw.ps1 -Path "C:\path\to\file.pdf"

# Watch a folder — auto-signs every new file
.\watch-davw.ps1 -WatchPath "C:\MyOutputFolder"

# Watch with filter
.\watch-davw.ps1 -WatchPath "C:\Output" -Extensions "pdf,docx,png" -Interval 5

# Uninstall context menus
.\install-davw-context.ps1 -Uninstall
```

---

## Verify output

```
 HONEY BADGER — davw verify v1.0
 ─────────────────────────────────

 Source:   report.pdf
 Signed:   2026-05-27 14:32:01 by Dave on WORKSTATION-01
 Parent:   DAVID — 6DD8EE2539...B58BF

[PASS]  File exists: C:\Users\Dave\Documents\report.pdf
[PASS]  File hash: A3F9C2...E847
[PASS]  Chain hash: B4D7A2...F193

 ══ VERIFIED — file matches sidecar, chain intact ══
```

---

## Use cases

| Scenario | What Honey Badger proves |
|----------|--------------------------|
| AI-generated images | This image came from this machine, before this date |
| Legal documents | File hasn't changed since signing |
| Creative IP | First author claim with machine-rooted timestamp |
| Code releases | Build artifacts tied to the build machine |
| Evidence files | Chain of custody with tamper detection |
| Anything | File + machine + time, cryptographically bound |

---

## The chain

Every Honey Badger installation inherits from the root machine (DAVID).
Your `.davw` files are children of `6DD8EE...B58BF`.

If you build tools on top of Honey Badger, your tool's root becomes
a child of DAVID — and the chain extends. This is the provenance model:
every file knows its parent machine. Every machine knows its root.

---

## Files

```
honey-badger-v1-core/
├── sign-with-davw.ps1       Core signer
├── verify-davw.ps1          Signature verifier
├── watch-davw.ps1           Folder watcher / MAKER_BOT
├── install-davw-context.ps1 Context menu installer (+ uninstall)
├── install.bat              Run this to install
├── uninstall.bat            Run this to uninstall
└── README.txt               Quick reference

honey-badger-v01-core/       Original v0.1 — preserved as historical record
FIRST_AUTHOR.json            Root identity declaration
MACHINE.davw                 The first signature (the machine itself)
CHANGELOG.md                 Version history
```

---

## License

First Author Reserved.
Use it, fork it, build on it — but keep the root hash.
The chain starts at DAVID. That's the axiom.
