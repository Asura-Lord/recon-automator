# recon-automator  Help / Quick Reference

## NAME
recon-automator  lightweight lab recon orchestration & quick reference.

## OVERVIEW
This repo provides:
- recon.sh (Linux) and recon.ps1 (Windows) orchestration scripts
- parse_results.py to merge outputs into summary.json
- usage examples and safe lab guidance

## USAGE (Windows PowerShell)
Run the Windows orchestration:
  .\recon.ps1 -Target <IP> [-Dir] 

Then summarize:
  python parse_results.py --input .\results\<target_timestamp> --output .\results\<target_timestamp>\summary.json

## USAGE (Linux / Kali)
Run Linux orchestration (if recon.sh exists):
  ./recon.sh --target <IP> [--dir] [--wordlist /path/to/wordlist]

Then summarize:
  python3 parse_results.py --input ./results/<target_timestamp> --output ./results/<target_timestamp>/summary.json

## FLAGS (common)
- --target / -t    Target IP or hostname (required)
- --dir            Enable directory fuzzing (requires ffuf)
- --wordlist       Path to wordlist for dir fuzzing
- -h, --help       Show this help text

## OUTPUT
Results are stored under:
  results/<target>_<timestamp>/
   nmap/   (scan.xml, scan.nmap, scan.gnmap)
   http/   (http_headers.txt, http_robots.txt)
   dir/    (ffuf/gobuster output, optional)
   summary.json  (merged output)

## TROUBLESHOOTING QUICK
- If nmap missing: `sudo apt install nmap` or install on Windows
- If curl missing: `sudo apt install curl` or use Windows Invoke-WebRequest
- If parser shows BOM characters (\u00ef\u00bb\u00bf): remove BOM or regenerate file with UTF8 no BOM
- If git push fails: use your GitHub username and PAT (or configure SSH)

## ETHICS / SAFETY
Run only on VMs or systems you own or have explicit permission to test. Use snapshots and isolated networks.

Maintained by Asura-Lord  https://github.com/Asura-Lord/recon-automator