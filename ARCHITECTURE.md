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

El servidor crea la calle, la alcantarilla, el túnel inicial, los dos derrumbes y el laberinto. Cada cliente reproduce la introducción una vez, con actores, partículas y cámara locales sobre la misma geometría que usa el juego. El punto de aparición coincide con la entrega del control. Las rocas estáticas quedan en el servidor y el cliente revela cada grupo a su marca de tiempo.

`Shared.Expedition` replica la fase, el inventario compartido, el contador de rubíes, el estado de la puerta y la criatura. El servidor valida alcance, línea de visión y estado para recoger objetos. Los clientes presentan subtítulos, música, ajustes y cinemáticas. El laberinto usa una red conectada de 225 celdas con enlaces adicionales y tres cámaras ocultas. La criatura se mueve de nodo a nodo con visión, audición y memoria limitada.
