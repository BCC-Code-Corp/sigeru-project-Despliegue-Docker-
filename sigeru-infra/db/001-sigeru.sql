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

-- Sistema de penalizaciones por reportes falsos (equivale a migrations/002_penalizaciones.sql).
ALTER TABLE usuarios
ADD penalizaciones int NOT NULL DEFAULT 0,
ADD penalizado_desde datetime NULL,
ADD penalizado_hasta datetime NULL,
ADD baneo_permanente boolean NOT NULL DEFAULT 0;

ALTER TABLE incidencias MODIFY estado_incidencia enum ('abierta', 'en curso', 'cerrada', 'reportada') NOT NULL DEFAULT 'abierta',
ADD motivo_reporte varchar(500) NULL,
ADD reportada_por int NULL,
ADD fecha_reporte datetime NULL,
ADD CONSTRAINT fk_incidencia_reportada_por FOREIGN KEY (reportada_por) REFERENCES usuarios (id);

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

-- ==========================================================
-- Cierre de las incidencias precargadas (equivale a migrations/003_cerrar_incidencias_precargadas.sql)
-- ==========================================================
-- Cierra las incidencias precargadas (datos de prueba) que quedaron abiertas o en curso.
-- Las resuelve la Cuadrilla Prueba (id 4) con el camión por defecto 'ABC 1234', deja el
-- historial, avisa al vecino y libera el camión. Así ningún vecino de prueba supera el
-- límite de 2 reportes abiertos. Es segura de repetir: si no queda nada abierto, no hace nada.
-- Precargadas = sin descripción (las 3 del esquema base) o con 'Dato de prueba:' (simuladas).
-- (Las reportadas por vecinos reales siempre tienen descripción y no se tocan.)

DROP TEMPORARY TABLE IF EXISTS tmp_cerradas;
CREATE TEMPORARY TABLE tmp_cerradas AS
SELECT
  id,
  estado_incidencia AS estado_anterior,
  usuario_id,
  ubicacion,
  IF(cuadrilla_id IS NULL OR matricula_camion IS NULL, 'ABC 1234', matricula_camion) AS matricula
FROM
  incidencias
WHERE
  estado_incidencia IN ('abierta', 'en curso')
  AND (descripcion IS NULL OR descripcion LIKE 'Dato de prueba:%');

UPDATE incidencias i
JOIN tmp_cerradas t ON t.id = i.id
SET
  i.estado_incidencia = 'cerrada',
  i.cuadrilla_id = IF(i.cuadrilla_id IS NULL OR i.matricula_camion IS NULL, 4, i.cuadrilla_id),
  i.matricula_camion = t.matricula,
  i.comentario_operario = COALESCE(i.comentario_operario, 'Asignación de cuadrilla y camión'),
  i.solucion = COALESCE(i.solucion, CONCAT('Resuelta por la Cuadrilla Prueba con el camión ', t.matricula, '.')),
  i.fecha_cierre = LEAST(NOW(), i.fecha_creacion + INTERVAL 1 DAY);

-- Historial: asignación (solo si estaba abierta) y cierre
INSERT INTO
  historial_incidencias (incidencia_id, usuario_id, estado_anterior, estado_nuevo, observacion, fecha)
SELECT
  i.id,
  (SELECT MIN(id) FROM usuarios WHERE rol = 'administrador'),
  'abierta',
  'en curso',
  i.comentario_operario,
  LEAST(i.fecha_cierre, i.fecha_creacion + INTERVAL 1 HOUR)
FROM
  incidencias i
  JOIN tmp_cerradas t ON t.id = i.id
WHERE
  t.estado_anterior = 'abierta';

INSERT INTO
  historial_incidencias (incidencia_id, usuario_id, estado_anterior, estado_nuevo, observacion, fecha)
SELECT
  i.id,
  4,
  'en curso',
  'cerrada',
  i.solucion,
  i.fecha_cierre
FROM
  incidencias i
  JOIN tmp_cerradas t ON t.id = i.id;

-- Aviso de solución al vecino (mismo texto que genera el sistema)
INSERT INTO
  notificaciones (usuario_id, tipo, mensaje, incidencia_id, fecha_creacion)
SELECT
  t.usuario_id,
  'incidencia',
  CONCAT('Tu incidencia #', t.id, ' en ', t.ubicacion, ' fue marcada como solucionada.'),
  t.id,
  i.fecha_cierre
FROM
  tmp_cerradas t
  JOIN incidencias i ON i.id = t.id
WHERE
  t.usuario_id IS NOT NULL;

-- Los reclamos sobre esas incidencias se cierran, como hace el sistema al resolver
UPDATE reclamos
SET
  estado = 'cerrado'
WHERE
  incidencia_id IN (SELECT id FROM tmp_cerradas);

-- Camiones que atendían alguna de esas incidencias: vuelven a "Disponible" si ya no tienen otra en curso
UPDATE camiones c
SET
  c.estado = 'Disponible'
WHERE
  c.estado = 'En Ruta'
  AND c.matricula IN (SELECT matricula FROM tmp_cerradas)
  AND NOT EXISTS (
    SELECT 1
    FROM incidencias x
    WHERE x.matricula_camion = c.matricula
      AND x.estado_incidencia = 'en curso'
  );

DROP TEMPORARY TABLE tmp_cerradas;

-- Estado de actividad de la cuadrilla (migración 005).
ALTER TABLE cuadrillas
  ADD estado_actividad enum ('trabajando', 'inactivo', 'yendo_a_descarga') NOT NULL DEFAULT 'inactivo',
  ADD estado_actividad_desde datetime NULL;

-- Ubicación exacta de centros de acopio y vertederos (migración 006).
ALTER TABLE centros_acopio
  ADD latitud DECIMAL(10,7) NULL,
  ADD longitud DECIMAL(10,7) NULL;

-- Datos de simulación: más contenedores, rutas por barrio y más funcionarios (aplicar una vez).
-- Cada contenedor en servicio queda en UNA ruta según el barrio donde está. Asignar una ruta a una
-- cuadrilla asigna sus contenedores (y las incidencias abiertas sobre ellos). Todo es dato de prueba.

