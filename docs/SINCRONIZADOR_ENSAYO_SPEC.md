# Sincronizador de ensayo

## Alcance
Ensayo sincroniza el audio original con tres capas: tabla de numerofonía, letra/karaoke y mini zampoña. No es un DAW: no corta, divide, recorta, mezcla ni exporta audio. El archivo original es una referencia de solo lectura.

## Experiencia
Editor temporal con controles de audio, cursor compartido y tres pistas sincronizables. Permite marcar el instante actual, ajustar tiempos exactos, mover eventos/grupos, zoom, snap opcional, undo/redo y bucle de escucha. La vista de músico será simple y ofrecerá tabla, karaoke o vista combinada, velocidad, mini zampoña y repetición de secciones.

## Autoridad temporal
La posición del reproductor nativo es el reloj maestro. La interfaz solo representa snapshots; requestAnimationFrame/performance.now no acumulan el tiempo musical ni disparan muestras. Seek, pausa, reanudación, velocidad y cambio de canción invalidan eventos pendientes y reconstruyen el estado desde el reloj nativo. Los tiempos se almacenan como enteros de microsegundos relativos al inicio del audio.

## Modelo
Un SyncProject versionado referencia songId y audio; contiene eventos tipados de numerofonía, letra y mini zampoña, además de marcadores y regiones de bucle. Tabla y mini zampoña comparten identidad de evento cuando representan la misma nota. Letra puede sincronizarse por verso, palabra o sílaba. Los proyectos son independientes del documento de canción.

## Motor de mini zampoña
El backend actual crea un Sink independiente por nota y hace detach; carece de un mezclador central de voces y control explícito de solapamiento. Se sustituirá por un mixer persistente con muestras PCM precargadas, programación por frames, cola acotada, política de voces explícita, envolventes de ataque/liberación, headroom y protección contra clipping. No se creará un Sink por nota. Pausa/seek/stop invalidan eventos futuros. El hilo de audio no hará I/O, decodificación ni locks prolongados.

Los pops pueden proceder de cortes bruscos, clipping, solapamiento o reinicio de voces. Se probarán ataques, finales, notas consecutivas, simultáneas y saltos; no se asumirá que un crossfade aislado resuelve todos los casos.

## Fuera de alcance
Edición de waveform, clips, cortar/dividir audio, mezcla multipista, edición destructiva y exportación de audio.

## Compatibilidad y seguridad de datos
Los proyectos se guardan aparte de canciones con schemaVersion. No sobrescribir campos antiguos ni migrar automáticamente timingsMs/letraTimingsMs sin validar su semántica. Autosave y recuperación deben ser no destructivos.

## Fases
1. Modelo tipado y motor puro de sincronización.
2. Mixer persistente de mini zampoña.
3. Reloj real y scheduler nativo.
4. Conectar tabla/cursor.
5. Editor temporal de tabla, letra y zampoña.
6. Reproductor simplificado.
7. Pruebas Android de latencia, jitter, pops y persistencia.

## Aceptación
Audio, tabla, karaoke y mini zampoña permanecen alineados en play/pause/seek/velocidad/bucle, sin deriva acumulativa ni clics audibles. Undo/redo restaura tiempos y ningún ajuste modifica el audio ni el cancionero.
