import config from "@payload-config";
import { NextResponse, type NextRequest } from "next/server";
import { getPayload, type Payload } from "payload";
import type { GameRoom, Submission, User } from "@payload-types";
import { isAdmin, isProfessor } from "@/lib/user";
import { generateMelody, type Melody, type NoteEvent } from "@/lib/music";
import {
  activityForRound,
  assembleStrands,
  buildNextRoundSubmissions,
  computeLeaderboard,
  evaluateResponse,
  parseGameSettings,
  parseResponseNotes,
  type StrandSubmission,
} from "./rules";
import type {
  Activity,
  GalleryData,
  GameSettings,
  GalleryStrand,
  LeaderboardEntry,
  LeaderboardRound,
  MyRoundRow,
  RoomState,
  RoundState,
  SpectateData,
  SubmissionInfo,
} from "./types";

export class HttpError extends Error {
  status: number;

  constructor(status: number, message: string) {
    super(message);
    this.status = status;
  }
}

export const requireProfessor = (user: User): void => {
  if (!isAdmin(user) && !isProfessor(user)) {
    throw new HttpError(403, "solo docentes y administradores pueden hacer esto");
  }
};

let payloadInstance: Payload | null = null;

export const getServerPayload = async (): Promise<Payload> => {
  payloadInstance ??= await getPayload({ config });
  return payloadInstance;
};

export const errorResponse = (error: unknown): NextResponse => {
  if (error instanceof HttpError) {
    return NextResponse.json({ error: error.message }, { status: error.status });
  }
  console.error(error);
  return NextResponse.json(
    { error: "error interno del servidor" },
    { status: 500 },
  );
};

export const readJson = async (
  request: NextRequest,
): Promise<Record<string, unknown>> => {
  try {
    return (await request.json()) as Record<string, unknown>;
  } catch {
    return {};
  }
};

export const requireUser = async (
  payload: Payload,
  headers: Headers,
): Promise<User> => {
  const { user } = await payload.auth({ headers });
  if (!user) {
    throw new HttpError(401, "debes iniciar sesión");
  }
  return user as User;
};

// Las operaciones que mutan una sala se serializan por sala; se asume un único
// proceso de servidor (prototipo). Un despliegue multi-instancia requeriría un
// candado distribuido.
const roomLocks = new Map<string, Promise<unknown>>();

const withRoomLock = async <T>(
  roomKey: string,
  fn: () => Promise<T>,
): Promise<T> => {
  const previous = roomLocks.get(roomKey) ?? Promise.resolve();
  const run = previous.then(fn, fn);
  roomLocks.set(
    roomKey,
    run.catch(() => undefined),
  );
  return run;
};

const ALPHABET = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";

const generateRoomCode = (): string =>
  Array.from({ length: 6 }, () => {
    const bytes = new Uint8Array(1);
    crypto.getRandomValues(bytes);
    return ALPHABET[bytes[0] % ALPHABET.length];
  }).join("");

export const idOf = (value: number | { id: number | string }): number =>
  typeof value === "object" ? Number(value.id) : Number(value);

const findRoom = async (payload: Payload, roomId: string): Promise<GameRoom> => {
  try {
    return await payload.findByID({
      collection: "game-rooms",
      id: roomId,
      depth: 0,
    });
  } catch {
    throw new HttpError(404, "la sala no existe");
  }
};

export const fetchNames = async (
  payload: Payload,
  ids: number[],
): Promise<Map<number, string>> => {
  const unique = [...new Set(ids)];
  if (unique.length === 0) return new Map();
  const users = await payload.find({
    collection: "users",
    where: { id: { in: unique } },
    pagination: false,
    depth: 0,
  });
  return new Map(
    users.docs.map((doc) => [Number(doc.id), doc.name ?? doc.email]),
  );
};

export const createRoom = async (
  payload: Payload,
  user: User,
): Promise<{ roomId: string; code: string }> => {
  if (isProfessor(user)) {
    throw new HttpError(403, "los docentes no pueden jugar, solo espectar");
  }
  for (let attempt = 0; attempt < 5; attempt += 1) {
    const code = generateRoomCode();
    const existing = await payload.find({
      collection: "game-rooms",
      where: { code: { equals: code } },
      limit: 1,
      depth: 0,
    });
    if (existing.totalDocs > 0) continue;
    const room = await payload.create({
      collection: "game-rooms",
      data: {
        code,
        host: user.id,
        status: "waiting",
        currentRound: 0,
        participants: [{ user: user.id, joinOrder: 0 }],
      },
      depth: 0,
    });
    return { roomId: String(room.id), code };
  }
  throw new HttpError(500, "no se pudo generar un código de sala");
};

