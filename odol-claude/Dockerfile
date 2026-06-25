ARG BUILD_FROM
FROM ${BUILD_FROM}

# Systeem- en ontwikkeltools
RUN apk add --no-cache \
    bash \
    curl \
    wget \
    git \
    jq \
    yq \
    nano \
    vim \
    tree \
    tmux \
    openssh-client \
    nodejs \
    npm \
    python3 \
    py3-pip \
    py3-requests \
    py3-aiohttp \
    py3-yaml \
    py3-beautifulsoup4 \
    ttyd

# uv (voor 'uvx ha-mcp') via pip -> onafhankelijk van de Alpine-versie
RUN pip install --no-cache-dir --break-system-packages uv

# Claude Code CLI via npm (vermijdt musl-binary-problemen)
RUN npm install -g @anthropic-ai/claude-code@latest \
    && npm cache clean --force

WORKDIR /config

# Scripts, hooks en slash-commands
COPY scripts/ /opt/scripts/
RUN chmod +x /opt/scripts/*.sh /opt/scripts/hooks/*.sh \
    && ln -sf /opt/scripts/welcome.sh         /usr/local/bin/welcome \
    && ln -sf /opt/scripts/claude-login.sh    /usr/local/bin/claude-login \
    && ln -sf /opt/scripts/session-picker.sh  /usr/local/bin/session-picker \
    && ln -sf /opt/scripts/ha-context.sh      /usr/local/bin/ha-context \
    && ln -sf /opt/scripts/setup-ha-mcp.sh    /usr/local/bin/setup-ha-mcp \
    && ln -sf /opt/scripts/bootstrap-claude.sh /usr/local/bin/bootstrap-claude \
    && ln -sf /opt/scripts/ha-check.sh        /usr/local/bin/ha-check \
    && ln -sf /opt/scripts/ha-backup.sh       /usr/local/bin/ha-backup \
    && ln -sf /opt/scripts/ha-restart.sh      /usr/local/bin/ha-restart \
    && ln -sf /opt/scripts/ha-fleet.sh        /usr/local/bin/ha-fleet

COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]
