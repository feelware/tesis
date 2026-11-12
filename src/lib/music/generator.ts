import { Note, Scale } from "tonal";
import type { Difficulty, Melody, Modulation, NoteEvent } from "./types";
import { validateMelody } from "./melody";

export const GENERATOR_VERSION = "0.1.0";

export interface DifficultyRules {
  maxIntervalSemitones: number;
  ambitusSemitones: number;
  noteCount: number;
  rhythmDurations: number[];
  rhythmWeights: number[];
  requiredRhythmFigures: number[];
  modulation: "none" | "optional" | "required";
}

export const DIFFICULTY_RULES: Record<Difficulty, DifficultyRules> = {
  low: {
    maxIntervalSemitones: 2,
    ambitusSemitones: 12,
    noteCount: 8,
    rhythmDurations: [1, 2],
    rhythmWeights: [3, 1],
    requiredRhythmFigures: [],
    modulation: "none",
  },
  medium: {
    maxIntervalSemitones: 5,
    ambitusSemitones: 24,
    noteCount: 15,
    rhythmDurations: [0.5, 1, 2],
    rhythmWeights: [2, 4, 1],
    requiredRhythmFigures: [0.5],
    modulation: "optional",
  },
  high: {
    maxIntervalSemitones: 7,
    ambitusSemitones: 36,
    noteCount: 24,
    rhythmDurations: [0.5, 1, 1.5, 2, 2 / 3],
    rhythmWeights: [3, 3, 2, 1, 2],
    requiredRhythmFigures: [1.5, 2 / 3],
    modulation: "required",
  },
};

export interface GenerateMelodyParams {
  difficulty: Difficulty;
  seed: string;
  tempoBpm?: number;
  timeSignature?: [number, number];
}

const DEFAULT_TEMPO_BPM = 90;
const DEFAULT_TIME_SIGNATURE: [number, number] = [4, 4];
const TONIC_MIDI = 60;
const KEY_POOL = ["C", "G", "D", "A", "F", "Bb", "Eb"];
const KEY_NAMES = ["C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab", "A", "Bb", "B"];
const EPSILON = 1e-9;
const MAX_GENERATION_ATTEMPTS = 50;

type Rng = () => number;

const hashString = (value: string): number => {
  let hash = 1779033703 ^ value.length;
  for (let i = 0; i < value.length; i += 1) {
    hash = Math.imul(hash ^ value.charCodeAt(i), 3432918353);
    hash = (hash << 13) | (hash >>> 19);
  }
  return hash >>> 0;
};

