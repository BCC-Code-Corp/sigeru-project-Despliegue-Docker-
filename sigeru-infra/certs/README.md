# Certificados TLS

No guardar claves privadas ni certificados reales en Git. Para habilitar HTTPS, obtener un certificado válido para el dominio del servidor, guardarlo aquí como `fullchain.pem` y `privkey.pem`, y agregar la configuración TLS del gateway y la publicación del puerto 443.

El Compose base sirve HTTP para desarrollo y para la primera puesta en marcha. No se incluye un certificado autofirmado porque los navegadores mostrarían una advertencia de seguridad.
