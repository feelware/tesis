import { describe, expect, it } from "vitest";
import {
  DEFAULT_TOLERANCES,
  evaluateSimilarity,
  transcriptionTolerances,
} from "./analyzer";
import type { EvaluatedNote } from "./types";

const note = (
  midiPitch: number,
  onsetSeconds: number,
  durationSeconds = 0.5,
): EvaluatedNote => ({ midiPitch, onsetSeconds, durationSeconds });

describe("analizador de similitud", () => {
  it("puntúa 1 en ambas dimensiones con secuencias idénticas", () => {
    const reference = [note(60, 0), note(62, 0.5), note(64, 1), note(65, 1.5)];
    const result = evaluateSimilarity(reference, reference);
    expect(result.pitch).toMatchObject({ precision: 1, recall: 1, f1: 1 });
    expect(result.rhythm).toMatchObject({ precision: 1, recall: 1, f1: 1 });
    expect(result.overall).toBe(1);
  });

  it("penaliza en recall una nota omitida", () => {
    const reference = [note(60, 0), note(62, 0.5), note(64, 1), note(65, 1.5)];
    const estimated = [note(60, 0), note(62, 0.5), note(64, 1)];
    const result = evaluateSimilarity(reference, estimated);
    expect(result.pitch.precision).toBe(1);
    expect(result.pitch.recall).toBeCloseTo(3 / 4, 10);
    expect(result.pitch.f1).toBeCloseTo(6 / 7, 10);
    expect(result.rhythm.f1).toBeCloseTo(6 / 7, 10);
    expect(result.overall).toBeCloseTo(6 / 7, 10);
  });

  it("penaliza en precision una nota adicional", () => {
    const reference = [note(60, 0), note(62, 0.5), note(64, 1)];
    const estimated = [note(60, 0), note(62, 0.5), note(64, 1), note(67, 1.5)];
    const result = evaluateSimilarity(reference, estimated);
    expect(result.pitch.precision).toBeCloseTo(3 / 4, 10);
    expect(result.pitch.recall).toBe(1);
    expect(result.rhythm.precision).toBeCloseTo(3 / 4, 10);
    expect(result.rhythm.recall).toBe(1);
  });

  it("castiga una altura equivocada solo en la dimensión de alturas", () => {
    const reference = [note(60, 0), note(62, 0.5), note(64, 1)];
    const estimated = [note(60, 0), note(63, 0.5), note(64, 1)];
    const result = evaluateSimilarity(reference, estimated);
    expect(result.pitch.precision).toBeCloseTo(2 / 3, 10);
    expect(result.pitch.recall).toBeCloseTo(2 / 3, 10);
    expect(result.pitch.f1).toBeCloseTo(2 / 3, 10);
    expect(result.rhythm.f1).toBe(1);
  });

  it("acepta un ataque desplazado dentro de la tolerancia", () => {
    const reference = [note(60, 0), note(62, 0.5)];
    const estimated = [
      note(60, DEFAULT_TOLERANCES.onsetSeconds - 0.001),
      note(62, 0.5 + DEFAULT_TOLERANCES.onsetSeconds - 0.001),
    ];
    const result = evaluateSimilarity(reference, estimated);
    expect(result.rhythm.f1).toBe(1);
  });

  it("castiga un ataque desplazado más allá de la tolerancia solo en ritmo", () => {
    const reference = [note(60, 0), note(62, 0.5)];
    const estimated = [note(60, 0), note(62, 0.5 + DEFAULT_TOLERANCES.onsetSeconds + 0.01)];
    const result = evaluateSimilarity(reference, estimated);
    expect(result.pitch.f1).toBe(1);
    expect(result.rhythm.precision).toBeCloseTo(1 / 2, 10);
    expect(result.rhythm.recall).toBeCloseTo(1 / 2, 10);
  });

  it("empareja cada nota como máximo una vez con notas duplicadas", () => {
    const reference = [note(60, 0)];
    const estimated = [note(60, 0), note(60, 0)];
    const result = evaluateSimilarity(reference, estimated);
    expect(result.pitch.matchedPairs).toHaveLength(1);
    expect(result.pitch.precision).toBeCloseTo(1 / 2, 10);
    expect(result.pitch.recall).toBe(1);
  });

  it("no depende del orden de las notas", () => {
    const reference = [note(60, 0), note(62, 0.5), note(64, 1)];
    const estimated = [note(64, 1), note(60, 0), note(62, 0.5)];
    const result = evaluateSimilarity(reference, estimated);
    expect(result.overall).toBe(1);
  });

  it("resuelve empates de forma uno a uno cuando una nota satisface varias", () => {
    const reference = [note(60, 0), note(60, 0.02)];
    const estimated = [note(60, 0.01)];
    const result = evaluateSimilarity(reference, estimated);
    expect(result.rhythm.matchedPairs).toHaveLength(1);
    expect(result.rhythm.precision).toBe(1);
    expect(result.rhythm.recall).toBeCloseTo(1 / 2, 10);
    expect(result.pitch.precision).toBe(1);
    expect(result.pitch.recall).toBeCloseTo(1 / 2, 10);
  });

  it("devuelve cero sin NaN cuando la respuesta está vacía", () => {
    const result = evaluateSimilarity([note(60, 0), note(62, 0.5)], []);
    expect(result.pitch).toMatchObject({ precision: 0, recall: 0, f1: 0 });
    expect(result.rhythm).toMatchObject({ precision: 0, recall: 0, f1: 0 });
    expect(result.overall).toBe(0);
  });

  it("devuelve cero cuando no hay ninguna coincidencia", () => {
    const reference = [note(60, 0), note(62, 0.5)];
    const estimated = [note(72, 10), note(74, 10.5)];
    const result = evaluateSimilarity(reference, estimated);
    expect(result.pitch.f1).toBe(0);
    expect(result.rhythm.f1).toBe(0);
    expect(result.overall).toBe(0);
  });

  it("considera perfecta la comparación de dos secuencias vacías", () => {
    const result = evaluateSimilarity([], []);
    expect(result.pitch.f1).toBe(1);
    expect(result.rhythm.f1).toBe(1);
    expect(result.overall).toBe(1);
  });

  it("permite ajustar las tolerancias de altura y ataque", () => {
    const reference = [note(60, 0)];
    const estimated = [note(61, 0.2)];
    const strict = evaluateSimilarity(reference, estimated, {
      pitchSemitones: 0.5,
      onsetSeconds: 0.05,
    });
    const lenient = evaluateSimilarity(reference, estimated, {
      pitchSemitones: 1,
      onsetSeconds: 0.25,
    });
    expect(strict.overall).toBe(0);
    expect(lenient.overall).toBe(1);
  });

  describe("tolerancia de octava", () => {
    it("acepta la melodía cantada una octava arriba", () => {
      const reference = [note(60, 0), note(62, 0.5), note(64, 1)];
      const estimated = [note(72, 0), note(74, 0.5), note(76, 1)];
      const result = evaluateSimilarity(reference, estimated, {
        ...DEFAULT_TOLERANCES,
        octaveTolerant: true,
      });
      expect(result.pitch.f1).toBe(1);
      expect(result.rhythm.f1).toBe(1);
      expect(result.overall).toBe(1);
    });

    it("acepta la melodía cantada una octava abajo", () => {
      const reference = [note(60, 0), note(62, 0.5)];
      const estimated = [note(48, 0), note(50, 0.5)];
      const result = evaluateSimilarity(reference, estimated, {
        ...DEFAULT_TOLERANCES,
        octaveTolerant: true,
      });
      expect(result.pitch.f1).toBe(1);
    });

    it("sigue castigando un error que no es de octava", () => {
      const reference = [note(60, 0)];
      const estimated = [note(67, 0)];
      const result = evaluateSimilarity(reference, estimated, {
        ...DEFAULT_TOLERANCES,
        octaveTolerant: true,
      });
      expect(result.pitch.f1).toBe(0);
    });

    it("no altera la dimensión rítmica", () => {
      const reference = [note(60, 0)];
      const estimated = [note(72, DEFAULT_TOLERANCES.onsetSeconds + 0.01)];
      const result = evaluateSimilarity(reference, estimated, {
        ...DEFAULT_TOLERANCES,
        octaveTolerant: true,
      });
      expect(result.pitch.f1).toBe(1);
      expect(result.rhythm.f1).toBe(0);
    });

    it("queda desactivada por defecto", () => {
      const reference = [note(60, 0)];
      const estimated = [note(72, 0)];
      const result = evaluateSimilarity(reference, estimated);
      expect(result.pitch.f1).toBe(0);
    });

    it("se aplica a la repentización de dificultad fácil y no a las demás", () => {
      expect(transcriptionTolerances("low").octaveTolerant).toBe(true);
      expect(transcriptionTolerances("medium").octaveTolerant).toBeUndefined();
      expect(transcriptionTolerances("high").octaveTolerant).toBeUndefined();
    });

    it("conserva las tolerancias de transcripción en todas las dificultades", () => {
      for (const difficulty of ["low", "medium", "high"] as const) {
        expect(transcriptionTolerances(difficulty)).toMatchObject({
          pitchSemitones: 0.5,
          onsetSeconds: 0.15,
        });
      }
    });
  });
});
