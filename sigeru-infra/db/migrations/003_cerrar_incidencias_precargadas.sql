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
