#!/usr/bin/env bash
set -euo pipefail

############################
#    Konfigurationsbereich
############################

# URL Deines Snowstorm-Servers (Container-DNS + Port)
SNOWSTORM_URL="http://snowstorm:8080"

# Branch, in den importiert werden soll
BRANCH="MAIN"

# Pfad zum RF2-ZIP in Deinem Dev-Container
ZIP_PATH="/workspace/snomedct_releases/SnomedCT.zip"

############################
#    Import-Logik (versteckt)
############################

: <<'IMPORT_LOGIK'
# 1) Import-Job anlegen (POST /imports)
#    → Extrahiere IMPORT_ID

# 2) ZIP hochladen (POST /imports/${IMPORT_ID}/archive)

# 3) Status abfragen (GET /imports/${IMPORT_ID})

# 4) (optional) Polling & Fehlerbehandlung
IMPORT_LOGIK

echo "Konfiguration gesetzt – starte Schritt 1, wenn Du bereit bist."
