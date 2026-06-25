#!/usr/bin/env bash
# ha-backup.sh — maakt een volledige Home Assistant back-up via de supervisor.
set -uo pipefail
TOKEN="${SUPERVISOR_TOKEN:-}"
[ -z "${TOKEN}" ] && { echo "Geen SUPERVISOR_TOKEN beschikbaar."; exit 1; }

name="${1:-odol-$(date +%Y%m%d-%H%M%S)}"
echo "Volledige back-up maken: ${name} ..."
resp="$(curl -fsSL -X POST -H "Authorization: Bearer ${TOKEN}" \
  -H 'Content-Type: application/json' -d "{\"name\":\"${name}\"}" \
  http://supervisor/backups/new/full 2>/dev/null || echo '{"result":"error"}')"

if [ "$(echo "${resp}" | jq -r '.result // "error"')" = "ok" ]; then
  slug="$(echo "${resp}" | jq -r '.data.slug // "?"')"
  echo "✅ Back-up klaar (slug: ${slug})."
else
  echo "❌ Back-up mislukt:"; echo "${resp}" | jq -r '.message // .' 2>/dev/null || echo "${resp}"
  exit 1
fi
