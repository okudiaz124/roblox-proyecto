# Producción e importación de recursos

## Recursos usados en la expedición

La voz en español se genera con `AudioTextToSpeech` de Roblox. `Shared.Dialogue` contiene el guion de Claude y las marcas para sincronizarlo. La parte histórica se apoya en el traslado de restos a las canteras a finales del siglo XVIII. La zona prohibida y los personajes son ficticios. [Historia oficial de las Catacumbas de París](https://www.catacombes.paris.fr/en/history/site-history).

La música y los efectos se reproducen desde IDs del Creator Store. La exploración usa Dark Drone 12, el ritual usa Metallic Drone 03 y la persecución añade Heartbeat 02. Las vocalizaciones proceden de grabaciones porcinas de ProSoundEffects. Los IDs y volúmenes se controlan por separado en Luau. [Biblioteca de audio de Roblox](https://create.roblox.com/docs/audio/assets).

Para las mallas procedurales de cráneos y máscara en una experiencia publicada, habilita **Allow Mesh / Image APIs** en **Experience Settings → Security**. La ejecución local en Studio ya permite comprobarlas. Si la opción está apagada en el juego publicado, la criatura conserva una máscara alternativa y el laberinto conserva sus demás objetos. [Requisitos de EditableMesh](https://create.roblox.com/docs/reference/engine/classes/EditableMesh).

El cartel inicial se puede construir con Studio y Rojo. Para la próxima entrega de geometría orgánica, prepara Blender después de autorizar su instalación. Para grabaciones o música, elige Audacity o REAPER antes de reservar el trabajo de mezcla.

| Herramienta | Coste y papel | Instalación, archivos y entrega |
| --- | --- | --- |
| [Blender](https://www.blender.org/download/) | Gratuito. Herramienta prevista para cráneos, máscara, ropa, puertas, linterna, escombros y demás objetos a medida | Descarga el instalador de Windows y ejecútalo. Guarda `.blend` como fuente. Usa `.fbx` para rigs y clips, y `.glb` o `.fbx` para modelos estáticos. Importa con el Importador 3D de Studio y guarda un modelo revisado para Rojo. |
| [Roblox Animation Editor](https://create.roblox.com/docs/animation/editor) | Incluido en Studio. Primera opción para rigs y ajustes de clips | Abre **Avatar → Animation Editor** y selecciona un rig. Guarda los clips de cada personaje por separado. Publica las animaciones necesarias bajo el propietario de la experiencia y entrega sus IDs y tiempos. |
| [Moon Animator 2](https://create.roblox.com/store/asset/4725618216/Moon-Animator-) | De pago y opcional. Útil para previsualizar varios rigs y la cámara juntos | Si hace falta, usa la ficha oficial del Creator Store e instala el plugin desde Studio. Guarda la escena editable en el proyecto artístico. Entrega los clips publicados y las marcas temporales. La reproducción en juego se comprueba desde Luau. |
| [Audacity](https://www.audacityteam.org/download/windows/) | Gratuito. Primera opción para voz, limpieza de grabaciones, gruñidos y bucles sencillos | Ejecuta el MSI oficial. Conserva el proyecto `.aup3` y los originales. Exporta pistas y efectos por separado a WAV a 48 kHz. |
| [REAPER](https://www.reaper.fm/download.php) | De pago con evaluación. Opcional para sesiones multipista, mezcla y automatización | Usa el instalador oficial. Guarda el proyecto `.rpp` con sus medios. Exporta las capas y efectos finales en WAV a 48 kHz. [Licencia](https://www.reaper.fm/purchase.php). |
| Materiales de Blender y `SurfaceAppearance` de Studio | Incluidos. Primera opción para materiales PBR propios | Prepara UVs y guarda en PNG mapas de color, normal, rugosidad y metalicidad según el material. Impórtalos y asigna sus campos al `MeshPart` en Studio. [Texturas y materiales de Roblox](https://create.roblox.com/docs/art/modeling/surface-appearance). |

## Geometría e ítems

Modela con un rig de referencia y documenta el tamaño en studs. Usa origen y pivote consistentes, aplica transformaciones antes de exportar y revisa UVs, cantidad de triángulos y silueta a distancia. Para la linterna, vendas, rubíes y objetos rituales, usa una geometría de colisión simple y una malla visible independiente cuando convenga. Revisa el modelo importado con una copia fresca del juego. [Importador 3D de Roblox](https://create.roblox.com/docs/studio/importer).

La ficha de cada recurso entrega su fuente, pivote, tamaño, nombres de nodos, materiales, colisión y procedencia. Claude entrega el modelo. Codex lo convierte en un objeto del juego con identificadores, reglas de servidor y señales de animación. Los recursos compartidos deben funcionar con los permisos del propietario de la experiencia.

## Sonido y voces

Conserva capas separadas de exploración, ritual, cercanía y persecución, con puntos de inicio compatibles y bucles largos probados sin saltos. Entrega voz limpia por línea, ambiente, impactos y vocalizaciones porcinas como efectos separados. Documenta el derecho de uso de grabaciones y voces. Registra inicio y duración de cada línea para sincronizar subtítulos y gestos. Importa las pistas en Studio y entrega sus IDs y permisos para el mezclador y los emisores 3D. [Requisitos de importación de Roblox](https://create.roblox.com/docs/studio/importer).

## Revisión de publicación

Revisa las versiones finales del Hombre Cerdo, los restos rituales y el derrumbe con las normas vigentes. La propuesta visual usa la máscara, la silueta y los objetos abandonados para sugerir lo ocurrido. Declara la intensidad y frecuencia que efectivamente tenga el juego en el cuestionario de madurez. La clasificación se confirma con los recursos finales. [Normas de la comunidad](https://about.roblox.com/es/community-standards) · [Cuestionario y clasificación de Roblox](https://create.roblox.com/docs/production/promotion/content-ratings).
