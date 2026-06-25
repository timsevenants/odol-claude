#!/usr/bin/env bash
# ==============================================================================
# backup-before-edit.sh  (Claude Code PreToolUse hook)
# Maakt een tijdgestempelde kopie van elk bestand onder /config vóórdat Claude
# het wijzigt. Rollback = de kopie terugzetten uit /config/.odol_backups/.
# Leest de tool-input als JSON op stdin; blokkeert nooit (exit 0).
# ==============================================================================
input="$(cat 2>/dev/null)"
file="$(printf '%s' "${input}" | jq -r '.tool_input.file_path // empty' 2>/dev/null)"

case "${file}" in
  /config/.odol_backups/*) : ;;            # eigen back-ups niet back-uppen
  /config/*)
    if [ -f "${file}" ]; then
      ts="$(date +%Y%m%d-%H%M%S)"
      rel="${file#/config/}"
      dest="/config/.odol_backups/${ts}/${rel}"
      mkdir -p "$(dirname "${dest}")" 2>/dev/null
      cp -a "${file}" "${dest}" 2>/dev/null || true
    fi
    ;;
esac
exit 0
