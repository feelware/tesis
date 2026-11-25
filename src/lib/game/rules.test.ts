import { describe, expect, it } from "vitest";
import type { Melody, NoteEvent } from "@/lib/music";
import {
  activityForRound,
  buildNextRoundSubmissions,
  computeLeaderboard,
  evaluateResponse,
  melodyFromResponse,
  parseGameSettings,
  parseResponseNotes,
  sourceIndexFor,
} from "./rules";

const note = (
  midiPitch: number,
  onsetBeats: number,
  durationBeats = 1,
): NoteEvent => ({ midiPitch, onsetBeats, durationBeats });

const chainMelody = (notes: NoteEvent[]): Melody =>
  melodyFromResponse({
    response: notes,
    roomSeed: "abc123",
    roundNumber: 2,
    sourcePlayerIndex: 0,
    tempoBpm: 90,
    difficulty: "low",
  });

describe("activityForRound", () => {
  it("alterna empezando por dictado", () => {
    expect([1, 2, 3, 4].map((round) => activityForRound("dictation", round))).toEqual([
      "dictation",
      "sight_singing",
      "dictation",
      "sight_singing",
    ]);
  });

  it("alterna empezando por repentización", () => {
    expect(
      [1, 2, 3, 4].map((round) => activityForRound("sight_singing", round)),
    ).toEqual([
      "sight_singing",
      "dictation",
      "sight_singing",
      "dictation",
    ]);
  });
});

describe("sourceIndexFor", () => {
  it("con dos jugadores cada uno recibe al otro", () => {
    expect(sourceIndexFor(0, 2)).toBe(1);
    expect(sourceIndexFor(1, 2)).toBe(0);
  });

  it("rota hacia atrás con tres o más jugadores", () => {
    expect(sourceIndexFor(0, 3)).toBe(2);
    expect(sourceIndexFor(1, 3)).toBe(0);
    expect(sourceIndexFor(2, 3)).toBe(1);
  });

  it("nunca devuelve al propio jugador", () => {
    for (let playerCount = 2; playerCount <= 8; playerCount += 1) {
      for (let playerIndex = 0; playerIndex < playerCount; playerIndex += 1) {
        expect(sourceIndexFor(playerIndex, playerCount)).not.toBe(playerIndex);
      }
    }
  });
});

describe("melodyFromResponse", () => {
  it("conserva las notas y el tempo de la respuesta", () => {
    const notes = [note(60, 0), note(62, 1)];
    const melody = chainMelody(notes);
    expect(melody.notes).toEqual(notes);
    expect(melody.tempoBpm).toBe(90);
    expect(melody.difficulty).toBe("low");
    expect(melody.modulations).toEqual([]);
  });

  it("identifica la ronda y el jugador de origen", () => {
    const melody = melodyFromResponse({
      response: [note(60, 0)],
      roomSeed: "abc123",
      roundNumber: 3,
      sourcePlayerIndex: 1,
      tempoBpm: 90,
      difficulty: "medium",
    });
    expect(melody.id).toBe("abc123-r3-p2");
  });
});

describe("buildNextRoundSubmissions", () => {
  it("cada jugador recibe la respuesta del jugador anterior en la rotación", () => {
    const responses = [[note(60, 0)], [note(64, 0)], [note(67, 0)]];
    const { roundNumber, submissions } = buildNextRoundSubmissions({
      finishedRoundNumber: 1,
      playerCount: 3,
      responsesByPlayerIndex: responses,
      tempoBpm: 90,
      difficulty: "low",
      roomSeed: "abc123",
    });
    expect(roundNumber).toBe(2);
    expect(submissions).toHaveLength(3);
    expect(submissions[0].receivedMelody.notes).toEqual(responses[2]);
    expect(submissions[1].receivedMelody.notes).toEqual(responses[0]);
    expect(submissions[2].receivedMelody.notes).toEqual(responses[1]);
    expect(submissions.map((item) => item.sourcePlayerIndex)).toEqual([2, 0, 1]);
    for (const submission of submissions) {
      expect(submission.playerIndex).not.toBe(submission.sourcePlayerIndex);
    }
  });

  it("con dos jugadores la salida de cada uno es la entrada del otro", () => {
    const responses = [[note(60, 0), note(62, 1)], [note(70, 0)]];
    const { submissions } = buildNextRoundSubmissions({
      finishedRoundNumber: 2,
      playerCount: 2,
      responsesByPlayerIndex: responses,
      tempoBpm: 100,
      difficulty: "medium",
      roomSeed: "abc123",
    });
    expect(submissions[0].receivedMelody.notes).toEqual(responses[1]);
    expect(submissions[1].receivedMelody.notes).toEqual(responses[0]);
    expect(submissions[0].receivedMelody.id).toBe("abc123-r3-p2");
  });
});

