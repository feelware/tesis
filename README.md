# Prototipo del videojuego

Prototipo de la tesis: un videojuego web multijugador de entrenamiento auditivo
con ejercicios de **dictado** y **repentización** melódica, generación procedural
de melodías, evaluación de similitud melódica (alturas y ritmo por separado) y
transcripción automática de canto a MIDI.

El prototipo es multijugador: cuentas de usuario, salas por código y rondas
encadenadas donde la salida de cada jugador es la entrada de otro en la ronda
siguiente (nadie recibe su propia melodía). La evaluación se calcula en el
servidor y la partida avanza cuando todos los jugadores envían su respuesta.

## Requisitos

- Node.js 22+
- Docker con Docker Compose (para PostgreSQL)

## Puesta en marcha

```bash
cp .env.example .env   # ajustar secretos y contraseñas
docker compose -f compose.yaml -f compose.dev.yaml up -d postgres
npm install
npm run dev            # http://localhost:3000
```

`compose.dev.yaml` publica el puerto 5432 de Postgres en el host, necesario para
correr `npm run dev` fuera de Docker. Alternativa con la app contenedizada:

```bash
docker compose -f compose.yaml -f compose.dev.yaml up --build
```

El admin de Payload queda en `http://localhost:3000/admin`.

## Prueba con dos usuarios

1. Abrir `http://localhost:3000` en dos navegadores distintos.
2. Crear una cuenta en cada navegador (correo y contraseña).
3. En uno: "Crear sala" y anotar el código de 6 caracteres.
4. En el otro: "Unirse a una sala" con ese código.
5. El anfitrión configura (dificultad, primera actividad, rondas, tempo) e
   inicia la partida. Las rondas de dictado y repentización se alternan y cada
   jugador recibe en cada ronda la melodía producida por otro jugador en la
   ronda anterior.

## Estructura

- `app/(frontend)/`: interfaz del juego (auth, lobby, sala, rondas, resumen).
- `app/(payload)/`: rutas del admin y API de Payload.
- `app/api/rooms/`: endpoints de juego (crear, unirse, iniciar, enviar, estado).
- `src/collections/`: colecciones de Payload (`Users`, `GameRooms`, `Submissions`).
- `src/lib/music/`: dominio musical independiente de la UI (tipos, generador
  procedural, analizador de similitud) con pruebas unitarias.
- `src/lib/game/`: reglas de juego (asignación encadenada, evaluación,
  leaderboard) con pruebas unitarias, y orquestación de servidor.
- `docs/`: documentos de la tesis (el borrador vive en `docs/tesis/tesis.typ`).

## Pruebas

```bash
npm test
```
