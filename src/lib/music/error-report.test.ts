import { describe, expect, it } from "vitest";
import type { EvaluatedNote } from "./types";
import { evaluateSimilarity } from "./analyzer";
import { describeEvaluationErrors } from "./error-report";

const note = (
  midiPitch: number,
  onsetSeconds: number,
  durationSeconds = 1,
): EvaluatedNote => ({ midiPitch, onsetSeconds, durationSeconds });

const reportFor = (
  reference: EvaluatedNote[],
  estimated: EvaluatedNote[],
) => describeEvaluationErrors(evaluateSimilarity(reference, estimated), reference, estimated);

describe("describeEvaluationErrors", () => {
  it("sin errores: sin omitidas ni adicionales y desviación cero", () => {
    const report = reportFor([note(60, 0), note(62, 1)], [note(60, 0), note(62, 1)]);
    expect(report.pitch.missed).toEqual([]);
    expect(report.pitch.extra).toEqual([]);
    expect(report.pitch.meanDeviation).toBe(0);
    expect(report.rhythm.meanDeviation).toBe(0);
  });

  it("localiza notas omitidas y adicionales con su posición", () => {
    const report = reportFor(
      [note(60, 0), note(62, 1), note(64, 2)],
      [note(60, 0), note(71, 1), note(64, 2)],
    );
    // 62 y 71 no coinciden en altura: la referencia se omite y la respuesta sobra.
    expect(report.pitch.missed).toEqual([{ position: 2, midiPitch: 62 }]);
    expect(report.pitch.extra).toEqual([{ position: 2, midiPitch: 71 }]);
    // En ritmo las tres coinciden.
    expect(report.rhythm.missed).toEqual([]);
    expect(report.rhythm.extra).toEqual([]);
  });

  it("mide la magnitud del desvío de ataque en milisegundos", () => {
    const report = reportFor(
      [note(60, 0), note(62, 1)],
      [note(60, 0), note(62, 1.03)],
    );
    expect(report.rhythm.meanDeviation).toBe(15);
    expect(report.rhythm.maxDeviation).toBe(30);
    expect(report.pitch.meanDeviation).toBe(0);
  });

  it("reporta la desviación de octava cuando la evaluación es tolerante a octava", () => {
    const report = describeEvaluationErrors(
      evaluateSimilarity([note(60, 0)], [note(72, 0)], {
        pitchSemitones: 0.5,
        onsetSeconds: 0.15,
        octaveTolerant: true,
      }),
      [note(60, 0)],
      [note(72, 0)],
    );
    expect(report.pitch.missed).toEqual([]);
    expect(report.pitch.meanDeviation).toBe(12);
  });

  it("devuelve null sin pares emparejados", () => {
    const report = reportFor([note(60, 0)], [note(72, 5)]);
    expect(report.pitch.meanDeviation).toBeNull();
    expect(report.rhythm.maxDeviation).toBeNull();
  });
});
