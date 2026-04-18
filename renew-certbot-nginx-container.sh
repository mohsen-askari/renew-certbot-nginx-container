#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# SSL Auto Renewal Script for Nginx Docker Container
# Author: Mohsen Askari
# Role: DevOps Engineer And Fullstack Developer
# Website: https://mohsen-askari.ir
# GitHub: https://github.com/mohsen-askari
# -----------------------------------------------------------------------------

CONTAINER_NAME="nginx"
SIGNATURE="Mohsen Askari | DevOps Engineer And Fullstack Developer | mohsen-askari.ir | github.com/mohsen-askari"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$SIGNATURE] SSL renew job started"

# Check whether the container exists
if ! docker inspect "$CONTAINER_NAME" >/dev/null 2>&1; then
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$SIGNATURE] Container '$CONTAINER_NAME' not found. Exit."
  exit 0
fi

# Check whether the container is running
IS_RUNNING="$(docker inspect -f '{{.State.Running}}' "$CONTAINER_NAME" 2>/dev/null || echo false)"
if [ "$IS_RUNNING" != "true" ]; then
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$SIGNATURE] Container '$CONTAINER_NAME' is not running. Exit."
  exit 0
fi

# Execute the renewal flow inside the container
docker exec -i "$CONTAINER_NAME" sh -lc '
set -eu

export DEBIAN_FRONTEND=noninteractive
SIGNATURE="Mohsen Askari | DevOps Engineer And Fullstack Developer | mohsen-askari.ir | github.com/mohsen-askari"

echo "[$(date "+%Y-%m-%d %H:%M:%S")] [$SIGNATURE] [inside-container] Checking certbot..."

# Install certbot only if it is not already installed
if ! command -v certbot >/dev/null 2>&1; then
  echo "[$(date "+%Y-%m-%d %H:%M:%S")] [$SIGNATURE] [inside-container] Certbot not found. Installing..."
  apt-get update
  apt-get install -y certbot python3-certbot-nginx
else
  echo "[$(date "+%Y-%m-%d %H:%M:%S")] [$SIGNATURE] [inside-container] Certbot already installed."
fi

# Exit if no renewal configuration exists yet
if [ ! -d /etc/letsencrypt/renewal ] || ! ls /etc/letsencrypt/renewal/*.conf >/dev/null 2>&1; then
  echo "[$(date "+%Y-%m-%d %H:%M:%S")] [$SIGNATURE] [inside-container] No existing renewal configs found. Nothing to renew."
  exit 0
fi

echo "[$(date "+%Y-%m-%d %H:%M:%S")] [$SIGNATURE] [inside-container] Running certbot renew..."

# Nginx will reload only when a certificate is actually renewed successfully
certbot renew --deploy-hook "nginx -t && nginx -s reload"

echo "[$(date "+%Y-%m-%d %H:%M:%S")] [$SIGNATURE] [inside-container] Certbot renew finished."
'

echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$SIGNATURE] SSL renew job finished"
