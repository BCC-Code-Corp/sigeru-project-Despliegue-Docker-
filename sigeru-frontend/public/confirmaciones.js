// Confirmación previa a escrituras importantes. Cancelar nunca envía la petición.
export async function confirmarOperacion(url, opciones = {}) {
  const metodo = (opciones.method || "GET").toUpperCase();
  const destino = new URL(url, location.href);
  const recurso = destino.pathname.split("/").pop().replace(".php", "");
  if (
    !["POST", "PUT", "DELETE"].includes(metodo) ||
    recurso === "logout" ||
    (recurso === "notificaciones" && metodo === "PUT") ||
    // Estas acciones ya piden su propia confirmación con formulario (solicitarDatos).
    recurso === "penalizados" ||
    destino.searchParams.get("accion") === "reportar" ||
    destino.searchParams.get("accion") === "estado"
  )
    return true;
  const nombres = {
    usuarios: "usuario",
    cuadrillas: "cuadrilla",
    camiones: "camión",
    contenedores: "contenedor",
    centros_acopio: "instalación",
    maquinaria: "máquina",
    rutas: "ruta",
    asignaciones: "asignación de ruta",
    relaciones: "asignación de recursos",
    recepciones: "recepción de residuos",
    capacidad: "capacidad de la instalación",
    incidencias: "incidencia",
    recolecciones: "recolección",
    reclamos: "reclamo",
    residuos: "tipo de residuo",
    mantenimientos: "mantenimiento",
    reparaciones: "reparación",
    notificaciones: "anuncio",
  };
  const nombre = nombres[recurso] || "registro";
  const eliminar = metodo === "DELETE";
  const accion = eliminar
    ? "Confirmar baja"
    : metodo === "PUT"
      ? "Guardar cambios"
      : "Confirmar registro";
  let datos = {};
  try {
    datos = JSON.parse(opciones.body || "{}");
  } catch {}
  const referencia =
    datos.nombre ||
    datos.matricula ||
    destino.searchParams.get("matricula") ||
    (destino.searchParams.get("id")
      ? "#" + destino.searchParams.get("id")
      : "");
  const dialog = document.createElement("dialog");
  dialog.className = "confirmacion";
  dialog.setAttribute("aria-labelledby", "confirmacion-titulo");
  dialog.innerHTML =
    '<form method="dialog"><h2 id="confirmacion-titulo"></h2><p class="confirmacion-descripcion"></p><dl class="confirmacion-detalle"></dl><div class="confirmacion-acciones"><button value="cancelar" class="btn-mini boton-secundario" autofocus>Cancelar</button><button value="confirmar" class="btn-mini"></button></div></form>';
  dialog.querySelector("h2").textContent = accion;
  dialog.querySelector("p").textContent = eliminar
    ? `Se dará de baja este ${nombre}. El historial se conservará.`
    : `Se ${metodo === "PUT" ? "actualizarán" : "guardarán"} los datos de ${nombre}. Revisá la información antes de confirmar.`;
  const detalles = dialog.querySelector("dl");
  const agregar = (etiqueta, valor) => {
    if (valor === undefined || valor === null || valor === "") return;
    const dt = document.createElement("dt");
    dt.textContent = etiqueta;
    const dd = document.createElement("dd");
    dd.textContent = String(valor);
    detalles.append(dt, dd);
  };
  agregar("Registro", referencia);
  const etiquetas = {
    email: "Correo",
    rol: "Rol",
    estado_registro: "Solicitud",
    disponibilidad: "Disponibilidad",
    cuadrilla_id: "Cuadrilla",
    usuario_id: "Usuario",
    chofer_id: "Chofer",
    centro_id: "Instalación",
    ruta_id: "Ruta",
    estado: "Estado",
    capacidad_ocupada: "Capacidad ocupada",
    cantidad: "Cantidad",
    fecha: "Fecha",
    accion: "Operación",
  };
  for (const [campo, etiqueta] of Object.entries(etiquetas))
    agregar(etiqueta, datos[campo]);
  if (datos.password) agregar("Contraseña", "Se cambiará la contraseña");
  agregar("Motivo", destino.searchParams.get("motivo"));
  const aceptar = dialog.querySelector('[value="confirmar"]');
  aceptar.textContent = accion;
  if (eliminar) aceptar.classList.add("boton-peligro");
  const anterior = document.activeElement;
  document.body.append(dialog);
  return new Promise((resolve) => {
    dialog.addEventListener(
      "close",
      () => {
        const ok = dialog.returnValue === "confirmar";
        dialog.remove();
        if (anterior?.isConnected) anterior.focus();
        resolve(ok);
      },
      { once: true },
    );
    dialog.showModal();
  });
}

