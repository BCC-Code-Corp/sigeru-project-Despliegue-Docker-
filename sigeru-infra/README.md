# SiGeRU: infraestructura Docker

Esta carpeta contiene la orquestación Compose y el gateway. Las seis aplicaciones son carpetas hermanas dentro del mismo repositorio Git.

## Estructura local esperada

La raíz del repositorio debe tener esta estructura:

```text
sigeru/
├── sigeru-landing/
├── sigeru-frontend/
├── sigeru-backoffice/
├── sigeru-api-usuarios/
├── sigeru-api-gestion/
├── sigeru-api-recoleccion/
└── sigeru-infra/                 # Compose, gateway, certificados y base
```

Cada aplicación contiene su propio `Dockerfile`. Las rutas `build.context` apuntan a las carpetas hermanas desde `sigeru-infra/`.

## Preparar y levantar

1. Crear `.env` copiando `.env.example` y cambiar ambas contraseñas.
2. Desde `sigeru-infra`, revisar la configuración: `docker compose config`.
3. Construir e iniciar: `docker compose up -d --build`.
4. Abrir `http://localhost:8080` (o el puerto definido en `HTTP_PORT`).
5. Ver los servicios: `docker compose ps`; ver registros: `docker compose logs -f`.

En desarrollo se pueden publicar los puertos internos de cada servicio solo en `127.0.0.1`:

```bash
docker compose -f compose.yaml -f compose.dev.yaml up -d --build
```

El gateway publica la aplicación; MariaDB no publica su puerto. Las aplicaciones PHP usan `db:3306` en la red interna `data`. El gateway solo comparte la red `proxy`.

## Convenciones de URL del gateway

- `/` → `sigeru-landing`
- `/Frontend/` → `sigeru-frontend`
- `/backoffice/` → `sigeru-backoffice`
- `/Backend/api/usuarios/` → `sigeru-api-usuarios`
- `/Backend/api/gestion/` → `sigeru-api-gestion`
- `/Backend/api/recoleccion/` → `sigeru-api-recoleccion`

Los servicios API reciben la ruta interna desde la raíz de su `public/`; por ejemplo, `/Backend/api/usuarios/login.php` en el navegador se reenvía como `/login.php` al servicio `api-usuarios`. Mantener estas convenciones al separar los endpoints.

La base `sigeru_db` se inicializa desde `db/001-sigeru.sql` al crear el volumen por primera vez. No usar los datos de demostración como datos reales. Para detener sin borrar datos, ejecutar `docker compose down`. No eliminar el volumen si se necesita conservar la base.

## Ubuntu Server

Instalar Docker Engine y Docker Compose, clonar este único repositorio en Ubuntu Server, crear `sigeru-infra/.env` y ejecutar los comandos de despliegue desde `sigeru-infra/`. Autorizar el puerto HTTP configurado en el firewall. La configuración HTTPS se agrega cuando se disponga de un dominio y certificado válido; nunca subir claves al repositorio.

## Despliegue separado y seguridad

Para el esquema de tres hosts, usar `compose.app-server.yaml` en el host de aplicaciones y `compose.database-server.yaml` en el host DB. La guía completa está en `docs/Guia_Seguridad_y_Despliegue_SiGeRU.docx` y su versión Markdown en `docs/SEGURIDAD-Y-DESPLIEGUE.md`. El tercer host recibe copias cifradas según `host-security/BACKUPS.md`.

El Compose de aplicaciones presupone certificado en `certs/fullchain.pem` y `certs/privkey.pem`, dominio configurado en Nginx, CIDR de administración limitado a la VPN y conectividad privada a MariaDB. Estos recursos no vienen en el repositorio.

Las plantillas de firewall deben revisarse en el servidor real. Docker documenta que los puertos publicados pueden no quedar filtrados por UFW; aplicar y probar reglas compatibles con Docker y firewall perimetral antes de producción. No exponer 3306 a Internet.
