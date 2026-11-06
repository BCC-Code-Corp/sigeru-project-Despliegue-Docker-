<?php

/**
 * ==================================================
 *  CONTROLADOR: INCIDENCIAS
 * ==================================================
 * Coordina el ciclo de vida de una incidencia (crear, listar,
 * asignar logística, resolver o reportar como falsa). "asignar" y "resolver" tocan
 * dos tablas a la vez (incidencias + camiones), por lo que usan
 * una transacción PDO para garantizar que ambas se actualicen
 * juntas o ninguna lo haga.
 */

require_once __DIR__ . '/../models/Incidencia.php';
require_once __DIR__ . '/../models/Camion.php';
require_once __DIR__ . '/../models/Contenedor.php';
require_once __DIR__ . '/../models/Notificacion.php';
require_once __DIR__ . '/../models/Usuario.php';
require_once __DIR__ . '/../core/AsignacionRuta.php';

class IncidenciaController
{
    private Incidencia $incidenciaModel;
    private Camion $camionModel;
    private Notificacion $notificacionModel;
    private Usuario $usuarioModel;
    private PDO $pdo;

    public function __construct(PDO $pdo)
    {
        $this->pdo = $pdo;
        $this->incidenciaModel = new Incidencia($pdo);
        $this->camionModel = new Camion($pdo);
        $this->notificacionModel = new Notificacion($pdo);
        $this->usuarioModel = new Usuario($pdo);
    }

    /** Vecino reporta una incidencia nueva. */
    public function crear(array $datos): array
    {
        $ubicacion        = $datos['ubicacion'] ?? null;
        $estadoContenedor = $datos['estado_contenedor'] ?? null;
        $tipoBasura       = $datos['tipo_basura'] ?? null;
        $usuarioId        = $GLOBALS['actor']['id'];

        $penalizacion = $this->usuarioModel->estadoPenalizacion((int)$usuarioId);
        if ($penalizacion['activa']) {
            return ["status" => "error", "message" => $this->mensajePenalizacion($penalizacion), "_code" => 403];
        }

        if (!$ubicacion || !$estadoContenedor || !$tipoBasura) {
            return ["status" => "error", "message" => "Todos los campos son requeridos.", "_code" => 400];
        }

        if ($this->incidenciaModel->contarActivasPorUsuario((int)$usuarioId) >= 2) {
            return ["status" => "error", "message" => "Podés tener como máximo 2 reportes abiertos. Esperá a que se resuelvan para reportar nuevamente.", "_code" => 409];
        }

        if (empty($datos['contenedor_id']) || !ctype_digit((string)$datos['contenedor_id']) || (int)$datos['contenedor_id'] <= 0) {
            return ["status" => "error", "message" => "Seleccioná un contenedor para registrar el reporte.", "_code" => 400];
        }

        if (!in_array($estadoContenedor, ['roto', 'desborde'], true)) return ['status' => 'error', 'message' => 'Tipo de incidencia: roto o desborde.', '_code' => 400];
        if (empty(trim($datos['descripcion'] ?? ''))) return ['status' => 'error', 'message' => 'La descripción es obligatoria.', '_code' => 400];
        foreach (['latitud', 'longitud'] as $campo) if (isset($datos[$campo]) && $datos[$campo] !== '' && !is_numeric($datos[$campo])) return ['status' => 'error', 'message' => 'Coordenadas inválidas.', '_code' => 400];
        $latitud  = (isset($datos['latitud'])  && $datos['latitud']  !== '' && $datos['latitud']  !== null) ? (float) $datos['latitud']  : null;
        $longitud = (isset($datos['longitud']) && $datos['longitud'] !== '' && $datos['longitud'] !== null) ? (float) $datos['longitud'] : null;

        if (($latitud !== null && $longitud === null) || ($latitud === null && $longitud !== null)) {
            return ["status" => "error", "message" => "Latitud y longitud deben informarse juntas.", "_code" => 400];
        }
        if ($latitud !== null && ($latitud < -90 || $latitud > 90 || $longitud < -180 || $longitud > 180)) {
            return ["status" => "error", "message" => "Las coordenadas seleccionadas no son válidas.", "_code" => 400];
        }

        // El punto del reporte es el del contenedor elegido: si el contenedor tiene coordenadas
        // guardadas, prevalecen sobre las que envíe el cliente (no se puede marcar cualquier lugar).
        $contenedor = (new Contenedor($this->pdo))->buscarPorId((int)$datos['contenedor_id']);
        if ($contenedor && $contenedor['latitud'] !== null && $contenedor['longitud'] !== null) {
            $latitud  = (float) $contenedor['latitud'];
            $longitud = (float) $contenedor['longitud'];
        }

        $this->incidenciaModel->crear($ubicacion, $estadoContenedor, $tipoBasura, $usuarioId, $latitud, $longitud);
        $id = (int)$this->pdo->lastInsertId();
        $this->incidenciaModel->describir($id, trim($datos['descripcion']));
        if (!(new Contenedor($this->pdo))->enServicio((int)$datos['contenedor_id'])) throw new DomainException('El contenedor no está en servicio.');
        $this->incidenciaModel->asociarContenedor($id, (int)$datos['contenedor_id']);
        $this->historial($id, null, 'abierta', $datos['descripcion']);
        // Si la ruta de ese contenedor ya tiene cuadrilla y camión asignados, la incidencia se asigna sola.
        (new AsignacionRuta($this->pdo))->alCrearIncidencia($id, (int)$datos['contenedor_id']);
        $this->notificacionModel->crearParaRol('administrador', 'alerta', "Nueva incidencia #{$id} ({$estadoContenedor}) en {$ubicacion}: requiere atención.", $id);

        return ["status" => "success", "message" => "Reporte ciudadano registrado con éxito.", "_code" => 201];
    }

