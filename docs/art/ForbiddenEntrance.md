# ForbiddenEntrance (ART-02A)

Cartel 3D francés envejecido para la ruta lateral prohibida.

- **Archivo:** `src/server-assets/Art/ForbiddenEntrance.rbxmx` (Model Rojo, sin IDs externos, scripts ni plugins).
- **Destino previsto:** `ServerStorage.GameAssets.Art.ForbiddenEntrance`. La colocación en la entrada real corresponde a Codex.
- **Tamaño:** ≈ 3.8 × 2.5 studs, profundidad ≈ 0.4 (Z −0.16 a +0.26, por remaches y traviesa).
- **Pivote:** `PrimaryPart = Panel`, en el origen (0, 0, 0), centro del panel. La cara visible apunta a **−Z**.
- **Piezas:** 31 `Part` más un `SurfaceGui`, todas con `Anchored = true`, `CanCollide = false`, `CanTouch = false`.

## Contenido
- **Marco:** 4 barras `CorrodedMetal` de óxido pardo, con panel marfil (`Plastic`).
- **Soportes:** 2 montantes y 1 traviesa traseros (`Metal` gris).
- **Remaches:** 12 esferas, `Remache01`–`Remache12`, en el borde.
- **Texto:** `Panel.Texte` (`SurfaceGui`, cara Front = −Z) con tres `TextLabel` en `ArialBold` y `TextScaled`:
  - `ZONE INTERDITE` en negro.
  - `DANGER DE MORT` en rojo oscuro.
  - `ACCÈS INTERDIT` en negro.
  - Contraste alto sobre marfil para luz pobre; `LightInfluence = 0.5`.
- **Calavera:** gráfica plana con medallón oscuro, calavera marfil (cráneo, mandíbula, ojos, nariz, dientes) y dos huesos cruzados.

## Notas de integración
- Importar con Rojo o insertar el `.rbxmx`; mover con `PivotTo`.
- Sin colisión: no bloquea al jugador.
- Para verlo desde +Z, rotar el modelo completo 180°; el texto del `SurfaceGui` solo se ve por −Z.
- **Validado en Studio:** la integración comprobó el pivote, la orientación del panel, el color marfil, los tres textos, el pictograma y la ausencia de colisión. La legibilidad a distancia se revisará con la iluminación del túnel definitivo.
