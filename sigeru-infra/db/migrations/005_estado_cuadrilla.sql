-- Estado de actividad de la cuadrilla (aplicar una vez).
-- Lo cambia la propia cuadrilla desde su panel y lo ven el administrador y los operarios.
ALTER TABLE cuadrillas
  ADD estado_actividad enum ('trabajando', 'inactivo', 'yendo_a_descarga') NOT NULL DEFAULT 'inactivo',
  ADD estado_actividad_desde datetime NULL;
