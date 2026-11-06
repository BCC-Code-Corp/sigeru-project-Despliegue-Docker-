-- Ubicaciones oficiales para pruebas del mapa (aplicar una vez).
ALTER TABLE contenedores
  ADD latitud DECIMAL(10,7) NULL,
  ADD longitud DECIMAL(10,7) NULL,
  ADD fuente VARCHAR(255) NULL,
  ADD referencia_externa VARCHAR(50) NULL,
  ADD datos_prueba BOOLEAN NOT NULL DEFAULT 0,
  ADD UNIQUE KEY contenedor_fuente_referencia (fuente, referencia_externa);
