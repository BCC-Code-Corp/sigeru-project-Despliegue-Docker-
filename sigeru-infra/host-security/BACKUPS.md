# Copia de seguridad cifrada de MariaDB

Ejecutar desde el host DB después de configurar acceso SSH por clave al host de backups. Requiere `age`, `rsync` y Docker Compose. No introducir secretos en el repositorio ni en argumentos visibles de shell.

Variables requeridas: `AGE_RECIPIENT` (clave pública age), `BACKUP_DEST` (ej. `backupuser@10.0.0.30:/srv/sigeru/incoming/`), `BACKUP_SSH_KEY` (ruta a clave privada protegida). Registrar `BACKUP_DEST` en `known_hosts`; el script conserva StrictHostKeyChecking.

El receptor age privado se guarda solo en el host de backups, con permisos restringidos. Sin esa clave privada no se puede restaurar.
