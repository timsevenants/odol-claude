#!/usr/bin/env bash
# ==============================================================================
# claude-run.sh
# Start Claude in een tmux-sessie. Stopt Claude onverwacht, dan blijft de
# foutmelding op het scherm staan in plaats van dat tmux het venster direct
# opruimt (wat enkel een nietszeggend '[exited]' achterliet).
# ==============================================================================
set -uo pipefail

SESSION="${1:-claude}"

read -r -d '' INNER <<'INNEREOF' || true
claude
code=$?
if [ "$code" -ne 0 ]; then
  echo
  echo "---- Claude is gestopt met exitcode $code -------------------------"
  echo "  Diagnose-commandos:"
  echo "    claude doctor"
  echo "    ldd \$(command -v claude) | grep 'not found'"
  echo "-------------------------------------------------------------------"
  echo
  read -rp "Druk op Enter om naar de shell te gaan..." _ || true
fi
INNEREOF

exec tmux new-session -A -s "${SESSION}" bash -lc "${INNER}"
