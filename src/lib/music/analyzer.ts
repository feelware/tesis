import type { EvaluatedNote } from "./types";

export interface Score {
  precision: number;
  recall: number;
  f1: number;
}

export interface MatchingResult extends Score {
  matchedPairs: [number, number][];
}

export interface EvaluationTolerances {
  pitchSemitones: number;
  onsetSeconds: number;
}

export interface EvaluationResult {
  pitch: MatchingResult;
  rhythm: MatchingResult;
  overall: number;
}

export const DEFAULT_TOLERANCES: EvaluationTolerances = {
  pitchSemitones: 0.5,
  onsetSeconds: 0.05,
};

const maximumMatching = (compatibility: boolean[][]): [number, number][] => {
  const referenceCount = compatibility.length;
  const estimatedCount = compatibility[0]?.length ?? 0;
  const matchOfEstimated = new Array<number>(estimatedCount).fill(-1);

  const tryAssign = (referenceIndex: number, visited: boolean[]): boolean => {
    for (let estimatedIndex = 0; estimatedIndex < estimatedCount; estimatedIndex += 1) {
      if (!compatibility[referenceIndex][estimatedIndex] || visited[estimatedIndex]) {
        continue;
      }
      visited[estimatedIndex] = true;
      if (
        matchOfEstimated[estimatedIndex] === -1 ||
        tryAssign(matchOfEstimated[estimatedIndex], visited)
      ) {
        matchOfEstimated[estimatedIndex] = referenceIndex;
        return true;
      }
    }
    return false;
  };

  for (let referenceIndex = 0; referenceIndex < referenceCount; referenceIndex += 1) {
    tryAssign(referenceIndex, new Array<boolean>(estimatedCount).fill(false));
  }

  const pairs: [number, number][] = [];
  for (let estimatedIndex = 0; estimatedIndex < estimatedCount; estimatedIndex += 1) {
    if (matchOfEstimated[estimatedIndex] !== -1) {
      pairs.push([matchOfEstimated[estimatedIndex], estimatedIndex]);
    }
  }
  pairs.sort((a, b) => a[0] - b[0]);
  return pairs;
};

const scoreFromMatches = (
  matchedCount: number,
  referenceCount: number,
  estimatedCount: number,
): Score => {
  if (referenceCount === 0 && estimatedCount === 0) {
    return { precision: 1, recall: 1, f1: 1 };
  }
  const precision = estimatedCount === 0 ? 0 : matchedCount / estimatedCount;
  const recall = referenceCount === 0 ? 0 : matchedCount / referenceCount;
  const f1 = precision + recall === 0 ? 0 : (2 * precision * recall) / (precision + recall);
  return { precision, recall, f1 };
};

const evaluateDimension = (
  reference: EvaluatedNote[],
  estimated: EvaluatedNote[],
  compatible: (referenceNote: EvaluatedNote, estimatedNote: EvaluatedNote) => boolean,
): MatchingResult => {
  const compatibility = reference.map((referenceNote) =>
    estimated.map((estimatedNote) => compatible(referenceNote, estimatedNote)),
  );
  const matchedPairs = maximumMatching(compatibility);
  return {
    ...scoreFromMatches(matchedPairs.length, reference.length, estimated.length),
    matchedPairs,
  };
};

export const evaluateSimilarity = (
  reference: EvaluatedNote[],
  estimated: EvaluatedNote[],
  tolerances: EvaluationTolerances = DEFAULT_TOLERANCES,
): EvaluationResult => {
  const pitch = evaluateDimension(
    reference,
    estimated,
    (referenceNote, estimatedNote) =>
      Math.abs(referenceNote.midiPitch - estimatedNote.midiPitch) <=
      tolerances.pitchSemitones,
  );
  const rhythm = evaluateDimension(
    reference,
    estimated,
    (referenceNote, estimatedNote) =>
      Math.abs(referenceNote.onsetSeconds - estimatedNote.onsetSeconds) <=
      tolerances.onsetSeconds,
  );
  return {
    pitch,
    rhythm,
    overall: (pitch.f1 + rhythm.f1) / 2,
  };
};
