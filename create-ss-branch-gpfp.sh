# ------------------- Konfiguration -------------------
SNOWSTORM_URL="http://snowstorm:8080"
BRANCH_NAME="GPFP-Extension"         # Nur der Name des neuen Branches
PARENT_BRANCH="MAIN"                 # Von welchem Branch soll abgezweigt werden?
BRANCH_PATH="MAIN/${BRANCH_NAME}"    # Volle Branch-Pfad-Angabe

# ------------------- Branch anlegen (immer versuchen) -------------------
# Wir versuchen, den Branch immer zu erstellen – unabhängig davon, ob er schon existiert.
# Falls er schon existiert, gibt das API einen Fehler (HTTP 409), den wir absichtlich ignorieren.
# Das > /dev/null sorgt dafür, dass die Konsolenausgabe sauber bleibt.
# Mit || true verhindern wir, dass das Skript bei einem Fehler (z.B. Branch existiert schon) abbricht.

echo "⏳ Lege Branch ${BRANCH_PATH} (ggf. erneut) an …"
curl -s -X POST "${SNOWSTORM_URL}/branches" \
  -H "Content-Type: application/json" \
  -d "{\"parent\": \"${PARENT_BRANCH}\", \"name\": \"${BRANCH_NAME}\"}" \
  > /dev/null || true

# WICHTIG:
# - Falls der Branch schon existiert, passiert einfach nichts und das Skript läuft weiter.
# - Etwaige Fehler oder Konflikte kannst du im Snowstorm-Container-Log nachschauen.
# - Es gibt kein API für "Branch überschreiben" – ein existierender Branch bleibt unverändert bestehen.
# - Das ist idempotent: mehrfaches Ausführen ändert nichts am Branch.

echo "✔️ Branch-Vorbereitung abgeschlossen. Import kann gestartet werden."