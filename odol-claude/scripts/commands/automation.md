---
description: Bouw of pas een Home Assistant automation aan
---
Help me een automation te maken of aan te passen voor: $ARGUMENTS

Werkwijze:
1. Bekijk relevante bestaande entiteiten (gebruik de `home-assistant` MCP-tools, of `curl -s -H "Authorization: Bearer $SUPERVISOR_TOKEN" http://supervisor/core/api/states | jq`).
2. Schrijf de automation in correcte YAML en plaats hem op de juiste plek in `/config` (bijv. `automations.yaml` of een package).
3. Valideer met `ha-check`.
4. Vraag mij om bevestiging voordat je voorstelt te herstarten.