export const joinRoom = async (
  payload: Payload,
  user: User,
  codeValue: unknown,
): Promise<{ roomId: string; code: string }> => {
  if (isProfessor(user)) {
    throw new HttpError(403, "los docentes no pueden jugar, solo espectar");
  }
  const code = String(codeValue ?? "").trim().toUpperCase();
  if (!/^[A-Z0-9]{6}$/.test(code)) {
    throw new HttpError(400, "el código debe tener 6 caracteres");
  }
  const found = await payload.find({
    collection: "game-rooms",
    where: { code: { equals: code } },
    limit: 1,
    depth: 0,
  });
  const room = found.docs[0];
  if (!room) {
    throw new HttpError(404, "no existe una sala con ese código");
  }
  await withRoomLock(String(room.id), async () => {
    const current = await findRoom(payload, String(room.id));
    const participants = current.participants ?? [];
    if (participants.some((item) => idOf(item.user) === Number(user.id))) {
      return;
    }
    if (current.status !== "waiting") {
      throw new HttpError(400, "la sala ya no está aceptando jugadores");
    }
    const joinOrder =
      participants.reduce(
        (max, item) => Math.max(max, item.joinOrder ?? 0),
        -1,
      ) + 1;
    await payload.update({
      collection: "game-rooms",
      id: current.id,
      data: {
        participants: [
          ...participants.map((item) => ({
            user: idOf(item.user),
            joinOrder: item.joinOrder,
          })),
          { user: user.id, joinOrder },
        ],
      },
    });
  });
  return { roomId: String(room.id), code: room.code };
};

export const startRoom = async (
  payload: Payload,
  user: User,
  roomId: string,
  settingsValue: unknown,
): Promise<void> => {
  const settings = parseGameSettings(settingsValue);
  await withRoomLock(roomId, async () => {
    const room = await findRoom(payload, roomId);
    if (String(idOf(room.host)) !== String(user.id)) {
      throw new HttpError(403, "solo el anfitrión puede iniciar la partida");
    }
    if (room.status !== "waiting") {
      throw new HttpError(400, "la partida ya fue iniciada");
    }
    const participants = (room.participants ?? [])
      .slice()
      .sort((a, b) => a.joinOrder - b.joinOrder);
    if (participants.length < 2) {
      throw new HttpError(400, "se necesitan al menos 2 jugadores para iniciar");
    }
    const sessionSeed = crypto.randomUUID().slice(0, 8);
    await Promise.all(
      participants.map((participant, index) => {
        const melody = generateMelody({
          difficulty: settings.difficulty,
          seed: `${sessionSeed}-p${index + 1}`,
          tempoBpm: settings.tempoBpm,
        });
        return payload.create({
          collection: "submissions",
          data: {
            room: room.id,
            roundNumber: 1,
            player: idOf(participant.user),
            activity: activityForRound(settings.firstActivity, 1),
            status: "pending",
            receivedMelody: melody as unknown as Record<string, unknown>,
            receivedFrom: null,
            sourceSubmission: null,
          },
        });
      }),
    );
    await payload.update({
      collection: "game-rooms",
      id: room.id,
      data: {
        status: "in_progress",
        currentRound: 1,
        sessionSeed,
        settings,
      },
    });
  });
};