// Confirmación con un campo de entrada (texto largo o número). Devuelve el valor
// ingresado ya validado o null si se cancela. Todo el contenido se inserta con
// textContent/atributos del DOM (nunca como HTML) para evitar XSS.
export function solicitarDatos({
  titulo,
  descripcion,
  detalle = [],
  campo,
  confirmar = "Confirmar",
  peligro = false,
}) {
  const dialog = document.createElement("dialog");
  dialog.className = "confirmacion";
  dialog.setAttribute("aria-labelledby", "solicitud-titulo");
  const form = document.createElement("form");
  form.method = "dialog";
  form.noValidate = true;

  const h2 = document.createElement("h2");
  h2.id = "solicitud-titulo";
  h2.textContent = titulo;
  const p = document.createElement("p");
  p.className = "confirmacion-descripcion";
  p.textContent = descripcion;
  const dl = document.createElement("dl");
  dl.className = "confirmacion-detalle";
  detalle.forEach(([etiqueta, valor]) => {
    if (valor === undefined || valor === null || valor === "") return;
    const dt = document.createElement("dt");
    dt.textContent = etiqueta;
    const dd = document.createElement("dd");
    dd.textContent = String(valor);
    dl.append(dt, dd);
  });

  const etiqueta = document.createElement("label");
  etiqueta.htmlFor = "solicitud-campo";
  etiqueta.style.cssText = "display:block;font-weight:600;margin:14px 0 6px";
  etiqueta.textContent = campo.etiqueta;
  const entrada = document.createElement(
    campo.tipo === "textarea" ? "textarea" : "input",
  );
  entrada.id = "solicitud-campo";
  entrada.className = "campo-entrada";
  entrada.style.cssText = "width:100%;box-sizing:border-box";
  entrada.required = true;
  entrada.autocomplete = "off";
  if (campo.tipo === "textarea") {
    entrada.rows = 4;
    entrada.maxLength = campo.maximo;
  } else {
    entrada.type = "number";
    entrada.min = "0";
    entrada.max = String(campo.maximo);
    entrada.step = "1";
    entrada.inputMode = "numeric";
  }
  const ayuda = document.createElement("small");
  ayuda.style.cssText = "display:block;margin-top:6px;color:#647268";
  ayuda.textContent = campo.ayuda || "";
  const error = document.createElement("p");
  error.setAttribute("role", "alert");
  error.hidden = true;
  error.style.cssText = "color:#a63232;margin:10px 0 0;font-weight:600";

  const acciones = document.createElement("div");
  acciones.className = "confirmacion-acciones";
  const cancelar = document.createElement("button");
  cancelar.type = "button";
  cancelar.className = "btn-mini boton-secundario";
  cancelar.textContent = "Cancelar";
  cancelar.addEventListener("click", () => dialog.close("cancelar"));
  const aceptar = document.createElement("button");
  aceptar.type = "submit";
  aceptar.value = "confirmar";
  aceptar.className = "btn-mini" + (peligro ? " boton-peligro" : "");
  aceptar.textContent = confirmar;
  acciones.append(cancelar, aceptar);

  form.append(h2, p, dl, etiqueta, entrada, ayuda, error, acciones);
  dialog.append(form);

  form.addEventListener("submit", (evento) => {
    const mensaje = campo.validar(entrada.value);
    if (mensaje) {
      evento.preventDefault();
      error.textContent = mensaje;
      error.hidden = false;
      entrada.focus();
    }
  });

  const anterior = document.activeElement;
  document.body.append(dialog);
  return new Promise((resolve) => {
    dialog.addEventListener(
      "close",
      () => {
        const ok = dialog.returnValue === "confirmar";
        const valor = entrada.value.trim();
        dialog.remove();
        if (anterior?.isConnected) anterior.focus();
        resolve(ok ? valor : null);
      },
      { once: true },
    );
    dialog.showModal();
    entrada.focus();
  });
}