describe("parseResponseNotes", () => {
  it("acepta notas válidas y las ordena por ataque", () => {
    const notes = parseResponseNotes([
      note(62, 1),
      note(60, 0),
      note(64, 2),
    ]);
    expect(notes.map((item) => item.onsetBeats)).toEqual([0, 1, 2]);
  });

  it("rechaza listas vacías y valores que no son listas", () => {
    expect(() => parseResponseNotes([])).toThrow(/al menos una nota/);
    expect(() => parseResponseNotes("nota")).toThrow(/lista de notas/);
    expect(() => parseResponseNotes(null)).toThrow(/lista de notas/);
  });

  it("rechaza notas inválidas", () => {
    expect(() => parseResponseNotes([note(200, 0)])).toThrow(/midiPitch/);
    expect(() => parseResponseNotes([note(60, -1)])).toThrow(/onsetBeats/);
    expect(() => parseResponseNotes([note(60, 0, 0)])).toThrow(
      /durationBeats/,
    );
    expect(() =>
      parseResponseNotes([{ midiPitch: 60, onsetBeats: 0 }]),
    ).toThrow(/números finitos/);
    expect(() => parseResponseNotes([null])).toThrow(/objeto/);
    expect(() =>
      parseResponseNotes([
        { midiPitch: 60, onsetBeats: Number.NaN, durationBeats: 1 },
      ]),
    ).toThrow(/números finitos/);
  });

  it("rechaza respuestas con demasiadas notas", () => {
    const tooMany = Array.from({ length: 201 }, (_, index) =>
      note(60, index),
    );
    expect(() => parseResponseNotes(tooMany)).toThrow(/200 notas/);
  });
});

describe("parseGameSettings", () => {
  it("acepta una configuración válida", () => {
    expect(
      parseGameSettings({
        difficulty: "medium",
        firstActivity: "sight_singing",
        roundCount: 4,
        tempoBpm: 90,
      }),
    ).toEqual({
      difficulty: "medium",
      firstActivity: "sight_singing",
      roundCount: 4,
      tempoBpm: 90,
    });
  });

  it("rechaza valores fuera de rango", () => {
    const base = {
      difficulty: "low",
      firstActivity: "dictation",
      roundCount: 4,
      tempoBpm: 90,
    };
    expect(() =>
      parseGameSettings({ ...base, difficulty: "impossible" }),
    ).toThrow(/dificultad/);
    expect(() =>
      parseGameSettings({ ...base, firstActivity: "other" }),
    ).toThrow(/primera actividad/);
    expect(() => parseGameSettings({ ...base, roundCount: 1 })).toThrow(
      /rondas/,
    );
    expect(() => parseGameSettings({ ...base, roundCount: 9 })).toThrow(
      /rondas/,
    );
    expect(() => parseGameSettings({ ...base, tempoBpm: 50 })).toThrow(
      /tempo/,
    );
    expect(() => parseGameSettings({ ...base, tempoBpm: 130 })).toThrow(
      /tempo/,
    );
  });
});

describe("evaluateResponse", () => {
  it("una respuesta idéntica a la referencia puntúa 1", () => {
    const notes = [note(60, 0), note(62, 1), note(64, 2)];
    const evaluation = evaluateResponse({
      receivedMelody: chainMelody(notes),
      response: notes,
      activity: "dictation",
    });
    expect(evaluation.pitch.f1).toBe(1);
    expect(evaluation.rhythm.f1).toBe(1);
    expect(evaluation.overall).toBe(1);
  });

  it("una respuesta distinta puntúa menos de 1", () => {
    const evaluation = evaluateResponse({
      receivedMelody: chainMelody([note(60, 0), note(62, 1)]),
      response: [note(60, 0), note(72, 1)],
      activity: "sight_singing",
    });
    expect(evaluation.pitch.f1).toBeLessThan(1);
    expect(evaluation.rhythm.f1).toBe(1);
  });
});

describe("computeLeaderboard", () => {
  it("promedia las rondas y ordena por precisión general", () => {
    const leaderboard = computeLeaderboard([
      {
        userId: "a",
        name: "Ana",
        rounds: [
          { roundNumber: 2, activity: "sight_singing", overall: 0.4, pitch: 0.5, rhythm: 0.3 },
          { roundNumber: 1, activity: "dictation", overall: 0.6, pitch: 0.6, rhythm: 0.6 },
        ],
      },
      {
        userId: "b",
        name: "Beto",
        rounds: [
          { roundNumber: 1, activity: "dictation", overall: 1, pitch: 1, rhythm: 1 },
          { roundNumber: 2, activity: "sight_singing", overall: 0.8, pitch: 0.8, rhythm: 0.8 },
        ],
      },
    ]);
    expect(leaderboard.map((entry) => entry.userId)).toEqual(["b", "a"]);
    expect(leaderboard[0].overall).toBeCloseTo(0.9);
    expect(leaderboard[1].overall).toBeCloseTo(0.5);
    expect(leaderboard[1].rounds.map((round) => round.roundNumber)).toEqual([
      1, 2,
    ]);
  });

  it("sin rondas el promedio es 0", () => {
    const leaderboard = computeLeaderboard([
      { userId: "a", name: "Ana", rounds: [] },
    ]);
    expect(leaderboard[0].overall).toBe(0);
  });
});
