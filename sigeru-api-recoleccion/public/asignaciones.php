<?php
require_once __DIR__ . '/../app/config/conexion.php';
require_once __DIR__ . '/../app/core/Sesion.php';
require_once __DIR__ . '/../app/controllers/OperacionController.php';
try {
    Sesion::proteger($pdo, 'asignaciones');
    $controller = new OperacionController($pdo);
    Respuesta::enviarResultado($controller->atender('asignaciones', $_SERVER['REQUEST_METHOD'], Sesion::datos(), $_GET));
} catch (Throwable $e) {
    Respuesta::enviarErrorInterno($e, 'asignaciones');
}
