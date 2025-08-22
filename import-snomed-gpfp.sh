#!/usr/bin/env bash
set -euo pipefail

############################
#    Konfigurationsbereich
############################

# URL Deines Snowstorm-Servers
SNOWSTORM_URL="http://snowstorm:8080"

# Branch, in den importiert werden soll
BRANCH="MAIN/GPFP-EXTENSION2"

# Pfad zum RF2-ZIP in Deinem Dev-Container
ZIP_PATH="/workspaces/piskklis/snomedct_releases/SnomedCT_GPFP_PRODUCTION_20250331T120000Z.zip"

############################
#    Import-Logik Schritt 1
############################

echo "▶ Erstelle neuen Import-Job..."
RESPONSE=$(curl -s -D - -o /dev/null -X POST "${SNOWSTORM_URL}/imports" \
  -H "Content-Type: application/json" \
  -d '{"branchPath": "'"${BRANCH}"'", "createCodeSystemVersion": true, "type": "SNAPSHOT"}')

# Trenne Body und Statuscode
HTTP_BODY=$(echo "$RESPONSE" | sed '$d')
HTTP_STATUS=$(echo "$RESPONSE" | tail -n1)

echo "→ HTTP Status: $HTTP_STATUS"
echo "→ Rohes JSON:"
echo "$HTTP_BODY"

# Location sieht so aus: Location: /imports/d0b30d96-3714-443e-99a5-2f282b1f1b0
IMPORT_ID=$(echo "$RESPONSE" \
  | grep -i '^Location:' \
  | sed -E 's|.*/imports/([a-f0-9\-]+).*|\1|I')

echo "→ Import-ID: $IMPORT_ID"

############################
#    Import-Logik Schritt 2
############################

echo "▶ Lade ZIP-Datei hoch…"
UPLOAD_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "${SNOWSTORM_URL}/imports/${IMPORT_ID}/archive" \
  -H "Content-Type: multipart/form-data" -F "file=@${ZIP_PATH}")

# HTTP-Body und Status trennen
UPLOAD_BODY=$(echo "$UPLOAD_RESPONSE" | sed '$d')
UPLOAD_STATUS=$(echo "$UPLOAD_RESPONSE" | tail -n1)

echo "→ HTTP Status (Upload): $UPLOAD_STATUS"
echo "→ Antwort-Body (Upload):"
echo "$UPLOAD_BODY"

if [[ "$UPLOAD_STATUS" =~ ^2 ]]; then
  echo "✔ ZIP erfolgreich hochgeladen."
else
  echo "✘ Fehler beim Hochladen!"
  exit 1
fi

############################
#    Import-Logik Schritt 3
############################

echo "▶ Prüfe Import-Status einmalig…"
STATUS_RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "${SNOWSTORM_URL}/imports/${IMPORT_ID}")

# Body und HTTP-Status trennen
STATUS_BODY=$(echo "$STATUS_RESPONSE" | sed '$d')
STATUS_CODE=$(echo "$STATUS_RESPONSE" | tail -n1)

echo "→ HTTP Status (Status-Abfrage): $STATUS_CODE"
echo "→ Antwort-Body (Status-Abfrage):"
echo "$STATUS_BODY"

# Extrahiere das Feld `state`
IMPORT_STATE=$(echo "$STATUS_BODY" | jq -r '.status')
echo "→ Aktueller Import-Zustand: ${IMPORT_STATE}"

############################
#    Import-Logik Schritt 4: Polling
############################

echo "▶ Starte Polling, bis der Import abgeschlossen ist…"
while true; do
  S=$(curl -s "${SNOWSTORM_URL}/imports/${IMPORT_ID}" | jq -r '.status')
    echo "→ Import-Status aktuell: ${S}"
    case "$S" in
      COMPLETED)
        echo "✔ Import erfolgreich abgeschlossen!"
        break
        ;;
      FAILED)
        echo "✘ Import ist fehlgeschlagen!"
        exit 1
        ;;
      *)
        # z.B. WAITING_FOR_FILE, IMPORTING, etc.
        sleep 10
        ;;
    esac
done