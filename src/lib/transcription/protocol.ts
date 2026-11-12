export interface BasicNoteTime {
  startTimeSeconds: number;
  durationSeconds: number;
  pitchMidi: number;
  amplitude: number;
}

export interface TranscriptionRequest {
  id: number;
  audio: Float32Array;
  modelUrl: string;
}

export type TranscriptionResponse =
  | { id: number; type: "progress"; percent: number }
  | { id: number; type: "notes"; notes: BasicNoteTime[] }
  | { id: number; type: "error"; message: string };

export const BASIC_PITCH_MODEL_URL = "/models/basic-pitch/model.json";
