#!/usr/bin/with-contenv bashio
# ==============================================================================
# ODOL Claude - startscript
# Web-terminal met Claude Code + pro-features (API-key login, slash-commands,
# back-up-hook, git-versiebeheer, ha-mcp, smart context, fleet-tools).
# Alles persistent onder /data.
# ==============================================================================
set -e

# ------------------------------------------------------------------------------
# Persistente opslag (alles onder /data)
# ------------------------------------------------------------------------------
export HOME="/data"
export XDG_CONFIG_HOME="/data/.config"
export XDG_DATA_HOME="/data/.local/share"
export XDG_CACHE_HOME="/data/.cache"
mkdir -p "${HOME}/.claude" "${XDG_CONFIG_HOME}" "${XDG_DATA_HOME}" "${XDG_CACHE_HOME}"

# ------------------------------------------------------------------------------
# API-key (optioneel) - vervangt de browser/OAuth-login volledig
# ------------------------------------------------------------------------------
if bashio::config.has_value 'anthropic_api_key'; then
  export ANTHROPIC_API_KEY="$(bashio::config 'anthropic_api_key')"
  bashio::log.info "ANTHROPIC_API_KEY ingesteld - geen browser-login nodig."
fi

# ------------------------------------------------------------------------------
# Auth-migratie van oude login-locaties
# ------------------------------------------------------------------------------
for legacy in /config/claude-config /config/.claude /root/.claude; do
  if [ -f "${legacy}/.credentials.json" ] && [ ! -f "${HOME}/.claude/.credentials.json" ]; then
    bashio::log.info "Login migreren van ${legacy} ..."
    cp -a "${legacy}/." "${HOME}/.claude/" 2>/dev/null || true
  fi
done

# ------------------------------------------------------------------------------
# Optionele extra pakketten
# ------------------------------------------------------------------------------
if bashio::config.has_value 'persistent_apk_packages'; then
  for pkg in $(bashio::config 'persistent_apk_packages'); do
    bashio::log.info "apk: ${pkg}"
    apk add --no-cache "${pkg}" || bashio::log.warning "apk faalde: ${pkg}"
  done
fi
if bashio::config.has_value 'persistent_pip_packages'; then
  for pkg in $(bashio::config 'persistent_pip_packages'); do
    bashio::log.info "pip: ${pkg}"
    pip install --break-system-packages "${pkg}" || bashio::log.warning "pip faalde: ${pkg}"
  done
fi

# ------------------------------------------------------------------------------
# Claude bootstrap: slash-commands + hooks (settings.json) op basis van opties
# ------------------------------------------------------------------------------
INSTALL_HA_COMMANDS=$(bashio::config.true 'install_ha_commands' && echo 1 || echo 0)
BACKUP_BEFORE_EDIT=$(bashio::config.true 'backup_before_edit' && echo 1 || echo 0)
GIT_VERSIONING=$(bashio::config.true 'git_versioning' && echo 1 || echo 0)
export INSTALL_HA_COMMANDS BACKUP_BEFORE_EDIT GIT_VERSIONING
bootstrap-claude || bashio::log.warning "Claude bootstrap onvolledig."

# ------------------------------------------------------------------------------
# Git-versiebeheer van /config (optioneel)
# ------------------------------------------------------------------------------
if [ "${GIT_VERSIONING}" = "1" ] && [ ! -d /config/.git ]; then
  bashio::log.info "Git-versiebeheer initialiseren in /config ..."
  git -C /config init -q || true
  printf '.odol_backups/\nclaude-config/\n.storage/\n*.log\n' > /config/.gitignore
  git -C /config add -A >/dev/null 2>&1 || true
  git -C /config -c user.name="ODOL Claude" -c user.email="odol@local" \
    commit -q -m "init: ODOL Claude baseline" >/dev/null 2>&1 || true
fi

# ------------------------------------------------------------------------------
# HA smart context
# ------------------------------------------------------------------------------
if bashio::config.true 'ha_smart_context'; then
  bashio::log.info "HA-context genereren..."
  ha-context || bashio::log.warning "Context mislukt."
fi

# ------------------------------------------------------------------------------
# HA MCP-server (ha-mcp)
# ------------------------------------------------------------------------------
if bashio::config.true 'enable_ha_mcp'; then
  bashio::log.info "ha-mcp registreren..."
  setup-ha-mcp || bashio::log.warning "MCP mislukt."
fi

# ------------------------------------------------------------------------------
# HA Claude-plugins (optioneel)
# ------------------------------------------------------------------------------
if bashio::config.true 'install_ha_plugins'; then
  bashio::log.info "HA Claude-plugins installeren..."
  claude plugin marketplace add ESJavadex/claude-homeassistant-plugins >/dev/null 2>&1 \
    || bashio::log.warning "plugin marketplace mislukt"
  claude plugin install homeassistant-config@claude-homeassistant-plugins >/dev/null 2>&1 \
    || bashio::log.warning "plugin install mislukt"
fi

# ------------------------------------------------------------------------------
# Launch-logica
#  - API-key gezet of al ingelogd -> direct Claude
#  - anders -> begeleide login
# ------------------------------------------------------------------------------
cd /config

if bashio::config.true 'auto_launch_claude'; then
  LAUNCH_CMD='welcome; if [ -n "$ANTHROPIC_API_KEY" ] || [ -f "$HOME/.claude/.credentials.json" ]; then tmux new-session -A -s claude claude; else claude-login; fi; echo; echo "Sessie beeindigd - typ \"session-picker\" of \"claude-login\"."; exec bash'
else
  LAUNCH_CMD='exec session-picker'
fi

bashio::log.info "ODOL Claude start op poort 7681..."

exec ttyd \
  --port 7681 \
  --interface 0.0.0.0 \
  --writable \
  --ping-interval 30 \
  --client-option fontSize=14 \
  --client-option 'theme={"background":"#1e1e2e","foreground":"#cdd6f4"}' \
  --client-option disableLeaveAlert=true \
  bash -lc "${LAUNCH_CMD}"