INSERT INTO rutas (nombre, zona, frecuencia, horario)
SELECT v.nombre, v.zona, v.frecuencia, v.horario FROM (
  SELECT 'Ruta Centro' nombre, 'Ciudad Vieja - Centro - Barrio Sur' zona, 'Diaria' frecuencia, '06:00 a 10:00' horario UNION ALL
  SELECT 'Ruta Buceo' nombre, 'Buceo - Malvín' zona, 'Lunes, miércoles y viernes' frecuencia, '07:00 a 11:00' horario UNION ALL
  SELECT 'Ruta Cordón - Parque Rodó' nombre, 'Cordón - Parque Rodó' zona, 'Diaria' frecuencia, '06:00 a 10:00' horario UNION ALL
  SELECT 'Ruta Pocitos - Punta Carretas' nombre, 'Pocitos - Punta Carretas - Villa Biarritz' zona, 'Lunes a sábado' frecuencia, '06:30 a 10:30' horario UNION ALL
  SELECT 'Ruta Carrasco - Punta Gorda' nombre, 'Carrasco - Punta Gorda' zona, 'Martes, jueves y sábado' frecuencia, '07:00 a 11:00' horario UNION ALL
  SELECT 'Ruta Tres Cruces - La Blanqueada' nombre, 'Tres Cruces - La Blanqueada - Unión' zona, 'Lunes, miércoles y viernes' frecuencia, '06:00 a 10:00' horario UNION ALL
  SELECT 'Ruta Aguada - Reducto - Prado' nombre, 'Aguada - Reducto - Prado' zona, 'Martes, jueves y sábado' frecuencia, '06:00 a 10:00' horario UNION ALL
  SELECT 'Ruta Cerro - La Teja' nombre, 'Cerro - La Teja' zona, 'Lunes, miércoles y viernes' frecuencia, '07:00 a 11:00' horario UNION ALL
  SELECT 'Ruta Colón - Sayago - Peñarol' nombre, 'Colón - Sayago - Peñarol' zona, 'Martes, jueves y sábado' frecuencia, '07:00 a 11:00' horario UNION ALL
  SELECT 'Ruta Manga - Piedras Blancas' nombre, 'Manga - Piedras Blancas - Cerrito' zona, 'Lunes, miércoles y viernes' frecuencia, '06:30 a 10:30' horario
) v
WHERE NOT EXISTS (SELECT 1 FROM rutas r WHERE r.nombre = v.nombre);

UPDATE contenedores SET latitud = -34.8915, longitud = -56.156 WHERE id = 1 AND latitud IS NULL;
UPDATE contenedores SET latitud = -34.9046, longitud = -56.1865 WHERE id = 2 AND latitud IS NULL;
UPDATE contenedores SET latitud = -34.889, longitud = -56.17 WHERE id = 3 AND latitud IS NULL;
UPDATE contenedores SET latitud = -34.915, longitud = -56.162 WHERE id = 4 AND latitud IS NULL;

