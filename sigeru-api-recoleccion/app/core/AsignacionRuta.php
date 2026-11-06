<?php

/**
 * ==================================================
 *  ASIGNACIÓN AUTOMÁTICA DE INCIDENCIAS POR RUTA
 * ==================================================
 * Una ruta agrupa contenedores (tabla `contiene`). Cuando el administrador
 * le asigna una cuadrilla y un camión para una fecha, las incidencias
 * abiertas de esos contenedores quedan asignadas solas; y lo mismo ocurre
 * con las incidencias que se reporten después sobre esos contenedores.
 *
 *  - Asignación para HOY  -> la incidencia pasa a "en curso" (camión En Ruta).
 *  - Asignación FUTURA    -> la incidencia queda planificada (ruta, cuadrilla y
 *                            camión) y sigue "abierta" hasta ese día.
 *  - Si la cuadrilla no está disponible o el camión no es apto, la
 *    incidencia queda abierta para asignarla a mano.
 */

require_once __DIR__ . '/../models/Incidencia.php';
require_once __DIR__ . '/../models/Notificacion.php';
require_once __DIR__ . '/../models/Camion.php';

final class AsignacionRuta
{
    private PDO $pdo;
    private Incidencia $incidencias;
    private Notificacion $notificaciones;
    private Camion $camiones;

    public function __construct(PDO $pdo)
    {
        $this->pdo = $pdo;
        $this->incidencias = new Incidencia($pdo);
        $this->notificaciones = new Notificacion($pdo);
        $this->camiones = new Camion($pdo);
    }

    /** El administrador asignó la ruta: aplica la asignación a las incidencias abiertas de sus contenedores. */
    public function aplicarRuta(int $rutaId, int $cuadrillaId, string $matricula, string $fecha): int
    {
        $hoy = $this->consultar('SELECT DATE(?) = CURDATE() AS hoy', [$fecha])[0]['hoy'] == 1;
        $abiertas = $this->consultar(
            "SELECT DISTINCT i.id FROM incidencias i JOIN sobre s ON s.incidencia_id=i.id JOIN contiene c ON c.contenedor_id=s.contenedor_id
             WHERE c.ruta_id=? AND i.estado_incidencia='abierta' FOR UPDATE",
            [$rutaId]
        );
        $n = 0;
        foreach ($abiertas as $fila) {
            if ($this->aplicar((int)$fila['id'], $rutaId, $cuadrillaId, $matricula, $hoy)) $n++;
        }
        return $n;
    }

    /** Se acaba de reportar una incidencia sobre un contenedor: si su ruta ya tiene asignación vigente, se asigna sola. */
    public function alCrearIncidencia(int $incidenciaId, int $contenedorId): bool
    {
        $a = $this->consultar(
            "SELECT a.ruta_id, a.cuadrilla_id, a.matricula, a.fecha = CURDATE() AS hoy
             FROM asignaciones a JOIN rutas r ON r.id=a.ruta_id AND r.activo=1 JOIN contiene c ON c.ruta_id=a.ruta_id
             WHERE c.contenedor_id=? AND a.fecha >= CURDATE() ORDER BY a.fecha ASC, a.id ASC LIMIT 1",
            [$contenedorId]
        );
        if (!$a) return false;
        return $this->aplicar($incidenciaId, (int)$a[0]['ruta_id'], (int)$a[0]['cuadrilla_id'], $a[0]['matricula'], $a[0]['hoy'] == 1);
    }

    private function aplicar(int $id, int $rutaId, int $cuadrillaId, string $matricula, bool $hoy): bool
    {
        $camion = $this->camiones->buscarPorMatricula($matricula);
        $apto = $camion && in_array($camion['estado'], ['Disponible', 'En Ruta'], true)
            && (int)$camion['cuadrilla_id'] === $cuadrillaId
            && $this->camiones->buscarCuadrillaDisponible($cuadrillaId);
        if (!$apto) return false;

        if (!$hoy) {
            $this->pdo->prepare("UPDATE incidencias SET ruta_id=?, cuadrilla_id=?, matricula_camion=? WHERE id=? AND estado_incidencia='abierta'")
                ->execute([$rutaId, $cuadrillaId, $matricula, $id]);
            return true;
        }

        $this->pdo->prepare(
            "UPDATE incidencias SET ruta_id=?, cuadrilla_id=?, matricula_camion=?, comentario_operario='Asignación automática por ruta', estado_incidencia='en curso'
             WHERE id=? AND estado_incidencia='abierta'"
        )->execute([$rutaId, $cuadrillaId, $matricula, $id]);
        $this->incidencias->registrarHistorial($id, (int)$GLOBALS['actor']['id'], 'abierta', 'en curso', 'Asignación automática por ruta');
        $this->camiones->actualizarEstado($matricula, 'En Ruta');

        $incidencia = $this->incidencias->buscarPorId($id);
        if ($incidencia && !empty($incidencia['usuario_id'])) {
            $this->notificaciones->crear(
                $incidencia['usuario_id'],
                'incidencia',
                "Tu incidencia #{$id} en {$incidencia['ubicacion']} fue asignada automáticamente a una cuadrilla y está en curso.",
                $id
            );
        }
        return true;
    }

    private function consultar(string $sql, array $valores): array
    {
        $q = $this->pdo->prepare($sql);
        $q->execute($valores);
        return $q->fetchAll();
    }
}
