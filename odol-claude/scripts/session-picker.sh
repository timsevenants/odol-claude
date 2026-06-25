#!/usr/bin/env bash
# ==============================================================================
# session-picker.sh
# Menu om een Claude-sessie te starten of te hervatten (via tmux 'claude').
# ==============================================================================
set -uo pipefail

SESSION="claude"

run_in_tmux() {
  local cmd="$1"
  if tmux has-session -t "${SESSION}" 2>/dev/null; then
    tmux kill-session -t "${SESSION}" 2>/dev/null || true
  fi
  exec tmux new-session -s "${SESSION}" "${cmd}"
}

while true; do
  clear
  welcome 2>/dev/null || true

  has_session="nee"
  tmux has-session -t "${SESSION}" 2>/dev/null && has_session="ja"

  echo "  Wat wil je doen?"
  echo
  [ "${has_session}" = "ja" ] && echo "    0) Herverbinden met lopende sessie  (aanbevolen)"
  echo "    1) Nieuwe Claude-sessie"
  echo "    2) Doorgaan met laatste gesprek        (claude -c)"
  echo "    3) Eerder gesprek hervatten            (claude -r)"
  echo "    4) Inloggen / login-hulp               (claude-login)"
  echo "    5) Gewone shell (bash)"
  echo "    6) Afsluiten"
  echo
  default="1"; [ "${has_session}" = "ja" ] && default="0"
  read -rp "  Keuze [${default}]: " choice
  choice="${choice:-${default}}"

  case "${choice}" in
    0) [ "${has_session}" = "ja" ] && exec tmux attach-session -t "${SESSION}" ;;
    1) run_in_tmux "claude" ;;
    2) run_in_tmux "claude -c" ;;
    3) run_in_tmux "claude -r" ;;
    4) exec claude-login ;;
    5) exec bash -l ;;
    6) exit 0 ;;
    *) echo "  Ongeldige keuze."; sleep 1 ;;
  esac
done
