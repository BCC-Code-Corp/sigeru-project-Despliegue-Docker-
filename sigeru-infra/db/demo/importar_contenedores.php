<?php
/** Importa la muestra oficial con estados simulados solo en una base de prueba. */
if (PHP_SAPI !== 'cli') {
    http_response_code(404);
    exit;
}
if (($argv[1] ?? '') !== '--base-de-prueba') {
    exit("Uso: php Backend/database/demo/importar_contenedores.php --base-de-prueba\n");
}
require_once __DIR__ . '/../../config/conexion.php';
$datos = json_decode(file_get_contents(__DIR__ . '/contenedores_im_50.json'), true, 512, JSON_THROW_ON_ERROR);
$campos = $pdo->query('SHOW COLUMNS FROM contenedores')->fetchAll(PDO::FETCH_COLUMN);
if (!in_array('latitud', $campos, true)) {
    $pdo->exec(file_get_contents(__DIR__ . '/../migrations/001_coordenadas_contenedores.sql'));
}
$pdo->beginTransaction();
try {
    $existe = $pdo->prepare('SELECT id FROM contenedores WHERE fuente=? AND referencia_externa=?');
    $insertar = $pdo->prepare('INSERT INTO contenedores (ubicacion,estado,tipo_residuo,en_servicio,latitud,longitud,fuente,referencia_externa,datos_prueba) VALUES (?,?,?,1,?,?,?,?,1)');
    $nuevos = 0;
    foreach ($datos['contenedores'] as $c) {
        $existe->execute([$datos['fuente'], $c['referencia_externa']]);
        if ($existe->fetchColumn()) continue;
        $insertar->execute([$c['ubicacion'], $c['estado'], $c['tipo_residuo'], $c['latitud'], $c['longitud'], $datos['fuente'], $c['referencia_externa']]);
        $nuevos++;
    }
    $pdo->commit();
    echo "$nuevos contenedores de prueba importados; los existentes se conservaron.\n";
} catch (Throwable $e) {
    $pdo->rollBack();
    throw $e;
}