const createRng = (seed: number): Rng => {
  let state = seed >>> 0;
  return () => {
    state = (state + 0x6d2b79f5) >>> 0;
    let t = state;
    t = Math.imul(t ^ (t >>> 15), t | 1);
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
};

const pick = <T>(rng: Rng, items: readonly T[]): T =>
  items[Math.floor(rng() * items.length)];

const weightedPick = <T>(rng: Rng, items: readonly T[], weights: readonly number[]): T => {
  const total = weights.reduce((sum, weight) => sum + weight, 0);
  let threshold = rng() * total;
  for (let i = 0; i < items.length; i += 1) {
    threshold -= weights[i];
    if (threshold <= 0) return items[i];
  }
  return items[items.length - 1];
};

const closeEnough = (a: number, b: number): boolean => Math.abs(a - b) < EPSILON;

const keyNameFromChroma = (chroma: number): string =>
  KEY_NAMES[((chroma % 12) + 12) % 12];

const chromaSetOf = (key: string, scale: string): Set<number> =>
  new Set(Scale.get(`${key} ${scale}`).notes.map((note) => Note.chroma(note)));

const relativeKeyOf = (key: string, scale: string): [string, string] =>
  scale === "major"
    ? [keyNameFromChroma(Note.chroma(key) + 9), "minor"]
    : [keyNameFromChroma(Note.chroma(key) + 3), "major"];

const dominantKeyOf = (key: string, scale: string): [string, string] => [
  keyNameFromChroma(Note.chroma(key) + 7),
  scale,
];

const subdominantKeyOf = (key: string, scale: string): [string, string] => [
  keyNameFromChroma(Note.chroma(key) + 5),
  scale,
];

interface Segment {
  fromNoteIndex: number;
  key: string;
  scale: string;
  tonicChroma: number;
  chromas: Set<number>;
}

const segmentAt = (segments: Segment[], noteIndex: number): Segment => {
  for (let i = segments.length - 1; i >= 0; i -= 1) {
    if (noteIndex >= segments[i].fromNoteIndex) return segments[i];
  }
  return segments[0];
};

const planModulations = (
  rng: Rng,
  key: string,
  scale: string,
  rules: DifficultyRules,
): Modulation[] => {
  const pivot = Math.floor(rules.noteCount / 2);
  if (rules.modulation === "none") return [];
  if (rules.modulation === "optional" && rng() >= 0.5) return [];
  const [nextKey, nextScale] =
    rules.modulation === "optional"
      ? relativeKeyOf(key, scale)
      : pick(rng, [dominantKeyOf, subdominantKeyOf])(key, scale);
  return [{ atNoteIndex: pivot, key: nextKey, scale: nextScale }];
};

const buildSegments = (
  key: string,
  scale: string,
  modulations: Modulation[],
): Segment[] => {
  const boundaries = [
    { atNoteIndex: 0, key, scale },
    ...modulations.map((modulation) => ({
      atNoteIndex: modulation.atNoteIndex,
      key: modulation.key,
      scale: modulation.scale,
    })),
  ];
  return boundaries.map((boundary) => ({
    fromNoteIndex: boundary.atNoteIndex,
    key: boundary.key,
    scale: boundary.scale,
    tonicChroma: Note.chroma(boundary.key),
    chromas: chromaSetOf(boundary.key, boundary.scale),
  }));
};

const pitchesInWindow = (segment: Segment, windowMin: number, windowMax: number): number[] => {
  const pitches: number[] = [];
  for (let midi = windowMin; midi <= windowMax; midi += 1) {
    if (segment.chromas.has(Note.chroma(Note.fromMidi(midi)))) pitches.push(midi);
  }
  return pitches;
};

const generatePitches = (
  rng: Rng,
  rules: DifficultyRules,
  segments: Segment[],
  windowMin: number,
  windowMax: number,
): number[] => {
  const pitches: number[] = [];
  const intervals: number[] = [];
  for (let index = 0; index < rules.noteCount; index += 1) {
    const segment = segmentAt(segments, index);
    const candidates = pitchesInWindow(segment, windowMin, windowMax);
    const prev = pitches[index - 1];
    const prevPrev = pitches[index - 2];
    const lastInterval = intervals[intervals.length - 1];
    const secondLastInterval = intervals[intervals.length - 2];
    const withinReach = (pitch: number) =>
      index === 0 ? Math.abs(pitch - TONIC_MIDI) <= 3 : Math.abs(pitch - prev) <= rules.maxIntervalSemitones;
    const avoidsRepetition = (pitch: number) =>
      !(pitch === prev && prev === prevPrev) &&
      !(intervals.length >= 2 && pitch - prev === lastInterval && lastInterval === secondLastInterval);
    let pool = candidates.filter((pitch) => withinReach(pitch) && avoidsRepetition(pitch));
    if (pool.length === 0) pool = candidates.filter(withinReach);
    if (pool.length === 0) pool = candidates;
    const weights = pool.map((pitch) => {
      const distance = index === 0 ? Math.abs(pitch - TONIC_MIDI) : Math.abs(pitch - prev);
      const stepWeight = 1 / (1 + distance * distance);
      return ((pitch % 12) + 12) % 12 === segment.tonicChroma ? stepWeight * 1.5 : stepWeight;
    });
    const chosen = weightedPick(rng, pool, weights);
    pitches.push(chosen);
    if (index > 0) intervals.push(chosen - prev);
  }
  return pitches;
};

const generateRhythm = (rng: Rng, rules: DifficultyRules): number[] => {
  const durations = Array.from({ length: rules.noteCount }, () =>
    weightedPick(rng, rules.rhythmDurations, rules.rhythmWeights),
  );
  const missingFigures = rules.requiredRhythmFigures.filter(
    (figure) => !durations.some((duration) => closeEnough(duration, figure)),
  );
  if (missingFigures.length > 0) {
    durations[Math.floor(rng() * durations.length)] = pick(rng, missingFigures);
  }
  return durations;
};

const buildNotes = (pitches: number[], durations: number[]): NoteEvent[] => {
  let onsetBeats = 0;
  return pitches.map((midiPitch, index) => {
    const note: NoteEvent = {
      midiPitch,
      onsetBeats,
      durationBeats: durations[index],
    };
    onsetBeats += durations[index];
    return note;
  });
};

const findViolations = (melody: Melody, rules: DifficultyRules): string[] => {
  const violations: string[] = [];
  const windowSpan = rules.ambitusSemitones;
  const windowMin = TONIC_MIDI - Math.floor(windowSpan / 2);
  const windowMax = TONIC_MIDI + Math.ceil(windowSpan / 2);
  if (melody.notes.length !== rules.noteCount) violations.push("cantidad de notas");
  const pitches = melody.notes.map((note) => note.midiPitch);
  if (Math.max(...pitches) - Math.min(...pitches) > windowSpan) violations.push("ambitus");
  if (pitches.some((pitch) => pitch < windowMin || pitch > windowMax)) {
    violations.push("registro fuera de ventana");
  }
  for (let i = 1; i < pitches.length; i += 1) {
    if (Math.abs(pitches[i] - pitches[i - 1]) > rules.maxIntervalSemitones) {
      violations.push("intervalo máximo");
      break;
    }
  }
  const segments = buildSegments(melody.key, melody.scale, melody.modulations);
  for (let i = 0; i < melody.notes.length; i += 1) {
    const segment = segmentAt(segments, i);
    const chroma = ((melody.notes[i].midiPitch % 12) + 12) % 12;
    if (!segment.chromas.has(chroma)) {
      violations.push("escala");
      break;
    }
  }
  const durations = melody.notes.map((note) => note.durationBeats);
  if (durations.some((duration) => !rules.rhythmDurations.some((allowed) => closeEnough(duration, allowed)))) {
    violations.push("valores rítmicos");
  }
  if (
    rules.requiredRhythmFigures.length > 0 &&
    !rules.requiredRhythmFigures.some((figure) => durations.some((duration) => closeEnough(duration, figure)))
  ) {
    violations.push("figura rítmica requerida");
  }
  for (let i = 1; i < melody.notes.length; i += 1) {
    const previous = melody.notes[i - 1];
    if (melody.notes[i].onsetBeats < previous.onsetBeats + previous.durationBeats - EPSILON) {
      violations.push("notas superpuestas");
      break;
    }
  }
  if (validateMelody(melody).length > 0) violations.push("validación estructural");
  return violations;
};

export const generateMelody = (params: GenerateMelodyParams): Melody => {
  const rules = DIFFICULTY_RULES[params.difficulty];
  const tempoBpm = params.tempoBpm ?? DEFAULT_TEMPO_BPM;
  const timeSignature = params.timeSignature ?? DEFAULT_TIME_SIGNATURE;
  const windowMin = TONIC_MIDI - Math.floor(rules.ambitusSemitones / 2);
  const windowMax = TONIC_MIDI + Math.ceil(rules.ambitusSemitones / 2);

  for (let attempt = 0; attempt < MAX_GENERATION_ATTEMPTS; attempt += 1) {
    const rng = createRng(
      hashString(
        `${params.seed}|${params.difficulty}|${tempoBpm}|${timeSignature.join("/")}#${attempt}`,
      ),
    );
    const key = pick(rng, KEY_POOL);
    const scale = pick(rng, ["major", "minor"] as const);
    const modulations = planModulations(rng, key, scale, rules);
    const segments = buildSegments(key, scale, modulations);
    const pitches = generatePitches(rng, rules, segments, windowMin, windowMax);
    const durations = generateRhythm(rng, rules);
    const melody: Melody = {
      id: `mel-${hashString(`${params.seed}|${params.difficulty}|${tempoBpm}|${timeSignature.join("/")}`).toString(16)}`,
      tempoBpm,
      timeSignature,
      key,
      scale,
      notes: buildNotes(pitches, durations),
      modulations,
      difficulty: params.difficulty,
      generatorVersion: GENERATOR_VERSION,
      seed: params.seed,
    };
    if (findViolations(melody, rules).length === 0) return melody;
  }
  throw new Error("no fue posible generar una melodía que cumpla las restricciones");
};
