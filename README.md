# Prototipo del videojuego

Prototipo de la tesis: un videojuego web de entrenamiento auditivo con
ejercicios de **dictado** y **repentización** melódica, generación procedural de
melodías, evaluación de similitud melódica (alturas y ritmo por separado) y
transcripción automática de canto a MIDI.

Este prototipo es una partida de un solo jugador, sin usuarios ni salas: una
página de prueba con una partida lista para configurarse y jugar.

## Requisitos

- Node.js 22+
- Docker con Docker Compose (para PostgreSQL)

## Puesta en marcha

```bash
cp .env.example .env   # ajustar secretos y contraseñas
docker compose up -d postgres
npm install
npm run dev            # http://localhost:3000
```

Alternativa con la app contenedizada (como en desarrollo):

```bash
docker compose -f compose.yaml -f compose.dev.yaml up --build
```

El admin de Payload queda en `http://localhost:3000/admin` (crear el primer
usuario con `npm run payload users:create` o desde la interfaz).

## Estructura

- `app/(frontend)/`: interfaz del juego.
- `app/(payload)/`: rutas del admin y API de Payload.
- `src/collections/`: colecciones de Payload.
- `src/lib/music/`: dominio musical independiente de la UI (tipos, generador
  procedural, analizador de similitud) con pruebas unitarias.
- `docs/`: documentos de la tesis (el borrador vive en `docs/tesis/tesis.typ`).

## Pruebas

```bash
npm test
```
