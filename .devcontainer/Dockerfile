# Basis-Image: Nutzt ein schlankes Python 3.11-Image aus dem offiziellen Python-Repository.
# Das ist ein minimales, auf Debian basierendes Image – ideal, um schlank zu bleiben und nur zu installieren, was wirklich gebraucht wird.
FROM python:3.11-slim

# Installiert einige nützliche Systemwerkzeuge:
# - 'apt-get update': Aktualisiert die Paketlisten des Paketmanagers, damit wir die neuesten Versionen installieren.
# - 'git': Ermöglicht es, direkt im Container mit Git-Repositories zu arbeiten (z. B. Code klonen oder Änderungen committen).
# - 'curl': Ein Kommandozeilentool, um Daten aus dem Internet abzurufen – oft für Installationen und Tests gebraucht.
# - 'build-essential': Installiert grundlegende Compiler und Build-Tools (z. B. gcc, make). Viele Python-Pakete mit nativen Erweiterungen benötigen das.
# - 'rm -rf /var/lib/apt/lists/*': Entfernt die heruntergeladenen Paketlisten, um das Image möglichst klein zu halten.
RUN apt-get update && apt-get install -y \
    git curl build-essential \
    && rm -rf /var/lib/apt/lists/*

# Installiere jq im Build-Step
RUN apt-get update && apt-get install -y jq && rm -rf /var/lib/apt/lists/*

# Installiert das Python-Paket 'jupyter' im Container:
# - 'pip install --no-cache-dir jupyter': Installiert das Jupyter Notebook (und alles was dazugehört) ohne Pip-Cache zu speichern (spart Speicherplatz).
RUN pip install --no-cache-dir jupyter
