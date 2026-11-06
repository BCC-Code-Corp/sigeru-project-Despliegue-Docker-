<?php

/**
 * ==================================================
 *  CONTROLADOR: PENALIZACIONES (usuarios penalizados)
 * ==================================================
 * El administrador lista a los usuarios con una penalización
 * vigente y puede regularla: fijar nuevas horas de penalización
 * o levantarla por completo (0 horas), por ejemplo cuando una
 * cuadrilla se equivocó al reportar una incidencia como falsa.
 * La penalización se aplica automáticamente desde
 * IncidenciaController::reportar().
 */

require_once __DIR__ . '/../models/Usuario.php';
require_once __DIR__ . '/../models/Notificacion.php';

class PenalizacionController
{
    private Usuario $usuarioModel;
    private Notificacion $notificacionModel;

    public function __construct(PDO $pdo)
    {
        $this->usuarioModel = new Usuario($pdo);
        $this->notificacionModel = new Notificacion($pdo);
    }

    /** READ (todos) — usuarios penalizados vigentes. */
    public function listar(): array
    {
        $this->exigirAdministrador();
        return ["status" => "success", "data" => $this->usuarioModel->listarPenalizados()];
    }

    /** UPDATE — nueva duración (en horas, desde ahora). 0 = despenalizar por completo. */
    public function despenalizar(int $id, array $datos): array
    {
        $this->exigirAdministrador();

        $horas = $datos['horas'] ?? null;
        $valida = (is_int($horas) || (is_string($horas) && ctype_digit($horas))) && (int) $horas >= 0 && (int) $horas <= Usuario::HORAS_MAXIMAS_PENALIZACION;
        if (!$valida) {
            return ["status" => "error", "message" => "Ingresá un número entero de horas entre 0 y " . Usuario::HORAS_MAXIMAS_PENALIZACION . ".", "_code" => 400];
        }
        $horas = (int) $horas;

        $estado = $this->usuarioModel->estadoPenalizacion($id);
        if (!$estado['existe']) {
            return ["status" => "error", "message" => "El usuario no existe.", "_code" => 404];
        }
        if (!$estado['activa']) {
            return ["status" => "error", "message" => "El usuario no tiene una penalización vigente.", "_code" => 409];
        }

        $this->usuarioModel->despenalizar($id, $horas);

        $aviso = $horas === 0
            ? "Un administrador levantó tu penalización: ya podés reportar incidencias nuevamente."
            : "Un administrador revisó tu penalización: no podrás reportar incidencias durante {$horas} horas a partir de ahora.";
        $this->notificacionModel->crear($id, 'sistema', $aviso);

        return [
            "status" => "success",
            "message" => $horas === 0 ? "Usuario despenalizado por completo." : "Penalización actualizada a {$horas} horas desde ahora.",
        ];
    }

    private function exigirAdministrador(): void
    {
        if (($GLOBALS['actor']['rol'] ?? '') !== 'administrador') {
            throw new DomainException('No tenés permiso para esta operación.', 403);
        }
    }
}
