# recon-automator (Windows-friendly)

Run quick lab-only recon using Nmap + HTTP header/robots fetch. Optional dir fuzz if ffuf installed.

Usage (PowerShell):
  .\recon.ps1 -Target 10.0.2.15 -Dir

Then:
  python parse_results.py --input .\results\<target_timestamp> --output .\results\<target_timestamp>\summary.json

 Lab-only: only run against VMs/targets you own or have permission to test.
