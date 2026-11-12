import type { EvaluatedNote, Melody, NoteEvent } from "./types";

const DIFFICULTIES = ["low", "medium", "high"] as const;

const isFiniteNumber = (value: unknown): value is number =>
  typeof value === "number" && Number.isFinite(value);

const isNoteEvent = (value: unknown): value is NoteEvent => {
  if (typeof value !== "object" || value === null) return false;
  const note = value as Record<string, unknown>;
  return (
    isFiniteNumber(note.midiPitch) &&
    isFiniteNumber(note.onsetBeats) &&
    isFiniteNumber(note.durationBeats)
  );
};

export const validateNote = (note: NoteEvent, index: number): string[] => {
  const errors: string[] = [];
  if (!Number.isInteger(note.midiPitch) || note.midiPitch < 0 || note.midiPitch > 127) {
    errors.push(`nota ${index}: midiPitch debe ser un entero entre 0 y 127`);
  }
  if (note.onsetBeats < 0) {
    errors.push(`nota ${index}: onsetBeats debe ser mayor o igual a 0`);
  }
  if (note.durationBeats <= 0) {
    errors.push(`nota ${index}: durationBeats debe ser mayor que 0`);
  }
  return errors;
};

export const validateMelody = (melody: Melody): string[] => {
  const errors: string[] = [];
  if (typeof melody.id !== "string" || melody.id.trim() === "") {
    errors.push("id no puede estar vacío");
  }
  if (!isFiniteNumber(melody.tempoBpm) || melody.tempoBpm <= 0) {
    errors.push("tempoBpm debe ser mayor que 0");
  }
  const [beatsPerBar, beatUnit] = melody.timeSignature ?? [];
  if (
    !Number.isInteger(beatsPerBar) ||
    beatsPerBar <= 0 ||
    !Number.isInteger(beatUnit) ||
    beatUnit <= 0
  ) {
    errors.push("timeSignature debe contener dos enteros positivos");
  }
  if (!Array.isArray(melody.notes) || melody.notes.length === 0) {
    errors.push("la melodía debe contener al menos una nota");
    return errors;
  }
  melody.notes.forEach((note, index) => {
    errors.push(...validateNote(note, index));
  });
  for (let i = 1; i < melody.notes.length; i += 1) {
    if (melody.notes[i].onsetBeats < melody.notes[i - 1].onsetBeats) {
      errors.push("las notas deben estar ordenadas por onsetBeats");
      break;
    }
  }
  return errors;
};

export const parseMelody = (value: unknown): Melody => {
  if (typeof value !== "object" || value === null) {
    throw new Error("melodía inválida: se esperaba un objeto");
  }
  const candidate = value as Record<string, unknown>;
  if (!Array.isArray(candidate.notes) || !candidate.notes.every(isNoteEvent)) {
    throw new Error("melodía inválida: notes debe ser una lista de eventos de nota");
  }
  if (!Array.isArray(candidate.timeSignature) || candidate.timeSignature.length !== 2) {
    throw new Error("melodía inválida: timeSignature debe ser una tupla [número, número]");
  }
  if (
    typeof candidate.difficulty !== "string" ||
    !DIFFICULTIES.includes(candidate.difficulty as (typeof DIFFICULTIES)[number])
  ) {
    throw new Error("melodía inválida: difficulty debe ser low, medium o high");
  }
  const melody = candidate as unknown as Melody;
  const errors = validateMelody(melody);
  if (errors.length > 0) {
    throw new Error(`melodía inválida: ${errors.join("; ")}`);
  }
  return melody;
};

export const melodyToJson = (melody: Melody): string => JSON.stringify(melody);

export const melodyFromJson = (json: string): Melody => parseMelody(JSON.parse(json));

export const beatsToSeconds = (beats: number, tempoBpm: number): number =>
  (beats * 60) / tempoBpm;

export const melodyToEvaluatedNotes = (melody: Melody): EvaluatedNote[] =>
  melody.notes.map((note) => ({
    midiPitch: note.midiPitch,
    onsetSeconds: beatsToSeconds(note.onsetBeats, melody.tempoBpm),
    durationSeconds: beatsToSeconds(note.durationBeats, melody.tempoBpm),
  }));
