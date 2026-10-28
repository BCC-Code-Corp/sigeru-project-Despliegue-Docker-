USE sigeru_db;

-- Modelo físico y datos de demostración. Importar una vez en una base VACÍA.
-- No importar sobre una instalación con datos existentes.
SET
  SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";

SET
  time_zone = "+00:00";

-- --------------------------------------------------------
-- Limpieza previa (orden inverso a las dependencias FK)
-- --------------------------------------------------------
-- --------------------------------------------------------
-- Tabla: usuarios
-- --------------------------------------------------------
CREATE TABLE
  `usuarios` (
    `id` int (11) NOT NULL AUTO_INCREMENT,
    `nombre` varchar(100) NOT NULL,
    `email` varchar(100) NOT NULL,
    `cedula` varchar(20) NOT NULL,
    `password` varchar(255) NOT NULL,
    `rol` enum (
      'administrador',
      'operario',
      'cuadrilla',
      'vecino'
    ) NOT NULL DEFAULT 'vecino',
    PRIMARY KEY (`id`),
    UNIQUE KEY `email` (`email`),
    UNIQUE KEY `cedula` (`cedula`)
  ) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci;

-- --------------------------------------------------------
-- Tabla: camiones
-- --------------------------------------------------------
CREATE TABLE
  `camiones` (
    `id` int (11) NOT NULL AUTO_INCREMENT,
    `matricula` varchar(20) NOT NULL,
    `capacidad_carga` decimal(10, 2) DEFAULT NULL,
    `estado` varchar(30) NOT NULL DEFAULT 'Disponible',
    `cuadrilla_id` int (11) DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `matricula` (`matricula`),
    KEY `fk_camion_cuadrilla` (`cuadrilla_id`),
    CONSTRAINT `fk_camion_cuadrilla` FOREIGN KEY (`cuadrilla_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL
  ) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci;

-- --------------------------------------------------------
-- Tabla: contenedores
-- --------------------------------------------------------
CREATE TABLE
  `contenedores` (
    `id` int (11) NOT NULL AUTO_INCREMENT,
    `ubicacion` varchar(255) NOT NULL,
    `estado` enum ('lleno', 'vacio', 'mantenimiento') DEFAULT 'vacio',
    PRIMARY KEY (`id`)
  ) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci;

-- --------------------------------------------------------
-- Tabla: incidencias
-- --------------------------------------------------------
CREATE TABLE
  `incidencias` (
    `id` int (11) NOT NULL AUTO_INCREMENT,
    `ubicacion` varchar(255) NOT NULL,
    `latitud` decimal(10, 7) DEFAULT NULL,
    `longitud` decimal(10, 7) DEFAULT NULL,
    `estado_contenedor` varchar(100) NOT NULL,
    `tipo_basura` varchar(100) NOT NULL,
    `estado_incidencia` varchar(50) DEFAULT 'abierta',
    `usuario_id` int (11) DEFAULT NULL,
    `cuadrilla_id` int (11) DEFAULT NULL,
    `matricula_camion` varchar(20) DEFAULT NULL,
    `comentario_operario` varchar(255) DEFAULT NULL,
    `fecha_creacion` timestamp NOT NULL DEFAULT current_timestamp(),
    PRIMARY KEY (`id`),
    KEY `fk_incidencia_usuario` (`usuario_id`),
    KEY `fk_incidencia_cuadrilla` (`cuadrilla_id`),
    KEY `fk_incidencia_camion` (`matricula_camion`),
    CONSTRAINT `fk_incidencia_usuario` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL,
    CONSTRAINT `fk_incidencia_cuadrilla` FOREIGN KEY (`cuadrilla_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL,
    CONSTRAINT `fk_incidencia_camion` FOREIGN KEY (`matricula_camion`) REFERENCES `camiones` (`matricula`) ON DELETE SET NULL
  ) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci;

-- --------------------------------------------------------
-- Tabla: notificaciones
-- --------------------------------------------------------
-- usuario_id = NULL  ->  anuncio público (visible para todos los usuarios)
-- usuario_id = X     ->  notificación privada para el usuario X
--                        (por ejemplo, el cambio de estado de su incidencia)
CREATE TABLE
  `notificaciones` (
    `id` int (11) NOT NULL AUTO_INCREMENT,
    `usuario_id` int (11) DEFAULT NULL,
    `tipo` varchar(30) NOT NULL DEFAULT 'sistema',
    `mensaje` varchar(500) NOT NULL,
    `incidencia_id` int (11) DEFAULT NULL,
    `leida` tinyint (1) NOT NULL DEFAULT 0,
    `fecha_creacion` timestamp NOT NULL DEFAULT current_timestamp(),
    PRIMARY KEY (`id`),
    KEY `fk_notificacion_usuario` (`usuario_id`),
    KEY `fk_notificacion_incidencia` (`incidencia_id`),
    CONSTRAINT `fk_notificacion_usuario` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_notificacion_incidencia` FOREIGN KEY (`incidencia_id`) REFERENCES `incidencias` (`id`) ON DELETE SET NULL
  ) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci;

-- --------------------------------------------------------
-- Tabla: centros_acopio
-- --------------------------------------------------------
CREATE TABLE
  `centros_acopio` (
    `id` int (11) NOT NULL AUTO_INCREMENT,
    `nombre` varchar(150) NOT NULL,
    `ubicacion` varchar(255) NOT NULL,
    `maquinaria` varchar(255) DEFAULT NULL,
    `estado` varchar(30) NOT NULL DEFAULT 'Operativo',
    PRIMARY KEY (`id`)
  ) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci;

-- --------------------------------------------------------
-- Datos de ejemplo
-- --------------------------------------------------------
-- Contraseñas de prueba (en texto plano, documentadas también en el README):
--   admin@sigeru.uy      -> admin123
--   vecino@sigeru.uy     -> vecino123
--   operario@sigeru.uy   -> operario123
--   cuadrilla@sigeru.uy  -> cuadrilla123
INSERT INTO
  `usuarios` (`nombre`, `email`, `cedula`, `password`, `rol`)
VALUES
  (
    'Admin Prueba',
    'admin@sigeru.uy',
    '10000008',
    '$2b$10$t3DloQv8mEmIeQb.Jzq5NOTQRHv33IGcipQZraC.6r3C34WlLvmgO',
    'administrador'
  ),
  (
    'Vecino Prueba',
    'vecino@sigeru.uy',
    '10000014',
    '$2b$10$PWDGKWPX1Pp9wzlDwV5PAuKGubAQZBH180E1QBo74DiZJ0MZy97Sm',
    'vecino'
  ),
  (
    'Operario Prueba',
    'operario@sigeru.uy',
    '10000020',
    '$2b$10$9eiyJONfrLI.v1FF/0Rx6.fipIrPAm/7x/J8n3/kzm5q24bGGi5wO',
    'operario'
  ),
  (
    'Cuadrilla Prueba',
    'cuadrilla@sigeru.uy',
    '10000036',
    '$2b$10$s1sQ/IpEgrlVE5GbHVuu4OWk.hgS5svE9rGHxaYh8HEzvJYfyDvs6',
    'cuadrilla'
  );

-- El camión 'ABC 1234' ya tiene asignada a la Cuadrilla Prueba (id 4)
-- de forma persistente, a modo de ejemplo de la asignación cuadrilla-camión.
INSERT INTO
  `camiones` (
    `matricula`,
    `capacidad_carga`,
    `estado`,
    `cuadrilla_id`
  )
VALUES
  ('ABC 1234', 100.00, 'Disponible', 4),
  ('SBJ 3422', 73.00, 'Disponible', NULL),
  ('XYZ 9087', 120.50, 'En Ruta', NULL),
  ('LMN 5566', 85.00, 'Mantenimiento', NULL);

INSERT INTO
  `contenedores` (`ubicacion`, `estado`)
VALUES
  ('Av Italia 1413', 'lleno'),
  ('18 de Julio esq. Ejido', 'vacio'),
  ('Bulevar Artigas 2340', 'mantenimiento'),
  ('Rambla Rep. de Chile 1200', 'vacio');

INSERT INTO
  `incidencias` (
    `ubicacion`,
    `estado_contenedor`,
    `tipo_basura`,
    `estado_incidencia`,
    `usuario_id`
  )
VALUES
  (
    'Alejandro Gallinal 1675',
    'Lleno',
    'Reciclable',
    'abierta',
    2
  ),
  (
    'Av Italia 1333',
    'Desbordado',
    'Normal / Orgánica',
    'abierta',
    2
  ),
  (
    'Camino Cervando y Camino Carrasco',
    'Roto / Dañado',
    'Reciclable',
    'abierta',
    2
  );

INSERT INTO
  `centros_acopio` (`nombre`, `ubicacion`, `maquinaria`, `estado`)
VALUES
  (
    'Centro de Acopio Norte',
    'Ruta 8 km 17',
    'Compactadora, cinta transportadora',
    'Operativo'
  ),
  (
    'Centro de Acopio Sur',
    'Camino Maldonado km 22',
    'Cargador frontal, prensa de fardos',
    'Operativo'
  ),
  (
    'Planta de Clasificación Este',
    'Ruta 102 km 5',
    'Cinta de selección manual, imán separador',
    'Mantenimiento'
  );

INSERT INTO
  `notificaciones` (`usuario_id`, `tipo`, `mensaje`)
VALUES
  (
    NULL,
    'anuncio',
    'Bienvenido a SiGeRU: ya podés reportar incidencias de contenedores y hacer seguimiento de su estado desde tu panel.'
  );

-- Ejecutar UNA VEZ sobre el esquema anterior, después de realizar un respaldo.
-- No elimina registros. Los datos históricos desconocidos quedan NULL.
CREATE TABLE
  cuadrillas (
    id int PRIMARY KEY AUTO_INCREMENT,
    nombre varchar(100) NOT NULL,
    disponibilidad boolean NOT NULL DEFAULT 1,
    fecha_creacion timestamp DEFAULT CURRENT_TIMESTAMP,
    fecha_modificacion timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
  ) ENGINE = InnoDB;

INSERT INTO
  cuadrillas (id, nombre)
SELECT
  id,
  nombre
FROM
  usuarios
WHERE
  rol = 'cuadrilla';

ALTER TABLE usuarios MODIFY rol enum (
  'administrador',
  'operario',
  'cuadrilla',
  'vecino',
  'chofer',
  'recolector'
) NOT NULL DEFAULT 'vecino',
ADD activo boolean NOT NULL DEFAULT 1,
ADD fecha_creacion timestamp DEFAULT CURRENT_TIMESTAMP,
ADD fecha_modificacion timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;

CREATE TABLE
  funcionarios (
    id int PRIMARY KEY,
    fecha_contratacion date NULL,
    direccion varchar(255),
    email_laboral varchar(100),
    FOREIGN KEY (id) REFERENCES usuarios (id)
  ) ENGINE = InnoDB;

CREATE TABLE
  administradores (
    id int PRIMARY KEY,
    nombre_municipio varchar(100),
    FOREIGN KEY (id) REFERENCES funcionarios (id)
  ) ENGINE = InnoDB;

CREATE TABLE
  choferes (
    id int PRIMARY KEY,
    lic_conducir varchar(100),
    cuadrilla_id int NULL,
    FOREIGN KEY (id) REFERENCES funcionarios (id),
    FOREIGN KEY (cuadrilla_id) REFERENCES cuadrillas (id)
  ) ENGINE = InnoDB;

CREATE TABLE
  recolectores (
    id int PRIMARY KEY,
    turno varchar(50),
    cuadrilla_id int NULL,
    FOREIGN KEY (id) REFERENCES funcionarios (id),
    FOREIGN KEY (cuadrilla_id) REFERENCES cuadrillas (id)
  ) ENGINE = InnoDB;

CREATE TABLE
  vecinos (
    id int PRIMARY KEY,
    direccion varchar(255),
    FOREIGN KEY (id) REFERENCES usuarios (id)
  ) ENGINE = InnoDB;

INSERT INTO
  funcionarios (id)
SELECT
  id
FROM
  usuarios
WHERE
  rol <> 'vecino';

INSERT INTO
  administradores (id)
SELECT
  id
FROM
  usuarios
WHERE
  rol = 'administrador';

INSERT INTO
  vecinos (id)
SELECT
  id
FROM
  usuarios
WHERE
  rol = 'vecino';

INSERT INTO
  recolectores (id, cuadrilla_id)
SELECT
  id,
  id
FROM
  usuarios
WHERE
  rol = 'cuadrilla';

UPDATE usuarios
SET
  rol = 'recolector'
WHERE
  rol = 'cuadrilla';

ALTER TABLE usuarios MODIFY rol enum (
  'administrador',
  'operario',
  'vecino',
  'chofer',
  'recolector'
) NOT NULL DEFAULT 'vecino';

ALTER TABLE camiones
DROP FOREIGN KEY fk_camion_cuadrilla,
ADD CONSTRAINT fk_camion_equipo FOREIGN KEY (cuadrilla_id) REFERENCES cuadrillas (id),
ADD modelo varchar(100),
ADD chofer_id int NULL,
ADD centro_id int NULL,
ADD activo boolean NOT NULL DEFAULT 1,
ADD motivo_baja varchar(255),
ADD fecha_creacion timestamp DEFAULT CURRENT_TIMESTAMP,
ADD fecha_modificacion timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
ADD FOREIGN KEY (chofer_id) REFERENCES choferes (id);

ALTER TABLE contenedores MODIFY estado varchar(30) NOT NULL DEFAULT 'funcional',
ADD tipo_residuo varchar(100) NULL,
ADD tipo_contenedor varchar(100) NULL,
ADD en_servicio boolean NOT NULL DEFAULT 1,
ADD motivo_baja varchar(255),
ADD fecha_creacion timestamp DEFAULT CURRENT_TIMESTAMP,
ADD fecha_modificacion timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;

UPDATE contenedores
SET
  estado = CASE estado
    WHEN 'vacio' THEN 'funcional'
    WHEN 'lleno' THEN 'desbordado'
    WHEN 'mantenimiento' THEN 'roto'
    ELSE estado
  END;

ALTER TABLE contenedores MODIFY estado enum ('funcional', 'roto', 'desbordado') NOT NULL DEFAULT 'funcional';

ALTER TABLE centros_acopio ADD tipo_centro enum ('acopio', 'vertedero') NOT NULL DEFAULT 'acopio',
ADD capacidad decimal(12, 2) NULL,
ADD capacidad_ocupada decimal(12, 2) NOT NULL DEFAULT 0,
ADD administrador_id int NULL,
ADD activo boolean NOT NULL DEFAULT 1,
ADD motivo_baja varchar(255),
ADD fecha_creacion timestamp DEFAULT CURRENT_TIMESTAMP,
ADD fecha_modificacion timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
ADD FOREIGN KEY (administrador_id) REFERENCES administradores (id);

ALTER TABLE camiones ADD FOREIGN KEY (centro_id) REFERENCES centros_acopio (id);

CREATE TABLE
  operarios (
    id int PRIMARY KEY,
    especialidad varchar(100),
    planta_reciclaje varchar(100),
    centro_id int NULL,
    FOREIGN KEY (id) REFERENCES funcionarios (id),
    FOREIGN KEY (centro_id) REFERENCES centros_acopio (id)
  ) ENGINE = InnoDB;

INSERT INTO
  operarios (id)
SELECT
  id
FROM
  usuarios
WHERE
  rol = 'operario';

CREATE TABLE
  maquinaria (
    id int PRIMARY KEY AUTO_INCREMENT,
    nombre varchar(255) NOT NULL,
    estado varchar(30) NOT NULL DEFAULT 'Operativo',
    centro_id int NOT NULL,
    fecha_creacion timestamp DEFAULT CURRENT_TIMESTAMP,
    fecha_modificacion timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (centro_id) REFERENCES centros_acopio (id)
  ) ENGINE = InnoDB;

INSERT INTO
  maquinaria (nombre, estado, centro_id)
SELECT
  maquinaria,
  estado,
  id
FROM
  centros_acopio
WHERE
  maquinaria IS NOT NULL
  AND maquinaria <> '';

CREATE TABLE
  residuos (
    id int PRIMARY KEY AUTO_INCREMENT,
    tipo_residuo varchar(100) NOT NULL UNIQUE
  ) ENGINE = InnoDB;

CREATE TABLE
  gestionan (
    centro_id int NOT NULL,
    residuo_id int NOT NULL,
    PRIMARY KEY (centro_id, residuo_id),
    FOREIGN KEY (centro_id) REFERENCES centros_acopio (id),
    FOREIGN KEY (residuo_id) REFERENCES residuos (id)
  ) ENGINE = InnoDB;

CREATE TABLE
  rutas (
    id int PRIMARY KEY AUTO_INCREMENT,
    nombre varchar(100) NOT NULL,
    zona varchar(255) NOT NULL,
    frecuencia varchar(100) NOT NULL,
    horario varchar(100) NOT NULL,
    activo boolean NOT NULL DEFAULT 1,
    fecha_creacion timestamp DEFAULT CURRENT_TIMESTAMP,
    fecha_modificacion timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
  ) ENGINE = InnoDB;

CREATE TABLE
  sigue (
    cuadrilla_id int NOT NULL,
    ruta_id int NOT NULL,
    PRIMARY KEY (cuadrilla_id, ruta_id),
    FOREIGN KEY (cuadrilla_id) REFERENCES cuadrillas (id),
    FOREIGN KEY (ruta_id) REFERENCES rutas (id)
  ) ENGINE = InnoDB;

CREATE TABLE
  realiza (
    matricula varchar(20) NOT NULL,
    ruta_id int NOT NULL,
    PRIMARY KEY (matricula, ruta_id),
    FOREIGN KEY (matricula) REFERENCES camiones (matricula),
    FOREIGN KEY (ruta_id) REFERENCES rutas (id)
  ) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci;

CREATE TABLE
  contiene (
    ruta_id int NOT NULL,
    contenedor_id int NOT NULL,
    PRIMARY KEY (ruta_id, contenedor_id),
    FOREIGN KEY (ruta_id) REFERENCES rutas (id),
    FOREIGN KEY (contenedor_id) REFERENCES contenedores (id)
  ) ENGINE = InnoDB;

ALTER TABLE incidencias
DROP FOREIGN KEY fk_incidencia_cuadrilla,
ADD CONSTRAINT fk_incidencia_equipo FOREIGN KEY (cuadrilla_id) REFERENCES cuadrillas (id),
ADD descripcion text NULL,
ADD solucion text NULL,
ADD fecha_cierre datetime NULL,
ADD ruta_id int NULL,
ADD fecha_modificacion timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
ADD FOREIGN KEY (ruta_id) REFERENCES rutas (id);

UPDATE incidencias
SET
  estado_incidencia = 'cerrada'
WHERE
  estado_incidencia IN (
    'incidencia solucionada',
    'resuelta',
    'solucionada'
  );

ALTER TABLE incidencias MODIFY estado_incidencia enum ('abierta', 'en curso', 'cerrada') NOT NULL DEFAULT 'abierta';

CREATE TABLE
  sobre (
    contenedor_id int NOT NULL,
    incidencia_id int NOT NULL,
    PRIMARY KEY (contenedor_id, incidencia_id),
    FOREIGN KEY (contenedor_id) REFERENCES contenedores (id),
    FOREIGN KEY (incidencia_id) REFERENCES incidencias (id)
  ) ENGINE = InnoDB;

CREATE TABLE
  reclamos (
    id int PRIMARY KEY AUTO_INCREMENT,
    usuario_id int NOT NULL,
    incidencia_id int NOT NULL,
    descripcion text NOT NULL,
    ubicacion varchar(255) NOT NULL,
    prioridad enum ('baja', 'media', 'alta') DEFAULT 'media',
    estado enum ('abierto', 'en curso', 'cerrado') DEFAULT 'abierto',
    fecha_creacion timestamp DEFAULT CURRENT_TIMESTAMP,
    fecha_modificacion timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES vecinos (id),
    FOREIGN KEY (incidencia_id) REFERENCES incidencias (id)
  ) ENGINE = InnoDB;

CREATE TABLE
  asignaciones (
    id int PRIMARY KEY AUTO_INCREMENT,
    ruta_id int NOT NULL,
    cuadrilla_id int NOT NULL,
    matricula varchar(20) NOT NULL,
    fecha date NOT NULL,
    fecha_creacion timestamp DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (cuadrilla_id, fecha),
    UNIQUE (matricula, fecha),
    FOREIGN KEY (ruta_id) REFERENCES rutas (id),
    FOREIGN KEY (cuadrilla_id) REFERENCES cuadrillas (id),
    FOREIGN KEY (matricula) REFERENCES camiones (matricula)
  ) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci;

CREATE TABLE
  recolecciones (
    id int PRIMARY KEY AUTO_INCREMENT,
    contenedor_id int NOT NULL,
    recolector_id int NOT NULL,
    ruta_id int NOT NULL,
    cuadrilla_id int NOT NULL,
    fecha datetime NOT NULL,
    volumen decimal(12, 2) NULL,
    simulado boolean NOT NULL DEFAULT 0,
    fecha_creacion timestamp DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (contenedor_id) REFERENCES contenedores (id),
    FOREIGN KEY (recolector_id) REFERENCES recolectores (id),
    FOREIGN KEY (ruta_id) REFERENCES rutas (id),
    FOREIGN KEY (cuadrilla_id) REFERENCES cuadrillas (id)
  ) ENGINE = InnoDB;

CREATE TABLE
  mantenimientos (
    id int PRIMARY KEY AUTO_INCREMENT,
    descripcion text NOT NULL,
    tipo_man varchar(100) NOT NULL,
    fecha_man date NOT NULL,
    prox_man date NULL,
    fecha_creacion timestamp DEFAULT CURRENT_TIMESTAMP
  ) ENGINE = InnoDB;

CREATE TABLE
  recibe (
    matricula varchar(20) NOT NULL,
    mantenimiento_id int NOT NULL,
    PRIMARY KEY (matricula, mantenimiento_id),
    FOREIGN KEY (matricula) REFERENCES camiones (matricula),
    FOREIGN KEY (mantenimiento_id) REFERENCES mantenimientos (id)
  ) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci;

CREATE TABLE
  reparaciones (
    id int PRIMARY KEY AUTO_INCREMENT,
    tipo_reparacion varchar(100) NOT NULL,
    fecha_inicio date NOT NULL,
    fecha_fin date NULL,
    fecha_creacion timestamp DEFAULT CURRENT_TIMESTAMP
  ) ENGINE = InnoDB;

CREATE TABLE
  necesita (
    incidencia_id int NOT NULL,
    reparacion_id int NOT NULL,
    PRIMARY KEY (incidencia_id, reparacion_id),
    FOREIGN KEY (incidencia_id) REFERENCES incidencias (id),
    FOREIGN KEY (reparacion_id) REFERENCES reparaciones (id)
  ) ENGINE = InnoDB;

CREATE TABLE
  recepciones (
    id int PRIMARY KEY AUTO_INCREMENT,
    centro_id int NOT NULL,
    residuo_id int NOT NULL,
    operario_id int NOT NULL,
    cantidad decimal(12, 2) NOT NULL,
    simulado boolean NOT NULL DEFAULT 0,
    fecha_creacion timestamp DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (centro_id, residuo_id) REFERENCES gestionan (centro_id, residuo_id),
    FOREIGN KEY (operario_id) REFERENCES usuarios (id)
  ) ENGINE = InnoDB;

CREATE TABLE
  historial_incidencias (
    id int PRIMARY KEY AUTO_INCREMENT,
    incidencia_id int NOT NULL,
    usuario_id int NOT NULL,
    estado_anterior varchar(30),
    estado_nuevo varchar(30) NOT NULL,
    observacion text NOT NULL,
    fecha timestamp DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (incidencia_id) REFERENCES incidencias (id),
    FOREIGN KEY (usuario_id) REFERENCES usuarios (id)
  ) ENGINE = InnoDB;

CREATE TABLE
  auditoria (
    id bigint PRIMARY KEY AUTO_INCREMENT,
    usuario_id int NULL,
    recurso varchar(100) NOT NULL,
    accion varchar(30) NOT NULL,
    referencia varchar(100),
    detalle text,
    fecha timestamp DEFAULT CURRENT_TIMESTAMP
  ) ENGINE = InnoDB;

CREATE TABLE
  notificaciones_leidas (
    notificacion_id int NOT NULL,
    usuario_id int NOT NULL,
    PRIMARY KEY (notificacion_id, usuario_id),
    FOREIGN KEY (notificacion_id) REFERENCES notificaciones (id),
    FOREIGN KEY (usuario_id) REFERENCES usuarios (id)
  ) ENGINE = InnoDB;

ALTER TABLE usuarios ADD auth_version int NOT NULL DEFAULT 1;

CREATE TABLE
  intentos_login (
    email_hash char(64) PRIMARY KEY,
    intentos int NOT NULL DEFAULT 0,
    bloqueado_hasta datetime NULL,
    actualizado timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
  ) ENGINE = InnoDB;

CREATE TABLE
  historial_capacidad (
    id bigint PRIMARY KEY AUTO_INCREMENT,
    centro_id int NOT NULL,
    usuario_id int NOT NULL,
    capacidad decimal(12, 2) NOT NULL,
    capacidad_ocupada decimal(12, 2) NOT NULL,
    estado varchar(30) NOT NULL,
    fecha timestamp DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (centro_id) REFERENCES centros_acopio (id),
    FOREIGN KEY (usuario_id) REFERENCES usuarios (id)
  ) ENGINE = InnoDB;

ALTER TABLE usuarios ADD estado_registro enum ('pendiente', 'aprobado', 'rechazado') NOT NULL DEFAULT 'aprobado';

ALTER TABLE maquinaria ADD activo boolean NOT NULL DEFAULT 1,
ADD motivo_baja varchar(255);

ALTER TABLE contenedores ADD activo boolean NOT NULL DEFAULT 1;

UPDATE contenedores
SET
  activo = en_servicio;

-- Datos adicionales de demostración SOLO para instalación nueva.
INSERT INTO
  usuarios (nombre, email, cedula, password, rol)
VALUES
  (
    'Chofer Prueba',
    'chofer@sigeru.uy',
    '20000006',
    '$2y$10$qRYWe1Rg4NQa.y4gmqh/teMz9sQbR1LZLmgcfR4UTLoI3ThWp2wQS',
    'chofer'
  );

INSERT INTO
  funcionarios (id, fecha_contratacion, direccion, email_laboral)
SELECT
  id,
  '2026-01-01',
  'Buceo, Montevideo',
  email
FROM
  usuarios
WHERE
  email = 'chofer@sigeru.uy';

INSERT INTO
  choferes (id, lic_conducir, cuadrilla_id)
SELECT
  id,
  'Licencia de ejemplo',
  4
FROM
  usuarios
WHERE
  email = 'chofer@sigeru.uy';

UPDATE camiones
SET
  chofer_id = (
    SELECT
      id
    FROM
      usuarios
    WHERE
      email = 'chofer@sigeru.uy'
  ),
  modelo = 'Recolector de prueba'
WHERE
  matricula = 'ABC 1234';

UPDATE contenedores
SET
  tipo_residuo = 'Orgánico',
  tipo_contenedor = 'Urbano';

UPDATE centros_acopio
SET
  capacidad = 100,
  capacidad_ocupada = 0;

UPDATE operarios
SET
  centro_id = 1
WHERE
  id = 3;

INSERT INTO
  residuos (tipo_residuo)
VALUES
  ('Orgánico'),
  ('Reciclable');

INSERT INTO
  gestionan (centro_id, residuo_id)
SELECT
  c.id,
  r.id
FROM
  centros_acopio c
  CROSS JOIN residuos r;

INSERT INTO
  contenedores (
    ubicacion,
    estado,
    tipo_residuo,
    tipo_contenedor,
    en_servicio
  )
VALUES
  (
    'Depósito municipal de prueba',
    'funcional',
    'Orgánico',
    'Urbano',
    0
  );

-- --------------------------------------------------------
-- Datos de prueba adicionales: operativa de recolección
-- (rutas, asignaciones, recolecciones, mantenimientos,
--  reparaciones, reclamos y tablas de relación del DER)
-- --------------------------------------------------------
-- Una instalación como vertedero, para dejar de ejemplo la distinción
-- tipo_centro=acopio / vertedero que introduce el modelo físico actual.
UPDATE centros_acopio
SET
  tipo_centro = 'vertedero'
WHERE
  nombre = 'Planta de Clasificación Este';

-- Rutas de recolección
INSERT INTO
  rutas (nombre, zona, frecuencia, horario)
VALUES
  (
    'Ruta Centro',
    'Ciudad Vieja - Centro',
    'Diaria',
    '06:00 a 10:00'
  ),
  (
    'Ruta Buceo',
    'Buceo - Malvín',
    'Lunes, miércoles y viernes',
    '07:00 a 11:00'
  );

-- La cuadrilla de prueba (id 4, ex "Cuadrilla Prueba") sigue la Ruta Centro
INSERT INTO
  sigue (cuadrilla_id, ruta_id)
SELECT
  4,
  id
FROM
  rutas
WHERE
  nombre = 'Ruta Centro';

-- El camión de prueba realiza esa misma ruta
INSERT INTO
  realiza (matricula, ruta_id)
SELECT
  'ABC 1234',
  id
FROM
  rutas
WHERE
  nombre = 'Ruta Centro';

-- La Ruta Centro pasa por los dos primeros contenedores de ejemplo
INSERT INTO
  contiene (ruta_id, contenedor_id)
SELECT
  r.id,
  c.id
FROM
  rutas r
  JOIN contenedores c ON c.id IN (1, 2)
WHERE
  r.nombre = 'Ruta Centro';

-- Cada incidencia de ejemplo queda asociada al contenedor correspondiente
INSERT INTO
  sobre (contenedor_id, incidencia_id)
VALUES
  (1, 1),
  (2, 2),
  (3, 3);

-- Calendario: la cuadrilla 4 y el camión ABC 1234 tienen asignada
-- la Ruta Centro para una fecha de ejemplo
INSERT INTO
  asignaciones (ruta_id, cuadrilla_id, matricula, fecha)
SELECT
  id,
  4,
  'ABC 1234',
  '2026-09-10'
FROM
  rutas
WHERE
  nombre = 'Ruta Centro';

-- Recolección registrada por el recolector de prueba (id 4) sobre esa ruta
INSERT INTO
  recolecciones (
    contenedor_id,
    recolector_id,
    ruta_id,
    cuadrilla_id,
    fecha,
    volumen,
    simulado
  )
SELECT
  1,
  4,
  id,
  4,
  '2026-09-10 08:15:00',
  1.50,
  0
FROM
  rutas
WHERE
  nombre = 'Ruta Centro';

-- Mantenimiento preventivo del camión de prueba
INSERT INTO
  mantenimientos (descripcion, tipo_man, fecha_man, prox_man)
VALUES
  (
    'Cambio de aceite y filtros',
    'Preventivo',
    '2026-08-01',
    '2026-11-01'
  );

INSERT INTO
  recibe (matricula, mantenimiento_id)
SELECT
  'ABC 1234',
  id
FROM
  mantenimientos
WHERE
  descripcion = 'Cambio de aceite y filtros';

-- Reparación asociada a la incidencia de contenedor roto (id 3)
INSERT INTO
  reparaciones (tipo_reparacion, fecha_inicio, fecha_fin)
VALUES
  ('Reparación de tapa', '2026-08-15', '2026-08-16');

INSERT INTO
  necesita (incidencia_id, reparacion_id)
SELECT
  3,
  id
FROM
  reparaciones
WHERE
  tipo_reparacion = 'Reparación de tapa';

-- Reclamo de un vecino sobre una de sus incidencias abiertas
INSERT INTO
  reclamos (
    usuario_id,
    incidencia_id,
    descripcion,
    ubicacion,
    prioridad,
    estado
  )
VALUES
  (
    2,
    2,
    'El contenedor sigue desbordado tres días después del reporte.',
    'Av Italia 1333',
    'alta',
    'abierto'
  );

-- Recepción de residuos registrada por el operario de prueba
INSERT INTO
  recepciones (
    centro_id,
    residuo_id,
    operario_id,
    cantidad,
    simulado
  )
VALUES
  (1, 1, 3, 25.50, 0);

UPDATE centros_acopio
SET
  capacidad_ocupada = 25.50
WHERE
  nombre = 'Centro de Acopio Norte';

INSERT INTO
  historial_capacidad (
    centro_id,
    usuario_id,
    capacidad,
    capacidad_ocupada,
    estado
  )
SELECT
  id,
  3,
  100,
  25.50,
  'Operativo'
FROM
  centros_acopio
WHERE
  nombre = 'Centro de Acopio Norte';
-- Ubicaciones oficiales para pruebas del mapa (aplicar una vez).
ALTER TABLE contenedores
  ADD latitud DECIMAL(10,7) NULL,
  ADD longitud DECIMAL(10,7) NULL,
  ADD fuente VARCHAR(255) NULL,
  ADD referencia_externa VARCHAR(50) NULL,
  ADD datos_prueba BOOLEAN NOT NULL DEFAULT 0,
  ADD UNIQUE KEY contenedor_fuente_referencia (fuente, referencia_externa);

-- --------------------------------------------------------
-- Datos de prueba para el mapa, los informes y el panel de control
-- (solo datos: no modifica la estructura de la base)
-- --------------------------------------------------------
-- Contenedores: 50 ubicaciones OFICIALES de la Intendencia de Montevideo
-- (ver Backend/database/demo/README.md). Sus estados (funcional, roto,
-- desbordado) y las incidencias de más abajo son SIMULADOS para pruebas;
-- no describen su condición real. El importador de demo no los duplica
-- porque usa la misma fuente y referencia externa.
INSERT INTO
  contenedores (
    ubicacion,
    estado,
    tipo_residuo,
    en_servicio,
    latitud,
    longitud,
    fuente,
    referencia_externa,
    datos_prueba
  )
VALUES
  ('Prueba IM #134095 · circuito C_DU_RM_CL_103', 'funcional', 'Domiciliarios', 1, -34.8853462, -56.1695427, 'https://datos-abiertos.montevideo.gub.uy/Contenedores_domiciliarios.zip', '134095', 1),
  ('Prueba IM #101350 · circuito E_DU_RM_CL_101', 'desbordado', 'Domiciliarios', 1, -34.881594, -56.1466661, 'https://datos-abiertos.montevideo.gub.uy/Contenedores_domiciliarios.zip', '101350', 1),
  ('Prueba IM #114339 · circuito D_DU_RM_CL_105', 'roto', 'Domiciliarios', 1, -34.8703061, -56.1554992, 'https://datos-abiertos.montevideo.gub.uy/Contenedores_domiciliarios.zip', '114339', 1),
  ('Prueba IM #133918 · circuito C_DU_RM_CL_101', 'funcional', 'Domiciliarios', 1, -34.8853881, -56.1834894, 'https://datos-abiertos.montevideo.gub.uy/Contenedores_domiciliarios.zip', '133918', 1),
  ('Prueba IM #177000 · circuito CH_DU_RM_CL_110', 'desbordado', 'Domiciliarios', 1, -34.9014887, -56.1607573, 'https://datos-abiertos.montevideo.gub.uy/Contenedores_domiciliarios.zip', '177000', 1),
  ('Prueba IM #101332 · circuito E_DU_RM_CL_101', 'roto', 'Domiciliarios', 1, -34.8791883, -56.1467133, 'https://datos-abiertos.montevideo.gub.uy/Contenedores_domiciliarios.zip', '101332', 1),
  ('Prueba IM #134302 · circuito C_DU_RM_CL_105', 'funcional', 'Domiciliarios', 1, -34.8732374, -56.1722971, 'https://datos-abiertos.montevideo.gub.uy/Contenedores_domiciliarios.zip', '134302', 1),
  ('Prueba IM #139110 · circuito B_DU_RM_CL_101', 'desbordado', 'Domiciliarios', 1, -34.8949381, -56.1845799, 'https://datos-abiertos.montevideo.gub.uy/Contenedores_domiciliarios.zip', '139110', 1),
  ('Prueba IM #175857 · circuito CH_DU_RM_CL_108', 'roto', 'Domiciliarios', 1, -34.9028024, -56.1407482, 'https://datos-abiertos.montevideo.gub.uy/Contenedores_domiciliarios.zip', '175857', 1),
  ('Prueba IM #101334 · circuito E_DU_RM_CL_101', 'funcional', 'Domiciliarios', 1, -34.8840013, -56.1388318, 'https://datos-abiertos.montevideo.gub.uy/Contenedores_domiciliarios.zip', '101334', 1),
  ('Prueba IM #114352 · circuito D_DU_RM_CL_105', 'desbordado', 'Domiciliarios', 1, -34.8677237, -56.1564636, 'https://datos-abiertos.montevideo.gub.uy/Contenedores_domiciliarios.zip', '114352', 1),
  ('Prueba IM #133892 · circuito C_DU_RM_CL_101', 'roto', 'Domiciliarios', 1, -34.8856294, -56.1851315, 'https://datos-abiertos.montevideo.gub.uy/Contenedores_domiciliarios.zip', '133892', 1),
  ('Prueba IM #175453 · circuito CH_DU_RM_CL_105', 'funcional', 'Domiciliarios', 1, -34.9062103, -56.1573828, 'https://datos-abiertos.montevideo.gub.uy/Contenedores_domiciliarios.zip', '175453', 1),
  ('Prueba IM #105419 · circuito E_DU_RM_CL_102', 'desbordado', 'Domiciliarios', 1, -34.8773991, -56.1396634, 'https://datos-abiertos.montevideo.gub.uy/Contenedores_domiciliarios.zip', '105419', 1),
  ('Prueba IM #107789 · circuito E_DU_RM_CL_104', 'roto', 'Domiciliarios', 1, -34.8928995, -56.1294373, 'https://datos-abiertos.montevideo.gub.uy/Contenedores_domiciliarios.zip', '107789', 1),
  ('Prueba IM #114335 · circuito D_DU_RM_CL_105', 'funcional', 'Domiciliarios', 1, -34.8676684, -56.1511665, 'https://datos-abiertos.montevideo.gub.uy/Contenedores_domiciliarios.zip', '114335', 1),
  ('Prueba IM #124072 · circuito D_DU_RM_CL_111', 'desbordado', 'Domiciliarios', 1, -34.8610206, -56.1709589, 'https://datos-abiertos.montevideo.gub.uy/Contenedores_domiciliarios.zip', '124072', 1),
  ('Prueba IM #134529 · circuito C_DU_RM_CL_107', 'roto', 'Domiciliarios', 1, -34.8780231, -56.186188, 'https://datos-abiertos.montevideo.gub.uy/Contenedores_domiciliarios.zip', '134529', 1),
  ('Prueba IM #139092 · circuito B_DU_RM_CL_101', 'funcional', 'Domiciliarios', 1, -34.895791, -56.1923583, 'https://datos-abiertos.montevideo.gub.uy/Contenedores_domiciliarios.zip', '139092', 1),
  ('Prueba IM #175451 · circuito CH_DU_RM_CL_102', 'desbordado', 'Domiciliarios', 1, -34.9112724, -56.1538162, 'https://datos-abiertos.montevideo.gub.uy/Contenedores_domiciliarios.zip', '175451', 1),
  ('Prueba IM #177565 · circuito B_DU_RM_CL_06', 'roto', 'Domiciliarios', 1, -34.9052747, -56.1745744, 'https://datos-abiertos.montevideo.gub.uy/Contenedores_domiciliarios.zip', '177565', 1),
  ('Prueba IM #114232 · circuito D_DU_RM_CL_103', 'funcional', 'Domiciliarios', 1, -34.8673265, -56.1369312, 'https://datos-abiertos.montevideo.gub.uy/Contenedores_domiciliarios.zip', '114232', 1),
  ('Prueba IM #138338 · circuito C_DU_RM_CL_111', 'desbordado', 'Domiciliarios', 1, -34.8649486, -56.1856461, 'https://datos-abiertos.montevideo.gub.uy/Contenedores_domiciliarios.zip', '138338', 1),
  ('Prueba IM #175769 · circuito CH_DU_RM_CL_109', 'roto', 'Domiciliarios', 1, -34.9046057, -56.1329794, 'https://datos-abiertos.montevideo.gub.uy/Contenedores_domiciliarios.zip', '175769', 1),
  ('Prueba IM #178138 · circuito B_DU_RM_CL_01', 'funcional', 'Domiciliarios', 1, -34.9042201, -56.1993982, 'https://datos-abiertos.montevideo.gub.uy/Contenedores_domiciliarios.zip', '178138', 1),
  ('Prueba IM #105212 · circuito E_DU_RM_CL_136', 'desbordado', 'Domiciliarios', 1, -34.880763, -56.1187962, 'https://datos-abiertos.montevideo.gub.uy/Contenedores_domiciliarios.zip', '105212', 1),
  ('Prueba IM #115643 · circuito D_DU_RM_CL_110', 'roto', 'Domiciliarios', 1, -34.8504393, -56.1558743, 'https://datos-abiertos.montevideo.gub.uy/Contenedores_domiciliarios.zip', '115643', 1),
  ('Prueba IM #175380 · circuito CH_DU_RM_CL_101', 'funcional', 'Domiciliarios', 1, -34.9271499, -56.1593106, 'https://datos-abiertos.montevideo.gub.uy/Contenedores_domiciliarios.zip', '175380', 1),
  ('Prueba IM #105230 · circuito E_DU_RM_CL_136', 'desbordado', 'Domiciliarios', 1, -34.8722796, -56.1152279, 'https://datos-abiertos.montevideo.gub.uy/Contenedores_domiciliarios.zip', '105230', 1),
  ('Prueba IM #107392 · circuito E_DU_RM_CL_105', 'roto', 'Domiciliarios', 1, -34.8936353, -56.1143946, 'https://datos-abiertos.montevideo.gub.uy/Contenedores_domiciliarios.zip', '107392', 1),
  ('Prueba IM #115636 · circuito D_DU_RM_CL_110', 'funcional', 'Domiciliarios', 1, -34.855641, -56.1531209, 'https://datos-abiertos.montevideo.gub.uy/Contenedores_domiciliarios.zip', '115636', 1),
  ('Prueba IM #124091 · circuito D_DU_RM_CL_111', 'desbordado', 'Domiciliarios', 1, -34.8517104, -56.1706557, 'https://datos-abiertos.montevideo.gub.uy/Contenedores_domiciliarios.zip', '124091', 1),
  ('Prueba IM #134743 · circuito C_DU_RM_CL_109', 'roto', 'Domiciliarios', 1, -34.8753625, -56.2002054, 'https://datos-abiertos.montevideo.gub.uy/Contenedores_domiciliarios.zip', '134743', 1),
  ('Prueba IM #175583 · circuito CH_DU_RM_CL_101', 'funcional', 'Domiciliarios', 1, -34.9229399, -56.1545443, 'https://datos-abiertos.montevideo.gub.uy/Contenedores_domiciliarios.zip', '175583', 1),
  ('Prueba IM #177698 · circuito B_DU_RM_CL_01', 'desbordado', 'Domiciliarios', 1, -34.9037562, -56.2056014, 'https://datos-abiertos.montevideo.gub.uy/Contenedores_domiciliarios.zip', '177698', 1),
  ('Prueba IM #100544 · circuito A_DU_RM_CL_106', 'roto', 'Domiciliarios', 1, -34.8620431, -56.2139121, 'https://datos-abiertos.montevideo.gub.uy/Contenedores_domiciliarios.zip', '100544', 1),
  ('Prueba IM #117943 · circuito G_DU_RM_CL_101', 'funcional', 'Domiciliarios', 1, -34.8446856, -56.1973751, 'https://datos-abiertos.montevideo.gub.uy/Contenedores_domiciliarios.zip', '117943', 1),
  ('Prueba IM #141652 · circuito F_DU_RM_CL_104', 'desbordado', 'Domiciliarios', 1, -34.8480422, -56.1384271, 'https://datos-abiertos.montevideo.gub.uy/Contenedores_domiciliarios.zip', '141652', 1),
  ('Prueba IM #141911 · circuito F_DU_RM_CL_106', 'roto', 'Domiciliarios', 1, -34.856407, -56.1168096, 'https://datos-abiertos.montevideo.gub.uy/Contenedores_domiciliarios.zip', '141911', 1),
  ('Prueba IM #177316 · circuito B_DU_RM_CL_01', 'funcional', 'Domiciliarios', 1, -34.9081833, -56.2137299, 'https://datos-abiertos.montevideo.gub.uy/Contenedores_domiciliarios.zip', '177316', 1),
  ('Prueba IM #105247 · circuito E_DU_RM_CL_106', 'desbordado', 'Domiciliarios', 1, -34.8856968, -56.1065919, 'https://datos-abiertos.montevideo.gub.uy/Contenedores_domiciliarios.zip', '105247', 1),
  ('Prueba IM #124289 · circuito D_DU_RM_CL_113', 'roto', 'Domiciliarios', 1, -34.8425194, -56.1580753, 'https://datos-abiertos.montevideo.gub.uy/Contenedores_domiciliarios.zip', '124289', 1),
  ('Prueba IM #175498 · circuito CH_DU_RM_CL_101', 'funcional', 'Domiciliarios', 1, -34.9283769, -56.1601128, 'https://datos-abiertos.montevideo.gub.uy/Contenedores_domiciliarios.zip', '175498', 1),
  ('Prueba IM #100426 · circuito A_DU_RM_CL_106', 'desbordado', 'Domiciliarios', 1, -34.8682002, -56.2224368, 'https://datos-abiertos.montevideo.gub.uy/Contenedores_domiciliarios.zip', '100426', 1),
  ('Prueba IM #105302 · circuito E_DU_RM_CL_107', 'roto', 'Domiciliarios', 1, -34.8782111, -56.1026998, 'https://datos-abiertos.montevideo.gub.uy/Contenedores_domiciliarios.zip', '105302', 1),
  ('Prueba IM #107430 · circuito E_DU_RM_CL_105', 'funcional', 'Domiciliarios', 1, -34.8957907, -56.1092846, 'https://datos-abiertos.montevideo.gub.uy/Contenedores_domiciliarios.zip', '107430', 1),
  ('Prueba IM #117157 · circuito G_DU_RM_CL_115', 'desbordado', 'Domiciliarios', 1, -34.8369877, -56.1849775, 'https://datos-abiertos.montevideo.gub.uy/Contenedores_domiciliarios.zip', '117157', 1),
  ('Prueba IM #124394 · circuito D_DU_RM_CL_114', 'roto', 'Domiciliarios', 1, -34.8395741, -56.1500713, 'https://datos-abiertos.montevideo.gub.uy/Contenedores_domiciliarios.zip', '124394', 1),
  ('Prueba IM #100705 · circuito A_DU_RM_CL_108', 'funcional', 'Domiciliarios', 1, -34.8500403, -56.214529, 'https://datos-abiertos.montevideo.gub.uy/Contenedores_domiciliarios.zip', '100705', 1),
  ('Prueba IM #141858 · circuito F_DU_RM_CL_106', 'desbordado', 'Domiciliarios', 1, -34.8533833, -56.1205237, 'https://datos-abiertos.montevideo.gub.uy/Contenedores_domiciliarios.zip', '141858', 1);

-- Incidencias simuladas sobre esos contenedores. Las fechas son relativas al
-- mes en curso (nunca futuras) para que el top de desbordados del mes y los
-- informes tengan datos sin importar cuándo se importe el script. Las
-- cerradas las atendió la cuadrilla de prueba (id 4) con el camión ABC 1234
-- y pertenecen al vecino de prueba; las abiertas no tienen vecino asociado.
SET @inicio_mes = CAST(DATE_FORMAT(NOW(), '%Y-%m-01') AS DATE);

INSERT INTO
  incidencias (
    ubicacion,
    latitud,
    longitud,
    estado_contenedor,
    tipo_basura,
    estado_incidencia,
    usuario_id,
    cuadrilla_id,
    matricula_camion,
    comentario_operario,
    descripcion,
    solucion,
    fecha_creacion,
    fecha_cierre
  )
SELECT
  c.ubicacion,
  c.latitud,
  c.longitud,
  t.problema,
  'Normal / Orgánica',
  t.estado,
  IF(t.estado = 'cerrada', 2, NULL),
  IF(t.estado = 'cerrada', 4, NULL),
  IF(t.estado = 'cerrada', 'ABC 1234', NULL),
  IF(t.estado = 'cerrada', 'Asignación de cuadrilla y camión', NULL),
  CONCAT('Dato de prueba: ', t.descripcion),
  t.solucion,
  LEAST(NOW(), TIMESTAMP(@inicio_mes + INTERVAL t.dia DAY, '09:30:00')),
  IF(t.estado = 'cerrada', LEAST(NOW(), TIMESTAMP(@inicio_mes + INTERVAL t.dia_cierre DAY, '16:00:00')), NULL)
FROM
  (
      SELECT 101350 AS ref, 'desborde' AS problema, 'cerrada' AS estado, -6 AS dia, -5 AS dia_cierre, 'Contenedor desbordado, bolsas acumuladas en la vereda.' AS descripcion, 'Vaciado completo y limpieza de la vereda.' AS solucion
      UNION ALL
      SELECT 101350, 'desborde', 'cerrada', 1, 2, 'Contenedor desbordado, residuos fuera del contenedor.', 'Vaciado completo y limpieza de la zona.'
      UNION ALL
      SELECT 101350, 'desborde', 'cerrada', 6, 7, 'Contenedor desbordado nuevamente, olor intenso.', 'Vaciado y lavado del contenedor.'
      UNION ALL
      SELECT 101350, 'desborde', 'cerrada', 12, 13, 'Contenedor lleno hasta el tope, tapa abierta.', 'Vaciado completo del contenedor.'
      UNION ALL
      SELECT 101350, 'desborde', 'abierta', 19, NULL, 'Contenedor desbordado desde hace dos días.', NULL
      UNION ALL
      SELECT 177000, 'desborde', 'cerrada', 4, 5, 'Residuos desparramados alrededor del contenedor.', 'Recolección y barrido de la zona.'
      UNION ALL
      SELECT 177000, 'desborde', 'cerrada', 10, 11, 'Contenedor desbordado, bolsas rotas en la calle.', 'Vaciado completo y limpieza de la calle.'
      UNION ALL
      SELECT 177000, 'desborde', 'abierta', 18, NULL, 'Contenedor desbordado, bolsas en la calzada.', NULL
      UNION ALL
      SELECT 139110, 'desborde', 'cerrada', 8, 9, 'Contenedor desbordado, residuos sobre la vereda.', 'Vaciado completo del contenedor.'
      UNION ALL
      SELECT 139110, 'desborde', 'abierta', 17, NULL, 'Contenedor desbordado, dificulta el paso peatonal.', NULL
      UNION ALL
      SELECT 114352, 'desborde', 'cerrada', 3, 4, 'Contenedor lleno, residuos en el piso.', 'Vaciado y limpieza de la zona.'
      UNION ALL
      SELECT 114352, 'desborde', 'abierta', 20, NULL, 'Contenedor desbordado, residuos esparcidos.', NULL
      UNION ALL
      SELECT 105419, 'desborde', 'abierta', 21, NULL, 'Contenedor desbordado, bolsas apiladas a su lado.', NULL
      UNION ALL
      SELECT 124072, 'desborde', 'cerrada', 14, 15, 'Contenedor desbordado, bolsas en la esquina.', 'Vaciado completo del contenedor.'
      UNION ALL
      SELECT 114339, 'roto', 'abierta', 16, NULL, 'Tapa del contenedor rota, no cierra.', NULL
      UNION ALL
      SELECT 175857, 'roto', 'abierta', 19, NULL, 'Contenedor con la base dañada, pierde líquidos.', NULL
      UNION ALL
      SELECT 134095, 'roto', 'cerrada', 5, 8, 'Tapa del contenedor desprendida.', 'Reemplazo de la tapa del contenedor.'
  ) t
  JOIN contenedores c ON c.referencia_externa = t.ref
  AND c.fuente = 'https://datos-abiertos.montevideo.gub.uy/Contenedores_domiciliarios.zip';

-- Cada incidencia queda asociada a su contenedor (mismas coordenadas)
INSERT INTO
  sobre (contenedor_id, incidencia_id)
SELECT
  c.id,
  i.id
FROM
  incidencias i
  JOIN contenedores c ON c.latitud = i.latitud
  AND c.longitud = i.longitud
  AND c.datos_prueba = 1
WHERE
  i.descripcion LIKE 'Dato de prueba:%';

-- Seguimiento: historial de estados de cada incidencia simulada
INSERT INTO
  historial_incidencias (
    incidencia_id,
    usuario_id,
    estado_anterior,
    estado_nuevo,
    observacion,
    fecha
  )
SELECT
  id,
  COALESCE(usuario_id, 1),
  NULL,
  'abierta',
  descripcion,
  fecha_creacion
FROM
  incidencias
WHERE
  descripcion LIKE 'Dato de prueba:%';

INSERT INTO
  historial_incidencias (
    incidencia_id,
    usuario_id,
    estado_anterior,
    estado_nuevo,
    observacion,
    fecha
  )
SELECT
  id,
  1,
  'abierta',
  'en curso',
  comentario_operario,
  LEAST(fecha_cierre, fecha_creacion + INTERVAL 1 HOUR)
FROM
  incidencias
WHERE
  descripcion LIKE 'Dato de prueba:%'
  AND estado_incidencia = 'cerrada';

INSERT INTO
  historial_incidencias (
    incidencia_id,
    usuario_id,
    estado_anterior,
    estado_nuevo,
    observacion,
    fecha
  )
SELECT
  id,
  4,
  'en curso',
  'cerrada',
  solucion,
  fecha_cierre
FROM
  incidencias
WHERE
  descripcion LIKE 'Dato de prueba:%'
  AND estado_incidencia = 'cerrada';

-- Notificaciones y alertas (mismos textos que genera el sistema):
-- alerta a los administradores por cada incidencia abierta...
INSERT INTO
  notificaciones (usuario_id, tipo, mensaje, incidencia_id, fecha_creacion)
SELECT
  u.id,
  'alerta',
  CONCAT('Nueva incidencia #', i.id, ' (', i.estado_contenedor, ') en ', i.ubicacion, ': requiere atención.'),
  i.id,
  i.fecha_creacion
FROM
  incidencias i
  JOIN usuarios u ON u.rol = 'administrador'
  AND u.activo = 1
WHERE
  i.descripcion LIKE 'Dato de prueba:%'
  AND i.estado_incidencia = 'abierta';

-- ...y aviso de solución al vecino por cada incidencia suya cerrada
INSERT INTO
  notificaciones (usuario_id, tipo, mensaje, incidencia_id, fecha_creacion)
SELECT
  usuario_id,
  'incidencia',
  CONCAT('Tu incidencia #', id, ' en ', ubicacion, ' fue marcada como solucionada.'),
  id,
  fecha_cierre
FROM
  incidencias
WHERE
  descripcion LIKE 'Dato de prueba:%'
  AND estado_incidencia = 'cerrada';