INSERT IGNORE INTO contenedores (ubicacion, estado, tipo_residuo, en_servicio, latitud, longitud, fuente, referencia_externa, datos_prueba)
VALUES
  ('Simulado · Barrio Sur · punto 001', 'funcional', 'Domiciliarios', 1, -34.9103271, -56.1945328, 'Simulado SiGeRU', 'SIM-001', 1),
  ('Simulado · Ciudad Vieja · punto 002', 'roto', 'Domiciliarios', 1, -34.9019308, -56.2083665, 'Simulado SiGeRU', 'SIM-002', 1),
  ('Simulado · Ciudad Vieja · punto 003', 'desbordado', 'Domiciliarios', 1, -34.9122472, -56.2053125, 'Simulado SiGeRU', 'SIM-003', 1),
  ('Simulado · Ciudad Vieja · punto 004', 'desbordado', 'Domiciliarios', 1, -34.9039612, -56.2085009, 'Simulado SiGeRU', 'SIM-004', 1),
  ('Simulado · Centro · punto 005', 'funcional', 'Domiciliarios', 1, -34.9057126, -56.1879021, 'Simulado SiGeRU', 'SIM-005', 1),
  ('Simulado · Cordón · punto 006', 'desbordado', 'Domiciliarios', 1, -34.9009751, -56.1835127, 'Simulado SiGeRU', 'SIM-006', 1),
  ('Simulado · Centro · punto 007', 'desbordado', 'Domiciliarios', 1, -34.8987807, -56.187423, 'Simulado SiGeRU', 'SIM-007', 1),
  ('Simulado · Centro · punto 008', 'funcional', 'Domiciliarios', 1, -34.9064437, -56.190358, 'Simulado SiGeRU', 'SIM-008', 1),
  ('Simulado · Parque Rodó · punto 009', 'funcional', 'Domiciliarios', 1, -34.9123056, -56.1765252, 'Simulado SiGeRU', 'SIM-009', 1),
  ('Simulado · Ciudad Vieja · punto 010', 'desbordado', 'Domiciliarios', 1, -34.9011606, -56.2022748, 'Simulado SiGeRU', 'SIM-010', 1),
  ('Simulado · Barrio Sur · punto 011', 'desbordado', 'Domiciliarios', 1, -34.9122332, -56.1906237, 'Simulado SiGeRU', 'SIM-011', 1),
  ('Simulado · Barrio Sur · punto 012', 'roto', 'Domiciliarios', 1, -34.9129257, -56.184944, 'Simulado SiGeRU', 'SIM-012', 1),
  ('Simulado · Barrio Sur · punto 013', 'funcional', 'Domiciliarios', 1, -34.9142494, -56.1821274, 'Simulado SiGeRU', 'SIM-013', 1),
  ('Simulado · Barrio Sur · punto 014', 'funcional', 'Domiciliarios', 1, -34.9141935, -56.1859904, 'Simulado SiGeRU', 'SIM-014', 1),
  ('Simulado · Cordón · punto 015', 'funcional', 'Domiciliarios', 1, -34.9085578, -56.1795618, 'Simulado SiGeRU', 'SIM-015', 1),
  ('Simulado · Cordón · punto 016', 'roto', 'Domiciliarios', 1, -34.9078252, -56.1772528, 'Simulado SiGeRU', 'SIM-016', 1),
  ('Simulado · Cordón · punto 017', 'desbordado', 'Domiciliarios', 1, -34.9002136, -56.1797004, 'Simulado SiGeRU', 'SIM-017', 1),
  ('Simulado · Cordón · punto 018', 'desbordado', 'Domiciliarios', 1, -34.9026813, -56.1730397, 'Simulado SiGeRU', 'SIM-018', 1),
  ('Simulado · Cordón · punto 019', 'roto', 'Domiciliarios', 1, -34.9082686, -56.1775586, 'Simulado SiGeRU', 'SIM-019', 1),
  ('Simulado · Cordón · punto 020', 'funcional', 'Domiciliarios', 1, -34.9022319, -56.1750284, 'Simulado SiGeRU', 'SIM-020', 1),
  ('Simulado · Parque Rodó · punto 021', 'roto', 'Domiciliarios', 1, -34.913872, -56.1691539, 'Simulado SiGeRU', 'SIM-021', 1),
  ('Simulado · Parque Rodó · punto 022', 'funcional', 'Domiciliarios', 1, -34.9166022, -56.1670961, 'Simulado SiGeRU', 'SIM-022', 1),
  ('Simulado · Parque Rodó · punto 023', 'desbordado', 'Domiciliarios', 1, -34.9140435, -56.169571, 'Simulado SiGeRU', 'SIM-023', 1),
  ('Simulado · Parque Rodó · punto 024', 'desbordado', 'Domiciliarios', 1, -34.9173201, -56.1733491, 'Simulado SiGeRU', 'SIM-024', 1),
  ('Simulado · Parque Rodó · punto 025', 'funcional', 'Domiciliarios', 1, -34.9150205, -56.1641461, 'Simulado SiGeRU', 'SIM-025', 1),
  ('Simulado · Parque Rodó · punto 026', 'desbordado', 'Domiciliarios', 1, -34.9194074, -56.1696335, 'Simulado SiGeRU', 'SIM-026', 1),
  ('Simulado · Punta Carretas · punto 027', 'funcional', 'Domiciliarios', 1, -34.9264394, -56.1577045, 'Simulado SiGeRU', 'SIM-027', 1),
  ('Simulado · Punta Carretas · punto 028', 'roto', 'Domiciliarios', 1, -34.9221797, -56.1588739, 'Simulado SiGeRU', 'SIM-028', 1),
  ('Simulado · Punta Carretas · punto 029', 'desbordado', 'Domiciliarios', 1, -34.9184023, -56.1606769, 'Simulado SiGeRU', 'SIM-029', 1),
  ('Simulado · Punta Carretas · punto 030', 'desbordado', 'Domiciliarios', 1, -34.9253614, -56.1570442, 'Simulado SiGeRU', 'SIM-030', 1),
  ('Simulado · Punta Carretas · punto 031', 'desbordado', 'Domiciliarios', 1, -34.9293402, -56.1576516, 'Simulado SiGeRU', 'SIM-031', 1),
  ('Simulado · Villa Biarritz · punto 032', 'funcional', 'Domiciliarios', 1, -34.9175229, -56.1529458, 'Simulado SiGeRU', 'SIM-032', 1),
  ('Simulado · Villa Biarritz · punto 033', 'funcional', 'Domiciliarios', 1, -34.9139022, -56.1422581, 'Simulado SiGeRU', 'SIM-033', 1),
  ('Simulado · Villa Biarritz · punto 034', 'desbordado', 'Domiciliarios', 1, -34.9157058, -56.1477243, 'Simulado SiGeRU', 'SIM-034', 1),
  ('Simulado · Villa Biarritz · punto 035', 'funcional', 'Domiciliarios', 1, -34.9114008, -56.1414305, 'Simulado SiGeRU', 'SIM-035', 1),
  ('Simulado · Pocitos · punto 036', 'desbordado', 'Domiciliarios', 1, -34.9049777, -56.1514919, 'Simulado SiGeRU', 'SIM-036', 1),
  ('Simulado · Punta Carretas · punto 037', 'funcional', 'Domiciliarios', 1, -34.9211162, -56.1516003, 'Simulado SiGeRU', 'SIM-037', 1),
  ('Simulado · Villa Biarritz · punto 038', 'funcional', 'Domiciliarios', 1, -34.91264, -56.1414017, 'Simulado SiGeRU', 'SIM-038', 1),
  ('Simulado · Villa Biarritz · punto 039', 'funcional', 'Domiciliarios', 1, -34.9126779, -56.1382652, 'Simulado SiGeRU', 'SIM-039', 1),
  ('Simulado · Villa Biarritz · punto 040', 'funcional', 'Domiciliarios', 1, -34.9127813, -56.1449933, 'Simulado SiGeRU', 'SIM-040', 1),
  ('Simulado · Buceo · punto 041', 'roto', 'Domiciliarios', 1, -34.8923441, -56.1357602, 'Simulado SiGeRU', 'SIM-041', 1),
  ('Simulado · Buceo · punto 042', 'funcional', 'Domiciliarios', 1, -34.8891334, -56.1316767, 'Simulado SiGeRU', 'SIM-042', 1),
  ('Simulado · Buceo · punto 043', 'funcional', 'Domiciliarios', 1, -34.8952279, -56.1377053, 'Simulado SiGeRU', 'SIM-043', 1),
  ('Simulado · Buceo · punto 044', 'roto', 'Domiciliarios', 1, -34.8882726, -56.1328189, 'Simulado SiGeRU', 'SIM-044', 1),
  ('Simulado · Buceo · punto 045', 'desbordado', 'Domiciliarios', 1, -34.8920416, -56.1422295, 'Simulado SiGeRU', 'SIM-045', 1),
  ('Simulado · Buceo · punto 046', 'desbordado', 'Domiciliarios', 1, -34.8957848, -56.1413152, 'Simulado SiGeRU', 'SIM-046', 1),
  ('Simulado · Malvín · punto 047', 'roto', 'Domiciliarios', 1, -34.8966729, -56.1046595, 'Simulado SiGeRU', 'SIM-047', 1),
  ('Simulado · Malvín · punto 048', 'funcional', 'Domiciliarios', 1, -34.892301, -56.1081653, 'Simulado SiGeRU', 'SIM-048', 1),
  ('Simulado · Malvín · punto 049', 'funcional', 'Domiciliarios', 1, -34.8966437, -56.1038912, 'Simulado SiGeRU', 'SIM-049', 1),
  ('Simulado · Malvín · punto 050', 'funcional', 'Domiciliarios', 1, -34.8935181, -56.1132523, 'Simulado SiGeRU', 'SIM-050', 1),
  ('Simulado · Malvín Norte · punto 051', 'desbordado', 'Domiciliarios', 1, -34.874948, -56.1063759, 'Simulado SiGeRU', 'SIM-051', 1),
  ('Simulado · Malvín Norte · punto 052', 'funcional', 'Domiciliarios', 1, -34.8689123, -56.1134571, 'Simulado SiGeRU', 'SIM-052', 1),
  ('Simulado · Malvín Norte · punto 053', 'funcional', 'Domiciliarios', 1, -34.8709597, -56.1090493, 'Simulado SiGeRU', 'SIM-053', 1),
  ('Simulado · Malvín Norte · punto 054', 'funcional', 'Domiciliarios', 1, -34.8745325, -56.1170546, 'Simulado SiGeRU', 'SIM-054', 1),
  ('Simulado · Malvín Norte · punto 055', 'funcional', 'Domiciliarios', 1, -34.8664087, -56.1093085, 'Simulado SiGeRU', 'SIM-055', 1),
  ('Simulado · Malvín Norte · punto 056', 'desbordado', 'Domiciliarios', 1, -34.8767427, -56.1074062, 'Simulado SiGeRU', 'SIM-056', 1),
  ('Simulado · Carrasco · punto 057', 'funcional', 'Domiciliarios', 1, -34.8922097, -56.0629883, 'Simulado SiGeRU', 'SIM-057', 1),
  ('Simulado · Carrasco · punto 058', 'roto', 'Domiciliarios', 1, -34.8888308, -56.061404, 'Simulado SiGeRU', 'SIM-058', 1),
  ('Simulado · Carrasco · punto 059', 'funcional', 'Domiciliarios', 1, -34.8892329, -56.0556064, 'Simulado SiGeRU', 'SIM-059', 1),
  ('Simulado · Carrasco · punto 060', 'funcional', 'Domiciliarios', 1, -34.8878065, -56.0602937, 'Simulado SiGeRU', 'SIM-060', 1),
  ('Simulado · Carrasco · punto 061', 'funcional', 'Domiciliarios', 1, -34.8831465, -56.0586632, 'Simulado SiGeRU', 'SIM-061', 1),
  ('Simulado · Punta Gorda · punto 062', 'desbordado', 'Domiciliarios', 1, -34.8909053, -56.0920085, 'Simulado SiGeRU', 'SIM-062', 1),
  ('Simulado · Punta Gorda · punto 063', 'funcional', 'Domiciliarios', 1, -34.895594, -56.0955584, 'Simulado SiGeRU', 'SIM-063', 1),
  ('Simulado · Punta Gorda · punto 064', 'desbordado', 'Domiciliarios', 1, -34.8953707, -56.0901163, 'Simulado SiGeRU', 'SIM-064', 1),
  ('Simulado · Punta Gorda · punto 065', 'funcional', 'Domiciliarios', 1, -34.8926261, -56.0892718, 'Simulado SiGeRU', 'SIM-065', 1),
  ('Simulado · Punta Gorda · punto 066', 'funcional', 'Domiciliarios', 1, -34.896595, -56.0854498, 'Simulado SiGeRU', 'SIM-066', 1),
  ('Simulado · Carrasco Norte · punto 067', 'funcional', 'Domiciliarios', 1, -34.8615298, -56.0483612, 'Simulado SiGeRU', 'SIM-067', 1),
  ('Simulado · Carrasco Norte · punto 068', 'funcional', 'Domiciliarios', 1, -34.8603168, -56.0455572, 'Simulado SiGeRU', 'SIM-068', 1),
  ('Simulado · Carrasco Norte · punto 069', 'desbordado', 'Domiciliarios', 1, -34.8604683, -56.0476945, 'Simulado SiGeRU', 'SIM-069', 1),
  ('Simulado · Carrasco Norte · punto 070', 'desbordado', 'Domiciliarios', 1, -34.8616085, -56.0497837, 'Simulado SiGeRU', 'SIM-070', 1),
  ('Simulado · Tres Cruces · punto 071', 'funcional', 'Domiciliarios', 1, -34.8914925, -56.1727465, 'Simulado SiGeRU', 'SIM-071', 1),
  ('Simulado · Tres Cruces · punto 072', 'desbordado', 'Domiciliarios', 1, -34.8925858, -56.1659482, 'Simulado SiGeRU', 'SIM-072', 1),
  ('Simulado · Tres Cruces · punto 073', 'funcional', 'Domiciliarios', 1, -34.8959972, -56.1690847, 'Simulado SiGeRU', 'SIM-073', 1),
  ('Simulado · Tres Cruces · punto 074', 'funcional', 'Domiciliarios', 1, -34.8911075, -56.1668544, 'Simulado SiGeRU', 'SIM-074', 1),
  ('Simulado · Tres Cruces · punto 075', 'desbordado', 'Domiciliarios', 1, -34.8969095, -56.16135, 'Simulado SiGeRU', 'SIM-075', 1),
  ('Simulado · La Blanqueada · punto 076', 'desbordado', 'Domiciliarios', 1, -34.8830815, -56.1541656, 'Simulado SiGeRU', 'SIM-076', 1),
  ('Simulado · La Blanqueada · punto 077', 'roto', 'Domiciliarios', 1, -34.8869594, -56.1641575, 'Simulado SiGeRU', 'SIM-077', 1),
  ('Simulado · La Blanqueada · punto 078', 'desbordado', 'Domiciliarios', 1, -34.8877008, -56.1551153, 'Simulado SiGeRU', 'SIM-078', 1),
  ('Simulado · La Blanqueada · punto 079', 'funcional', 'Domiciliarios', 1, -34.8832466, -56.1530944, 'Simulado SiGeRU', 'SIM-079', 1),
  ('Simulado · Unión · punto 080', 'funcional', 'Domiciliarios', 1, -34.8706924, -56.1349195, 'Simulado SiGeRU', 'SIM-080', 1),
  ('Simulado · Unión · punto 081', 'funcional', 'Domiciliarios', 1, -34.8733542, -56.1423976, 'Simulado SiGeRU', 'SIM-081', 1),
  ('Simulado · Unión · punto 082', 'funcional', 'Domiciliarios', 1, -34.8755739, -56.1401273, 'Simulado SiGeRU', 'SIM-082', 1),
  ('Simulado · Unión · punto 083', 'funcional', 'Domiciliarios', 1, -34.8737092, -56.1368062, 'Simulado SiGeRU', 'SIM-083', 1),
  ('Simulado · Unión · punto 084', 'funcional', 'Domiciliarios', 1, -34.8730206, -56.1393653, 'Simulado SiGeRU', 'SIM-084', 1),
  ('Simulado · Aguada · punto 085', 'funcional', 'Domiciliarios', 1, -34.8919264, -56.1972813, 'Simulado SiGeRU', 'SIM-085', 1),
  ('Simulado · Aguada · punto 086', 'desbordado', 'Domiciliarios', 1, -34.8913774, -56.1967199, 'Simulado SiGeRU', 'SIM-086', 1),
  ('Simulado · Aguada · punto 087', 'funcional', 'Domiciliarios', 1, -34.8996554, -56.20112, 'Simulado SiGeRU', 'SIM-087', 1),
  ('Simulado · Aguada · punto 088', 'roto', 'Domiciliarios', 1, -34.8944019, -56.1931512, 'Simulado SiGeRU', 'SIM-088', 1),
  ('Simulado · Aguada · punto 089', 'roto', 'Domiciliarios', 1, -34.8898359, -56.1960852, 'Simulado SiGeRU', 'SIM-089', 1),
  ('Simulado · Reducto · punto 090', 'funcional', 'Domiciliarios', 1, -34.8818005, -56.1942314, 'Simulado SiGeRU', 'SIM-090', 1),
  ('Simulado · Reducto · punto 091', 'funcional', 'Domiciliarios', 1, -34.8814723, -56.1989593, 'Simulado SiGeRU', 'SIM-091', 1),
  ('Simulado · Reducto · punto 092', 'funcional', 'Domiciliarios', 1, -34.8849478, -56.1860854, 'Simulado SiGeRU', 'SIM-092', 1),
  ('Simulado · Reducto · punto 093', 'funcional', 'Domiciliarios', 1, -34.8742574, -56.1898666, 'Simulado SiGeRU', 'SIM-093', 1),
  ('Simulado · Prado · punto 094', 'funcional', 'Domiciliarios', 1, -34.8628916, -56.2049584, 'Simulado SiGeRU', 'SIM-094', 1),
  ('Simulado · Prado · punto 095', 'roto', 'Domiciliarios', 1, -34.8629657, -56.1982251, 'Simulado SiGeRU', 'SIM-095', 1),
  ('Simulado · Prado · punto 096', 'funcional', 'Domiciliarios', 1, -34.8587208, -56.20472, 'Simulado SiGeRU', 'SIM-096', 1),
  ('Simulado · Prado · punto 097', 'funcional', 'Domiciliarios', 1, -34.8616473, -56.200778, 'Simulado SiGeRU', 'SIM-097', 1),
  ('Simulado · Prado · punto 098', 'funcional', 'Domiciliarios', 1, -34.8611412, -56.2003447, 'Simulado SiGeRU', 'SIM-098', 1),
  ('Simulado · Cerro · punto 099', 'funcional', 'Domiciliarios', 1, -34.8842706, -56.2607245, 'Simulado SiGeRU', 'SIM-099', 1),
  ('Simulado · Cerro · punto 100', 'funcional', 'Domiciliarios', 1, -34.8758644, -56.2591017, 'Simulado SiGeRU', 'SIM-100', 1),
  ('Simulado · Cerro · punto 101', 'funcional', 'Domiciliarios', 1, -34.8826834, -56.2581236, 'Simulado SiGeRU', 'SIM-101', 1),
  ('Simulado · Cerro · punto 102', 'funcional', 'Domiciliarios', 1, -34.8828848, -56.2655975, 'Simulado SiGeRU', 'SIM-102', 1),
  ('Simulado · La Teja · punto 103', 'desbordado', 'Domiciliarios', 1, -34.8549945, -56.2389273, 'Simulado SiGeRU', 'SIM-103', 1),
  ('Simulado · La Teja · punto 104', 'funcional', 'Domiciliarios', 1, -34.8613011, -56.2434949, 'Simulado SiGeRU', 'SIM-104', 1),
  ('Simulado · La Teja · punto 105', 'funcional', 'Domiciliarios', 1, -34.8594748, -56.2426635, 'Simulado SiGeRU', 'SIM-105', 1),
  ('Simulado · La Teja · punto 106', 'funcional', 'Domiciliarios', 1, -34.860613, -56.2357232, 'Simulado SiGeRU', 'SIM-106', 1),
  ('Simulado · La Teja · punto 107', 'roto', 'Domiciliarios', 1, -34.8583108, -56.2405355, 'Simulado SiGeRU', 'SIM-107', 1),
  ('Simulado · La Teja · punto 108', 'funcional', 'Domiciliarios', 1, -34.8582977, -56.238727, 'Simulado SiGeRU', 'SIM-108', 1),
  ('Simulado · Sayago · punto 109', 'desbordado', 'Domiciliarios', 1, -34.8337586, -56.2181398, 'Simulado SiGeRU', 'SIM-109', 1),
  ('Simulado · Sayago · punto 110', 'funcional', 'Domiciliarios', 1, -34.8349204, -56.2183201, 'Simulado SiGeRU', 'SIM-110', 1),
  ('Simulado · Sayago · punto 111', 'funcional', 'Domiciliarios', 1, -34.8366571, -56.2170397, 'Simulado SiGeRU', 'SIM-111', 1),
  ('Simulado · Sayago · punto 112', 'funcional', 'Domiciliarios', 1, -34.8302593, -56.2160668, 'Simulado SiGeRU', 'SIM-112', 1),
  ('Simulado · Sayago · punto 113', 'funcional', 'Domiciliarios', 1, -34.8287554, -56.2186484, 'Simulado SiGeRU', 'SIM-113', 1),
  ('Simulado · Sayago · punto 114', 'funcional', 'Domiciliarios', 1, -34.8358019, -56.2184611, 'Simulado SiGeRU', 'SIM-114', 1),
  ('Simulado · Colón · punto 115', 'funcional', 'Domiciliarios', 1, -34.8086006, -56.228066, 'Simulado SiGeRU', 'SIM-115', 1),
  ('Simulado · Colón · punto 116', 'desbordado', 'Domiciliarios', 1, -34.8125048, -56.2220153, 'Simulado SiGeRU', 'SIM-116', 1),
  ('Simulado · Colón · punto 117', 'roto', 'Domiciliarios', 1, -34.8134585, -56.2263002, 'Simulado SiGeRU', 'SIM-117', 1),
  ('Simulado · Colón · punto 118', 'funcional', 'Domiciliarios', 1, -34.8107156, -56.2229373, 'Simulado SiGeRU', 'SIM-118', 1),
  ('Simulado · Colón · punto 119', 'funcional', 'Domiciliarios', 1, -34.806148, -56.218379, 'Simulado SiGeRU', 'SIM-119', 1),
  ('Simulado · Colón · punto 120', 'funcional', 'Domiciliarios', 1, -34.807631, -56.2316432, 'Simulado SiGeRU', 'SIM-120', 1),
  ('Simulado · Peñarol · punto 121', 'funcional', 'Domiciliarios', 1, -34.8208613, -56.2012224, 'Simulado SiGeRU', 'SIM-121', 1),
  ('Simulado · Peñarol · punto 122', 'funcional', 'Domiciliarios', 1, -34.8224037, -56.2008629, 'Simulado SiGeRU', 'SIM-122', 1),
  ('Simulado · Peñarol · punto 123', 'funcional', 'Domiciliarios', 1, -34.8193841, -56.2000055, 'Simulado SiGeRU', 'SIM-123', 1),
  ('Simulado · Peñarol · punto 124', 'funcional', 'Domiciliarios', 1, -34.8171037, -56.2047457, 'Simulado SiGeRU', 'SIM-124', 1),
  ('Simulado · Cerrito · punto 125', 'desbordado', 'Domiciliarios', 1, -34.856926, -56.1689484, 'Simulado SiGeRU', 'SIM-125', 1),
  ('Simulado · Cerrito · punto 126', 'funcional', 'Domiciliarios', 1, -34.8562446, -56.1710516, 'Simulado SiGeRU', 'SIM-126', 1),
  ('Simulado · Cerrito · punto 127', 'funcional', 'Domiciliarios', 1, -34.8585293, -56.1703885, 'Simulado SiGeRU', 'SIM-127', 1),
  ('Simulado · Cerrito · punto 128', 'funcional', 'Domiciliarios', 1, -34.860315, -56.1734032, 'Simulado SiGeRU', 'SIM-128', 1),
  ('Simulado · Cerrito · punto 129', 'funcional', 'Domiciliarios', 1, -34.861939, -56.1642288, 'Simulado SiGeRU', 'SIM-129', 1),
  ('Simulado · Cerrito · punto 130', 'desbordado', 'Domiciliarios', 1, -34.8586038, -56.1673054, 'Simulado SiGeRU', 'SIM-130', 1),
  ('Simulado · Piedras Blancas · punto 131', 'funcional', 'Domiciliarios', 1, -34.8353591, -56.1320281, 'Simulado SiGeRU', 'SIM-131', 1),
  ('Simulado · Piedras Blancas · punto 132', 'roto', 'Domiciliarios', 1, -34.8255394, -56.1408008, 'Simulado SiGeRU', 'SIM-132', 1),
  ('Simulado · Piedras Blancas · punto 133', 'funcional', 'Domiciliarios', 1, -34.8345364, -56.1472013, 'Simulado SiGeRU', 'SIM-133', 1),
  ('Simulado · Piedras Blancas · punto 134', 'desbordado', 'Domiciliarios', 1, -34.8273747, -56.1475763, 'Simulado SiGeRU', 'SIM-134', 1),
  ('Simulado · Piedras Blancas · punto 135', 'funcional', 'Domiciliarios', 1, -34.8281611, -56.135975, 'Simulado SiGeRU', 'SIM-135', 1),
  ('Simulado · Manga · punto 136', 'funcional', 'Domiciliarios', 1, -34.8118575, -56.130553, 'Simulado SiGeRU', 'SIM-136', 1),
  ('Simulado · Manga · punto 137', 'funcional', 'Domiciliarios', 1, -34.8165906, -56.1307394, 'Simulado SiGeRU', 'SIM-137', 1),
  ('Simulado · Manga · punto 138', 'funcional', 'Domiciliarios', 1, -34.8093667, -56.1311542, 'Simulado SiGeRU', 'SIM-138', 1),
  ('Simulado · Manga · punto 139', 'roto', 'Domiciliarios', 1, -34.8096095, -56.12785, 'Simulado SiGeRU', 'SIM-139', 1),
  ('Simulado · Manga · punto 140', 'funcional', 'Domiciliarios', 1, -34.8099824, -56.1281988, 'Simulado SiGeRU', 'SIM-140', 1);

