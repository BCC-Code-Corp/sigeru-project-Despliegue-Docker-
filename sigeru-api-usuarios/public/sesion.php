<?php
require_once __DIR__ . '/../../config/conexion.php';
require_once __DIR__ . '/../../core/Sesion.php';
require_once __DIR__ . '/../../models/Usuario.php';
try {
    if ($_SERVER['REQUEST_METHOD'] !== 'GET') Sesion::rechazar('Método no soportado.', 405);
    $u = Sesion::usuario($pdo);
    if ($u['rol'] === 'vecino') $u['penalizacion'] = (new Usuario($pdo))->estadoPenalizacion((int) $u['id']);
    Respuesta::enviar(['status' => 'success', 'usuario' => $u, 'csrf' => $_SESSION['csrf']]);
} catch (Throwable $e) {
    Respuesta::enviarErrorInterno($e);
}
