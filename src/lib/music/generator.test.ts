import { describe, expect, it } from "vitest";
import { Note, Scale } from "tonal";
import { GENERATOR_VERSION, generateMelody } from "./generator";
import { melodyScaleSegments, validateMelody } from "./melody";
import type { Difficulty } from "./types";

const SEEDS = Array.from({ length: 25 }, (_, index) => `semilla-${index}`);

const SPEC: Record<
  Difficulty,
  {
    noteCount: number;
    maxIntervalSemitones: number;
    ambitusSemitones: number;
    rhythmDurations: number[];
    requiredRhythmFigures: number[];
    modulation: "none" | "optional" | "required";
  }
> = {
  low: {
    noteCount: 8,
    maxIntervalSemitones: 2,
    ambitusSemitones: 12,
    rhythmDurations: [1, 2],
    requiredRhythmFigures: [],
    modulation: "none",
  },
  medium: {
    noteCount: 15,
    maxIntervalSemitones: 5,
    ambitusSemitones: 24,
    rhythmDurations: [0.5, 1, 2],
    requiredRhythmFigures: [0.5],
    modulation: "optional",
  },
  high: {
    noteCount: 24,
    maxIntervalSemitones: 7,
    ambitusSemitones: 36,
    rhythmDurations: [0.5, 1, 1.5, 2, 2 / 3],
    requiredRhythmFigures: [1.5, 2 / 3],
    modulation: "required",
  },
};

const EPSILON = 1e-9;
const closeEnough = (a: number, b: number) => Math.abs(a - b) < EPSILON;

const chromasOf = (key: string, scale: string) =>
  new Set(Scale.get(`${key} ${scale}`).notes.map((note) => Note.chroma(note)));

const difficulties = Object.keys(SPEC) as Difficulty[];

describe.each(difficulties)("generador procedural — dificultad %s", (difficulty) => {
  const spec = SPEC[difficulty];

  it("genera melodías estructuralmente válidas con la versión del generador", () => {
    for (const seed of SEEDS) {
      const melody = generateMelody({ difficulty, seed });
      expect(validateMelody(melody)).toEqual([]);
      expect(melody.generatorVersion).toBe(GENERATOR_VERSION);
      expect(melody.seed).toBe(seed);
    }
  });

  it("produce el número exacto de notas del nivel", () => {
    for (const seed of SEEDS) {
      const melody = generateMelody({ difficulty, seed });
      expect(melody.notes).toHaveLength(spec.noteCount);
    }
  });

  it("respeta el intervalo máximo entre notas consecutivas", () => {
    for (const seed of SEEDS) {
      const melody = generateMelody({ difficulty, seed });
      for (let i = 1; i < melody.notes.length; i += 1) {
        const interval = Math.abs(
          melody.notes[i].midiPitch - melody.notes[i - 1].midiPitch,
        );
        expect(interval).toBeLessThanOrEqual(spec.maxIntervalSemitones);
      }
    }
  });

  it("mantiene la melodía dentro del ambitus del nivel", () => {
    for (const seed of SEEDS) {
      const melody = generateMelody({ difficulty, seed });
      const pitches = melody.notes.map((note) => note.midiPitch);
      const ambitus = Math.max(...pitches) - Math.min(...pitches);
      expect(ambitus).toBeLessThanOrEqual(spec.ambitusSemitones);
    }
  });

  it("usa únicamente notas de la escala activa en cada segmento", () => {
    for (const seed of SEEDS) {
      const melody = generateMelody({ difficulty, seed });
      const segments = melodyScaleSegments(melody);
      for (const segment of segments) {
        const chromas = chromasOf(segment.key, segment.scale);
        for (let i = segment.fromNoteIndex; i <= segment.toNoteIndex; i += 1) {
          const chroma = ((melody.notes[i].midiPitch % 12) + 12) % 12;
          expect(chromas.has(chroma)).toBe(true);
        }
      }
    }
  });

  it("usa solo valores rítmicos permitidos e incluye las figuras requeridas", () => {
    for (const seed of SEEDS) {
      const melody = generateMelody({ difficulty, seed });
      const durations = melody.notes.map((note) => note.durationBeats);
      for (const duration of durations) {
        expect(
          spec.rhythmDurations.some((allowed) => closeEnough(duration, allowed)),
        ).toBe(true);
      }
      if (spec.requiredRhythmFigures.length > 0) {
        expect(
          spec.requiredRhythmFigures.some((figure) =>
            durations.some((duration) => closeEnough(duration, figure)),
          ),
        ).toBe(true);
      }
    }
  });

  it("no produce notas superpuestas ni desordenadas", () => {
    for (const seed of SEEDS) {
      const melody = generateMelody({ difficulty, seed });
      for (let i = 1; i < melody.notes.length; i += 1) {
        const previous = melody.notes[i - 1];
        expect(melody.notes[i].onsetBeats).toBeGreaterThanOrEqual(
          previous.onsetBeats + previous.durationBeats - EPSILON,
        );
      }
    }
  });

  it("cumple las reglas de modulación del nivel", () => {
    for (const seed of SEEDS) {
      const melody = generateMelody({ difficulty, seed });
      if (spec.modulation === "none") {
        expect(melody.modulations).toEqual([]);
      }
      if (spec.modulation === "required") {
        expect(melody.modulations.length).toBeGreaterThanOrEqual(1);
      }
      if (spec.modulation === "optional") {
        expect(melody.modulations.length).toBeLessThanOrEqual(1);
      }
    }
  });
});

describe("reproducibilidad del generador", () => {
  it("produce la misma melodía con la misma semilla", () => {
    const first = generateMelody({ difficulty: "medium", seed: "repetible" });
    const second = generateMelody({ difficulty: "medium", seed: "repetible" });
    expect(second).toEqual(first);
  });

  it("produce melodías distintas con semillas distintas", () => {
    const first = generateMelody({ difficulty: "high", seed: "una" });
    const second = generateMelody({ difficulty: "high", seed: "otra" });
    expect(second.notes).not.toEqual(first.notes);
  });
});
