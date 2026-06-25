# ODOL Claude

De "pro" Claude Code add-on voor Home Assistant: web-terminal met Claude Code plus API-key login, HA slash-commands, een back-up-veiligheidsnet, ha-mcp, smart context en fleet-tools.

## Installeren

1. **Instellingen → Add-ons → Add-on Store**
2. Drie-puntjes-menu → **Repositories** → voeg `https://github.com/timsevenants/odol-claude` toe
3. Installeer **ODOL Claude** en start hem
4. Open de Web UI

## Inloggen — twee manieren

**A. API-key (aanbevolen, geen gedoe)**
Vul `anthropic_api_key` in bij de add-on-opties. Geen browser, geen URL-klikken. Klaar.

**B. OAuth (account-login)**
Laat `anthropic_api_key` leeg. Bij de eerste start verschijnt een login-URL op het scherm; open die, log in, kopieer de code en plak hem terug. De login blijft bewaard in `/data`.

## Opties

| Optie | Standaard | Uitleg |
|-------|-----------|--------|
| `anthropic_api_key` | _(leeg)_ | API-key voor login zonder browser. Leeg = OAuth. |
| `auto_launch_claude` | `true` | Start Claude direct; `false` toont het sessiemenu. |
| `ha_smart_context` | `true` | Genereert `CLAUDE.md` met info over je instantie. |
| `enable_ha_mcp` | `true` | Registreert `ha-mcp` (states opvragen, services aanroepen). |
| `install_ha_commands` | `true` | Installeert de slash-commands (`/check`, `/automation`, …). |
| `backup_before_edit` | `true` | Back-upt elk bestand vóór Claude het wijzigt (`/config/.odol_backups/`). |
| `git_versioning` | `false` | Houdt een git-geschiedenis van `/config` bij (auto-commit per wijziging). |
| `install_ha_plugins` | `false` | Installeert de HA Claude-plugin-marketplace. |
| `persistent_apk_packages` | `[]` | Extra Alpine-pakketten bij elke start. |
| `persistent_pip_packages` | `[]` | Extra Python-pakketten bij elke start. |

## Slash-commands in Claude

- `/check` — configuratie valideren
- `/automation <wat>` — automation bouwen/aanpassen
- `/debug <entity>` — onderzoeken waarom iets niet werkt
- `/backup` — volledige HA-back-up
- `/restart` — HA Core herstarten (na validatie + bevestiging)
- `/entities <zoek>` — entiteiten zoeken/samenvatten

## Shell-commando's

- `ha-check` · `ha-backup` · `ha-restart` — valideren / back-uppen / herstarten
- `ha-context` — context opnieuw genereren
- `ha-fleet` — meerdere instanties beheren (zie onder)
- `session-picker` · `claude-login`

## Meerdere instanties (fleet)

```bash
ha-fleet add kantoor   https://kantoor.example/   <long-lived-token>
ha-fleet add magazijn  https://magazijn.example/  <long-lived-token>
ha-fleet list
ha-fleet connect kantoor      # koppelt die instantie als MCP aan Claude
ha-fleet disconnect
```

De inventory staat in `/config/odol-fleet.yaml`. Er wordt steeds één instantie tegelijk gekoppeld, om te voorkomen dat Claude met te veel tools tegelijk overladen wordt.

## Veiligheid

Deze add-on geeft Claude verregaande toegang tot je configuratie en de HA-API (manager-rol). Het back-up-net (`backup_before_edit`) en optioneel `git_versioning` maken wijzigingen terugdraaibaar. Test bij voorkeur eerst op een niet-kritieke instantie.
