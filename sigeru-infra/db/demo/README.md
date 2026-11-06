# Contenedores para probar el mapa

La muestra contiene 50 ubicaciones oficiales de contenedores domiciliarios de la Intendencia de Montevideo, descargadas el 8 de octubre de 2026. Los estados funcional, desbordado y roto son simulados: no describen su condición actual.

Fuente: https://datos-abiertos.montevideo.gub.uy/Contenedores_domiciliarios.zip

Catálogo y licencia DAG Uruguay: https://ckan.montevideo.gub.uy/dataset/contenedores-de-residuos-domiciliarios-ubicacion-circuitos-y-frecuencia-de-recoleccion

Las coordenadas X/Y se transformaron de SIRGAS 2000 / UTM 21S (EPSG:31981) a WGS84 (EPSG:4326), usando pyproj. Se eligió una ubicación por celda dentro de una zona urbana de Montevideo, hasta completar 50. El JSON conserva el identificador oficial, el circuito y el horario publicado.

Para una instalación existente, el importador aplica la migración de coordenadas si falta. El esquema principal ya incluye esos campos para instalaciones nuevas, y `sigeru_db.sql` ya carga estos 50 contenedores (con las mismas fuente y referencia externa) junto con incidencias simuladas sobre ellos; en una instalación nueva no hace falta ejecutar el importador.

Configurar las variables SIGERU_DB_HOST, SIGERU_DB_NAME, SIGERU_DB_USER y SIGERU_DB_PASSWORD según corresponda, y ejecutar desde la raíz del proyecto:

```sh
php Backend/database/demo/importar_contenedores.php --base-de-prueba
```

Usar solo en una base local de demostración. El importador conserva los contenedores existentes y no duplica los ya importados. Todos los registros de la muestra llevan datos_prueba=1 y su fuente oficial. El popup del mapa identifica los estados simulados.

En el backoffice, entrar en Mapa. En el panel de vecino, entrar en Reportar incidencia y seleccionar un marcador. Las coordenadas del contenedor pasan a la vista de confirmación del reporte. Los registros antiguos sin coordenadas conservan la búsqueda por dirección.
