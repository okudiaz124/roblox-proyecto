# Proyecto Roblox

Repositorio de desarrollo compartido por Claude Code y Codex. [GAME_DESIGN.md](GAME_DESIGN.md) recoge el concepto y [TASKS.md](TASKS.md) coordina los turnos. Consulta [PROGRESS.md](PROGRESS.md) para ver lo que ya se ha comprobado.

## Rojo en Windows

En la copia inicial de Windows ya están el ejecutable y el plugin oficiales en `.tools/rojo-7.7.1`. El lugar generado está en `build/RobloxProyecto.rbxl`. Ambos directorios son locales. En un clon de GitHub instala [Rokit](https://github.com/rojo-rbx/rokit) y ejecuta lo siguiente desde la raíz. También puedes descargar [Rojo 7.7.1](https://github.com/rojo-rbx/rojo/releases/tag/v7.7.1) y usar su ruta completa en lugar de `rojo`.

```powershell
rokit install
rojo --version
New-Item -ItemType Directory -Force build | Out-Null
rojo build --output build/RobloxProyecto.rbxl
```

En la copia inicial, con Studio cerrado, ejecuta estos comandos en una ventana normal de PowerShell desde la raíz del repositorio. Si ya tienes un plugin Rojo, comprueba primero su versión en Studio.

```powershell
$plugin = "$env:LOCALAPPDATA\Roblox\Plugins\Rojo.rbxm"
if (-not (Test-Path -LiteralPath $plugin)) {
    New-Item -ItemType Directory -Force (Split-Path $plugin) | Out-Null
    $download = (Resolve-Path ".tools/rojo-7.7.1/Rojo.rbxm").Path
    [System.IO.File]::Copy($download, $plugin, $false)
}
.\.tools\rojo-7.7.1\rojo.exe serve
```

En un clon con Rokit, los comandos equivalentes son `rojo plugin install` y `rojo serve`. Mantén el servidor abierto. En Studio abre **File → Open from File…** y selecciona `build/RobloxProyecto.rbxl`. Ve a **Plugins → Rojo → Connect**, usa `localhost:34872` y revisa las operaciones antes de confirmar. Detén el servidor con Ctrl+C al terminar.

Si usas dos copias del repositorio en la misma máquina, ejecuta **uno** de los servidores con `rojo serve --port 34873` e introduce ese puerto en el plugin de esa copia. Identifica cada lugar por nombre o ID antes de operar en él. Cuando ambos agentes usen la misma copia de Studio, alterna los turnos según [TASKS.md](TASKS.md).

## MCP oficial

1. Con el lugar abierto en Roblox Studio, abre **Assistant → … → Manage MCP Servers** y activa **Enable Studio as MCP server**. La [guía oficial](https://create.roblox.com/docs/studio/mcp) describe el launcher de Windows `%LOCALAPPDATA%\Roblox\mcp.bat`. Comprueba que exista con `Test-Path "$env:LOCALAPPDATA\Roblox\mcp.bat"`. Si sigue ausente tras activar el servidor, actualiza Studio y copia el comando Windows que muestre el panel.
2. En Codex abre esta carpeta como proyecto de confianza e inicia un chat nuevo para cargar `.codex/config.toml`. En una nueva ventana de PowerShell, situada en la raíz, puedes iniciar Claude Code con `& "$env:USERPROFILE\.local\bin\claude.exe"`. Aprueba el MCP de proyecto cuando Claude te lo solicite y usa `/mcp` para ver su estado. Si ya tienes el servidor registrado globalmente, usa un solo registro por cliente.
3. Pide a cada agente que ejecute `list_roblox_studios`. Debe devolver el nombre del lugar abierto y un ID de instancia. Comprueba además el indicador verde de conexiones en Studio. Si se ven varios lugares, el agente debe verificar cuál corresponde a su tarea antes de editar.

Si Codex no muestra `Roblox_Studio` con `/mcp` en el proyecto de confianza, ve a **Settings → MCP servers → Add server**. Elige **STDIO**, nombre `Roblox_Studio`, comando `cmd.exe` y argumentos `/c` y `%LOCALAPPDATA%\Roblox\mcp.bat`. Guarda y reinicia cuando lo pida la app. Ese registro aplica al host local de Codex. [Documentación de OpenAI](https://learn.chatgpt.com/docs/extend/mcp?surface=cli).

MCP facilita inspección y pruebas en Studio. La persistencia de scripts y arte de trabajo sigue el flujo de [INTEGRATION.md](INTEGRATION.md).

## GitHub

Si `git remote -v` está vacío, crea un repositorio privado vacío desde [GitHub → New repository](https://github.com/new). Deja sin seleccionar README, licencia y gitignore. Copia la URL HTTPS de tu nuevo repositorio y reemplázala en el comando.

```powershell
git remote add origin https://github.com/TU_USUARIO/roblox-proyecto.git
git push -u origin main
```

Cuando Git solicite autenticación, termina el inicio de sesión en Git Credential Manager. Si Claude y Codex trabajan desde máquinas o copias distintas, abre el mismo remoto en ambas y concede acceso a cualquier otra cuenta que lo necesite. Usa commits y ramas para pasar los cambios según TASKS.md.

## Primer encargo

Pasa [PROMPT_CLAUDE.md](PROMPT_CLAUDE.md) a Claude Code desde esta carpeta. Describe la idea y la primera acción que debe poder realizar el jugador. Con esa información, Claude prepara el primer escenario y Codex implementa y prueba la acción.
