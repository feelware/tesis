import {
  DEFAULT_TOLERANCES,
  beatsToSeconds,
  evaluateSimilarity,
  melodyToEvaluatedNotes,
  transcriptionTolerances,
  validateNote,
  type Difficulty,
  type EvaluatedNote,
  type EvaluationResult,
  type Melody,
  type NoteEvent,
} from "@/lib/music";
import type {
  Activity,
  GameSettings,
  LeaderboardEntry,
  LeaderboardRound,
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
  return {
    difficulty,
    firstActivity,
    roundCount: roundCount as number,
    tempoBpm: tempoBpm as number,
  };
};

export const evaluateResponse = (params: {
  receivedMelody: Melody;
  response: NoteEvent[];
  activity: Activity;
}): EvaluationResult => {
  const tolerances =
    params.activity === "sight_singing"
      ? transcriptionTolerances(params.receivedMelody.difficulty)
      : DEFAULT_TOLERANCES;
  const estimated: EvaluatedNote[] = params.response.map((note) => ({
    midiPitch: note.midiPitch,
    onsetSeconds: beatsToSeconds(note.onsetBeats, params.receivedMelody.tempoBpm),
    durationSeconds: beatsToSeconds(
      note.durationBeats,
      params.receivedMelody.tempoBpm,
    ),
  }));
  return evaluateSimilarity(
    melodyToEvaluatedNotes(params.receivedMelody),
    estimated,
    tolerances,
  );
};

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
