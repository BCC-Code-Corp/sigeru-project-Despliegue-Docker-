// Estado de actividad de la cuadrilla: control de 3 botones (estilo iOS) y etiqueta de solo lectura.

export const ESTADOS_CUADRILLA = {
  trabajando: "Trabajando",
  inactivo: "Inactivo",
  yendo_a_descarga: "Yendo a descarga",
};
const ORDEN = Object.keys(ESTADOS_CUADRILLA);
const URL_CUADRILLAS = "../Backend/api/recoleccion/cuadrillas.php";

const escaparHtml = (t) => String(t).replace(/[&<>"']/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" })[c]);

/** Etiqueta de solo lectura (admin y operarios). */
export function etiquetaEstadoCuadrilla(estado) {
  const clave = ORDEN.includes(estado) ? estado : "inactivo";
  return `<span class="estado-cuadrilla-tag estado-${clave}">${escaparHtml(ESTADOS_CUADRILLA[clave])}</span>`;
}

/** Dibuja el control en `contenedor` para la cuadrilla `id`. */
export function montarControlEstado(contenedor, id, apiFetch) {
  contenedor.innerHTML = `
    <div class="ios-segmentado" role="radiogroup" aria-label="Estado de la cuadrilla" data-estado="inactivo">
      <span class="ios-pulgar" aria-hidden="true"></span>
      ${ORDEN.map((k) => `<button type="button" role="radio" aria-checked="false" data-estado="${k}">${ESTADOS_CUADRILLA[k]}</button>`).join("")}
    </div>
    <p class="ios-estado-nota" aria-live="polite"></p>`;
  const grupo = contenedor.querySelector(".ios-segmentado");
  const nota = contenedor.querySelector(".ios-estado-nota");

  function pintar(estado) {
    const i = Math.max(0, ORDEN.indexOf(estado));
    grupo.dataset.estado = ORDEN[i];
    grupo.style.setProperty("--i", i);
    grupo.querySelectorAll("button").forEach((b) => b.setAttribute("aria-checked", String(b.dataset.estado === ORDEN[i])));
  }

  apiFetch(URL_CUADRILLAS + "?id=" + encodeURIComponent(id))
    .then((r) => {
      if (r.status !== "success") throw new Error();
      const c = (r.data || [])[0] || {};
      pintar(c.estado_actividad);
      nota.textContent = c.estado_actividad_desde ? "Desde " + c.estado_actividad_desde : "";
    })
    .catch(() => (nota.textContent = "No se pudo cargar el estado actual."));

  grupo.addEventListener("click", (e) => {
    const boton = e.target.closest("button[data-estado]");
    if (!boton || boton.dataset.estado === grupo.dataset.estado) return;
    const anterior = grupo.dataset.estado;
    pintar(boton.dataset.estado);
    apiFetch(URL_CUADRILLAS + "?id=" + encodeURIComponent(id) + "&accion=estado", {
      method: "PUT",
      body: JSON.stringify({ estado: boton.dataset.estado }),
    })
      .then((r) => {
        if (r.status !== "success") throw new Error(r.message);
        nota.textContent = "Estado actualizado: " + ESTADOS_CUADRILLA[boton.dataset.estado] + ".";
      })
      .catch((err) => {
        pintar(anterior);
        nota.textContent = (err && err.message) || "No se pudo cambiar el estado.";
      });
  });
}

/** Lista de solo lectura con el estado de todas las cuadrillas (admin y operarios). Se refresca sola. */
export function montarListaEstados(contenedor, apiFetch, cada = 15000) {
  function cargar() {
    if (!contenedor.isConnected) return clearInterval(timer);
    apiFetch(URL_CUADRILLAS)
      .then((r) => {
        if (r.status !== "success") throw new Error();
        const filas = r.data || [];
        contenedor.innerHTML = filas.length
          ? `<div class="estado-cuadrillas-lista">${filas
              .map((c) => `<div class="estado-cuadrilla-item"><strong>${escaparHtml(c.nombre)}</strong>${etiquetaEstadoCuadrilla(c.estado_actividad)}</div>`)
              .join("")}</div>`
          : "<p>No hay cuadrillas registradas.</p>";
      })
      .catch(() => (contenedor.textContent = "No se pudo cargar el estado de las cuadrillas."));
  }
  const timer = setInterval(cargar, cada);
  cargar();
}
