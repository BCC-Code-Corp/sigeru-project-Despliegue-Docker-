// El menú depende del DOM y funciona sin esperar la sesión de la API.
(() => {
  const boton = document.getElementById("toggle-sidebar");
  const sidebar = document.getElementById("sidebar");
  if (!boton || !sidebar) return;

  function actualizarEstado() {
    boton.setAttribute("aria-expanded", String(!sidebar.classList.contains("oculto")));
  }

  boton.addEventListener("click", () => {
    sidebar.classList.toggle("oculto");
    actualizarEstado();
  });

  sidebar.addEventListener("click", (evento) => {
    if (window.matchMedia("(max-width: 600px)").matches && evento.target.closest("a")) {
      sidebar.classList.add("oculto");
      actualizarEstado();
    }
  });

  actualizarEstado();
})();
