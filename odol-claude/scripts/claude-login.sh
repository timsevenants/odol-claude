#!/usr/bin/env bash
# ==============================================================================
# claude-login.sh
# Eenvoudige login: start Claude en toont de login-URL inline op het scherm.
# (Heb je een API-key ingesteld in de add-on-opties? Dan is dit niet nodig.)
# ==============================================================================
set -uo pipefail

SESSION="claude"

echo
echo "── Claude Code login ─────────────────────────────────────────────"
echo
echo "  Zo dadelijk verschijnt er een login-URL op het scherm."
echo "    1. Open de URL in je browser (klik erop, of selecteer + kopieer)."
echo "    2. Log in en klik op 'Authorize'."
echo "    3. Kopieer de code die je browser toont."
echo "    4. Plak die hier terug: rechtermuisklik → Plakken (Ctrl+Shift+V)."
echo
echo "  Tip: stel 'anthropic_api_key' in bij de add-on-opties om dit"
echo "       voortaan helemaal over te slaan."
echo "──────────────────────────────────────────────────────────────────"
sleep 2

exec tmux new-session -A -s "${SESSION}" claude
