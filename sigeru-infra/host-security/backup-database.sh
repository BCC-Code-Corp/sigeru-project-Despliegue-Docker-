#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
: "${AGE_RECIPIENT:?Falta AGE_RECIPIENT}"
: "${BACKUP_DEST:?Falta BACKUP_DEST}"
: "${BACKUP_SSH_KEY:?Falta BACKUP_SSH_KEY}"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
DUMP="$WORK/sigeru_db_${STAMP}.sql.gz.age"
docker compose -f "$ROOT/compose.database-server.yaml" exec -T db sh -ec \
  'MYSQL_PWD="$MARIADB_PASSWORD" mariadb-dump --single-transaction --routines --triggers --user="$MARIADB_USER" sigeru_db' \
  | gzip -c | age -r "$AGE_RECIPIENT" -o "$DUMP"
rsync -e "ssh -i $BACKUP_SSH_KEY -o BatchMode=yes -o StrictHostKeyChecking=yes" \
  "$DUMP" "$BACKUP_DEST"
printf 'Copia cifrada transferida: %s\n' "$(basename "$DUMP")"
