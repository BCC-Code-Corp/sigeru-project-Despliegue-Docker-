# Seguridad del host y despliegue en tres servidores

Estos archivos preparan configuraciones revisables para el esquema de red de SiGeRU. No se aplicaron cambios en un servidor remoto. Los valores de IP, VPN, dominio, certificados y usuarios deben completarse en el entorno real antes de publicar.

## Tres servidores previstos

1. **Aplicaciones**: gateway Nginx, landing, frontend, backoffice y tres APIs. Solo el gateway publica 80/443. Las APIs consultan MariaDB mediante la IP privada del host DB.
2. **Base de datos**: MariaDB en un volumen persistente. El puerto 3306 se enlaza a la IP privada especificada en `DB_BIND_IP`, y el firewall de red debe aceptar conexiones solo desde el host de aplicaciones.
3. **Copias**: receptor SSH sin puertos de aplicación ni acceso entrante desde Internet. El host DB inicia la transferencia de dumps cifrados mediante SSH.

Compose crea redes locales a cada host; no forma por sí mismo una red privada entre servidores. La conectividad DB debe viajar por una interfaz privada/VPN y filtrarse también en el firewall de la nube/red.

## Qué quedó preparado en este repositorio

- `compose.app-server.yaml` y `compose.database-server.yaml` separan aplicaciones y MariaDB para dos de los hosts; `BACKUPS.md` y `backup-database.sh` definen la transferencia cifrada al tercero.
- `compose.tls.yaml` agrega HTTPS y redirección desde HTTP. El certificado y la clave se montan de solo lectura desde `certs/`.
- `gateway/routes.conf` comparte rutas; `/backoffice/` solo permite subredes privadas como base. Antes de producción, reemplazar por CIDR exacto de la VPN administrativa.
- Se quitó al backoffice de la red Docker de base de datos en el despliegue local.
- `host-security/` contiene plantillas para reglas host, tráfico Docker, SSH, Fail2ban y Suricata IDS.

Esto es configuración en código. No acredita que el firewall del proveedor, VPN, IDS/IPS, Fail2ban, TLS o backups estén activos en servidores reales.

## Preparar el host de aplicaciones

1. En la raíz del repositorio, obtener el código aprobado y entrar a `sigeru-infra`.
2. Copiar `app-server.env.example` como `.env`. Completar IP privada DB, usuario y clave de aplicación. El `.env` está excluido de Git.
3. Instalar un certificado válido para el dominio y guardarlo como `certs/fullchain.pem` y `certs/privkey.pem`; no subir la clave privada al repositorio. Ajustar `server_name` del gateway al dominio antes de publicar.
4. Cambiar `gateway/admin-allowlist.conf` para permitir exclusivamente la VPN/red de administración.
5. Definir firewall perimetral: TCP 443 desde Internet; TCP 80 para redirección; administración SSH solo desde VPN; sin acceso público al backoffice ni a puertos de API.
6. Revisar `host-security/docker-forward-firewall.sh app` con el administrador. En Ubuntu/Docker con iptables, UFW por sí solo no controla necesariamente puertos publicados. Persistir y comprobar las reglas con el proveedor/administrador de red antes de producción.
7. Validar y levantar: `docker compose -f compose.app-server.yaml config` y luego `docker compose -f compose.app-server.yaml up -d --build`.

## Preparar el host de base de datos

1. Copiar `database-server.env.example` como `.env`, asignar la IP privada exacta de la interfaz a `DB_BIND_IP` y credenciales fuertes distintas para usuario y root.
2. En la red/firewall, permitir TCP 3306 solamente desde la IP privada de aplicaciones. No crear reglas desde Internet.
3. Revisar `host-security/docker-forward-firewall.sh database` con el administrador y asegurar reglas en firewall de proveedor/iptables. El script UFW solo atiende tráfico al host, y no basta por sí solo para proteger todos los puertos publicados por Docker.
4. Validar: `docker compose -f compose.database-server.yaml config`; levantar: `docker compose -f compose.database-server.yaml up -d`.
5. No usar `down -v` si se quieren conservar datos. En un volumen ya inicializado, el SQL de inicialización no vuelve a ejecutarse.

