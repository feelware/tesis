import { describe, expect, it } from "vitest";
import { Note, Scale } from "tonal";
import { generateMelody } from "./generator";
import { melodyScaleSegments } from "./melody";
import type { Difficulty } from "./types";

// Evaluación reproducible del generador (capítulo V). Genera 200 melodías por
// nivel con el patrón de semilla `resultado-{dificultad}-###` y calcula las
// métricas reportadas. Imprime el resumen para poder transcribirlo a la tesis.

const SEEDS_PER_LEVEL = 200;
const TEMPO_BPM = 90;
const DIFFICULTIES: Difficulty[] = ["low", "medium", "high"];

const chromasOf = (key: string, scale: string) =>
  new Set(Scale.get(`${key} ${scale}`).notes.map((note) => Note.chroma(note)));

const seedFor = (difficulty: Difficulty, index: number) =>
  `resultado-${difficulty}-${String(index + 1).padStart(3, "0")}`;

interface LevelMetrics {
  generated: number;
  scaleOk: number;
  noTripleRepeat: number;
  requiredFigureOk: number;
  timesMs: number[];
  intervalZero: number;
  intervalSmall: number;
  intervalJump: number;
  intervalTotal: number;
  intervalHist: number[];
  ambitusSum: number;
  ambitusUsedSum: number;
  durationBeatsSum: number;
  modulationCount: number;
  distinctPitchSum: number;
  directionChangeSum: number;
  distinctDurationSum: number;
  pitchSequences: Map<string, number>;
  repeatedNoteMelodies: number;
  maxRepeatStreak: number;
}

const compute = (difficulty: Difficulty): LevelMetrics => {
  const m: LevelMetrics = {
    generated: 0, scaleOk: 0, noTripleRepeat: 0, requiredFigureOk: 0, timesMs: [],
    intervalZero: 0, intervalSmall: 0, intervalJump: 0, intervalTotal: 0, intervalHist: new Array(9).fill(0),
    ambitusSum: 0, ambitusUsedSum: 0, durationBeatsSum: 0, modulationCount: 0,
    distinctPitchSum: 0, directionChangeSum: 0, distinctDurationSum: 0,
    pitchSequences: new Map(), repeatedNoteMelodies: 0, maxRepeatStreak: 0,
  };
  for (let i = 0; i < SEEDS_PER_LEVEL; i += 1) {
    const t0 = performance.now();
    const melody = generateMelody({ difficulty, seed: seedFor(difficulty, i) });
    m.timesMs.push(performance.now() - t0);
    m.generated += 1;

    const pitches = melody.notes.map((n) => n.midiPitch);
    const durations = melody.notes.map((n) => n.durationBeats);

    // Escala activa por segmento.
    const segments = melodyScaleSegments(melody);
    let scaleOk = true;
    for (const segment of segments) {
      const chromas = chromasOf(segment.key, segment.scale);
      for (let k = segment.fromNoteIndex; k <= segment.toNoteIndex; k += 1) {
        const chroma = ((melody.notes[k].midiPitch % 12) + 12) % 12;
        if (!chromas.has(chroma)) scaleOk = false;
      }
    }
    if (scaleOk) m.scaleOk += 1;

    // Sin tres notas iguales seguidas.
    let triple = false;
    for (let k = 2; k < pitches.length; k += 1) {
      if (pitches[k] === pitches[k - 1] && pitches[k] === pitches[k - 2]) triple = true;
    }
    if (!triple) m.noTripleRepeat += 1;

    // Figura rítmica requerida.
    const required = difficulty === "medium" ? [0.5] : difficulty === "high" ? [1.5, 2 / 3] : [];
    if (required.length === 0 || required.some((fig) => durations.some((d) => Math.abs(d - fig) < 1e-9))) {
      m.requiredFigureOk += 1;
    }

    // Intervalos.
    const intervals = pitches.slice(1).map((p, k) => p - pitches[k]);
    for (const interval of intervals) {
      const abs = Math.abs(interval);
      m.intervalTotal += 1;
      m.intervalHist[Math.min(abs, 8)] += 1;
      if (abs === 0) m.intervalZero += 1;
      else if (abs <= 2) m.intervalSmall += 1;
      else if (abs <= 7) m.intervalJump += 1;
    }

    // Ambitus y duración.
    const ambitus = Math.max(...pitches) - Math.min(...pitches);
    m.ambitusSum += ambitus;
    const maxAmbitus = difficulty === "low" ? 12 : difficulty === "medium" ? 19 : 24;
    m.ambitusUsedSum += ambitus / maxAmbitus;
    const beats = durations.reduce((a, b) => a + b, 0);
    m.durationBeatsSum += beats;

    if (melody.modulations.length > 0) m.modulationCount += 1;

    // Variedad.
    m.distinctPitchSum += new Set(pitches).size;
    m.distinctDurationSum += new Set(durations).size;
    let directionChanges = 0;
    for (let k = 1; k < intervals.length; k += 1) {
      const a = intervals[k - 1];
      const b = intervals[k];
      if ((a > 0 && b < 0) || (a < 0 && b > 0)) directionChanges += 1;
    }
    m.directionChangeSum += directionChanges;

    const key = pitches.join(",");
    m.pitchSequences.set(key, (m.pitchSequences.get(key) ?? 0) + 1);

    // Repetición de notas (rachas).
    let streak = 1;
    let hasRepeat = false;
    let maxStreak = 1;
    for (let k = 1; k < pitches.length; k += 1) {
      if (pitches[k] === pitches[k - 1]) {
        streak += 1;
        hasRepeat = true;
        maxStreak = Math.max(maxStreak, streak);
      } else {
        streak = 1;
      }
    }
    if (hasRepeat) m.repeatedNoteMelodies += 1;
    m.maxRepeatStreak = Math.max(m.maxRepeatStreak, maxStreak);
  }
  return m;
};

