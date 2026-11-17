# Arquitectura técnica

El proyecto usa Luau y las API de Roblox. `default.project.json` define el árbol administrado por Rojo.

| Archivos | Servicio o instancia | Responsabilidad |
| --- | --- | --- |
| `src/server` | `ServerScriptService.Server` | Entrada de servidor, reglas y estado autoritativo |
| `src/client` | `StarterPlayer.StarterPlayerScripts.Client` | Entrada de cliente, controles, presentación y controladores de UI |
| `src/shared` | `ReplicatedStorage.Shared` | Tipos, utilidades y contratos replicables |
| `src/server-assets` | `ServerStorage.GameAssets` | Plantillas privadas y recursos del servidor |
| `src/world` | `Workspace.World` | Escenario y objetos editables de la partida |
| `src/ui` | `StarterGui.GameUI` | Jerarquía visual que Roblox copia al jugador |

Añade entradas `.server.luau` y `.client.luau` cuando surja la primera funcionalidad. Usa `.luau` para módulos. Aplica `--!strict` en código nuevo cuando sea compatible con las dependencias. Mantén privadas las reglas sensibles y los datos que el cliente no necesita.

Cuando haya remotos, define su esquema, valida en servidor tipo, rango, permisos y contexto, y limita la frecuencia donde corresponda. Los controladores de UI consumen contratos de nombres, clases y estados documentados en [INTEGRATION.md](INTEGRATION.md). El acceso a datos persistentes, cuando exista, será responsabilidad del servidor.

Valida cada cambio con `rojo build` y una prueba acorde al comportamiento. Al añadir red, prueba en Studio con servidor y al menos dos clientes, incluyendo entradas inválidas y salida de un jugador. Verifica el Output y registra lo probado en [PROGRESS.md](PROGRESS.md).

El prototipo de catacumbas crea el mapa y el punto de aparición en el servidor. Cada cliente reproduce su propia introducción una vez por sesión de juego, con actores y decorado locales. El personaje aparece en el recorrido jugable desde el inicio y el cliente cede la cámara tras el fundido. La linterna y su interfaz se mantienen locales en esta etapa.
