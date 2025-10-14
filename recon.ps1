Param(
  [Parameter(Mandatory=$true)][string] $Target,
  [switch] $Dir,
  [string] $Wordlist = "C:\ProgramData\wordlists\common.txt"
)

if (-not $Target) { Write-Error "Target is required (e.g. 10.0.2.15)"; exit 1 }

$ts = (Get-Date).ToString("yyyyMMdd_HHmmss")
$targetDir = Join-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "results") -ChildPath ("{0}_{1}" -f $Target, $ts)
New-Item -Path $targetDir -ItemType Directory -Force | Out-Null
New-Item -Path (Join-Path $targetDir "nmap") -ItemType Directory -Force | Out-Null
New-Item -Path (Join-Path $targetDir "http") -ItemType Directory -Force | Out-Null
if ($Dir) { New-Item -Path (Join-Path $targetDir "dir") -ItemType Directory -Force | Out-Null }

Write-Host "[*] Output -> $targetDir"

# Run nmap (requires nmap in PATH)
Write-Host "[*] Running nmap..."
$nmapBase = Join-Path $targetDir "nmap\scan"
$nmapCmd = "nmap -sC -sV -oA `"$nmapBase`" $Target"
Write-Host "[CMD] $nmapCmd"
Invoke-Expression $nmapCmd

# HTTP header + robots
Write-Host "[*] Fetching headers & robots.txt"
foreach ($proto in @("http","https")) {
  $url = "${proto}://$Target"
  try {
    $hdrOut = Join-Path $targetDir ("http\{0}_headers.txt" -f $proto)
    $robotsOut = Join-Path $targetDir ("http\{0}_robots.txt" -f $proto)
    $resp = Invoke-WebRequest -Uri $url -Method Head -UseBasicParsing -ErrorAction Stop -TimeoutSec 10
    $resp.Headers | Out-File -FilePath $hdrOut -Encoding utf8
  } catch {
    "[!] Failed headers for $url" | Out-File -FilePath $hdrOut -Encoding utf8 -Append
  }
  try {
    Invoke-WebRequest -Uri "$url/robots.txt" -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop | Select-Object -ExpandProperty Content | Out-File -FilePath $robotsOut -Encoding utf8
  } catch {
    "No robots or failed to fetch" | Out-File -FilePath $robotsOut -Encoding utf8 -Append
  }
}

# Optional directory fuzzing
if ($Dir) {
  if (Get-Command ffuf -ErrorAction SilentlyContinue) {
    Write-Host "[*] Running ffuf..."
    $ffufOut = Join-Path $targetDir "dir\ffuf.json"
    & ffuf -w $Wordlist -u "http://$Target/FUZZ" -o $ffufOut -of json
  } else {
    Write-Host "[!] ffuf not found; skipping dir fuzz"
  }
}

Write-Host "[*] Done. Results in: $targetDir"
Write-Host "Next: python parse_results.py --input `"$targetDir`" --output `"$targetDir\summary.json`""