const advanceRound = async (
  payload: Payload,
  room: GameRoom,
): Promise<void> => {
  const settings = parseGameSettings(room.settings);
  const participants = (room.participants ?? [])
    .slice()
    .sort((a, b) => a.joinOrder - b.joinOrder);
  const roundNumber = room.currentRound;
  const submissions = await payload.find({
    collection: "submissions",
    where: {
      room: { equals: room.id },
      roundNumber: { equals: roundNumber },
    },
    pagination: false,
    depth: 0,
  });
  const submissionByPlayer = new Map(
    submissions.docs.map((doc) => [idOf(doc.player), doc]),
  );
  const responsesByPlayerIndex = participants.map((participant) => {
    const submission = submissionByPlayer.get(idOf(participant.user));
    return (submission?.response ?? []) as NoteEvent[];
  });

  if (roundNumber >= settings.roundCount) {
    await payload.update({
      collection: "game-rooms",
      id: room.id,
      data: { status: "finished" },
    });
    return;
  }

  const next = buildNextRoundSubmissions({
    finishedRoundNumber: roundNumber,
    playerCount: participants.length,
    responsesByPlayerIndex,
    tempoBpm: settings.tempoBpm,
    difficulty: settings.difficulty,
    roomSeed: room.sessionSeed ?? room.code,
  });
  await Promise.all(
    next.submissions.map((item) => {
      const sourceSubmission = submissionByPlayer.get(
        idOf(participants[item.sourcePlayerIndex].user),
      );
      return payload.create({
        collection: "submissions",
        data: {
          room: room.id,
          roundNumber: next.roundNumber,
          player: idOf(participants[item.playerIndex].user),
          activity: activityForRound(settings.firstActivity, next.roundNumber),
          status: "pending",
          receivedMelody: item.receivedMelody as unknown as Record<
            string,
            unknown
          >,
          receivedFrom: idOf(participants[item.sourcePlayerIndex].user),
          sourceSubmission: sourceSubmission ? sourceSubmission.id : null,
        },
      });
    }),
  );
  await payload.update({
    collection: "game-rooms",
    id: room.id,
    data: { currentRound: next.roundNumber },
  });
};

export const submitResponse = async (
  payload: Payload,
  user: User,
  roomId: string,
  responseValue: unknown,
  recordingValue: unknown,
): Promise<{ advanced: boolean }> => {
  const notes = parseResponseNotes(responseValue);
  let recordingId: number | null = null;
  if (recordingValue !== undefined && recordingValue !== null) {
    const id = Number(recordingValue);
    if (!Number.isInteger(id) || id <= 0) {
      throw new HttpError(400, "la grabación adjunta no es válida");
    }
    try {
      await payload.findByID({ collection: "media", id, depth: 0 });
    } catch {
      throw new HttpError(400, "la grabación adjunta no existe");
    }
    recordingId = id;
  }
  return withRoomLock(roomId, async () => {
    const room = await findRoom(payload, roomId);
    if (room.status !== "in_progress") {
      throw new HttpError(400, "la partida no está en curso");
    }
    const participants = room.participants ?? [];
    if (!participants.some((item) => idOf(item.user) === Number(user.id))) {
      throw new HttpError(403, "no participas en esta sala");
    }
    const found = await payload.find({
      collection: "submissions",
      where: {
        room: { equals: room.id },
        roundNumber: { equals: room.currentRound },
        player: { equals: user.id },
      },
      limit: 1,
      depth: 0,
    });
    const submission = found.docs[0];
    if (!submission) {
      throw new HttpError(400, "no tienes un ejercicio pendiente en esta ronda");
    }
    if (submission.status !== "pending") {
      throw new HttpError(400, "ya enviaste tu respuesta para esta ronda");
    }
    const evaluation = evaluateResponse({
      receivedMelody: submission.receivedMelody as unknown as Melody,
      response: notes,
      activity: submission.activity as Activity,
    });
    await payload.update({
      collection: "submissions",
      id: submission.id,
      data: {
        response: notes,
        evaluation: evaluation as unknown as Record<string, unknown>,
        status: "done",
        submittedAt: new Date().toISOString(),
        recording:
          submission.activity === "sight_singing" ? recordingId : null,
      },
    });
    const done = await payload.count({
      collection: "submissions",
      where: {
        room: { equals: room.id },
        roundNumber: { equals: room.currentRound },
        status: { equals: "done" },
      },
    });
    if (done.totalDocs < participants.length) {
      return { advanced: false };
    }
    await advanceRound(payload, room);
    return { advanced: true };
  });
};

