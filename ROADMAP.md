# Producción de las catacumbas de París

La referencia de atmósfera es *As Above, So Below*. El juego conserva su propia historia, diseño y recursos. La primera versión jugable queda como base de comparación.

## Entregas en orden

| Entrega | Claude | Codex | Criterio de aceptación |
| --- | --- | --- | --- |
| París y acceso | París de noche, Eiffel a escala creíble, tapa de alcantarilla, rigs, actuación y animaciones de Hikari, Matthew y el guía | Coordinar cámara POV, tapa, descenso y marcas de posición | El grupo comprueba que nadie lo mira, abre la tapa y desciende por el mapa real |
| Relato y derrumbes | Guion, voz, actuación facial y corporal, ambiente y escombros | Temporizar voz y subtítulos, reproducir señales y conservar el estado del túnel | El guía habla al menos 60 segundos efectivos, con intervenciones de Hikari y Matthew. Bloquean la ruta principal y el regreso dos derrumbes distintos que persisten al recuperar el control |
| Zona prohibida y laberinto | Cartel en francés, túneles, cráneos anatómicos, altares, objetos, decoración húmeda y restos estilizados | Validar rutas, streaming y objetivos. Mostrar `SIN SEÑAL` y «Tenemos que continuar. No tenemos señal en el celular.» | Se puede completar el recorrido y perderse entre bucles, ramales, desniveles y salas ocultas |
| Audio continuo | Mezclar música suave, capas de ritual y persecución, voces, pasos y efectos con derechos de uso | Mantener la música en bucle largo, fundir capas sin reiniciar y bajar su volumen bajo las voces | La música permanece aun sin criatura cercana. Retrocede suavemente al escapar |
| Hombre Cerdo | Modelo humanoide, máscara orgánica no explícita, traje, animaciones originales y vocalizaciones porcinas | Controlar detección por visión y ruido, estados, navegación, daño y audio 3D | La puerta presenta la inscripción de los rubíes. La criatura aparece como entidad física, se aleja y sigue activa al recuperar el control |
| Recursos y puerta | Vendas, rubíes, puerta, animaciones y FX de recogida e inserción | Mantener dos vendas totales y tres rubíes compartidos por partida. Validar recogida, cura y apertura en servidor | Cada recurso se recoge una vez. Con 3/3 el grupo abre el acceso a otra zona |
| Calidad | Revisar lectura y detalle de los recursos en las condiciones de juego | Probar cooperativo, rendimiento, colisiones, oclusión, volumen, subtítulos y reducción de temblor | La cámara se mantiene en primera persona. La intro y el gameplay comparten suelo, luces, props y la posición de entrega |

El relato del guía cubre los restos humanos, la complejidad de las rutas, las desapariciones ficticias y la advertencia reiterada. En la primera aparición del monstruo la cámara sostiene la puerta durante los primeros dos sonidos, gira lentamente y deja ver la silueta, el giro de cabeza y su retirada.

## Primera entrega de arte

`ServerStorage.GameAssets.Art.ForbiddenEntrance` es un `Model` reutilizable para el aviso de la ruta lateral. Lleva una calavera gráfica y el texto **ZONE INTERDITE — DANGER DE MORT — ACCÈS INTERDIT**. Se origina cerca de `(0, 0, 0)`, su cara visible apunta hacia `-Z` y el pivote queda en el centro del panel. Codex lo coloca desde el servidor en la entrada real. Claude trabaja en el recurso y explica sus propiedades en su ficha de arte.

Los siguientes recursos compartirán un contrato de pivote, escala, colisión, nombres y fondos de importación. La colocación, los cambios de estado, la interacción y las pruebas corresponden a Codex.
