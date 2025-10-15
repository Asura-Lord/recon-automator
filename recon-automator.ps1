<#
recon-automator.ps1
Simple helper: prints HELP.md on --help, or short usage otherwise.
Usage:
  recon-automator --help
  recon-automator
#>

Param(
  [switch]$Help
)

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
$helpFile = Join-Path $scriptRoot "HELP.md"

function Show-Short {
  Write-Host ""
  Write-Host "recon-automator helper - quick usage"
  Write-Host "  .\recon.ps1 -Target <IP> [-Dir]         # Windows PowerShell orchestration"
  Write-Host "  ./recon.sh --target <IP> [--dir]       # Linux orchestration (if available)"
  Write-Host "  python parse_results.py --input <dir> --output <dir>/summary.json"
  Write-Host ""
  Write-Host "Run 'recon-automator --help' to view full HELP.md"
  Write-Host ""
}

# Accept --help or -h via $args as well
if ($Help -or $args -contains '--help' -or $args -contains '-h') {
  if (Test-Path $helpFile) {
    Get-Content $helpFile -Raw | Out-Host
    exit 0
  } else {
    Write-Host "HELP.md not found in $scriptRoot"
    exit 1
  }
} else {
  Show-Short
  exit 0
}