import { describe, expect, it } from "vitest";
import { trackMonophonic, DSP_PARAMS } from "./dsp-tracker";

const SR = 22050;
const midiToFreq = (midi: number) => 440 * 2 ** ((midi - 69) / 12);

type SynthNote = { midi: number; onset: number; dur: number; vibrato?: number };

// Sintetiza una melodía monofónica (senos con envolvente) a partir de notas conocidas.
const synth = (notes: SynthNote[]): Float32Array => {
  const total = Math.ceil((notes.reduce((m, n) => Math.max(m, n.onset + n.dur), 0) + 0.3) * SR);
  const out = new Float32Array(total);
  for (const note of notes) {
    const freq = midiToFreq(note.midi);
    const start = Math.floor(note.onset * SR);
    const len = Math.floor(note.dur * SR);
    const attack = Math.floor(0.01 * SR);
    const release = Math.floor(0.03 * SR);
    for (let i = 0; i < len; i += 1) {
      const t = i / SR;
      const vibPhase = note.vibrato
        ? note.vibrato * Math.sin(2 * Math.PI * 5.5 * t)
        : 0;
      let env = 1;
      if (i < attack) env = i / attack;
      else if (i > len - release) env = Math.max(0, (len - i) / release);
      out[start + i] += 0.5 * env * Math.sin(2 * Math.PI * freq * t + vibPhase);
    }
  }
  return out;
};

// Empareja notas detectadas con las esperadas por cercanía de onset.
const match = (
  detected: { pitchMidi: number; startTimeSeconds: number }[],
  expected: SynthNote[],
) => {
  let pitchOk = 0;
  let onsetOk = 0;
  for (const exp of expected) {
    const best = detected.reduce(
      (acc, d) => {
        const dist = Math.abs(d.startTimeSeconds - exp.onset);
        return dist < acc.dist ? { dist, d } : acc;
      },
      { dist: Infinity, d: undefined as undefined | (typeof detected)[number] },
    );
    if (!best.d || best.dist > 0.15) continue;
    onsetOk += 1;
    if (Math.abs(best.d.pitchMidi - exp.midi) <= 1) pitchOk += 1;
  }
  return { pitchOk, onsetOk };
};

describe("trackMonophonic (tracker DSP)", () => {
  it("transcribe una secuencia de notas distintas con pitch y onset correctos", () => {
    const notes: SynthNote[] = [
      { midi: 60, onset: 0.0, dur: 0.5 },
      { midi: 62, onset: 0.5, dur: 0.5 },
      { midi: 64, onset: 1.0, dur: 0.5 },
      { midi: 67, onset: 1.5, dur: 0.5 },
    ];
    const audio = synth(notes);
    const detected = trackMonophonic(audio, SR);
    expect(detected.length).toBeGreaterThanOrEqual(3);
    const { pitchOk, onsetOk } = match(detected, notes);
    expect(onsetOk).toBeGreaterThanOrEqual(3);
    expect(pitchOk).toBeGreaterThanOrEqual(3);
  });

  it("detecta notas repetidas separadas por onsets", () => {
    const notes: SynthNote[] = [
      { midi: 64, onset: 0.0, dur: 0.35 },
      { midi: 64, onset: 0.5, dur: 0.35 },
      { midi: 64, onset: 1.0, dur: 0.35 },
    ];
    const audio = synth(notes);
    const detected = trackMonophonic(audio, SR);
    expect(detected.length).toBeGreaterThanOrEqual(2);
  });

  it("mantiene el pitch con vibrato moderado", () => {
    const notes: SynthNote[] = [
      { midi: 60, onset: 0.0, dur: 0.6, vibrato: 1.0 },
      { midi: 65, onset: 0.6, dur: 0.6, vibrato: 1.0 },
      { midi: 67, onset: 1.2, dur: 0.6, vibrato: 1.0 },
    ];
    const audio = synth(notes);
    const detected = trackMonophonic(audio, SR);
    const { pitchOk } = match(detected, notes);
    expect(pitchOk).toBeGreaterThanOrEqual(2);
  });

  it("respeta el rango de frecuencia configurado (75–1500 Hz)", () => {
    expect(DSP_PARAMS.minFreq).toBe(75);
    expect(DSP_PARAMS.maxFreq).toBe(1500);
    expect(DSP_PARAMS.minFreq).toBeLessThan(DSP_PARAMS.maxFreq);
  });

  it("es rápido (no bloquea): transcribe ~2 s de audio en menos de 3 s", () => {
    const notes: SynthNote[] = Array.from({ length: 12 }, (_, i) => ({
      midi: 60 + (i % 7),
      onset: i * 0.35,
      dur: 0.32,
    }));
    const audio = synth(notes);
    const t0 = performance.now();
    trackMonophonic(audio, SR);
    const elapsed = performance.now() - t0;
    expect(elapsed).toBeLessThan(3000);
  });
});