-- Contenedores de la muestra IM y los de simulación: cada uno en la ruta de su barrio
INSERT IGNORE INTO contiene (ruta_id, contenedor_id)
SELECT r.id, c.id FROM (
  SELECT 'Ruta Tres Cruces - La Blanqueada' ruta, '134095' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Tres Cruces - La Blanqueada' ruta, '101350' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Tres Cruces - La Blanqueada' ruta, '114339' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Aguada - Reducto - Prado' ruta, '133918' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Tres Cruces - La Blanqueada' ruta, '177000' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Tres Cruces - La Blanqueada' ruta, '101332' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Manga - Piedras Blancas' ruta, '134302' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Cordón - Parque Rodó' ruta, '139110' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Pocitos - Punta Carretas' ruta, '175857' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Buceo' ruta, '101334' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Manga - Piedras Blancas' ruta, '114352' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Aguada - Reducto - Prado' ruta, '133892' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Pocitos - Punta Carretas' ruta, '175453' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Tres Cruces - La Blanqueada' ruta, '105419' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Buceo' ruta, '107789' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Tres Cruces - La Blanqueada' ruta, '114335' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Manga - Piedras Blancas' ruta, '124072' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Aguada - Reducto - Prado' ruta, '134529' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Aguada - Reducto - Prado' ruta, '139092' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Pocitos - Punta Carretas' ruta, '175451' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Cordón - Parque Rodó' ruta, '177565' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Tres Cruces - La Blanqueada' ruta, '114232' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Aguada - Reducto - Prado' ruta, '138338' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Buceo' ruta, '175769' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Centro' ruta, '178138' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Buceo' ruta, '105212' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Manga - Piedras Blancas' ruta, '115643' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Pocitos - Punta Carretas' ruta, '175380' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Buceo' ruta, '105230' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Buceo' ruta, '107392' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Manga - Piedras Blancas' ruta, '115636' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Manga - Piedras Blancas' ruta, '124091' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Aguada - Reducto - Prado' ruta, '134743' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Pocitos - Punta Carretas' ruta, '175583' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Centro' ruta, '177698' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Aguada - Reducto - Prado' ruta, '100544' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Colón - Sayago - Peñarol' ruta, '117943' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Manga - Piedras Blancas' ruta, '141652' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Buceo' ruta, '141911' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Centro' ruta, '177316' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Buceo' ruta, '105247' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Manga - Piedras Blancas' ruta, '124289' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Pocitos - Punta Carretas' ruta, '175498' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Cerro - La Teja' ruta, '100426' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Buceo' ruta, '105302' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Buceo' ruta, '107430' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Colón - Sayago - Peñarol' ruta, '117157' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Manga - Piedras Blancas' ruta, '124394' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Colón - Sayago - Peñarol' ruta, '100705' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Buceo' ruta, '141858' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Centro' ruta, 'SIM-001' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Centro' ruta, 'SIM-002' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Centro' ruta, 'SIM-003' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Centro' ruta, 'SIM-004' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Centro' ruta, 'SIM-005' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Cordón - Parque Rodó' ruta, 'SIM-006' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Centro' ruta, 'SIM-007' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Centro' ruta, 'SIM-008' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Cordón - Parque Rodó' ruta, 'SIM-009' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Centro' ruta, 'SIM-010' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Centro' ruta, 'SIM-011' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Centro' ruta, 'SIM-012' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Centro' ruta, 'SIM-013' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Centro' ruta, 'SIM-014' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Cordón - Parque Rodó' ruta, 'SIM-015' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Cordón - Parque Rodó' ruta, 'SIM-016' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Cordón - Parque Rodó' ruta, 'SIM-017' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Cordón - Parque Rodó' ruta, 'SIM-018' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Cordón - Parque Rodó' ruta, 'SIM-019' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Cordón - Parque Rodó' ruta, 'SIM-020' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Cordón - Parque Rodó' ruta, 'SIM-021' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Cordón - Parque Rodó' ruta, 'SIM-022' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Cordón - Parque Rodó' ruta, 'SIM-023' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Cordón - Parque Rodó' ruta, 'SIM-024' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Cordón - Parque Rodó' ruta, 'SIM-025' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Cordón - Parque Rodó' ruta, 'SIM-026' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Pocitos - Punta Carretas' ruta, 'SIM-027' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Pocitos - Punta Carretas' ruta, 'SIM-028' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Pocitos - Punta Carretas' ruta, 'SIM-029' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Pocitos - Punta Carretas' ruta, 'SIM-030' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Pocitos - Punta Carretas' ruta, 'SIM-031' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Pocitos - Punta Carretas' ruta, 'SIM-032' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Pocitos - Punta Carretas' ruta, 'SIM-033' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Pocitos - Punta Carretas' ruta, 'SIM-034' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Pocitos - Punta Carretas' ruta, 'SIM-035' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Pocitos - Punta Carretas' ruta, 'SIM-036' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Pocitos - Punta Carretas' ruta, 'SIM-037' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Pocitos - Punta Carretas' ruta, 'SIM-038' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Pocitos - Punta Carretas' ruta, 'SIM-039' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Pocitos - Punta Carretas' ruta, 'SIM-040' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Buceo' ruta, 'SIM-041' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Buceo' ruta, 'SIM-042' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Buceo' ruta, 'SIM-043' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Buceo' ruta, 'SIM-044' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Buceo' ruta, 'SIM-045' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Buceo' ruta, 'SIM-046' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Buceo' ruta, 'SIM-047' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Buceo' ruta, 'SIM-048' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Buceo' ruta, 'SIM-049' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Buceo' ruta, 'SIM-050' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Buceo' ruta, 'SIM-051' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Buceo' ruta, 'SIM-052' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Buceo' ruta, 'SIM-053' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Buceo' ruta, 'SIM-054' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Buceo' ruta, 'SIM-055' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Buceo' ruta, 'SIM-056' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Carrasco - Punta Gorda' ruta, 'SIM-057' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Carrasco - Punta Gorda' ruta, 'SIM-058' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Carrasco - Punta Gorda' ruta, 'SIM-059' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Carrasco - Punta Gorda' ruta, 'SIM-060' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Carrasco - Punta Gorda' ruta, 'SIM-061' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Carrasco - Punta Gorda' ruta, 'SIM-062' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Carrasco - Punta Gorda' ruta, 'SIM-063' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Carrasco - Punta Gorda' ruta, 'SIM-064' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Carrasco - Punta Gorda' ruta, 'SIM-065' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Carrasco - Punta Gorda' ruta, 'SIM-066' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Carrasco - Punta Gorda' ruta, 'SIM-067' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Carrasco - Punta Gorda' ruta, 'SIM-068' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Carrasco - Punta Gorda' ruta, 'SIM-069' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Carrasco - Punta Gorda' ruta, 'SIM-070' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Tres Cruces - La Blanqueada' ruta, 'SIM-071' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Tres Cruces - La Blanqueada' ruta, 'SIM-072' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Tres Cruces - La Blanqueada' ruta, 'SIM-073' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Tres Cruces - La Blanqueada' ruta, 'SIM-074' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Tres Cruces - La Blanqueada' ruta, 'SIM-075' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Tres Cruces - La Blanqueada' ruta, 'SIM-076' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Tres Cruces - La Blanqueada' ruta, 'SIM-077' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Tres Cruces - La Blanqueada' ruta, 'SIM-078' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Tres Cruces - La Blanqueada' ruta, 'SIM-079' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Tres Cruces - La Blanqueada' ruta, 'SIM-080' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Tres Cruces - La Blanqueada' ruta, 'SIM-081' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Tres Cruces - La Blanqueada' ruta, 'SIM-082' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Tres Cruces - La Blanqueada' ruta, 'SIM-083' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Tres Cruces - La Blanqueada' ruta, 'SIM-084' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Aguada - Reducto - Prado' ruta, 'SIM-085' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Aguada - Reducto - Prado' ruta, 'SIM-086' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Aguada - Reducto - Prado' ruta, 'SIM-087' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Aguada - Reducto - Prado' ruta, 'SIM-088' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Aguada - Reducto - Prado' ruta, 'SIM-089' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Aguada - Reducto - Prado' ruta, 'SIM-090' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Aguada - Reducto - Prado' ruta, 'SIM-091' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Aguada - Reducto - Prado' ruta, 'SIM-092' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Aguada - Reducto - Prado' ruta, 'SIM-093' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Aguada - Reducto - Prado' ruta, 'SIM-094' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Aguada - Reducto - Prado' ruta, 'SIM-095' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Aguada - Reducto - Prado' ruta, 'SIM-096' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Aguada - Reducto - Prado' ruta, 'SIM-097' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Aguada - Reducto - Prado' ruta, 'SIM-098' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Cerro - La Teja' ruta, 'SIM-099' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Cerro - La Teja' ruta, 'SIM-100' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Cerro - La Teja' ruta, 'SIM-101' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Cerro - La Teja' ruta, 'SIM-102' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Cerro - La Teja' ruta, 'SIM-103' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Cerro - La Teja' ruta, 'SIM-104' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Cerro - La Teja' ruta, 'SIM-105' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Cerro - La Teja' ruta, 'SIM-106' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Cerro - La Teja' ruta, 'SIM-107' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Cerro - La Teja' ruta, 'SIM-108' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Colón - Sayago - Peñarol' ruta, 'SIM-109' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Colón - Sayago - Peñarol' ruta, 'SIM-110' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Colón - Sayago - Peñarol' ruta, 'SIM-111' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Colón - Sayago - Peñarol' ruta, 'SIM-112' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Colón - Sayago - Peñarol' ruta, 'SIM-113' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Colón - Sayago - Peñarol' ruta, 'SIM-114' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Colón - Sayago - Peñarol' ruta, 'SIM-115' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Colón - Sayago - Peñarol' ruta, 'SIM-116' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Colón - Sayago - Peñarol' ruta, 'SIM-117' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Colón - Sayago - Peñarol' ruta, 'SIM-118' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Colón - Sayago - Peñarol' ruta, 'SIM-119' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Colón - Sayago - Peñarol' ruta, 'SIM-120' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Colón - Sayago - Peñarol' ruta, 'SIM-121' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Colón - Sayago - Peñarol' ruta, 'SIM-122' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Colón - Sayago - Peñarol' ruta, 'SIM-123' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Colón - Sayago - Peñarol' ruta, 'SIM-124' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Manga - Piedras Blancas' ruta, 'SIM-125' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Manga - Piedras Blancas' ruta, 'SIM-126' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Manga - Piedras Blancas' ruta, 'SIM-127' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Manga - Piedras Blancas' ruta, 'SIM-128' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Manga - Piedras Blancas' ruta, 'SIM-129' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Manga - Piedras Blancas' ruta, 'SIM-130' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Manga - Piedras Blancas' ruta, 'SIM-131' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Manga - Piedras Blancas' ruta, 'SIM-132' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Manga - Piedras Blancas' ruta, 'SIM-133' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Manga - Piedras Blancas' ruta, 'SIM-134' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Manga - Piedras Blancas' ruta, 'SIM-135' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Manga - Piedras Blancas' ruta, 'SIM-136' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Manga - Piedras Blancas' ruta, 'SIM-137' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Manga - Piedras Blancas' ruta, 'SIM-138' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Manga - Piedras Blancas' ruta, 'SIM-139' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Manga - Piedras Blancas' ruta, 'SIM-140' ref, NULL cid
  UNION ALL
  SELECT 'Ruta Tres Cruces - La Blanqueada' ruta, NULL ref, 1 cid
  UNION ALL
  SELECT 'Ruta Centro' ruta, NULL ref, 2 cid
  UNION ALL
  SELECT 'Ruta Tres Cruces - La Blanqueada' ruta, NULL ref, 3 cid
  UNION ALL
  SELECT 'Ruta Cordón - Parque Rodó' ruta, NULL ref, 4 cid
) m
JOIN rutas r ON r.nombre = m.ruta
JOIN contenedores c ON (c.id = m.cid OR (m.ref IS NOT NULL AND c.referencia_externa = m.ref));

