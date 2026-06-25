#!/usr/bin/env bash
# ==============================================================================
# ha-fleet.sh — beheer meerdere Home Assistant-instanties vanuit één terminal.
#
# Houdt een inventory bij (/config/odol-fleet.yaml) en koppelt een gekozen
# instantie als ha-mcp MCP-server aan Claude, zodat je states/services van een
# ANDERE instantie kunt opvragen/aanroepen.
#
#   ha-fleet add <naam> <url> <long-lived-token>
#   ha-fleet list
#   ha-fleet connect <naam>
#   ha-fleet disconnect
# ==============================================================================
set -uo pipefail

INV="/config/odol-fleet.yaml"
HA_MCP_VERSION="3.5.1"
cmd="${1:-list}"

_ensure_inv() { [ -f "${INV}" ] || echo "instances: []" > "${INV}"; }

case "${cmd}" in
  add)
    name="${2:-}"; url="${3:-}"; token="${4:-}"
    if [ -z "${name}" ] || [ -z "${url}" ] || [ -z "${token}" ]; then
      echo "Gebruik: ha-fleet add <naam> <url> <long-lived-token>"; exit 1
    fi
    _ensure_inv
    NAME="${name}" URL="${url}" TOKEN="${token}" \
      yq -i '.instances += [{"name": strenv(NAME), "url": strenv(URL), "token": strenv(TOKEN)}]' "${INV}"
    echo "✅ Toegevoegd: ${name} (${url})"
    ;;
  list)
    if [ ! -f "${INV}" ]; then
      echo "Geen instanties. Voeg toe met: ha-fleet add <naam> <url> <token>"; exit 0
    fi
    echo "Bekende instanties:"
    yq '.instances[] | "  - " + .name + "  (" + .url + ")"' "${INV}"
    ;;
  connect)
    name="${2:-}"
    [ -z "${name}" ] && { echo "Gebruik: ha-fleet connect <naam>"; exit 1; }
    [ -f "${INV}" ] || { echo "Geen inventory."; exit 1; }
    url="$(NAME="${name}" yq '.instances[] | select(.name == strenv(NAME)) | .url' "${INV}")"
    token="$(NAME="${name}" yq '.instances[] | select(.name == strenv(NAME)) | .token' "${INV}")"
    if [ -z "${url}" ] || [ "${url}" = "null" ]; then echo "Onbekende instantie: ${name}"; exit 1; fi
    # bestaande fleet-verbindingen opruimen (1 tegelijk -> geen tool-overload)
    for s in $(claude mcp list 2>/dev/null | grep -oE 'fleet-[A-Za-z0-9_.-]+' || true); do
      claude mcp remove "${s}" >/dev/null 2>&1 || true
    done
    if claude mcp add "fleet-${name}" \
        --env "HOMEASSISTANT_URL=${url}" \
        --env "HOMEASSISTANT_TOKEN=${token}" \
        -- uvx --index-strategy unsafe-best-match "ha-mcp@${HA_MCP_VERSION}"; then
      echo "✅ Verbonden met '${name}'. MCP-tools beschikbaar als 'fleet-${name}'."
    else
      echo "❌ Verbinden mislukt."; exit 1
    fi
    ;;
  disconnect)
    for s in $(claude mcp list 2>/dev/null | grep -oE 'fleet-[A-Za-z0-9_.-]+' || true); do
      claude mcp remove "${s}" >/dev/null 2>&1 || true
    done
    echo "✅ Fleet-verbindingen verwijderd."
    ;;
  *)
    echo "Gebruik: ha-fleet [list | add <naam> <url> <token> | connect <naam> | disconnect]"
    ;;
esac
