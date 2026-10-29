# Suricata IDS

Instalar Suricata en el host de aplicaciones y configurarlo en modo IDS (detección), no IPS, hasta validar la interfaz, HOME_NET y falsos positivos.

1. Identificar interfaz de red y direcciones reales del host (`ip -br address`, `ip route`).
2. Definir HOME_NET con la(s) subred(es) internas del entorno en `/etc/suricata/suricata.yaml`.
3. Actualizar reglas y validar sintaxis: `sudo suricata-update` y `sudo suricata -T -c /etc/suricata/suricata.yaml`.
4. Configurar captura sobre la interfaz correcta (AF_PACKET o el método soportado por la distribución) y revisar que el servicio inicie sin errores.
5. Verificar alertas y logs con `sudo journalctl -u suricata` y `/var/log/suricata/fast.log`.
6. Guardar evidencia fechada de versión, interfaz, HOME_NET, prueba de configuración, servicio activo y alertas de prueba autorizadas.

No activar IPS ni reglas de bloqueo hasta probarlas en una ventana controlada. Docker puede alterar el camino de paquetes; revisar la documentación del firewall de Docker y capturar en la interfaz que realmente ve el tráfico.
