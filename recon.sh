#!/usr/bin/env bash
set -euo pipefail

# recon.sh — Linux/Kali orchestration (nmap + http checks + optional ffuf)
# Usage: ./recon.sh --target <IP|HOST> [--dir] [--wordlist /path/to/wordlist]

usage() {
  cat <<EOF
Usage: $0 --target <IP|HOST> [--dir] [--wordlist /path/to/wordlist]
  --target   | -t   Target IP or hostname (required)
  --dir            Enable directory fuzzing (requires ffuf)
  --wordlist       Path to wordlist (default: /usr/share/wordlists/dirb/common.txt)
EOF
  exit 1
}

TARGET=""
DO_DIR=0
WORDLIST="/usr/share/wordlists/dirb/common.txt"

# parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --target|-t) TARGET="${2:-}"; shift 2 ;;
    --dir) DO_DIR=1; shift 1 ;;
    --wordlist) WORDLIST="${2:-}"; shift 2 ;;
    -h|--help) usage ;;
    *) echo "Unknown arg: $1"; usage ;;
  esac
done

if [[ -z "$TARGET" ]]; then
  echo "[!] Missing --target"
  usage
fi

TS=$(date +"%Y%m%d_%H%M%S")
OUTDIR="./results/${TARGET}_${TS}"
mkdir -p "${OUTDIR}/nmap" "${OUTDIR}/http"
if [[ $DO_DIR -eq 1 ]]; then
  mkdir -p "${OUTDIR}/dir"
fi

echo "[*] Output -> ${OUTDIR}"

# Nmap: service/version + default scripts
echo "[*] Running nmap..."
NMAP_BASE="${OUTDIR}/nmap/scan"
if ! command -v nmap >/dev/null 2>&1; then
  echo "[!] nmap not found in PATH. Install it and retry."
  exit 2
fi
nmap -sC -sV -oA "${NMAP_BASE}" "${TARGET}"

# HTTP headers + robots
echo "[*] Fetching headers & robots.txt..."
for proto in http https; do
  url="${proto}://${TARGET}"
  hdr_out="${OUTDIR}/http/${proto}_headers.txt"
  robots_out="${OUTDIR}/http/${proto}_robots.txt"

  # try HEAD; if fails, try GET
  if command -v curl >/dev/null 2>&1; then
    if curl -I --max-time 8 -s -S "$url" > "$hdr_out" 2>/dev/null; then
      echo "[+] Saved headers to ${hdr_out}"
    else
      echo "[!] Failed headers for ${url}" > "$hdr_out"
    fi

    if curl -s --max-time 8 "${url}/robots.txt" -o "$robots_out" --fail 2>/dev/null; then
      echo "[+] Saved robots to ${robots_out}"
    else
      echo "No robots or failed to fetch" > "$robots_out"
    fi
  else
    echo "[!] curl not found; skipping http checks"
    echo "curl missing" > "$hdr_out"
    echo "curl missing" > "$robots_out"
  fi
done

# Optional directory fuzzing (ffuf)
if [[ $DO_DIR -eq 1 ]]; then
  if command -v ffuf >/dev/null 2>&1; then
    echo "[*] Running ffuf (dir fuzz)..."
    ffuf -w "${WORDLIST}" -u "http://${TARGET}/FUZZ" -o "${OUTDIR}/dir/ffuf.json" -of json || echo "[!] ffuf finished (possible non-zero exit)"
  else
    echo "[!] ffuf not found; skipping dir fuzz"
  fi
fi

echo "[*] Done. Results in: ${OUTDIR}"
echo "Next: python3 parse_results.py --input \"${OUTDIR}\" --output \"${OUTDIR}/summary.json\""