export const readRoomState = async (
  payload: Payload,
  user: User,
  roomId: string,
): Promise<RoomState> => {
  const room = await findRoom(payload, roomId);
  const participants = (room.participants ?? [])
    .slice()
    .sort((a, b) => a.joinOrder - b.joinOrder);
  const participantIds = participants.map((item) => idOf(item.user));
  if (!participantIds.includes(Number(user.id))) {
    throw new HttpError(403, "no participas en esta sala");
  }
  const hostId = idOf(room.host);

  let round: RoundState | null = null;
  let leaderboard: LeaderboardEntry[] | null = null;
  let receivedFromId: number | null = null;

  if (room.status === "in_progress") {
    const found = await payload.find({
      collection: "submissions",
      where: {
        room: { equals: room.id },
        roundNumber: { equals: room.currentRound },
      },
      pagination: false,
      depth: 0,
    });
    const mySubmission = found.docs.find(
      (doc) => idOf(doc.player) === Number(user.id),
    );
    receivedFromId = mySubmission?.receivedFrom
      ? idOf(mySubmission.receivedFrom)
      : null;
    round = {
      number: room.currentRound,
      activity: activityForRound(
        (room.settings?.firstActivity ?? "dictation") as Activity,
        room.currentRound,
      ),
      submission: mySubmission
        ? {
            id: String(mySubmission.id),
            status: mySubmission.status,
            receivedMelody: mySubmission.receivedMelody as unknown as Melody,
            receivedFromName: null,
            response: (mySubmission.response ?? null) as NoteEvent[] | null,
            evaluation: (mySubmission.evaluation ??
              null) as SubmissionInfo["evaluation"],
          }
        : null,
      players: found.docs.map((doc) => ({
        userId: String(idOf(doc.player)),
        name: "",
        done: doc.status === "done",
      })),
    };
  } else if (room.status === "finished") {
    const found = await payload.find({
      collection: "submissions",
      where: { room: { equals: room.id } },
      pagination: false,
      depth: 0,
    });
    const roundsByPlayer = new Map<number, LeaderboardRound[]>();
    for (const doc of found.docs as Submission[]) {
      const evaluation = (doc.evaluation ?? null) as SubmissionInfo["evaluation"];
      if (!evaluation) continue;
      const playerId = idOf(doc.player);
      const rounds = roundsByPlayer.get(playerId) ?? [];
      rounds.push({
        roundNumber: doc.roundNumber,
        activity: doc.activity,
        overall: evaluation.overall,
        pitch: evaluation.pitch.f1,
        rhythm: evaluation.rhythm.f1,
      });
      roundsByPlayer.set(playerId, rounds);
    }
    leaderboard = computeLeaderboard(
      participants.map((item) => {
        const playerId = idOf(item.user);
        return {
          userId: String(playerId),
          name: "",
          rounds: roundsByPlayer.get(playerId) ?? [],
        };
      }),
    );
  }

  const names = await fetchNames(payload, [
    ...participantIds,
    ...(receivedFromId === null ? [] : [receivedFromId]),
    ...(leaderboard ? leaderboard.map((entry) => Number(entry.userId)) : []),
  ]);
  const nameFor = (id: number | string): string =>
    names.get(Number(id)) ?? `jugador ${id}`;

  const participantsInfo = participants.map((item) => {
    const playerId = idOf(item.user);
    return {
      userId: String(playerId),
      name: nameFor(playerId),
      joinOrder: item.joinOrder,
      isHost: playerId === hostId,
    };
  });

  if (round) {
    round.players = round.players.map((player) => ({
      ...player,
      name: nameFor(player.userId),
    }));
    if (round.submission && receivedFromId !== null) {
      round.submission.receivedFromName = nameFor(receivedFromId);
    }
  }
  if (leaderboard) {
    leaderboard = leaderboard.map((entry) => ({
      ...entry,
      name: nameFor(entry.userId),
    }));
  }

  return {
    room: {
      id: String(room.id),
      code: room.code,
      status: room.status,
      currentRound: room.currentRound,
      settings: room.settings?.roundCount
        ? parseGameSettings(room.settings)
        : null,
      hostUserId: String(hostId),
      participants: participantsInfo,
    },
    me: { userId: String(user.id), name: nameFor(user.id) },
    round,
    leaderboard,
  };
};

