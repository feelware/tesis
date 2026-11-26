import {
  DEFAULT_TOLERANCES,
  beatsToSeconds,
  describeEvaluationErrors,
  evaluateSimilarity,
  melodyToEvaluatedNotes,
  transcriptionTolerances,
  validateNote,
  type Difficulty,
  type ErrorReport,
  type EvaluatedNote,
  type EvaluationResult,
  type Melody,
  type NoteEvent,
} from "@/lib/music";
import type {
  Activity,
  GalleryStrand,
  GameSettings,
  LeaderboardEntry,
  LeaderboardRound,
  MetricKey,
  PlayerScore,
  SortOrder,
} from "./types";

const MAX_RESPONSE_NOTES = 200;

const isFiniteNumber = (value: unknown): value is number =>
  typeof value === "number" && Number.isFinite(value);

export const activityForRound = (
  firstActivity: Activity,
  roundNumber: number,
): Activity => {
  const other: Activity =
    firstActivity === "dictation" ? "sight_singing" : "dictation";
  return roundNumber % 2 === 1 ? firstActivity : other;
};

// La salida del jugador j pasa al jugador (j + 1) % N; así cada jugador
// recibe siempre la producción de otro y nunca la suya propia.
export const sourceIndexFor = (
  playerIndex: number,
  playerCount: number,
): number => (playerIndex - 1 + playerCount) % playerCount;

export const melodyFromResponse = (params: {
  response: NoteEvent[];
  roomSeed: string;
  roundNumber: number;
  sourcePlayerIndex: number;
  tempoBpm: number;
  difficulty: Difficulty;
}): Melody => {
  const chainId = `${params.roomSeed}-r${params.roundNumber}-p${params.sourcePlayerIndex + 1}`;
  return {
    id: chainId,
    tempoBpm: params.tempoBpm,
    timeSignature: [4, 4],
    key: "",
    scale: "",
    notes: params.response,
    modulations: [],
    difficulty: params.difficulty,
    generatorVersion: "chain-v1",
    seed: chainId,
  };
};

export interface NextSubmission {
  playerIndex: number;
  sourcePlayerIndex: number;
  receivedMelody: Melody;
}

export const buildNextRoundSubmissions = (params: {
  finishedRoundNumber: number;
  playerCount: number;
  responsesByPlayerIndex: NoteEvent[][];
  tempoBpm: number;
  difficulty: Difficulty;
  roomSeed: string;
}): { roundNumber: number; submissions: NextSubmission[] } => {
  const roundNumber = params.finishedRoundNumber + 1;
  const submissions = params.responsesByPlayerIndex.map(
    (_, playerIndex): NextSubmission => {
      const sourcePlayerIndex = sourceIndexFor(playerIndex, params.playerCount);
      return {
        playerIndex,
        sourcePlayerIndex,
        receivedMelody: melodyFromResponse({
          response: params.responsesByPlayerIndex[sourcePlayerIndex],
          roomSeed: params.roomSeed,
          roundNumber,
          sourcePlayerIndex,
          tempoBpm: params.tempoBpm,
          difficulty: params.difficulty,
        }),
      };
    },
  );
  return { roundNumber, submissions };
};

export const parseResponseNotes = (value: unknown): NoteEvent[] => {
  if (!Array.isArray(value)) {
    throw new Error("la respuesta debe ser una lista de notas");
  }
  if (value.length === 0) {
    throw new Error("la respuesta debe contener al menos una nota");
  }
  if (value.length > MAX_RESPONSE_NOTES) {
    throw new Error(
      `la respuesta no puede exceder ${MAX_RESPONSE_NOTES} notas`,
    );
  }
  const errors: string[] = [];
  value.forEach((entry, index) => {
    if (typeof entry !== "object" || entry === null) {
      errors.push(`nota ${index}: debe ser un objeto`);
      return;
    }
    const note = entry as Record<string, unknown>;
    if (
      !isFiniteNumber(note.midiPitch) ||
      !isFiniteNumber(note.onsetBeats) ||
      !isFiniteNumber(note.durationBeats)
    ) {
      errors.push(
        `nota ${index}: midiPitch, onsetBeats y durationBeats deben ser números finitos`,
      );
      return;
    }
    errors.push(...validateNote(entry as NoteEvent, index));
  });
  if (errors.length > 0) {
    throw new Error(errors.join("; "));
  }
  return (value as NoteEvent[])
    .slice()
    .sort((a, b) => a.onsetBeats - b.onsetBeats);
};

