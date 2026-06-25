#!/usr/bin/env bash
# ==============================================================================
# git-commit.sh  (Claude Code PostToolUse hook)
# Commit wijzigingen in /config naar het lokale git-versiebeheer (indien actief).
# Blokkeert nooit (exit 0).
# ==============================================================================
cat >/dev/null 2>&1   # tool-input opslurpen en negeren

if [ -d /config/.git ]; then
  git -C /config add -A >/dev/null 2>&1 || true
  git -C /config -c user.name="ODOL Claude" -c user.email="odol@local" \
    commit -q -m "auto: wijziging via Claude ($(date +%Y-%m-%d_%H:%M:%S))" >/dev/null 2>&1 || true
fi
exit 0
