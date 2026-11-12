# Guión breve del prototipo

## Qué es

Una partida individual de un videojuego web para entrenamiento auditivo. El sistema genera melodías con una dificultad configurable y alterna dos ejercicios: **dictado** (escuchar y transcribir) y **repentización** (leer una melodía e interpretarla cantando). Cada respuesta se evalúa automáticamente con dos puntuaciones separadas —precisión de alturas y precisión rítmica— y la transcripción del canto se hace en el navegador con un modelo de audio a MIDI.

## Demo paso a paso

1. **Configurar la partida**: elegir dificultad (baja, media o alta), si se empieza por dictado o repentización, número de rondas y tempo. Cada partida tiene una semilla reproducible, visible en pantalla.
2. **Ronda de dictado**: escuchar la melodía generada y transcribirla colocando notas sobre un piano roll (altura y ataque). Al enviar, aparecen las puntuaciones de alturas y ritmo, y el piano roll señala en verde las notas correctas, en rojo las omitidas y en ámbar las de más.
3. **Ronda de repentización**: leer la melodía en el piano roll, grabar la interpretación con el micrófono, escucharla, enviarla y ver la misma evaluación. La grabación se transcribe con Spotify Basic Pitch dentro de un Web Worker, sin bloquear la interfaz.
4. **Resumen**: tabla con las puntuaciones de cada ronda y el promedio de precisión general; la partida completa (melodías, respuestas y resultados) se guarda en el CMS.

## Qué valida técnicamente

- Generador procedural de melodías por dificultad (intervalos, ambitus, ritmo y modulación), determinista por semilla.
- Evaluador de similitud melódica con matching uno a uno entre notas (alturas y onsets por separado).
- Integración de un modelo de transcripción automática de canto a MIDI.

## Arquitectura del repositorio (muy breve)

- `docs/` — documentos de la tesis (`docs/tesis/tesis.typ`) y este guión.
- `app/(frontend)/` — la página de partida: configuración, ejercicios, evaluación y resumen.
- `app/(payload)/` + `src/collections/` — CMS de Payload (melodías y partidas) sobre PostgreSQL.
- `src/lib/music/` — dominio musical puro: tipos, generador y analizador, con pruebas unitarias.
- `src/lib/transcription/` y `src/lib/audio/` — transcripción con Basic Pitch (Web Worker), reproducción y grabación.

## Cómo ejecutarlo

```bash
docker compose up -d postgres
npm install --include=dev
npm run dev   # http://localhost:3000
```
