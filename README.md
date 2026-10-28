# SiGeRU Docker

Repositorio único con las aplicaciones y la infraestructura de despliegue de SiGeRU. Cada servicio tiene su propia carpeta, Dockerfile y contexto de construcción; Docker Compose los coordina desde `sigeru-infra/`.

## Carpetas

- `sigeru-landing/`: portada y páginas públicas.
- `sigeru-frontend/`: acceso, registro y panel operativo.
- `sigeru-backoffice/`: interfaz administrativa.
- `sigeru-api-usuarios/`, `sigeru-api-gestion/`, `sigeru-api-recoleccion/`: APIs separadas por área.
- `sigeru-infra/`: Compose, gateway Nginx, configuración de base de datos y certificados.

Consultar [sigeru-infra/README.md](sigeru-infra/README.md) para configurar `.env` y levantar el entorno.
