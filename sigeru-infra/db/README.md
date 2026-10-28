# Base de datos

`001-sigeru.sql` se ejecuta automáticamente cuando MariaDB inicializa por primera vez un volumen vacío. El script del proyecto crea las tablas y los datos iniciales; no se vuelve a ejecutar sobre un volumen ya inicializado.

Los datos se conservan en el volumen nombrado `sigeru_db_data`. La persistencia no reemplaza las copias de seguridad.
