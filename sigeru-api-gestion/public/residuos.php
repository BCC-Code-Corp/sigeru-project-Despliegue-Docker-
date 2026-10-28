<?php
require_once __DIR__ . '/../app/config/conexion.php';
require_once __DIR__ . '/../app/core/Sesion.php';
require_once __DIR__ . '/../app/controllers/OperacionController.php';
try {
    Sesion::proteger($pdo, 'residuos');
    $controller = new OperacionController($pdo);
    Respuesta::enviarResultado($controller->atender('residuos', $_SERVER['REQUEST_METHOD'], Sesion::datos(), $_GET));
} catch (Throwable $e) {
    Respuesta::enviarErrorInterno($e, 'residuos');
}
