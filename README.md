# ODOL Claude add-ons

De "pro" Home Assistant add-on voor [Claude Code](https://github.com/anthropics/claude-code):
een web-terminal met Claude Code, plus alles wat een power-user en fleet-beheerder
nodig heeft.

Dit is een uitgebreide variant naast de minimale [`ha-claude`](https://github.com/timsevenants/ha-claude).

## Add-on: ODOL Claude

Bevat bovenop de basis:

- **API-key login** — geen browser/OAuth-gedoe meer (optioneel)
- **HA slash-commands** — `/check`, `/automation`, `/debug`, `/backup`, `/restart`, `/entities`
- **Veiligheidsnet** — automatische back-up van elk bestand vóór Claude het wijzigt
- **Git-versiebeheer** van `/config` (optioneel) — alles terugdraaibaar
- **ha-mcp** — states opvragen, services aanroepen, automations bouwen
- **Smart context** — `CLAUDE.md` met info over je instantie
- **Fleet-tools** — `ha-fleet` om meerdere HA-instanties te beheren
- **Plugin-marketplace** (optioneel)

## Installeren

1. **Instellingen → Add-ons → Add-on Store**
2. Drie-puntjes-menu → **Repositories**
3. Voeg toe: `https://github.com/timsevenants/odol-claude`
4. Installeer **ODOL Claude**

Zie [odol-claude/DOCS.md](./odol-claude/DOCS.md) voor alle opties.
