# ⚡ recon-automator

![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20Linux-blue?style=flat-square)
![License](https://img.shields.io/badge/license-MIT-brightgreen?style=flat-square)
![Status](https://img.shields.io/badge/status-LAB--ONLY-red?style=flat-square)

**Lightweight, lab-only recon automation** — Nmap + HTTP checks + optional dir fuzzing → single `summary.json`  
_Built for CTFs, learning, and defensive detection practice. **Run only in isolated VMs.**_

---

## 🔐 Quick warning

> **:warning: DO NOT** run these scripts against public networks or systems you do not own or have explicit permission to test.  
> This project is for lab environments only (VMware/VirtualBox, isolated networks, snapshots).

---

## 🧩 What it does

- 🔍 Runs `nmap` (service detection & safe NSE scripts), saves XML + grepable output
- 🌐 Fetches HTTP headers and `robots.txt` for `http` and `https`
- 🗂️ Optionally runs directory fuzzing with `ffuf` or `dirb`
- 📄 Produces a single, clean `summary.json` via `parse_results.py` for easy review

---

## 📂 Main files

| File/Folder          | Description                                 |
|----------------------|---------------------------------------------|
| `recon.ps1`          | PowerShell orchestration (Windows)          |
| `recon.sh`           | Bash orchestration (Linux, optional)        |
| `parse_results.py`   | Parser → `summary.json`                     |
| `sample_results/`    | Example run (BOM cleaned)                   |
| `README.md`          | This file                                   |
| `LICENSE`            | Open source license                         |

---

## 🚀 Quickstart

Get up and running with recon-automator in just a few steps!

---

### 🪟 Windows (PowerShell)

1. **Download the tool:**
   ```powershell
   git clone https://github.com/Asura-Lord/recon-automator.git
   cd recon-automator
   ```
2. **Enable script execution (one-time step):**
   ```powershell
   Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
   ```
3. **Run the recon script:**  
   Replace `<IP>` with your target machine’s IP address.
   ```powershell
   .\recon.ps1 -Target <IP> -dir 
   ```
4. **Get your summary:**
   ```powershell
   python parse_results.py --input .\results\latest --output .\results\latest\summary.json
   Get-Content .\results\latest\summary.json | Out-Host
   ```

---

### 🐧 Linux / Kali (Bash)

1. **Download the tool:**
   ```bash
   git clone https://github.com/Asura-Lord/recon-automator.git
   cd recon-automator
   ```
2. **Make the script executable (one-time step):**
   ```bash
   chmod +x recon.sh
   ```
3. **Install jq (for pretty output):**
   ```bash
   sudo apt update && sudo apt install -y jq
   ```
4. **Run the recon script:**  
   Replace `<IP>` with your target machine’s IP address.
   ```bash
   ./recon.sh --target <IP> --dir --wordlist /usr/share/wordlists/dirb/common.txt 
   ```
5. **Get your summary:**
   ```bash
   python3 parse_results.py --input results/latest --output results/latest/summary.json
   jq . results/latest/summary.json
   ```

---

**That’s it!**  
All your results are saved in `results/latest` for easy access.  
Only use this tool in lab environments you own or have permission to scan.
---

## 🧾 Example output (`summary.json`)

```json
{
  "target": "192.168.186.128_latest",
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
    "http_headers.txt":"[!] Failed headers for http://192.168.186.128",
    "http_robots.txt":"No robots or failed to fetch"
  },
  "dir": {}
}
```

---

## 🖼️ Screenshot

<img width="1917" height="757" alt="demo" src="https://github.com/user-attachments/assets/00b20f10-dd2e-4942-97cc-f33ef8eb14b9" />

---

## 🔭 Next-level ideas

- [ ] HTML report generator from summary.json (Streamlit / Flask)
- [ ] Slack/Discord webhook dry-run notifier (lab-only)
- [ ] Parsers for ffuf, gobuster, nuclei, and HTML reports
- [ ] CI check to validate summary.json format

---

## ⚖️ Responsible use

> This repo is an educational tool.  
> Always have permission before scanning.  
> Use snapshots, isolated networks, and follow rules of engagement.

---

## 🧾 License & contact

MIT — see [LICENSE](LICENSE).  
Maintained by [Asura-Lord](https://github.com/Asura-Lord)

_Keep it dangerous, keep it legal. — Asura-Lord 👹_
