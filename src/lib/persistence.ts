import type {
  EvaluationResult,
  Melody,
  NoteEvent,
} from "@/lib/music";

export interface SavedRound {
  roundNumber: number;
  activity: "dictation" | "sight_singing";
  melody: Melody;
  response: NoteEvent[];
  evaluation: EvaluationResult | null;
}

export interface SavedSession {
  sessionSeed: string;
  difficulty: string;
  firstActivity: string;
  tempoBpm: number;
  averageScore: number;
  rounds: SavedRound[];
}

const createDocument = async (
  collection: string,
  data: Record<string, unknown>,
): Promise<{ id: string | number }> => {
  const response = await fetch(`/api/${collection}`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(data),
  });
  if (!response.ok) {
    throw new Error(`no se pudo guardar en ${collection}: ${response.status}`);
  }
  const body = (await response.json()) as { doc: { id: string | number } };
  return body.doc;
};

export const saveGameSession = async (session: SavedSession): Promise<void> => {
  const melodies = await Promise.all(
    session.rounds.map((round) =>
      createDocument("melodies", {
        symbolicData: round.melody,
        seed: round.melody.seed,
        difficulty: round.melody.difficulty,
        tempoBpm: round.melody.tempoBpm,
        generatorVersion: round.melody.generatorVersion,
        key: round.melody.key,
        scale: round.melody.scale,
      }),
    ),
  );
  await createDocument("game-sessions", {
    sessionSeed: session.sessionSeed,
    difficulty: session.difficulty,
    firstActivity: session.firstActivity,
    tempoBpm: session.tempoBpm,
    averageScore: session.averageScore,
    rounds: session.rounds.map((round, index) => ({
      roundNumber: round.roundNumber,
      activity: round.activity,
      melody: melodies[index].id,
      response: round.response,
      pitchScore: round.evaluation ? round.evaluation.pitch.f1 : null,
      rhythmScore: round.evaluation ? round.evaluation.rhythm.f1 : null,
      overallScore: round.evaluation ? round.evaluation.overall : null,
    })),
  });
};
