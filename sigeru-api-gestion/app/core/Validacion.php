<?php
final class Validacion
{
    public static function password(string $password): bool
    {
        return strlen($password) >= 8 && strlen($password) <= 72
            && preg_match('/[A-Z]/', $password) && preg_match('/[a-z]/', $password)
            && preg_match('/[0-9]/', $password) && preg_match('/[^A-Za-z0-9]/', $password);
    }
    public const PASSWORD_MENSAJE = 'La contraseña debe tener entre 8 y 72 caracteres, mayúscula, minúscula, número y símbolo.';

    /** Valida latitud/longitud elegidas en el mapa. Devuelve el mensaje de error o null. */
    public static function coordenadas(array $datos, bool $obligatorias): ?string
    {
        $lat = $datos['latitud'] ?? null;
        $lon = $datos['longitud'] ?? null;
        $vacio = fn($v) => $v === null || $v === '';
        if ($vacio($lat) && $vacio($lon)) return $obligatorias ? 'Elegí la ubicación haciendo clic en el mapa.' : null;
        if ($vacio($lat) || $vacio($lon)) return 'Latitud y longitud deben informarse juntas.';
        if (!is_numeric($lat) || !is_numeric($lon) || abs((float)$lat) > 90 || abs((float)$lon) > 180) return 'Coordenadas inválidas.';
        return null;
    }

    public static function entrada(string $recurso, array $datos): void
    {
        $maximos = [
            'nombre' => $recurso === 'centros_acopio' ? 150 : 100,
            'email' => 100,
            'cedula' => 20,
            'matricula' => 20,
            'ubicacion' => 255,
            'tipo_residuo' => 100,
            'estado' => 30,
            'tipo_basura' => 100,
            'estado_contenedor' => 100,
            'comentario_operario' => 255,
            'mensaje' => 500,
            'modelo' => 100,
            'lic_conducir' => 100,
            'especialidad' => 100,
            'descripcion' => 5000,
            'solucion' => 5000,
            'motivo_reporte' => 500
        ];
        foreach ($datos as $campo => $valor) {
            if ($valor === null) continue;
            if (isset($maximos[$campo])) {
                if (!is_string($valor) || preg_match_all('/./us', $valor) > $maximos[$campo]) throw new DomainException("$campo debe ser texto de hasta {$maximos[$campo]} caracteres.");
                if ($campo === 'nombre' && preg_match_all('/./us', trim($valor)) < 3) throw new DomainException('El nombre debe tener al menos 3 caracteres.');
            }
            if (str_ends_with($campo, '_id') && $valor !== '') {
                if (!ctype_digit((string)$valor) || (int)$valor <= 0 || (float)$valor > 2147483647) throw new DomainException("Identificador inválido: $campo.");
            }
            if (in_array($campo, ['capacidad', 'capacidad_ocupada', 'capacidad_carga', 'cantidad', 'volumen'], true) && $valor !== '') {
                $max = $campo === 'capacidad_carga' ? 99999999.99 : 9999999999.99;
                if (!is_numeric($valor) || !is_finite((float)$valor) || $valor < 0 || $valor > $max) throw new DomainException("Valor numérico fuera de rango: $campo.");
            }
            if ($campo === 'password' && !is_string($valor)) throw new DomainException('La contraseña debe ser texto.');
        }
    }
}
