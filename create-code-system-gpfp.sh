#!/usr/bin/env bash
set -euo pipefail

# ------------------- Variablen -------------------
SNOWSTORM_URL="http://snowstorm:8080"
BRANCH_PATH="MAIN/GPFP-EXTENSION2"
SHORTNAME="GPFP"
NAME="GPFP Extension"
DEPENDANT_VERSION="20250515"   # EffectiveDate der Edition, auf der die Extension basiert

# ------------------- CodeSystem anlegen -------------------
echo "⏳ Lege CodeSystem ${SHORTNAME} auf ${BRANCH_PATH} an …"

curl -s -X POST "${SNOWSTORM_URL}/codesystems" \
  -H "Content-Type: application/json" \
  -d "{
        \"shortName\": \"${SHORTNAME}\",
        \"name\": \"${NAME}\",
        \"branchPath\": \"${BRANCH_PATH}\",
        \"dependantVersionEffectiveTime\": ${DEPENDANT_VERSION}
      }"

echo
echo "✅ CodeSystem ${SHORTNAME} erstellt"
