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
