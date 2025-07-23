#!/usr/bin/env bash
set -euo pipefail

############################
#    Konfigurationsbereich
############################

# URL Deines Snowstorm-Servers
SNOWSTORM_URL="http://snowstorm:8080"

# Branch, in den importiert werden soll
BRANCH="MAIN"

# Pfad zum RF2-ZIP in Deinem Dev-Container
ZIP_PATH="/workspace/snomedct_releases/SnomedCT.zip"

############################
#    Import-Logik Schritt 1
############################

echo "▶ Erstelle neuen Import-Job..."
IMPORT_ID=$(
  curl -s -X POST "${SNOWSTORM_URL}/imports" \
    -H "Content-Type: application/json" \
    -d '{
          "branchPath": "'"${BRANCH}"'",
          "createCodeSystemVersion": true,
          "type": "SNAPSHOT"
        }' \
  | jq -r '.importId'
)

echo "→ Import-ID ist: ${IMPORT_ID}"

############################
#    Import-Logik Folge­schritte (versteckt)
############################

: <<'IMPORT_FOLGE'
# 2) ZIP hochladen
# 3) Status abfragen
# 4) Polling & Fehlerbehandlung
IMPORT_FOLGE
