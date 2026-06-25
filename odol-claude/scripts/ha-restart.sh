#!/usr/bin/env bash
# ha-restart.sh — herstart Home Assistant Core (na validatie en bevestiging).
set -uo pipefail
TOKEN="${SUPERVISOR_TOKEN:-}"
[ -z "${TOKEN}" ] && { echo "Geen SUPERVISOR_TOKEN beschikbaar."; exit 1; }

# Eerst valideren
if ! ha-check; then
  echo "Herstart geannuleerd: configuratie is niet geldig."
  exit 1
fi

if [ "${1:-}" != "--yes" ]; then
  read -rp "Home Assistant Core nu herstarten? [j/N]: " ans
  case "${ans}" in j|J|y|Y) ;; *) echo "Geannuleerd."; exit 0 ;; esac
fi

echo "Home Assistant Core herstarten..."
curl -fsSL -X POST -H "Authorization: Bearer ${TOKEN}" \
  http://supervisor/core/restart >/dev/null 2>&1 \
  && echo "✅ Herstart gestart." || { echo "❌ Herstart mislukt."; exit 1; }
