#!/usr/bin/env bash
# ------------------------------------------------------------------------
# delete-snomed-indices.sh
# ------------------------------------------------------------------------
# Dieses Skript löscht alle SNOMED-bezogenen Elasticsearch-Indizes,
# auch wenn Wildcard-Löschungen (z.B. snomed-*) per Default in ES 8.x verboten sind.
# Es listet gezielt alle Indizes auf, die mit "snomed-" beginnen,
# und entfernt diese nacheinander per Einzel-DELETE-Request.
# ------------------------------------------------------------------------

set -euo pipefail

# Konfiguration: Elasticsearch-Endpunkt (anpassbar per Umgebungsvariable ES_URL)
ES_URL="${ES_URL:-http://elasticsearch:9200}"

echo "⏳ Suche alle SNOMED-Indizes …"

# 1. Hole eine Liste aller Indizes aus Elasticsearch (nur Index-Namen)
#    _cat/indices?h=index gibt nur die Index-Namen als Zeilen aus
indices=$(curl -s "${ES_URL}/_cat/indices?h=index" | grep -v '^$') # alle Indizes, leere Zeilen raus

# 2. Prüfe, ob überhaupt SNOMED-Indizes gefunden wurden
if [[ -z "$indices" ]]; then
  echo "✔️ Keine SNOMED-Indizes gefunden."
  exit 0
fi

echo "⚠️  Die folgenden SNOMED-Indizes werden gelöscht:"
echo "$indices"

# 3. Durchlaufe alle gefundenen SNOMED-Indices und lösche sie einzeln
for idx in $indices; do
  echo "⏳ Lösche $idx …"
  # Sende einen DELETE-Request an Elasticsearch für jeden Index
  # -s: silent (unterdrückt Fortschrittsausgabe)
  # -XDELETE: HTTP-Methode DELETE
  # Ausgabe ins Nirvana (> /dev/null), damit die Konsole sauber bleibt
  curl -s -XDELETE "${ES_URL}/${idx}" > /dev/null
done

echo "✅ Alle SNOMED-Indizes gelöscht!"

# Hinweis:
# - Das Skript löscht ausschließlich Indizes, die mit "snomed-" beginnen.
# - Es ist sicher auch auf ES 8.x+, wo Wildcards für DELETE nicht mehr erlaubt sind.
# - Bei anderen Index-Präfixen musst du ggf. "snomed-" anpassen.
