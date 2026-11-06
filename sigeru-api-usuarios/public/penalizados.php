<?php

/**
 * ==================================================
 *  API USUARIOS · Usuarios penalizados (solo administrador)
 * ==================================================
 * Endpoint : /Backend/api/usuarios/penalizados.php
 * GET                  -> lista los usuarios con penalización vigente (200)
 * PUT    ?id=1  body: { horas }  -> fija nuevas horas de penalización desde ahora;
 *                                   0 la levanta por completo (200 / 400 / 404 / 409)
 * Respuesta: { status, message?, data? }
 *
 * Las penalizaciones se generan solas cuando una cuadrilla reporta una
 * incidencia como falsa (incidencias.php?accion=reportar). Acá el
 * administrador las regula por si la cuadrilla cometió un error.
 */

require_once __DIR__ . '/../../config/conexion.php';
require_once __DIR__ . '/../../core/Respuesta.php';
require_once __DIR__ . '/../../controllers/PenalizacionController.php';

require_once __DIR__ . '/../../core/Sesion.php';

try {
    Sesion::proteger($pdo, 'penalizados');
    $controlador = new PenalizacionController($pdo);
    $metodo = $_SERVER['REQUEST_METHOD'];

    if ($metodo === 'GET') {
        Respuesta::enviarResultado($controlador->listar());
    }

    if ($metodo === 'PUT') {
        if (empty($_GET['id'])) {
            Respuesta::enviar(["status" => "error", "message" => "Falta el id del usuario."], 400);
        }
        Respuesta::enviarResultado($controlador->despenalizar((int) $_GET['id'], Sesion::datos()));
    }

    Respuesta::enviar(["status" => "error", "message" => "Método no soportado."], 405);
} catch (\Throwable $e) {
    Respuesta::enviarErrorInterno($e, 'penalizados.php');
}