## SSH, Fail2ban e IDS

- Crear una cuenta administrativa no root y desplegar primero su clave pública. Mantener una segunda sesión SSH abierta, validar el acceso por clave y recién entonces aplicar `host-security/sshd/99-sigeru.conf.example` y recargar SSH. Confirmar consola de proveedor para recuperación antes de deshabilitar contraseñas.
- Instalar Fail2ban desde paquetes oficiales de la distribución, copiar `host-security/fail2ban/sshd.local` a la ubicación local apropiada y revisar estado y logs. La plantilla solo protege SSH; no acredita instalación.
- Instalar Suricata en el host de aplicaciones en modo IDS, configurar interfaz y `HOME_NET` reales, validar con `suricata -T`, iniciar el servicio y conservar evidencias. El README de Suricata contiene la secuencia de revisión. No activar prevención IPS sin probar impacto.

## Copia de seguridad

Instalar `age` y `rsync` en host DB, configurar acceso SSH por clave al host de backup y validar fingerprints en `known_hosts`. Exportar `AGE_RECIPIENT`, `BACKUP_DEST` y `BACKUP_SSH_KEY` en un entorno protegido. El script genera `mariadb-dump`, gzip, cifra con la clave pública age y transfiere por SSH. La clave privada age debe permanecer solo en backup, con permisos restringidos.

Programar el script mediante timer de systemd o cron después de probarlo manualmente con datos de prueba. Definir retención, monitoreo de errores y una prueba periódica de restauración. El esquema no se considera respaldado hasta verificar que un dump se descifra y restaura correctamente.

## Matriz de requisitos y evidencia

| Requisito del esquema | Estado en el repositorio | Qué falta en infraestructura/evidencia |
| --- | --- | --- |
| Aplicaciones, DB y backup separados | Compose de aplicación y DB separados; procedimiento de backup al tercer host | Crear los tres hosts, direccionamiento privado y probar rutas/firewall |
| Gateway, HTTPS 443 y HTTP a HTTPS | Config TLS preparada como overlay | Dominio, certificado real, DNS y prueba externa de HTTPS/redirect |
| Base no accesible desde Internet | Compose no publica DB localmente; compose DB liga puerto a IP privada | IP privada correcta, firewall de proveedor y regla Docker persistente probada |
| Backoffice solo administración | Allowlist incluida | Restringir al CIDR VPN exacto y probar desde redes permitida/no permitida |
| Firewall / SSH con claves | Plantillas de host y SSH | Aplicar por administrador sin perder acceso; conservar configuración y logs |
| Fail2ban | Archivo local de configuración | Instalar/activar y guardar versión, estado y eventos |
| IDS/IPS | Procedimiento Suricata IDS | Instalar, validar interfaz/reglas y conservar logs de alertas; IPS queda pendiente de validación |
| Backups cifrados | Script y diseño age + rsync/SSH | Configurar secretos, automatizar, alertar y demostrar restauración |
| Reporte OWASP | No se inventa ni se simula en esta guía | Ejecutar análisis autorizado sobre versión desplegada, documentar alcance, fecha, hallazgos y correcciones |

## Evidencias que conviene adjuntar a la entrega

- Diagrama actualizado con tres hosts, segmentos, firewall, VPN, puertos y flujo de backup.
- Capturas con fecha de reglas del firewall de red y del host; prueba de que DB no responde desde Internet y sí desde API.
- Certificado/dominio y resultado de verificación HTTPS, sin exponer claves.
- `systemctl status` y logs de Fail2ban/Suricata, configuración y fecha.
- Log de backup cifrado, listado de archivos recibidos y registro de restauración de prueba.
- Reporte OWASP con versión, alcance, herramientas/fecha, hallazgos priorizados, remediaciones y reanálisis.

## Límite de esta entrega

Se prepararon archivos revisables y comandos de despliegue. No se instaló ni cambió ningún servicio de un servidor remoto porque la sesión no dispone de sus IPs, dominio, acceso VPN/SSH ni certificado. El PDF de tercera entrega marcado como desactualizado en su nombre no se usó como requisito vigente.
