#!/usr/bin/env bash
# ==============================================================================
# bootstrap-claude.sh
# Installeert de meegeleverde slash-commands en genereert ~/.claude/settings.json
# met de juiste hooks, op basis van de omgevingsvariabelen die run.sh zet.
# ==============================================================================
set -uo pipefail

CLAUDE_HOME="${HOME}/.claude"
mkdir -p "${CLAUDE_HOME}/commands"

# --- Slash-commands installeren (managed; worden elke start ververst) ---
if [ "${INSTALL_HA_COMMANDS:-1}" = "1" ]; then
  cp -f /opt/scripts/commands/*.md "${CLAUDE_HOME}/commands/" 2>/dev/null || true
fi

# --- Hooks samenstellen op basis van opties ---
pre_json='[]'
post_json='[]'
if [ "${BACKUP_BEFORE_EDIT:-1}" = "1" ]; then
  pre_json='[{"matcher":"Write|Edit|MultiEdit","hooks":[{"type":"command","command":"/opt/scripts/hooks/backup-before-edit.sh"}]}]'
fi
if [ "${GIT_VERSIONING:-0}" = "1" ]; then
  post_json='[{"matcher":"Write|Edit|MultiEdit","hooks":[{"type":"command","command":"/opt/scripts/hooks/git-commit.sh"}]}]'
fi

jq -n --argjson pre "${pre_json}" --argjson post "${post_json}" '
  {
    hooks: (
      {}
      + (if ($pre  | length) > 0 then {PreToolUse:  $pre}  else {} end)
      + (if ($post | length) > 0 then {PostToolUse: $post} else {} end)
    )
  }
' > "${CLAUDE_HOME}/settings.json" 2>/dev/null \
  || echo '{}' > "${CLAUDE_HOME}/settings.json"

echo "bootstrap-claude: commands + settings.json bijgewerkt."
