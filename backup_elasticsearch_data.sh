#!/bin/bash
# ------------------------------------------------------------------------------
# Purpose:
#   Back up Elasticsearch’s data directory from a running container into a
#   timestamped .tar.gz file in your Codespace workspace.
#
# Why stop/start the container?
#   Elasticsearch changes files constantly when running. By stopping the container
#   before reading the files, we avoid the “file changed as we read it” warning
#   and guarantee a consistent backup.
# ------------------------------------------------------------------------------

# ====== CONFIGURATION ======
BACKUP_DIR="/workspaces/piskklis/snomedct_releases"   # Where to store the backup archive on host/devcontainer
DATA_PATH="/usr/share/elasticsearch/data"             # Path to data inside the Elasticsearch container
CONTAINER="piskklis_devcontainer-elasticsearch-1"     # Container name or ID (check with: docker ps)

# ====== PREPARE BACKUP DIR ======
mkdir -p "$BACKUP_DIR"  # Create backup folder if it doesn't exist

# ====== STOP CONTAINER ======
echo "[INFO] Stopping container '$CONTAINER'..."
docker stop "$CONTAINER"

# ====== CREATE BACKUP ======
echo "[INFO] Creating archive from $DATA_PATH..."
docker run --rm \
  --volumes-from "$CONTAINER" \
  -v "$BACKUP_DIR":/backup \
  busybox sh -c "tar -C '$DATA_PATH' -czf /backup/elastic-$(date -u +%Y%m%dT%H%M%SZ).tar.gz ."

# ====== START CONTAINER ======
echo "[INFO] Restarting container '$CONTAINER'..."
docker start "$CONTAINER"

# ====== DONE ======
echo "[INFO] Backup completed."
echo "[INFO] File saved to: $BACKUP_DIR"
