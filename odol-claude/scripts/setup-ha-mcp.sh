#!/usr/bin/env bash
# ==============================================================================
# setup-ha-mcp.sh
# Registreert de Home Assistant MCP-server (ha-mcp) bij Claude Code via uvx,
# zodat Claude states kan opvragen en services kan aanroepen.
# ==============================================================================
set -uo pipefail

HA_MCP_VERSION="3.5.1"
TOKEN="${SUPERVISOR_TOKEN:-}"

if [ -z "${TOKEN}" ]; then
  echo "ha-mcp: geen SUPERVISOR_TOKEN, overslaan." >&2
  exit 0
fi
if ! command -v uvx >/dev/null 2>&1; then
  echo "ha-mcp: 'uvx' niet gevonden, overslaan." >&2
  exit 0
fi

claude mcp remove home-assistant >/dev/null 2>&1 || true

if claude mcp add home-assistant \
  --env "HOMEASSISTANT_URL=http://supervisor/core" \
  --env "HOMEASSISTANT_TOKEN=${TOKEN}" \
  -- uvx --index-strategy unsafe-best-match "ha-mcp@${HA_MCP_VERSION}"; then
  echo "ha-mcp: MCP-server 'home-assistant' geregistreerd (ha-mcp@${HA_MCP_VERSION})."
else
  echo "ha-mcp: registratie mislukt." >&2
fi
