import type { EvaluatedNote } from "./types";
import type { EvaluationResult, MatchingResult } from "./analyzer";

export interface ErrorNote {
  // Posición 1-based de la nota dentro de su secuencia (referencia o respuesta).
  position: number;
  midiPitch: number;
}

export interface DimensionErrors {
  missed: ErrorNote[];
  extra: ErrorNote[];
  // Desviación de los pares emparejados: semitonios en altura, milisegundos en
  // ataque. null si no hay ningún par emparejado.
  meanDeviation: number | null;
  maxDeviation: number | null;
}

export interface ErrorReport {
  pitch: DimensionErrors;
  rhythm: DimensionErrors;
}

const round = (value: number, decimals: number): number => {
  const factor = 10 ** decimals;
  return Math.round(value * factor) / factor;
};

const describeDimension = (
  matching: MatchingResult,
  reference: EvaluatedNote[],
  estimated: EvaluatedNote[],
  deviationOf: (referenceNote: EvaluatedNote, estimatedNote: EvaluatedNote) => number,
  decimals: number,
): DimensionErrors => {
  const deviations = matching.matchedPairs.map(([referenceIndex, estimatedIndex]) =>
    deviationOf(reference[referenceIndex], estimated[estimatedIndex]),
  );
  const toErrorNote = (note: EvaluatedNote | undefined, index: number): ErrorNote => ({
    position: index + 1,
    midiPitch: note?.midiPitch ?? 0,
  });
  return {
    missed: matching.missedReferenceIndices.map((index) =>
      toErrorNote(reference[index], index),
    ),
    extra: matching.extraEstimatedIndices.map((index) =>
      toErrorNote(estimated[index], index),
    ),
    meanDeviation:
      deviations.length === 0
        ? null
        : round(
            deviations.reduce((total, value) => total + value, 0) / deviations.length,
            decimals,
          ),
    maxDeviation:
      deviations.length === 0 ? null : round(Math.max(...deviations), decimals),
  };
};

// Localización y magnitud de errores por dimensión (context.md 9.4): qué notas
// de referencia se omitieron, cuáles se añadieron y cuánto se desviaron los
// pares emparejados en altura y en ataque. La magnitud del error es el feedback
// que Kim y Cozzarin (2023) muestran como útil para re-estrategizar.
export const describeEvaluationErrors = (
  evaluation: EvaluationResult,
  reference: EvaluatedNote[],
  estimated: EvaluatedNote[],
): ErrorReport => ({
  pitch: describeDimension(
    evaluation.pitch,
    reference,
    estimated,
    (referenceNote, estimatedNote) =>
      Math.abs(referenceNote.midiPitch - estimatedNote.midiPitch),
    2,
  ),
  rhythm: describeDimension(
    evaluation.rhythm,
    reference,
    estimated,
    (referenceNote, estimatedNote) =>
      Math.abs(referenceNote.onsetSeconds - estimatedNote.onsetSeconds) * 1000,
    1,
  ),
});