export const parseGameSettings = (value: unknown): GameSettings => {
  const candidate = (value ?? {}) as Record<string, unknown>;
  const { difficulty, firstActivity, roundCount, tempoBpm } = candidate;
  const showRecordings = candidate.showRecordings ?? true;
  if (
    difficulty !== "low" &&
    difficulty !== "medium" &&
    difficulty !== "high"
  ) {
    throw new Error("la dificultad debe ser low, medium o high");
  }
  if (firstActivity !== "dictation" && firstActivity !== "sight_singing") {
    throw new Error("la primera actividad debe ser dictation o sight_singing");
  }
  if (
    !Number.isInteger(roundCount) ||
    (roundCount as number) < 2 ||
    (roundCount as number) > 8
  ) {
    throw new Error("el número de rondas debe estar entre 2 y 8");
  }
  if (
    !Number.isInteger(tempoBpm) ||
    (tempoBpm as number) < 60 ||
    (tempoBpm as number) > 120
  ) {
    throw new Error("el tempo debe estar entre 60 y 120 BPM");
  }
  if (typeof showRecordings !== "boolean") {
    throw new Error("showRecordings debe ser verdadero o falso");
  }
  return {
    difficulty,
    firstActivity,
    roundCount: roundCount as number,
    tempoBpm: tempoBpm as number,
    showRecordings,
  };
};

const toEvaluatedNotes = (
  notes: NoteEvent[],
  tempoBpm: number,
): EvaluatedNote[] =>
  notes.map((note) => ({
    midiPitch: note.midiPitch,
    onsetSeconds: beatsToSeconds(note.onsetBeats, tempoBpm),
    durationSeconds: beatsToSeconds(note.durationBeats, tempoBpm),
  }));

export const evaluateResponse = (params: {
  receivedMelody: Melody;
  response: NoteEvent[];
  activity: Activity;
}): EvaluationResult => {
  const tolerances =
    params.activity === "sight_singing"
      ? transcriptionTolerances(params.receivedMelody.difficulty)
      : DEFAULT_TOLERANCES;
  return evaluateSimilarity(
    melodyToEvaluatedNotes(params.receivedMelody),
    toEvaluatedNotes(params.response, params.receivedMelody.tempoBpm),
    tolerances,
  );
};

// Localización y magnitud de errores de una respuesta ya evaluada, derivadas
// de la misma evaluación persistida (pares emparejados, notas omitidas y
// adicionales). No recalcula la evaluación: solo la describe para el feedback.
export const errorReportFor = (params: {
  receivedNotes: NoteEvent[];
  responseNotes: NoteEvent[];
  tempoBpm: number;
  evaluation: EvaluationResult;
}): ErrorReport =>
  describeEvaluationErrors(
    params.evaluation,
    toEvaluatedNotes(params.receivedNotes, params.tempoBpm),
    toEvaluatedNotes(params.responseNotes, params.tempoBpm),
  );

const mean = (values: number[]): number =>
  values.length === 0
    ? 0
    : values.reduce((total, value) => total + value, 0) / values.length;

