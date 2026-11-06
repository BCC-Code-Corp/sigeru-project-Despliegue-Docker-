-- Deja TODAS las incidencias abiertas o en curso como cerradas y deja lista la cuadrilla de prueba.
-- Las resuelve la Cuadrilla Prueba (id 4) con el camión que tenían asignado (por defecto 'ABC 1234'),
-- deja el historial, avisa al vecino, cierra los reclamos y libera los camiones. Después deja la
-- Cuadrilla Prueba disponible y con su camión ABC 1234 Disponible, lista para recibir incidencias nuevas.
-- Las incidencias "reportadas" (falsas) no se tocan: ya están resueltas por el flujo de reporte.
-- Es segura de repetir.

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
  estado_incidencia IN ('abierta', 'en curso');

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

-- Cuadrilla de prueba apta para nuevas asignaciones: disponible y con su camión por defecto libre
UPDATE cuadrillas
SET
  disponibilidad = 1
WHERE
  id = 4;

UPDATE camiones
SET
  cuadrilla_id = 4
WHERE
  matricula = 'ABC 1234'
  AND cuadrilla_id IS NULL;

UPDATE camiones c
SET
  c.estado = 'Disponible'
WHERE
  c.matricula = 'ABC 1234'
  AND c.cuadrilla_id = 4
  AND c.estado <> 'Disponible'
  AND NOT EXISTS (
    SELECT 1
    FROM incidencias x
    WHERE x.matricula_camion = c.matricula
      AND x.estado_incidencia = 'en curso'
  );