    /** Operario y Cuadrilla consultan el listado completo. */
    public function listar(): array
    {
        $u = $GLOBALS['actor'];
        if ($u['rol'] === 'vecino') return $this->listarPorUsuario(['usuario_id' => $u['id']]);
        if (in_array($u['rol'], ['chofer', 'recolector'], true)) {
            return ['status' => 'success', 'data' => $this->incidenciaModel->listarPorCuadrilla($u['cuadrilla_id'])];
        }
        if ($u['rol'] === 'operario') return ['status' => 'success', 'data' => []];
        return ["status" => "success", "data" => $this->incidenciaModel->listarTodas()];
    }

    /** Vecino consulta únicamente las incidencias que él mismo reportó. */
    public function listarPorUsuario(array $datos): array
    {
        if ($GLOBALS['actor']['rol'] !== 'administrador') $datos['usuario_id'] = $GLOBALS['actor']['id'];
        if (empty($datos['usuario_id'])) {
            return ["status" => "error", "message" => "Falta el ID del usuario.", "_code" => 400];
        }
        $lista = $this->incidenciaModel->listarPorUsuario((int) $datos['usuario_id']);
        if ($GLOBALS['actor']['rol'] === 'vecino') {
            foreach ($lista as &$fila) unset($fila['motivo_reporte'], $fila['reportada_por']);
            unset($fila);
        }
        return ["status" => "success", "data" => $lista];
    }

    /** Operario asigna cuadrilla + camión y pone la incidencia "en curso". */
    public function asignar(array $datos): array
    {
        if (empty($datos['id']) || empty($datos['matricula_camion'])) {
            return ["status" => "error", "message" => "Faltan datos para asignar la incidencia.", "_code" => 400];
        }

        $id          = (int) $datos['id'];
        $cuadrillaId = $datos['cuadrilla_id'] ?? null;
        $matricula   = $datos['matricula_camion'];
        $comentario  = $datos['comentario_operario'] ?? '';

        $incidencia = $this->incidenciaModel->buscarPorId($id);
        if (!$incidencia) {
            return ["status" => "error", "message" => "La incidencia no existe.", "_code" => 404];
        }

        try {

            if ($incidencia['estado_incidencia'] !== 'abierta') throw new DomainException('Solo se asignan incidencias abiertas.', 409);
            if ($incidencia['ruta_id'] && ((int)$incidencia['cuadrilla_id'] !== (int)$cuadrillaId || $incidencia['matricula_camion'] !== $matricula)) throw new DomainException('La incidencia tiene una ruta planificada con otra cuadrilla o camión.', 409);
            $camion = $this->camionModel->buscarPorMatricula($matricula);
            // Una cuadrilla puede tomar varias incidencias a la vez: el camión sirve si está Disponible o ya En Ruta con ella.
            if (!$camion || !in_array($camion['estado'], ['Disponible', 'En Ruta'], true) || !$camion['cuadrilla_id'] || (int)$camion['cuadrilla_id'] !== (int)$cuadrillaId) throw new DomainException('Se requiere un camión operativo (Disponible o En Ruta) de la cuadrilla indicada.', 409);
            if (!$this->camionModel->buscarCuadrillaDisponible((int)$cuadrillaId)) throw new DomainException('Cuadrilla no disponible.', 409);
            $this->historial($id, 'abierta', 'en curso', $comentario ?: 'Asignación de cuadrilla y camión');
            $this->incidenciaModel->asignar($id, $cuadrillaId, $matricula, $comentario);
            $this->camionModel->actualizarEstado($matricula, 'En Ruta');


            if ($incidencia && !empty($incidencia['usuario_id'])) {
                $this->notificacionModel->crear(
                    $incidencia['usuario_id'],
                    'incidencia',
                    "Tu incidencia #{$id} en {$incidencia['ubicacion']} fue asignada a una cuadrilla y está en curso.",
                    $id
                );
            }

            return ["status" => "success", "message" => "Logística asignada correctamente. Estado: En curso."];
        } catch (\Exception $e) {
            if ($this->pdo->inTransaction()) {
                $this->pdo->rollBack();
            }
            throw $e;
        }
    }