const mean = (values: number[]) => values.reduce((a, b) => a + b, 0) / values.length;
const pct = (n: number, total: number) => `${((100 * n) / total).toFixed(1)}%`;

describe("evaluación reproducible del generador (capítulo V)", () => {
  it("genera 600 melodías sin fallos y calcula las métricas", () => {
    const results: Record<string, unknown> = {};
    for (const difficulty of DIFFICULTIES) {
      const m = compute(difficulty);
      const unique = [...m.pitchSequences.values()].filter((count) => count === 1).length;
      const sortedTimes = [...m.timesMs].sort((a, b) => a - b);
      results[difficulty] = {
        generated: m.generated,
        escala: pct(m.scaleOk, m.generated),
        sinTripleRepeticion: pct(m.noTripleRepeat, m.generated),
        figuraRequerida: pct(m.requiredFigureOk, m.generated),
        tiempoMedioMs: +mean(m.timesMs).toFixed(2),
        tiempoP95Ms: +sortedTimes[Math.floor(sortedTimes.length * 0.95)].toFixed(2),
        intervalos_cero: pct(m.intervalZero, m.intervalTotal),
        intervalos_hasta2st: pct(m.intervalSmall, m.intervalTotal),
        intervalos_salto3a7: pct(m.intervalJump, m.intervalTotal),
        intervalos_hist: m.intervalHist.map((c) => +((100 * c) / m.intervalTotal).toFixed(1)),
        ambitusMedio: +(m.ambitusSum / m.generated).toFixed(2),
        ambitusUso: pct(Math.round((m.ambitusUsedSum / m.generated) * 100), 100),
        duracionMediaPulsos: +(m.durationBeatsSum / m.generated).toFixed(2),
        duracionMediaSeg: +(((m.durationBeatsSum / m.generated) * 60) / TEMPO_BPM).toFixed(1),
        modulacion: pct(m.modulationCount, m.generated),
        alturasDistintas: +(m.distinctPitchSum / m.generated).toFixed(1),
        cambiosDireccion: +(m.directionChangeSum / m.generated).toFixed(1),
        duracionesDistintas: +(m.distinctDurationSum / m.generated).toFixed(1),
        secuenciasUnicas: pct(unique, m.generated),
        melodiasConNotaRepetida: pct(m.repeatedNoteMelodies, m.generated),
        rachaRepeticionMax: m.maxRepeatStreak,
      };
    }
    console.log("MÉTRICAS DEL GENERADOR (200 semillas por nivel):");
    console.log(JSON.stringify(results, null, 2));
    // Invariantes que deben seguir cumpliéndose.
    for (const difficulty of DIFFICULTIES) {
      const r = results[difficulty] as { generated: number; escala: string; sinTripleRepeticion: string };
      expect(r.generated).toBe(SEEDS_PER_LEVEL);
      expect(r.escala).toBe("100.0%");
      expect(r.sinTripleRepeticion).toBe("100.0%");
    }
  });
});
