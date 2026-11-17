# Dirección visual

París al anochecer se reconoce por los tejados de mansarda, los faroles y la silueta de la torre Eiffel. La entrada corta esa vista y da paso a piedra húmeda, pasillos estrechos, lámparas ámbar y zonas que el jugador debe alumbrar. La primera persona mantiene la escala de los cuerpos y los túneles desde la altura de los ojos.

El derrumbe comunica el peligro mediante movimiento, oscuridad y escombros que ocultan al guía. La iluminación de emergencia orienta hacia el paso lateral. La interfaz de linterna usa un panel pequeño y oscuro con el nombre grande, el botón correspondiente al dispositivo y el estado de la luz. DOORS sirve como referencia de claridad para el acceso al utensilio dentro de un juego de terror. [DOORS, de LSPLASH](https://www.roblox.com/games/6516141723/DOORS).

Define la ambientación, la escala, la silueta, la paleta, los materiales y la iluminación del primer escenario. Añade referencias concretas con su procedencia. Para interfaces, documenta jerarquía, legibilidad y estados pertinentes, incluidos los dispositivos objetivo cuando estén definidos.

La primera entrega visual debe ser una escena pequeña y editable que permita probar la acción principal. Registra medidas, pivotes, colisiones, iluminación, dependencias y los nombres de los elementos que el código debe encontrar. Usa [INTEGRATION.md](INTEGRATION.md) para entregar la escena y sus recursos.

## Revisión de la primera entrega

- **Escenario.** Comprueba el punto de aparición, los límites y la ruta hasta la primera interacción. Mide en studs con un avatar de referencia. Usa formas, iconos o texto junto al color cuando deban distinguirse objetos o estados. Acuerda con Codex cómo versionar Terrain o Lighting si el diseño los requiere.
- **Modelos.** Documenta pivote y orientación, ancla las piezas estáticas y usa colisiones acordes a la interacción. Registra los Asset IDs y comprueba que sus permisos y dependencias funcionan en un build nuevo.
- **Interfaz.** Acordad los nombres y los estados que requiere cada interacción. Si el juego se dirige a móviles, comprueba legibilidad, zonas seguras y tamaños táctiles en el emulador de Studio. Verifica que los controles propios de Roblox dejen espacio para la UI.

Registra en [PROGRESS.md](PROGRESS.md) el lugar o build revisado, el dispositivo o modo de prueba, las observaciones y las correcciones pendientes.
