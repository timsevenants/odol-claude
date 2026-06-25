#!/usr/bin/env bash
# ==============================================================================
# ha-context.sh
# Genereert een overzicht van deze Home Assistant-instantie als CLAUDE.md
# (user-memory), zodat Claude meteen context heeft.
# ==============================================================================
set -uo pipefail

OUT="${1:-${HOME}/.claude/CLAUDE.md}"
TOKEN="${SUPERVISOR_TOKEN:-}"
API="http://supervisor"
mkdir -p "$(dirname "${OUT}")"

if [ -z "${TOKEN}" ]; then
  echo "ha-context: geen SUPERVISOR_TOKEN, overslaan." >&2
  exit 0
fi

_get() {
  curl -fsSL -H "Authorization: Bearer ${TOKEN}" -H "Content-Type: application/json" \
    "${API}/$1" 2>/dev/null || echo '{}'
}

core_info="$(_get core/info)"
ha_config="$(_get core/api/config)"
states="$(_get core/api/states)"
addons="$(_get addons)"

ha_version="$(echo "${core_info}" | jq -r '.data.version // "onbekend"')"
machine="$(echo "${core_info}" | jq -r '.data.machine // "onbekend"')"
tz="$(echo "${ha_config}" | jq -r '.time_zone // "onbekend"')"
location="$(echo "${ha_config}" | jq -r '.location_name // "onbekend"')"

{
  echo "# Home Assistant context (ODOL Claude)"
  echo
  echo "> Automatisch gegenereerd bij elke start van de add-on. Niet handmatig bewerken."
  echo
  echo "## Systeem"
  echo "- HA-versie: ${ha_version}"
  echo "- Machine: ${machine}"
  echo "- Locatie: ${location}"
  echo "- Tijdzone: ${tz}"
  echo "- Configuratiemap: \`/config\` (lees/schrijf vanuit deze terminal)"
  echo

  echo "## Entiteiten per domein"
  if echo "${states}" | jq -e 'type == "array"' >/dev/null 2>&1; then
    echo "| Domein | Aantal |"
    echo "|--------|--------|"
    echo "${states}" | jq -r '.[].entity_id | split(".")[0]' \
      | sort | uniq -c | sort -rn | awk '{printf "| %s | %s |\n", $2, $1}'
    total="$(echo "${states}" | jq -r 'length')"
    autos="$(echo "${states}" | jq -r '[.[].entity_id | select(startswith("automation."))] | length')"
    scripts="$(echo "${states}" | jq -r '[.[].entity_id | select(startswith("script."))] | length')"
    echo
    echo "Totaal: ${total} entiteiten (${autos} automations, ${scripts} scripts)."
  else
    echo "_Kon entiteiten niet ophalen._"
  fi
  echo

  echo "## Geïnstalleerde add-ons"
  if echo "${addons}" | jq -e '.data.addons | type == "array"' >/dev/null 2>&1; then
    echo "${addons}" | jq -r '.data.addons[] | "- \(.name) (\(.version)) — \(.state)"'
  else
    echo "_Kon add-onlijst niet ophalen._"
  fi
  echo

  echo "## Werkwijze voor Claude"
  echo "- Bewerk YAML rechtstreeks in \`/config\`. Elk bestand wordt automatisch geback-upt vóór wijziging."
  echo "- Valideer wijzigingen met \`ha-check\` vóór een herstart."
  echo "- Herstart HA pas na bevestiging met \`ha-restart\`."
  echo "- Gebruik bij voorkeur de \`home-assistant\` MCP-tools voor states en services."
} > "${OUT}"

echo "ha-context: geschreven naar ${OUT}"