DELETE FROM contiene WHERE contenedor_id = 1 AND ruta_id = (SELECT id FROM rutas WHERE nombre = 'Ruta Centro') AND EXISTS (SELECT 1 FROM (SELECT 1 FROM contiene c2 WHERE c2.contenedor_id = 1 AND c2.ruta_id <> (SELECT id FROM rutas WHERE nombre = 'Ruta Centro')) x);

-- Funcionarios simulados sin cuadrilla (disponibles para asignar). Contraseña de prueba común: Sigeru2026!
INSERT IGNORE INTO usuarios (nombre, email, cedula, password, rol) VALUES
  ('Martín Rodríguez', 'chofer01@sigeru.uy', '50324127', '$2y$10$9tuF7fs5hrGSEqAB0rHhv.Ezxd.4cRZgMFTPfR2YjVV1a98whpqGy', 'chofer'),
  ('Gonzalo Pereira', 'chofer02@sigeru.uy', '34504418', '$2y$10$9tuF7fs5hrGSEqAB0rHhv.Ezxd.4cRZgMFTPfR2YjVV1a98whpqGy', 'chofer'),
  ('Sebastián Fernández', 'chofer03@sigeru.uy', '33067348', '$2y$10$9tuF7fs5hrGSEqAB0rHhv.Ezxd.4cRZgMFTPfR2YjVV1a98whpqGy', 'chofer'),
  ('Diego Silva', 'chofer04@sigeru.uy', '45988625', '$2y$10$9tuF7fs5hrGSEqAB0rHhv.Ezxd.4cRZgMFTPfR2YjVV1a98whpqGy', 'chofer'),
  ('Matías González', 'chofer05@sigeru.uy', '41013036', '$2y$10$9tuF7fs5hrGSEqAB0rHhv.Ezxd.4cRZgMFTPfR2YjVV1a98whpqGy', 'chofer'),
  ('Nicolás Martínez', 'chofer06@sigeru.uy', '55876959', '$2y$10$9tuF7fs5hrGSEqAB0rHhv.Ezxd.4cRZgMFTPfR2YjVV1a98whpqGy', 'chofer'),
  ('Federico López', 'chofer07@sigeru.uy', '42645622', '$2y$10$9tuF7fs5hrGSEqAB0rHhv.Ezxd.4cRZgMFTPfR2YjVV1a98whpqGy', 'chofer'),
  ('Andrés Acosta', 'chofer08@sigeru.uy', '34930362', '$2y$10$9tuF7fs5hrGSEqAB0rHhv.Ezxd.4cRZgMFTPfR2YjVV1a98whpqGy', 'chofer'),
  ('Rodrigo Suárez', 'chofer09@sigeru.uy', '44587757', '$2y$10$9tuF7fs5hrGSEqAB0rHhv.Ezxd.4cRZgMFTPfR2YjVV1a98whpqGy', 'chofer'),
  ('Leandro Techera', 'chofer10@sigeru.uy', '49896989', '$2y$10$9tuF7fs5hrGSEqAB0rHhv.Ezxd.4cRZgMFTPfR2YjVV1a98whpqGy', 'chofer'),
  ('Lucía Ferreira', 'recolector01@sigeru.uy', '50919063', '$2y$10$9tuF7fs5hrGSEqAB0rHhv.Ezxd.4cRZgMFTPfR2YjVV1a98whpqGy', 'recolector'),
  ('Valentina Cabrera', 'recolector02@sigeru.uy', '35072531', '$2y$10$9tuF7fs5hrGSEqAB0rHhv.Ezxd.4cRZgMFTPfR2YjVV1a98whpqGy', 'recolector'),
  ('Camila Rivero', 'recolector03@sigeru.uy', '53303255', '$2y$10$9tuF7fs5hrGSEqAB0rHhv.Ezxd.4cRZgMFTPfR2YjVV1a98whpqGy', 'recolector'),
  ('Agustina Barrios', 'recolector04@sigeru.uy', '51766182', '$2y$10$9tuF7fs5hrGSEqAB0rHhv.Ezxd.4cRZgMFTPfR2YjVV1a98whpqGy', 'recolector'),
  ('Martina Sosa', 'recolector05@sigeru.uy', '40361050', '$2y$10$9tuF7fs5hrGSEqAB0rHhv.Ezxd.4cRZgMFTPfR2YjVV1a98whpqGy', 'recolector'),
  ('Florencia Núñez', 'recolector06@sigeru.uy', '45044011', '$2y$10$9tuF7fs5hrGSEqAB0rHhv.Ezxd.4cRZgMFTPfR2YjVV1a98whpqGy', 'recolector'),
  ('Joaquín Correa', 'recolector07@sigeru.uy', '49123255', '$2y$10$9tuF7fs5hrGSEqAB0rHhv.Ezxd.4cRZgMFTPfR2YjVV1a98whpqGy', 'recolector'),
  ('Bruno Delgado', 'recolector08@sigeru.uy', '54549892', '$2y$10$9tuF7fs5hrGSEqAB0rHhv.Ezxd.4cRZgMFTPfR2YjVV1a98whpqGy', 'recolector'),
  ('Santiago Maidana', 'recolector09@sigeru.uy', '44475334', '$2y$10$9tuF7fs5hrGSEqAB0rHhv.Ezxd.4cRZgMFTPfR2YjVV1a98whpqGy', 'recolector'),
  ('Emiliano Píriz', 'recolector10@sigeru.uy', '33462374', '$2y$10$9tuF7fs5hrGSEqAB0rHhv.Ezxd.4cRZgMFTPfR2YjVV1a98whpqGy', 'recolector');

