#!/usr/bin/env bash
# ha-check.sh — valideert de Home Assistant configuratie via de supervisor.
set -uo pipefail
TOKEN="${SUPERVISOR_TOKEN:-}"
[ -z "${TOKEN}" ] && { echo "Geen SUPERVISOR_TOKEN beschikbaar."; exit 1; }

echo "Configuratie valideren..."
resp="$(curl -fsSL -X POST -H "Authorization: Bearer ${TOKEN}" \
  http://supervisor/core/check 2>/dev/null || echo '{"result":"error"}')"

result="$(echo "${resp}" | jq -r '.result // "error"')"
if [ "${result}" = "ok" ]; then
  echo "✅ Configuratie is geldig."
else
  echo "❌ Configuratie bevat fouten:"
  echo "${resp}" | jq -r '.message // .data.message // .' 2>/dev/null || echo "${resp}"
  exit 1
fi
