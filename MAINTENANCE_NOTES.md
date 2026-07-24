# Notas de Mantenimiento - Harmony Music (fork LoborojoPy)

Este documento explica por qué esta app deja de funcionar de forma
recurrente (Home o Buscador que no cargan) y qué hacer cuando pase.

## ¿Por qué se rompe la app periódicamente?

Harmony Music **no usa una API oficial de YouTube**. Usa la API interna
("innertube") que utiliza el propio sitio `music.youtube.com` para su
funcionamiento web. Google:

- No publica documentación de esta API.
- No garantiza que su estructura (los campos JSON, los tipos de
  respuesta, las claves de acceso) se mantenga igual con el tiempo.
- La cambia sin avisar cuando actualiza music.youtube.com.

El repositorio original de esta app (`anandnet/Harmony-Music`) **ya no
está mantenido** (el autor lo declaró abandonado), así que cuando
YouTube cambia algo, nadie lo arregla salvo que lo hagamos nosotros en
este fork.

Otras apps del mismo estilo (ej. [RiMusic](https://github.com/fast4x/RiMusic),
[ytmusicapi](https://github.com/sigma67/ytmusicapi)) tienen el mismo
problema de fondo, pero sí se mantienen activamente, por lo que sirven
de referencia para encontrar el fix cuando algo se rompe aquí.

## ¿Por qué no usar la API oficial de YouTube (YouTube Data API v3)?

Existe, es gratuita (con un límite diario de cuota, sin plan de pago),
pero **no sirve para esta app** porque:

1. No tiene el catálogo de "YouTube Music" (canciones, álbumes,
   artistas, letras, quick picks, radio automático) — solo maneja
   videos/canales/playlists genéricos de YouTube normal.
2. **No entrega streaming de audio.** Solo permite buscar y listar
   metadatos; no da el archivo/stream de audio para reproducir.
3. Su cuota gratuita (10,000 unidades/día, ~100 unidades por búsqueda)
   se agotaría con muy poco uso normal de una app de música.

Por eso Harmony Music (y sus equivalentes) dependen de la API interna
no oficial, con el riesgo de rotura que eso implica.

## Cómo detectar que se rompió

Desde los fixes aplicados en este fork:

- Si el **Home** o el **Buscador** no cargan, ya NO se quedan con el
  shimmer/carga infinita en silencio. Muestran:
  **"Oops network error!"** con botón **"Retry!"**.
- Si tocas "Retry!" varias veces y sigue sin cargar nada, es una
  rotura real de la API (no solo un corte de red pasajero).
- Si solo el buscador falla pero el Home funciona (o viceversa), puede
  ser un problema más específico de parseo de resultados.

## Qué hacer cuando se rompa

1. Anota exactamente qué falla: ¿Home, Buscador, o ambos? ¿Falla
   siempre o a veces? Si es posible, captura de pantalla del error.
2. Pide ayuda (a Kiro u otro desarrollador) describiendo el síntoma.
   El proceso de arreglo típico es:
   - Revisar `lib/services/music_service.dart` (peticiones a la API)
     y `lib/services/nav_parser.dart` (parseo de las respuestas).
   - Comparar con un cliente de YT Music activamente mantenido (ej.
     RiMusic) para ver qué cambió en la estructura de respuesta de
     YouTube.
   - Aplicar el fix, subir el cambio, esperar a que el workflow de
     GitHub Actions (`.github/workflows/build_apk.yml`) genere el
     nuevo APK, y probarlo.
3. Repetir hasta confirmar que carga correctamente.

## Historial de fixes en este fork

- **Buscador solo mostraba playlists, no canciones/videos**: la
  clasificación de resultados usaba el nombre del artista en vez del
  tipo real (`resultType`) devuelto por YouTube. Corregido en
  `music_service.dart` / `media_Item_builder.dart`.
- **Home/Buscador se quedaban cargando sin fin ante errores
  inesperados**: se agregó manejo de errores visible (mensaje +
  botón "Reintentar") en `home_screen_controller.dart` y
  `search_result_screen_controller.dart`.
- **Fallos intermitentes de red**: se agregaron reintentos
  automáticos con espera progresiva en `_sendRequest()` y
  `genrateVisitorId()` en `music_service.dart`.
- **Canciones/videos ausentes incluso con la clasificación
  corregida**: YouTube dejó de incluirlos de forma confiable en la
  respuesta de búsqueda "mixta". Se agregó una búsqueda filtrada de
  respaldo específica para Songs/Videos (mismo enfoque que usa
  RiMusic con sus `SearchFilter`), en `music_service.dart`.

## Referencias útiles

- [RiMusic (fast4x)](https://github.com/fast4x/RiMusic) - cliente de
  YouTube Music para Android, activamente mantenido. Buena referencia
  para comparar lógica de parseo cuando algo se rompe aquí.
- [ytmusicapi (sigma67)](https://github.com/sigma67/ytmusicapi) -
  librería Python para la misma API interna, también mantenida
  activamente.
- [YouTube Data API v3 - docs oficiales](https://developers.google.com/youtube/v3/docs)
  - la API oficial, gratuita pero no aplicable a esta app (ver arriba).
