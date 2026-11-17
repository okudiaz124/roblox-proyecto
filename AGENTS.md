# Instrucciones para Codex

Codex se encarga de programación Luau, arquitectura, integración, seguridad, optimización y pruebas. Lee GAME_DESIGN.md, VISUAL_STYLE.md, ARCHITECTURE.md, TASKS.md, INTEGRATION.md, PROGRESS.md y CLAUDE.md. Trabaja a partir de las decisiones guardadas en el repositorio.

Reserva archivos e instancias en TASKS.md. Mantén servidor, cliente y módulos compartidos en sus rutas mapeadas. Coordina el relevo de una escena o UI con Claude antes de modificarla. Implementa primero la acción principal del prototipo, según el alcance acordado con el usuario.

Sincroniza scripts desde disco con Rojo. Usa el MCP oficial para inspección y pruebas en la instancia de Studio que corresponda. Reproduce en archivos cualquier corrección permanente hecha dentro de Studio y verifica el build. Comprueba la funcionalidad y los sistemas afectados, documenta resultados en PROGRESS.md, actualiza TASKS.md, prepara un commit descriptivo e identifica la siguiente acción de Claude.
