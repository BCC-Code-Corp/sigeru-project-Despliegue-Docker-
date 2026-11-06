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
