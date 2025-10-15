#!/usr/bin/env bash
set -euo pipefail

# recon.sh — Linux/Kali orchestration (nmap + http checks + optional ffuf)
# Usage: ./recon.sh --target <IP|HOST> [--dir] [--wordlist /path/to/wordlist]

usage() {
  cat <<EOF
Usage: $0 --target <IP|HOST> [--dir] [--wordlist /path/to/wordlist]
  --target | -t   Target IP or hostname (required)
  --dir           Enable directory fuzzing with ffuf (optional)
  --wordlist      Path to wordlist (default: /usr/share/wordlists/dirb/common.txt)
  -h, --help      Show this help
EOF
  exit 1
}

TARGET=""
DO_DIR=0
WORDLIST="/usr/share/wordlists/dirb/common.txt"

# parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --target|-t)
      TARGET="${2:-}"
      shift 2
      ;;
    --dir)
      DO_DIR=1
      shift 1
      ;;
    --wordlist)
      WORDLIST="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      ;;
    *)
      echo "[!] Unknown arg: $1"
      usage
      ;;
  esac
done

if [[ -z "${TARGET}" ]]; then
  echo "[!] Missing --target"
  usage
fi

# check for required commands
if ! command -v nmap >/dev/null 2>&1; then
  echo "[!] nmap not found in PATH. Install it (e.g. sudo apt install nmap) and retry."
  exit 2
fi

# prepare output dirs
TS=$(date +"%Y%m%d_%H%M%S")
OUTDIR="./results/${TARGET}_${TS}"
mkdir -p "${OUTDIR}/nmap" "${OUTDIR}/http"
if [[ ${DO_DIR} -eq 1 ]]; then
  mkdir -p "${OUTDIR}/dir"
fi

echo "[*] Output -> ${OUTDIR}"

# run nmap (service/version + safe scripts)
echo "[*] Running nmap..."
# use a basename so nmap creates scan.nmap, scan.xml, scan.gnmap
NMAP_BASE="${OUTDIR}/nmap/scan"
nmap -sC -sV -oA "${NMAP_BASE}" "${TARGET}"

# http headers + robots
echo "[*] Fetching headers & robots.txt..."
for proto in http https; do
  url="${proto}://${TARGET}"
  hdr_out="${OUTDIR}/http/${proto}_headers.txt"
  robots_out="${OUTDIR}/http/${proto}_robots.txt"

  # default: write a helpful fallback if curl not available
  if command -v curl >/dev/null 2>&1; then
    # attempt HEAD first (faster); if server blocks HEAD, try GET but don't save body
    if curl -I --max-time 8 -sS "$url" > "$hdr_out" 2>/dev/null; then
      echo "[+] Saved headers -> ${hdr_out}"
    else
      # try a GET but discard the body (some servers don't support HEAD)
      if curl -sS --max-time 8 -D "$hdr_out" --fail "$url" -o /dev/null 2>/dev/null; then
        echo "[+] Saved headers (GET fallback) -> ${hdr_out}"
      else
        echo "[!] Failed headers for ${url}" > "$hdr_out"
      fi
    fi

    # robots.txt (try fetch, fallback message)
    if curl -sS --max-time 8 "${url}/robots.txt" -o "${robots_out}" --fail 2>/dev/null; then
      echo "[+] Saved robots -> ${robots_out}"
    else
      echo "No robots or failed to fetch" > "${robots_out}"
    fi
  else
    echo "[!] curl not found; skipping http checks"
    echo "curl missing" > "$hdr_out"
    echo "curl missing" > "$robots_out"
  fi
done

# optional directory fuzzing with ffuf
if [[ ${DO_DIR} -eq 1 ]]; then
  if command -v ffuf >/dev/null 2>&1; then
    echo "[*] Running ffuf (dir fuzz) — this may take time..."
    # run with moderate threads, output JSON
    ffuf -w "${WORDLIST}" -u "http://${TARGET}/FUZZ" -t 20 -mc 200,301,302,401,403,405 -o "${OUTDIR}/dir/ffuf.json" -of json || echo "[!] ffuf finished (non-zero exit allowed)"
    echo "[+] ffuf output -> ${OUTDIR}/dir/ffuf.json"
  else
    echo "[!] ffuf not installed; skipping dir fuzz"
  fi
fi

echo "[*] Done. Results in: ${OUTDIR}"
echo "Next: python3 parse_results.py --input \"${OUTDIR}\" --output \"${OUTDIR}/summary.json\""
