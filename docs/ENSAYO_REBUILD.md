# Reconstrucción del modo Ensayo — AllinKawsay 3.0

## Objetivo

Reemplazar el flujo de ensayo simplificado por un sistema musical determinista, medible y desacoplado de la interfaz. La versión 2.0 es referencia de comportamiento; no se copiará su implementación.

## Criterios no negociables

- El audio es el reloj maestro cuando existe una pista asociada.
- Los tiempos manuales grabados por el usuario prevalecen sobre cualquier estimación por BPM.
- El modo guía debe seguir el tiempo real del reproductor, no acumular deriva con `requestAnimationFrame`.
- BIS repite exactamente el fragmento/estrofa definido y debe poder editarse y previsualizarse.
- La partitura no debe desplazarse horizontalmente: columnas proporcionales, contenido completo, simetría y tamaño legible.
- El brillo indica la celda/nota actual y no debe alterar las dimensiones del visor.
- Pausa, reanudación, búsqueda, cambio de velocidad y fin de pista deben reconstruir el cursor desde la posición real.
- Respetar reducción de movimiento y ahorro de batería.

## Flujo funcional propuesto

1. **Preparar canción:** validar audio, letra, estrofas, columnas y repeticiones.
2. **Construir setlist:** ordenar canciones y bloques; permitir insertar, quitar y reordenar sin perder tiempos.
3. **Definir bloques:** seleccionar rango de estrofas/columnas y asociar audio o modo de práctica sin audio.
4. **Capturar tiempos:** grabar inicio/fin por celda o bloque con controles grandes; corregir, desplazar y repetir mediciones.
5. **Ensayar:** audio como fuente de verdad; resolver evento activo por búsqueda binaria y emitir una sola transición por evento.
6. **Guiar:** resaltar fila/columna, anticipar la siguiente nota y sincronizar letra/indicaciones.
7. **Revisar:** reproducir, pausar, saltar, repetir bloque y guardar cambios de forma explícita.

## Estado de la rama 3.0 observado antes de esta reconstrucción

- `prepararEventos()` asignaba 500 ms por celda, ignoraba BIS y no usaba el tiempo real del audio.
- El store recorría los eventos en cada frame y disparaba sonidos desde el tick visual.
- El editor solo aceptaba dos cadenas separadas por espacios, sin edición por columna ni captura de tiempos.
- El visor aplicaba scroll horizontal y anchos mínimos fijos.

## Fases de implementación

- [x] Crear un compilador puro de línea de tiempo, con duración por BPM, ajustes manuales y repetición BIS.
- [x] Añadir búsqueda binaria del evento activo.
- [x] Corregir el backend de audio: ahora refresca posición/duración cada 16 ms aunque no reciba comandos (necesario para usar el audio como reloj maestro).
- [ ] Adaptar el store para consultar la posición real del reproductor y separar audio de animación.
- [ ] Reconstruir captura/edición de tiempos y bloques de ensayo.
- [ ] Reconstruir editor de numerofonía por celdas y entrada rápida desde texto/PDF.
- [ ] Rediseñar el visor sin scroll horizontal y con ajuste geométrico.
- [ ] Pruebas de regresión, dispositivos pequeños, pausa/búsqueda/velocidad y audios largos.

## Compatibilidad

Los datos existentes `estrofas[].columnas[].nota7/nota6` y `bis` siguen siendo válidos. Los tiempos manuales nuevos deben guardarse como metadatos versionados y opcionales; no se migran ni sobrescriben documentos antiguos automáticamente.
