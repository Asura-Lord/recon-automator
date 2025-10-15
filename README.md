<p align="center">
  <img src="https://upload.wikimedia.org/wikipedia/commons/6/6b/Digital_rain_animation_medium_letters_shine.gif" width="900" alt="matrix digital rain"/>
</p>

# ⚡ recon-automator
> Lightweight, **lab-only** recon automation — Nmap + HTTP checks + optional dir fuzzing → single `summary.json`.  
> Built for CTFs, learning, and defensive detection practice. Run only in isolated VMs.

---

| _ \ ___ ___ _ | | ___ _ __
| |) / _ / | | | | |/ _ | '

| _ < /_ \ || | | () | | | |
|| ||/,||/|| |_|
recon-automator v1.0


---

## 🔐 Quick Warning (Read This)
**DO NOT** run these scripts against public networks or systems you do not own or have explicit permission to test.
This project is for **lab environments only** (VMware/VirtualBox, isolated networks, snapshots).

---

## 🧩 What It Does
- Runs `nmap` (service detection & scripts) and saves XML + grepable outputs.
- Fetches HTTP headers and `robots.txt` (http/https).
- Optionally runs directory fuzzing with `ffuf`/`dirb`.
- Produces a single, clean `summary.json` via `parse_results.py` for easy review or ingestion.

---

## 🔧 Files (What to Look At)
- `recon.ps1` — PowerShell orchestration (Windows)
- `recon.sh` — Bash orchestration (Linux) *(optional)*
- `parse_results.py` — parser -> `summary.json`
- `sample_results/` — example run (BOM cleaned)
- `docs/demo.gif` — put demo GIF here (recommended)
- `README.md`, `LICENSE`, `.gitignore`

---

## 🚀 Quickstart — Windows (PowerShell)

1. Clone:
```powershell
git clone [https://github.com/Asura-Lord/recon-automator.git](https://github.com/Asura-Lord/recon-automator.git)
cd recon-automator
Allow scripts (one-time):

PowerShell

Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
Run (lab IP):

PowerShell

.\recon.ps1 -Target 10.0.2.15 -Dir
Summarize:

PowerShell

python parse_results.py --input .\results\<target_timestamp> --output .\results\<target_timestamp>\summary.json
Get-Content .\results\<target_timestamp>\summary.json | Out-Host
🐧 Quickstart — Linux / Kali (Bash)
Clone and Setup:

Bash

git clone [https://github.com/Asura-Lord/recon-automator.git](https://github.com/Asura-Lord/recon-automator.git)
cd recon-automator
chmod +x recon.sh
Run (lab IP):

Bash

./recon.sh --target 10.0.2.15 --dir --wordlist /usr/share/wordlists/dirb/common.txt
Summarize:

Bash

python3 parse_results.py --input results/10.0.2.15_* --output results/10.0.2.15_summary.json
jq . results/10.0.2.15_summary.json
🧾 Example Output (Cleaned summary.json)
JSON

{
  "target": "192.168.186.128_20251014_100936",
  "nmap": {
    "hosts": [
      {
        "addresses": [
          {"addr":"192.168.186.128","addrtype":"ipv4"},
          {"addr":"00:0C:29:D6:4C:37","addrtype":"mac","vendor":"VMware"}
        ],
        "ports": [
          {
            "portid":"22",
            "protocol":"tcp",
            "state":{"state":"open","reason":"syn-ack"},
            "service":{"name":"ssh","product":"OpenSSH","version":"10.0p2 Debian 5"}
          }
        ]
      }
    ]
  },
  "http": {
    "http_headers.txt":"[!] Failed headers for [http://192.168.186.128](http://192.168.186.128)",
    "http_robots.txt":"No robots or failed to fetch"
  },
  "dir": {}
}
✅ Tips to Make It Look Pro
Commit a cleaned sample_results/sample_summary.json so visitors see real output.

Add a short docs/demo.gif (8–12s) showing a run → embed it in README.

Pin this repo on your GitHub profile.

Embed GIF Example
Markdown

<p align="center">
  <img src="./docs/demo.gif" width="850" alt="demo run"/>
</p>
🔭 Next-Level Ideas (Grow This)
HTML report generator from summary.json (Streamlit / Flask)

Slack/Discord webhook dry-run notifier (lab-only)

Parsers for ffuf, gobuster, nuclei and HTML reports

CI check to validate summary.json format

⚖️ Responsible Use
This repo is an educational tool. Always have permission before scanning. Use snapshots, isolated networks, and follow rules of engagement.

🧾 License & Contact
MIT — see LICENSE.
Maintained by Asura-Lord.
Repo: https://github.com/Asura-Lord/recon-automator

Keep it dangerous, keep it legal. — Asura-Lord
