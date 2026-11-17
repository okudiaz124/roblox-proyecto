# Progreso

## 17 de noviembre de 2026

- Preparados el repositorio Git local, la configuración MCP de proyecto, los documentos de colaboración y el prompt para Claude.
- Rojo 7.7.1 instalado dentro de la carpeta del proyecto. Verificados los SHA-256 del ejecutable distribuido y el plugin, el build `build/RobloxProyecto.rbxl`, las seis raíces del sourcemap y la respuesta del servidor local en el puerto 34872.
- Roblox Studio y `StudioMCP.exe` detectados. El ejecutable respondió a `initialize`, pero la prueba desde Codex quedó bloqueada al crear `%LOCALAPPDATA%\Roblox\StudioMCP`. No se verificó un lugar activo por MCP y el launcher `mcp.bat` no estaba presente.
- Claude Code 2.1.326 reconoció el servidor MCP de proyecto y lo marcó pendiente de aprobación. Claude revisó los criterios de ART-00 y devolvió su propuesta en la respuesta tras un rechazo de escritura. Codex incorporó los criterios acordes al alcance.
- Pendientes la instalación y prueba del plugin Rojo en Studio, la conexión MCP de ambos clientes y el remoto privado de GitHub. La sesión de terminal recibió acceso denegado al crear la carpeta del plugin. El conector de GitHub reconoció la cuenta, y el repositorio propuesto aún no estaba accesible.
- Idea del juego pendiente. El proyecto contiene la base de desarrollo para implementar el primer prototipo cuando llegue la descripción.

### Publicación y verificación posterior

- Base publicada en el repositorio público `okudiaz124/roblox-proyecto`. La rama local `main` sigue a `origin/main`.
- Plugin oficial Rojo 7.7.1 instalado en el perfil de Roblox y verificado contra el SHA-256 de la publicación. El servidor local respondió en `127.0.0.1:34872`. Falta comprobar la sincronización desde el plugin en un lugar abierto.
- Claude verificó por separado el plugin y el lugar compilado. El launcher oficial seguía ausente y su cliente MCP devolvió `Connection closed`. Codex recibió la inicialización del proxy, con un rechazo HTTP 401 en el puente y sin enumeración del lugar. Falta activar y verificar el servidor en el panel de Studio.

### Studio MCP activo

- El servidor MCP de Roblox Studio quedó habilitado. El proxy oficial devolvió 38 herramientas y listó `RobloxProyecto.rbxl` en modo Edit por JSON-RPC desde PowerShell.
- Claude Code confirmó el mismo lugar mediante `list_roblox_studios` con la configuración MCP del repositorio cargada explícitamente. Fue una prueba de lectura.
- Falta comprobar el servidor integrado en un chat de Codex y una actualización de archivo sincronizada por el plugin de Rojo.
