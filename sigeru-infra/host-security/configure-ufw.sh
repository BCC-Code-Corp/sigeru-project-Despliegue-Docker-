#!/usr/bin/env bash
# Plantilla de política UFW para tráfico dirigido al host, especialmente SSH.
# UFW no basta para filtrar puertos publicados por Docker; ver README de host-security.
set -euo pipefail
ROLE="${1:-}"
: "${ADMIN_CIDR:?Definí ADMIN_CIDR con la subred VPN/administrativa}"
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow from "$ADMIN_CIDR" to any port 22 proto tcp comment 'SSH administración por VPN'
case "$ROLE" in
  app|database|backup) ;;
  *) echo 'Uso: configure-ufw.sh app|database|backup'; exit 2 ;;
esac
sudo ufw status numbered
printf '\nNo habilita UFW automáticamente. Confirmá consola de recuperación y acceso SSH antes de habilitar.\n'
