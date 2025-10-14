<p align="center">
  <img src="https://upload.wikimedia.org/wikipedia/commons/6/6b/Digital_rain_animation_medium_letters_shine.gif" width="800" alt="matrix digital rain"/>
</p>

# recon-automator
> Fast, lab-safe recon automation — Nmap, HTTP checks, optional dir fuzzing, and one-command JSON summarization.  
> Designed for learning, CTFs, and defensive detection practice. **Lab-only.**

[![Repo size](https://img.shields.io/github/repo-size/Asura-Lord/recon-automator)](https://github.com/Asura-Lord/recon-automator)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20Linux-lightgrey)](#)
[![Language](https://img.shields.io/badge/lang-PowerShell%20%7C%20Python-9cf)](#)
[![Stars](https://img.shields.io/github/stars/Asura-Lord/recon-automator?style=social)](https://github.com/Asura-Lord/recon-automator/stargazers)

---

## What is this?
**recon-automator** is a lightweight recon workflow that:
- runs quick Nmap scans,
- fetches `robots.txt` & HTTP headers,
- optionally runs directory fuzzing (ffuf/dirb),
- consolidates results into a single `summary.json` for easy reading and ingestion into other tools.

**Key design goals:** safe-by-default, reproducible, Windows-friendly (PowerShell), and easy to extend.

---

## ⚠️ Safety / Ethics (read this first)
This project is **for labs, CTFs, and authorized testing only**.  
Do **not** run these scripts against networks or systems you do not own or have explicit permission to test. Use VM snapshots and isolated networks.

---

## Features
- One command orchestration (`recon.ps1` on Windows) — no complicated flags.
- Output organized per-target with timestamps: `results/<target>_<timestamp>/`.
- Nmap XML + grepable outputs for deeper parsing.
- HTTP header & `robots.txt` capture for quick triage.
- Optional directory enumeration using `ffuf` or `dirb`.
- `parse_results.py` merges results into `summary.json` for sharing/writeups.

---

## Quick badges (status)
- Platform: Windows + Linux
- Scripts: `recon.ps1` (PowerShell) + `parse_results.py` (Python)
- License: MIT

---

## Quickstart — Windows (PowerShell) — **recommended**
1. Clone:
```powershell
git clone https://github.com/Asura-Lord/recon-automator.git
cd recon-automator