INSERT IGNORE INTO funcionarios (id, fecha_contratacion, direccion, email_laboral)
SELECT u.id, DATE_SUB('2026-10-01', INTERVAL (u.id * 37 % 900) DAY), CONCAT(ELT(u.id % 6 + 1, 'Av. Italia', 'Bvar. Artigas', 'Camino Maldonado', 'Garzón', 'Av. Millán', 'Av. Agraciada'), ' ', 100 + u.id * 13 % 3900, ', ', ELT(u.id % 6 + 1, 'Tres Cruces', 'Cordón', 'Unión', 'Colón', 'Prado', 'Aguada')), u.email
FROM usuarios u WHERE u.email IN ('chofer01@sigeru.uy','chofer02@sigeru.uy','chofer03@sigeru.uy','chofer04@sigeru.uy','chofer05@sigeru.uy','chofer06@sigeru.uy','chofer07@sigeru.uy','chofer08@sigeru.uy','chofer09@sigeru.uy','chofer10@sigeru.uy','recolector01@sigeru.uy','recolector02@sigeru.uy','recolector03@sigeru.uy','recolector04@sigeru.uy','recolector05@sigeru.uy','recolector06@sigeru.uy','recolector07@sigeru.uy','recolector08@sigeru.uy','recolector09@sigeru.uy','recolector10@sigeru.uy');

INSERT IGNORE INTO choferes (id, lic_conducir, cuadrilla_id)
SELECT u.id, CONCAT('Categoría ', ELT(u.id % 3 + 1, 'D', 'D', 'E'), ' · N.º ', 400000 + u.id * 731 % 99999), NULL
FROM usuarios u WHERE u.rol = 'chofer' AND u.email LIKE 'chofer__@sigeru.uy';

INSERT IGNORE INTO recolectores (id, turno, cuadrilla_id)
SELECT u.id, ELT(u.id % 3 + 1, 'Matutino', 'Vespertino', 'Nocturno'), NULL
FROM usuarios u WHERE u.rol = 'recolector' AND u.email LIKE 'recolector__@sigeru.uy';
