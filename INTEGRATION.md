# Integración de contenido

## Flujo entre Studio y el repositorio

Git conserva la fuente de trabajo. Rojo sincroniza los archivos hacia Studio. MCP sirve para inspeccionar la sesión, editar en un lugar de trabajo y realizar pruebas. Las ediciones hechas con MCP en Studio necesitan exportación o un cambio equivalente en el repositorio para perdurar.

1. Claude reserva las rutas en [TASKS.md](TASKS.md), genera su lugar de trabajo con `rojo build`, lo abre en Studio y verifica su nombre o ID con `list_roblox_studios` si usa MCP.
2. Para editar un modelo o la UI dentro de una raíz administrada, desconecta Rojo en esa copia antes de editar. Selecciona el modelo raíz o Frame de la entrega en Explorer, pulsa con el botón derecho **Save to File…** y guarda el modelo en `src/world/`, `src/ui/` o `src/server-assets/`, según su destino. Usa `.rbxmx` si Studio ofrece ese formato; `.rbxm` también es válido. Para UI, exporta los hijos de `GameUI`, que ya proporciona el `ScreenGui`. Si automatizas una exportación mediante una herramienta compatible, comprueba que el archivo existe y que el build lo incluye.
3. Anota abajo las rutas y propiedades esperadas, los Asset IDs externos y sus permisos de uso, y los pasos de verificación. Reabre un build fresco y comprueba la jerarquía, referencias, colisiones o escalado de UI. Si el escenario usa Terrain o iluminación global, acuerda y versiona primero cómo reproducir esos cambios. El modelo base todavía no cubre esos datos.
4. Claude prepara el commit visual. Codex integra los controladores y sistemas desde su rama o después del relevo de la copia compartida. Si recibes un binario cambiado por ambos, conserva ambas versiones y coordina su integración en Studio.
5. Al conectar el plugin, revisa la lista de operaciones y el lugar antes de aceptar. Los elementos fuera de las raíces mapeadas se preservan. Dentro de las raíces administradas, Rojo puede retirar descendientes que no figuren en los archivos. Para comprobar una exportación, usa un build nuevo o valida primero el diff en un lugar de trabajo.

## Registro de entregas

| Tarea | Archivo y ruta en Studio | Clases, nombres, tags y atributos | Dependencias y prueba |
| --- | --- | --- | --- |
| ART-01 | Pendiente | Pendiente | Pendiente |

Documenta el contrato de integración junto a la entrega, incluidas las señales o llamadas que usará el código, las propiedades esperadas y quién sigue. Los Asset IDs deben funcionar en la experiencia de destino. Verifica también cualquier recurso dependiente de Roblox que no viaje dentro del archivo de modelo.