export const computeLeaderboard = (
  players: { userId: string; name: string; rounds: LeaderboardRound[] }[],
): LeaderboardEntry[] =>
  players
    .map((player) => ({
      userId: player.userId,
      name: player.name,
      rounds: player.rounds
        .slice()
        .sort((a, b) => a.roundNumber - b.roundNumber),
      overall: mean(player.rounds.map((round) => round.overall)),
      pitch: mean(player.rounds.map((round) => round.pitch)),
      rhythm: mean(player.rounds.map((round) => round.rhythm)),
    }))
    .sort((a, b) => b.overall - a.overall);

export interface StrandSubmission {
  id: string;
  sourceSubmissionId: string | null;
  roundNumber: number;
  playerId: string;
  authorName: string;
  activity: Activity;
  tempoBpm: number;
  receivedNotes: NoteEvent[];
  responseNotes: NoteEvent[] | null;
  recordingUrl: string | null;
  evaluation: EvaluationResult | null;
}

// Reconstruye el "viaje" de cada melodía inicial: la versión original del
// sistema seguida de la producción de cada ronda, siguiendo la cadena
// sourceSubmission. El orden de las cadenas respeta el orden de los envíos.
export const assembleStrands = (
  submissions: StrandSubmission[],
): GalleryStrand[] => {
  const childBySource = new Map<string, StrandSubmission>();
  for (const submission of submissions) {
    if (submission.sourceSubmissionId !== null) {
      childBySource.set(submission.sourceSubmissionId, submission);
    }
  }
  return submissions
    .filter((submission) => submission.sourceSubmissionId === null)
    .map((head) => {
      const chain: StrandSubmission[] = [];
      let current: StrandSubmission | undefined = head;
      while (current) {
        chain.push(current);
        current = childBySource.get(current.id);
      }
      return {
        messages: [
          {
            authorName: "Sistema",
            authorUserId: null,
            isSystem: true,
            roundNumber: null,
            activity: null,
            notes: head.receivedNotes,
            recordingUrl: null,
            evaluation: null,
            errorReport: null,
          },
          ...chain.flatMap((item) =>
            item.responseNotes === null
              ? []
              : [
                  {
                    authorName: item.authorName,
                    authorUserId: item.playerId,
                    isSystem: false,
                    roundNumber: item.roundNumber,
                    activity: item.activity,
                    notes: item.responseNotes,
                    recordingUrl: item.recordingUrl,
                    evaluation: item.evaluation,
                    errorReport:
                      item.evaluation === null
                        ? null
                        : errorReportFor({
                            receivedNotes: item.receivedNotes,
                            responseNotes: item.responseNotes,
                            tempoBpm: item.tempoBpm,
                            evaluation: item.evaluation,
                          }),
                  },
                ],
          ),
        ],
      };
    });
};

export const scoreAverages = (
  evaluations: (EvaluationResult | null)[],
): { pitch: number; rhythm: number; overall: number } => {
  const valid = evaluations.filter(
    (evaluation): evaluation is EvaluationResult => evaluation !== null,
  );
  return {
    pitch: mean(valid.map((evaluation) => evaluation.pitch.f1)),
    rhythm: mean(valid.map((evaluation) => evaluation.rhythm.f1)),
    overall: mean(valid.map((evaluation) => evaluation.overall)),
  };
};

// Puntaje que representa a una partida al ordenarla: el del estudiante
// filtrado, o el promedio de los estudiantes del salón participantes.
export const gameSortScore = (
  participants: PlayerScore[],
  studentId: string | null,
  metric: MetricKey,
): number => {
  if (studentId !== null) {
    const filtered = participants.find(
      (participant) => participant.userId === studentId,
    );
    return filtered ? filtered[metric] : 0;
  }
  return mean(participants.map((participant) => participant[metric]));
};

export const sortScores = <T>(
  items: T[],
  metric: keyof T,
  order: SortOrder,
): T[] =>
  items.slice().sort((a, b) => {
    const left = Number(a[metric]);
    const right = Number(b[metric]);
    return order === "asc" ? left - right : right - left;
  });
