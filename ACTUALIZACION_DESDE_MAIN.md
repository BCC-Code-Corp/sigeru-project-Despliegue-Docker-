# Actualización de SiGeRU Docker desde la versión principal

Se sincronizó el código PHP de `Backend/api/{usuarios,gestion,recoleccion}` a los respectivos `public/` y las clases PHP compartidas a `app/` de cada API. Se actualizaron las páginas, scripts y recursos del frontend, landing y backoffice, conservando Dockerfiles, gateway, Compose y políticas de seguridad existentes.

## Despliegue

1. **Respaldá la base de datos** y conservá el archivo `.env` real fuera del ZIP.
2. En `sigeru-infra`, configurá `.env` a partir de `.env.example` si es un entorno nuevo.
3. Para construir: `docker compose -f compose.yaml build` y luego `docker compose -f compose.yaml up -d`.
4. En una instalación existente, **no se ejecutan automáticamente** las migraciones de `sigeru-infra/db/migrations/`. Revisalas y aplicalas en orden contra un respaldo de prueba antes de producción. Algunas migraciones alteran datos y estados.
5. En un volumen vacío, `db/001-sigeru.sql` inicializa el esquema y datos de la versión principal; no se reimporta en volúmenes existentes.

## Validación

Se verificó la sintaxis de los PHP con `php -l`. No se pudo ejecutar una compilación ni pruebas de integración de contenedores porque Docker no está instalado en el entorno de edición. Probar login, panel, backoffice, rutas, incidencias, penalizaciones y gestión de residuos antes de usar en producción.

## Consideraciones

El gateway conserva sus rutas `/Backend/api/usuarios/`, `/Backend/api/gestion/`, `/Backend/api/recoleccion/`, `/Frontend/` y `/backoffice.html`. La ruta nueva `penalizados.php` se publica por el prefijo de usuarios existente. Los archivos de base de datos demo son material de referencia, no se importan automáticamente.
