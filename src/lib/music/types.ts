export type Difficulty = "low" | "medium" | "high";

export interface NoteEvent {
  midiPitch: number;
  onsetBeats: number;
  durationBeats: number;
}

export interface Melody {
  id: string;
  tempoBpm: number;
  timeSignature: [number, number];
  key: string;
  scale: string;
  notes: NoteEvent[];
  difficulty: Difficulty;
  generatorVersion: string;
  seed: string;
}

export interface EvaluatedNote {
  midiPitch: number;
  onsetSeconds: number;
  durationSeconds: number;
}
