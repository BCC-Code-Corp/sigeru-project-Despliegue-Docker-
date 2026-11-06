-- Ubicación exacta (elegida en el mapa) de los centros de acopio y vertederos (aplicar una vez).
ALTER TABLE centros_acopio
  ADD latitud DECIMAL(10,7) NULL,
  ADD longitud DECIMAL(10,7) NULL;
