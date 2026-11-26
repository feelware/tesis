export type {
  Difficulty,
  EvaluatedNote,
  Melody,
  Modulation,
  NoteEvent,
} from "./types";
export {
  beatsToSeconds,
  melodyFromJson,
  melodyScaleSegments,
  melodyToEvaluatedNotes,
  melodyToJson,
  parseMelody,
  validateMelody,
  validateNote,
} from "./melody";
export type { DifficultyRules, GenerateMelodyParams } from "./generator";
export { DIFFICULTY_RULES, GENERATOR_VERSION, generateMelody } from "./generator";
export type {
  EvaluationResult,
  EvaluationTolerances,
  MatchingResult,
  Score,
} from "./analyzer";
export { DEFAULT_TOLERANCES, TRANSCRIPTION_TOLERANCES, evaluateSimilarity, transcriptionTolerances } from "./analyzer";
export type { DimensionErrors, ErrorNote, ErrorReport } from "./error-report";
export { describeEvaluationErrors } from "./error-report";
