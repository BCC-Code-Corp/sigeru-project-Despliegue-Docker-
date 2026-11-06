-- Sistema de penalizaciones por reportes falsos (aplicar una vez).
-- Nivel 1 = 24 h · Nivel 2 = 72 h · Nivel 3 o más = permanente (regulable por el administrador).
ALTER TABLE usuarios
  ADD penalizaciones int NOT NULL DEFAULT 0,
  ADD penalizado_desde datetime NULL,
  ADD penalizado_hasta datetime NULL,
  ADD baneo_permanente boolean NOT NULL DEFAULT 0;

ALTER TABLE incidencias
  MODIFY estado_incidencia enum ('abierta', 'en curso', 'cerrada', 'reportada') NOT NULL DEFAULT 'abierta',
  ADD motivo_reporte varchar(500) NULL,
  ADD reportada_por int NULL,
  ADD fecha_reporte datetime NULL,
  ADD CONSTRAINT fk_incidencia_reportada_por FOREIGN KEY (reportada_por) REFERENCES usuarios (id);
