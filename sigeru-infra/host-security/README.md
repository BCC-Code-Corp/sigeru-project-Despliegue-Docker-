# Firewall del host y puertos Docker

`configure-ufw.sh` es una plantilla de política para el propio host, incluido SSH administrativo. No la ejecutes sin revisar CIDR y conservar acceso de recuperación.

Docker documenta que el tráfico de puertos publicados se redirige antes de las cadenas que usa UFW; por ello, las reglas UFW pueden no filtrar esos puertos. Para 80/443 y 3306, configurar el firewall perimetral/proveedor y, según el sistema, reglas persistentes compatibles con Docker (por ejemplo, la cadena DOCKER-USER con iptables). Diseñar y probar las reglas según interfaces, IPs y versión reales: las reglas genéricas pueden cortar tráfico de contenedores o dejar puertos expuestos.

La plantilla `compose.database-server.yaml` liga MariaDB a `DB_BIND_IP` privado; esto reduce exposición, pero no reemplaza firewall de proveedor ni prueba desde una red externa. No publicar 3306 en dirección pública.