    /** Cuadrilla marca la incidencia como resuelta y libera el camión asignado. */
    public function resolver(array $datos): array
    {
        if (empty($datos['id'])) {
            return ["status" => "error", "message" => "Falta el ID de la incidencia.", "_code" => 400];
        }

        $id = (int) $datos['id'];
        $incidencia = $this->incidenciaModel->buscarPorId($id);
        if (!$incidencia) {
            return ["status" => "error", "message" => "La incidencia no existe.", "_code" => 404];
        }

        try {

            $u = $GLOBALS['actor'];
            if ($u['rol'] !== 'administrador' && (empty($u['cuadrilla_id']) || (int)$u['cuadrilla_id'] !== (int)$incidencia['cuadrilla_id'])) throw new DomainException('Esta incidencia no está asignada a tu cuadrilla.', 403);
            if ($incidencia['estado_incidencia'] !== 'en curso') throw new DomainException('Solo se cierran incidencias en curso.', 409);
            $solucion = trim($datos['solucion'] ?? '');
            if ($solucion === '') throw new DomainException('Debés describir la solución aplicada.');
            $this->incidenciaModel->resolver($id, $solucion);
            $this->historial($id, 'en curso', 'cerrada', $solucion);
            $this->incidenciaModel->cerrarReclamos($id);

            if ($incidencia && !empty($incidencia['matricula_camion']) && !$this->incidenciaModel->tieneIncidenciasEnCurso($incidencia['matricula_camion'])) {
                $this->camionModel->actualizarEstado($incidencia['matricula_camion'], 'Disponible');
            }



            if ($incidencia && !empty($incidencia['usuario_id'])) {
                $this->notificacionModel->crear(
                    $incidencia['usuario_id'],
                    'incidencia',
                    "Tu incidencia #{$id} en {$incidencia['ubicacion']} fue marcada como solucionada.",
                    $id
                );
            }

            return ["status" => "success", "message" => "Incidencia marcada como solucionada y camión liberado."];
        } catch (\Exception $e) {
            if ($this->pdo->inTransaction()) {
                $this->pdo->rollBack();
            }
            throw $e;
        }
    }
    /**
     * Cuadrilla reporta una incidencia en curso como falsa. Queda "reportada"
     * (con su motivo), se libera el camión y el vecino recibe la penalización
     * que corresponde a su cantidad de reportes falsos.
     */
    public function reportar(array $datos): array
    {
        if (empty($datos['id'])) {
            return ["status" => "error", "message" => "Falta el ID de la incidencia.", "_code" => 400];
        }

        $motivo = trim((string) ($datos['motivo_reporte'] ?? ''));
        $errorMotivo = $this->validarMotivo($motivo);
        if ($errorMotivo !== null) {
            return ["status" => "error", "message" => $errorMotivo, "_code" => 400];
        }

        $id = (int) $datos['id'];
        $incidencia = $this->incidenciaModel->buscarPorId($id);
        if (!$incidencia) {
            return ["status" => "error", "message" => "La incidencia no existe.", "_code" => 404];
        }

        $u = $GLOBALS['actor'];
        if (empty($u['cuadrilla_id']) || (int)$u['cuadrilla_id'] !== (int)$incidencia['cuadrilla_id']) throw new DomainException('Esta incidencia no está asignada a tu cuadrilla.', 403);
        if ($incidencia['estado_incidencia'] !== 'en curso') throw new DomainException('Solo se reportan incidencias en curso.', 409);

        $this->incidenciaModel->reportar($id, $motivo, (int) $u['id']);
        $this->historial($id, 'en curso', 'reportada', 'Reporte falso: ' . $motivo);
        $this->incidenciaModel->cerrarReclamos($id);

        if (!empty($incidencia['matricula_camion']) && !$this->incidenciaModel->tieneIncidenciasEnCurso($incidencia['matricula_camion'])) {
            $this->camionModel->actualizarEstado($incidencia['matricula_camion'], 'Disponible');
        }

        // Solo se penaliza a vecinos: otros roles pueden abrir incidencias pero no tienen penalización.
        $autor = !empty($incidencia['usuario_id']) ? $this->usuarioModel->buscarPorId((int) $incidencia['usuario_id']) : null;
        if ($autor && $autor['rol'] === 'vecino') {
            $pena = $this->usuarioModel->penalizar((int) $autor['id']);
            $sancion = $pena['permanente']
                ? "Con {$pena['nivel']} reportes falsos tu cuenta quedó penalizada de forma permanente y no podrás reportar incidencias. Un administrador puede revisar tu caso."
                : "Penalización nivel {$pena['nivel']}: no podrás reportar incidencias durante {$pena['horas']} horas. A los " . Usuario::NIVEL_BANEO_PERMANENTE . " reportes falsos la penalización es permanente.";
            $this->notificacionModel->crear(
                $autor['id'],
                'incidencia',
                "Tu incidencia #{$id} en {$incidencia['ubicacion']} fue reportada como falsa por la cuadrilla. {$sancion}",
                $id
            );
        }

        $this->notificacionModel->crearParaRol('administrador', 'alerta', "La incidencia #{$id} fue reportada como falsa por una cuadrilla: revisala en Incidencias reportadas.", $id);

        return ["status" => "success", "message" => "Incidencia reportada como falsa. Se notificó al administrador y se aplicó la penalización correspondiente al vecino."];
    }