const loadStrandSubmissions = async (
  payload: Payload,
  room: GameRoom,
  settings: GameSettings | null,
): Promise<{
  strandSubmissions: StrandSubmission[];
  names: Map<number, string>;
}> => {
  const participants = (room.participants ?? [])
    .slice()
    .sort((a, b) => a.joinOrder - b.joinOrder);
  const found = await payload.find({
    collection: "submissions",
    where: { room: { equals: room.id } },
    pagination: false,
    depth: 0,
  });
  const docs = found.docs as Submission[];
  const names = await fetchNames(
    payload,
    docs.map((doc) => idOf(doc.player)),
  );
  const recordingIds = docs
    .map((doc) => (doc.recording ? idOf(doc.recording) : null))
    .filter((id): id is number => id !== null);
  const media =
    recordingIds.length > 0
      ? await payload.find({
          collection: "media",
          where: { id: { in: recordingIds } },
          pagination: false,
          depth: 0,
        })
      : { docs: [] };
  const urlByMediaId = new Map(
    media.docs.map((doc) => [Number(doc.id), doc.url ?? null]),
  );
  const showRecordings = settings?.showRecordings ?? true;
  const recordingUrlFor = (doc: Submission): string | null => {
    if (!showRecordings) return null;
    if (doc.activity !== "sight_singing" || !doc.recording) return null;
    return urlByMediaId.get(idOf(doc.recording)) ?? null;
  };
  const playerOrder = new Map(
    participants.map((item, index) => [idOf(item.user), index]),
  );
  // En partidas en vivo solo las respuestas enviadas producen melodía; los
  // envíos pendientes solo aportan la melodía recibida (mensaje del sistema).
  const strandSubmissions: StrandSubmission[] = docs
    .filter((doc) => !doc.sourceSubmission || doc.status === "done")
    .map((doc): StrandSubmission => {
      const playerId = idOf(doc.player);
      return {
        id: String(doc.id),
        sourceSubmissionId: doc.sourceSubmission
          ? String(idOf(doc.sourceSubmission))
          : null,
        roundNumber: doc.roundNumber,
        playerId: String(playerId),
        authorName: names.get(playerId) ?? `jugador ${playerId}`,
        activity: doc.activity,
        receivedNotes: (doc.receivedMelody as unknown as Melody).notes,
        responseNotes:
          doc.status === "done" ? ((doc.response ?? []) as NoteEvent[]) : null,
        recordingUrl: recordingUrlFor(doc),
        evaluation: (doc.evaluation ?? null) as SubmissionInfo["evaluation"],
      };
    })
    .sort(
      (a, b) =>
        a.roundNumber - b.roundNumber ||
        (playerOrder.get(Number(a.playerId)) ?? 0) -
          (playerOrder.get(Number(b.playerId)) ?? 0),
    );
  return { strandSubmissions, names };
};

export const readGallery = async (
  payload: Payload,
  user: User,
  roomId: string,
): Promise<GalleryData> => {
  const room = await findRoom(payload, roomId);
  const participants = (room.participants ?? [])
    .slice()
    .sort((a, b) => a.joinOrder - b.joinOrder);
  const participantIds = participants.map((item) => idOf(item.user));
  if (!participantIds.includes(Number(user.id))) {
    throw new HttpError(403, "no participas en esta sala");
  }
  if (room.status !== "finished") {
    throw new HttpError(400, "la partida aún no ha terminado");
  }
  const settings = parseGameSettings(room.settings);
  const { strandSubmissions } = await loadStrandSubmissions(
    payload,
    room,
    settings,
  );
  const strands = assembleStrands(strandSubmissions);
  const myRounds: MyRoundRow[] = strandSubmissions
    .filter((item) => item.playerId === String(user.id))
    .map((item) => ({
      roundNumber: item.roundNumber,
      activity: item.activity,
      receivedNotes: item.receivedNotes,
      producedNotes: item.responseNotes ?? [],
      recordingUrl: item.recordingUrl,
    }));
  return { showRecordings: settings.showRecordings, strands, myRounds };
};

export const readSpectate = async (
  payload: Payload,
  user: User,
  roomId: string,
): Promise<SpectateData> => {
  requireProfessor(user);
  const room = await findRoom(payload, roomId);
  const settings = room.settings?.roundCount
    ? parseGameSettings(room.settings)
    : null;
  const participants = (room.participants ?? [])
    .slice()
    .sort((a, b) => a.joinOrder - b.joinOrder);
  const { strandSubmissions, names } = await loadStrandSubmissions(
    payload,
    room,
    settings,
  );
  const strands: GalleryStrand[] = assembleStrands(strandSubmissions);
  return {
    room: {
      id: String(room.id),
      code: room.code,
      status: room.status,
      currentRound: room.currentRound,
      roundCount: settings?.roundCount ?? 0,
      settings,
    },
    players: participants.map((item) => {
      const playerId = idOf(item.user);
      return {
        userId: String(playerId),
        name: names.get(playerId) ?? `jugador ${playerId}`,
      };
    }),
    strands,
  };
};