    /** Administrador: incidencias reportadas como falsas. */
    public function listarReportadas(): array
    {
        if ($GLOBALS['actor']['rol'] !== 'administrador') {
            return ["status" => "error", "message" => "No tenés permiso para esta operación.", "_code" => 403];
        }
        return ["status" => "success", "data" => $this->incidenciaModel->listarReportadas()];
    }

    /**
     * Valida el texto libre del motivo. La base usa consultas preparadas (sin
     * inyección SQL) y el Frontend lo escapa al mostrarlo; además acá se rechaza
     * marcado HTML, caracteres de control y UTF-8 inválido (defensa contra XSS).
     */
    private function validarMotivo(string $motivo): ?string
    {
        if (!preg_match('//u', $motivo)) return 'El motivo contiene caracteres inválidos.';
        $largo = preg_match_all('/./us', $motivo);
        if ($largo < 10 || $largo > 500) return 'El motivo debe tener entre 10 y 500 caracteres.';
        if (preg_match('/[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]/', $motivo)) return 'El motivo contiene caracteres no permitidos.';
        if (preg_match('/[<>]/', $motivo)) return 'El motivo no puede contener los caracteres < ni >.';
        return null;
    }

    private function mensajePenalizacion(array $p): string
    {
        if ($p['permanente']) {
            return 'Tu cuenta está penalizada de forma permanente por reportes falsos y no podés reportar incidencias. Si creés que es un error, contactá a un administrador.';
        }
        $horas = max(1, (int) ceil($p['minutos_restantes'] / 60));
        return "Estás penalizado por reportes falsos y no podés reportar incidencias. Podrás volver a hacerlo en aproximadamente {$horas} hora(s).";
    }

    private function historial(int $id, ?string $anterior, string $nuevo, string $observacion): void
    {
        $this->incidenciaModel->registrarHistorial($id, $GLOBALS['actor']['id'], $anterior, $nuevo, $observacion);
    }
}
