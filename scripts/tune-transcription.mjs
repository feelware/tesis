import { createRequire } from "node:module";
import { readFileSync } from "node:fs";
import { resolve } from "node:path";
import {
  BasicPitch,
  addPitchBendsToNoteEvents,
  noteFramesToTime,
  outputToNotesPoly,
} from "@spotify/basic-pitch";

const basicPitchRoot = resolve("node_modules/@spotify/basic-pitch");
const requireFromBasicPitch = createRequire(resolve(basicPitchRoot, "cjs/index.js"));
const tf = requireFromBasicPitch("@tensorflow/tfjs");
const modelDir = resolve(basicPitchRoot, "model");

const ioHandler = {
  load: async () => {
    const m = JSON.parse(readFileSync(resolve(modelDir, "model.json"), "utf8"));
    const ws = m.weightsManifest.flatMap((g) => g.weights);
    const wf = m.weightsManifest.flatMap((g) => g.paths);
    const wd = Buffer.concat(wf.map((p) => readFileSync(resolve(modelDir, p))));
    return {
      modelTopology: m.modelTopology,
      weightSpecs: ws,
      weightData: new Uint8Array(wd).buffer,
    };
  },
};

const SR = 22050;
const midiToHz = (midi) => 440 * 2 ** ((midi - 69) / 12);

const makeRng = (seedInit) => {
  let seed = seedInit;
  return () => {
    seed = (seed * 1103515245 + 12345) % 2147483648;
    return seed / 2147483648;
  };
};

const renderVoice = (notes, gain, rng) => {
  const gauss = () => {
    const u = Math.max(rng(), 1e-9);
    return Math.sqrt(-2 * Math.log(u)) * Math.cos(2 * Math.PI * rng());
  };
  const total = notes[notes.length - 1].start + notes[notes.length - 1].dur + 0.45;
  const audio = new Float32Array(Math.ceil(total * SR));
  const harmonics = [
    [1, 0.55],
    [2, 0.28],
    [3, 0.15],
    [4, 0.09],
    [5, 0.05],
  ];
  for (const note of notes) {
    const s = Math.floor(note.start * SR);
    const e = Math.min(audio.length, Math.floor((note.start + note.dur) * SR));
    const hz0 = midiToHz(note.midi);
    let phase = 0;
    const onsetDrift = (rng() - 0.5) * 30;
    for (let i = s; i < e; i += 1) {
      const t = (i - s) / SR;
      const attack = Math.min(1, t / 0.05);
      const release = Math.min(1, (e - i) / SR / 0.08);
      const vib = 18 * Math.sin(2 * Math.PI * 5.1 * t) * Math.min(1, t / 0.2);
      const jitter = 4 * gauss();
      const hz = hz0 * 2 ** ((onsetDrift * Math.exp(-t / 0.08) + vib + jitter) / 1200);
      phase += (2 * Math.PI * hz) / SR;
      let v = 0;
      for (const [mult, g] of harmonics) v += g * Math.sin(mult * phase);
      audio[i] += gain * attack * release * v;
    }
  }
  return audio;
};

const addMicNoise = (audio, profile, rng) => {
  const gauss = () => {
    const u = Math.max(rng(), 1e-9);
    return Math.sqrt(-2 * Math.log(u)) * Math.cos(2 * Math.PI * rng());
  };
  const out = new Float32Array(audio.length);
  let brown = 0;
  for (let i = 0; i < audio.length; i += 1) {
    const t = i / SR;
    brown = (brown + 0.02 * gauss()) / 1.02;
    let v = audio[i];
    if (profile.white) v += profile.white * gauss();
    if (profile.brown) v += profile.brown * brown * 10;
    if (profile.hum) {
      v += profile.hum * Math.sin(2 * Math.PI * 50 * t);
      v += profile.hum * 0.6 * Math.sin(2 * Math.PI * 100 * t);
      v += profile.hum * 0.3 * Math.sin(2 * Math.PI * 150 * t);
    }
    out[i] = Math.max(-1, Math.min(1, v));
  }
  if (profile.breath) {
    const bursts = 6;
    for (let k = 0; k < bursts; k += 1) {
      const start = Math.floor((0.02 + (k * (audio.length / SR - 0.04)) / bursts) * SR);
      const len = Math.floor(0.07 * SR);
      for (let i = 0; i < len && start + i < out.length; i += 1) {
        out[i + start] += profile.breath * Math.exp(-i / SR / 0.018) * gauss();
      }
    }
  }
  return out;
};

const trimLeadingSilence = (audio) => {
  const SILENCE_THRESHOLD = 0.01;
  const LEAD_IN = Math.round(0.05 * SR);
  let firstSound = 0;
  while (firstSound < audio.length && Math.abs(audio[firstSound]) < SILENCE_THRESHOLD) {
    firstSound += 1;
  }
  const startSample = Math.max(0, firstSound - LEAD_IN);
  return { audio: audio.slice(startSample), offsetSeconds: startSample / SR };
};

const MERGE_GAP_SECONDS = 0.08;
const normalizeTranscription = (notes) => {
  const sorted = [...notes].sort(
    (a, b) => a.startTimeSeconds - b.startTimeSeconds || a.pitchMidi - b.pitchMidi,
  );
  const normalized = [];
  for (const note of sorted) {
    const midiPitch = Math.round(note.pitchMidi);
    const onsetSeconds = note.startTimeSeconds;
    const durationSeconds = Math.max(note.durationSeconds, 0.05);
    const previous = normalized[normalized.length - 1];
    if (
      previous &&
      previous.midiPitch === midiPitch &&
      onsetSeconds - (previous.onsetSeconds + previous.durationSeconds) < MERGE_GAP_SECONDS
    ) {
      previous.durationSeconds = Math.max(
        previous.durationSeconds,
        onsetSeconds + durationSeconds - previous.onsetSeconds,
      );
      continue;
    }
    normalized.push({ midiPitch, onsetSeconds, durationSeconds });
  }
  return normalized;
};

const TOLERANCE = { pitchSemitones: 0.5, onsetSeconds: 0.15 };

const matchNotes = (expected, actual) => {
  const used = new Set();
  let matched = 0;
  const spurious = [];
  for (const note of actual) {
    const idx = expected.findIndex(
      (t, i) =>
        !used.has(i) &&
        Math.abs(note.midiPitch - t.midiPitch) <= TOLERANCE.pitchSemitones &&
        Math.abs(note.onsetSeconds - t.onsetSeconds) <= TOLERANCE.onsetSeconds,
    );
    if (idx >= 0) {
      used.add(idx);
      matched += 1;
    } else {
      spurious.push({ midi: note.midiPitch, t: +note.onsetSeconds.toFixed(2) });
    }
  }
  return {
    matched,
    spurious,
    precision: actual.length ? matched / actual.length : 1,
    recall: expected.length ? matched / expected.length : 1,
  };
};

const BEAT = 60 / 90;
const build = (specs) =>
  specs.map((n, i, arr) => ({
    midi: n.midi,
    start: 0.25 + arr.slice(0, i).reduce((s, x) => s + x.beats * BEAT, 0),
    dur: n.beats * BEAT * 0.92,
  }));

const melodies = {
  easy: build([
    { midi: 60, beats: 1 },
    { midi: 62, beats: 1 },
    { midi: 64, beats: 1 },
    { midi: 67, beats: 2 },
    { midi: 64, beats: 1 },
  ]),
  medium: build([
    { midi: 60, beats: 0.5 },
    { midi: 62, beats: 0.5 },
    { midi: 64, beats: 1 },
    { midi: 65, beats: 0.5 },
    { midi: 67, beats: 0.5 },
    { midi: 64, beats: 1 },
    { midi: 62, beats: 1 },
  ]),
  high: build([
    { midi: 72, beats: 0.5 },
    { midi: 74, beats: 0.5 },
    { midi: 76, beats: 1 },
    { midi: 75, beats: 0.5 },
    { midi: 77, beats: 0.5 },
    { midi: 79, beats: 1 },
    { midi: 76, beats: 1 },
  ]),
  longNotes: build([
    { midi: 57, beats: 2 },
    { midi: 60, beats: 2 },
    { midi: 62, beats: 2 },
  ]),
  octaveUp: build([
    { midi: 84, beats: 1 },
    { midi: 86, beats: 1 },
    { midi: 88, beats: 1 },
    { midi: 86, beats: 1 },
    { midi: 84, beats: 1 },
  ]),
};

const noiseProfiles = {
  clean: { gain: 0.3, noise: {} },
  "laptop-mic": { gain: 0.22, noise: { white: 0.012, brown: 0.012, hum: 0.004, breath: 0.12 } },
  "noisy-room": { gain: 0.2, noise: { white: 0.025, brown: 0.03, hum: 0.01, breath: 0.25 } },
  "very-noisy": { gain: 0.18, noise: { white: 0.05, brown: 0.05, hum: 0.02, breath: 0.4 } },
  "quiet-singer": { gain: 0.07, noise: { white: 0.02, brown: 0.02, hum: 0.008, breath: 0.1 } },
};

const basicPitch = new BasicPitch(tf.loadGraphModel(ioHandler));

const infer = async (audio) => {
  const frames = [];
  const onsets = [];
  const contours = [];
  await basicPitch.evaluateModel(
    audio,
    (f, o, c) => {
      frames.push(...f);
      onsets.push(...o);
      contours.push(...c);
    },
    () => {},
  );
  return { frames, onsets, contours };
};

const clone = (a) => a.map((row) => row.slice());

const transcribe = (entry, p) => {
  const notes = noteFramesToTime(
    addPitchBendsToNoteEvents(
      entry.contours,
      outputToNotesPoly(clone(entry.frames), clone(entry.onsets), ...p),
    ),
  ).map((n) => ({
    startTimeSeconds: n.startTimeSeconds,
    durationSeconds: n.durationSeconds,
    pitchMidi: n.pitchMidi,
    amplitude: n.amplitude,
  }));
  return normalizeTranscription(notes);
};

const main = async () => {
  const rng = makeRng(99887766);
  const cases = [];
  console.log("Renderizando e infiriendo (una vez por caso)...\n");
  for (const [melodyName, truth] of Object.entries(melodies)) {
    for (const [profileName, profile] of Object.entries(noiseProfiles)) {
      const rawAudio = addMicNoise(renderVoice(truth, profile.gain, rng), profile.noise, rng);
      const trimmed = trimLeadingSilence(rawAudio);
      cases.push({
        name: `${melodyName}/${profileName}`,
        truth: truth.map((n) => ({
          midiPitch: n.midi,
          onsetSeconds: n.start - trimmed.offsetSeconds,
        })),
        ...(await infer(trimmed.audio)),
      });
      process.stdout.write(".");
    }
  }
  console.log(`\n\n${cases.length} casos\n`);

  const evaluate = (params) => {
    let matched = 0;
    let expected = 0;
    let spurious = 0;
    let detected = 0;
    const bad = [];
    for (const entry of cases) {
      const notes = transcribe(entry, params);
      const result = matchNotes(entry.truth, notes);
      matched += result.matched;
      expected += entry.truth.length;
      spurious += result.spurious.length;
      detected += notes.length;
      if (result.recall < 0.999 || result.spurious.length) {
        bad.push({ name: entry.name, r: result, n: notes.length });
      }
    }
    return {
      recall: matched / expected,
      precision: detected ? matched / detected : 1,
      spurious,
      detected,
      empty: cases.filter((c) => transcribe(c, params).length === 0).length,
      bad,
    };
  };

  const grid = [];
  for (const onset of [0.45, 0.5, 0.55, 0.6]) {
    for (const len of [8, 10, 12, 14, 16]) {
      for (const melodia of [true, false]) {
        for (const minFreq of [75, 90]) {
          grid.push([onset, 0.3, len, true, 1500, minFreq, melodia, 11]);
        }
      }
    }
  }

  const results = grid.map((params) => ({ params, ...evaluate(params) }));
  results.sort(
    (a, b) => b.precision + b.recall - (a.precision + a.recall) || a.spurious - b.spurious,
  );

  console.log("Ranking (recall+precision):\n");
  console.log("onset  len  melodia  minF  | recall  precision  espurias  detectadas");
  for (const r of results.slice(0, 20)) {
    const p = r.params;
    console.log(
      `${p[0].toFixed(2)}  ${String(p[2]).padStart(3)}  ${String(p[6]).padEnd(7)}  ` +
        `${String(p[5]).padStart(4)}  | ${r.recall.toFixed(3)}   ${r.precision.toFixed(3)}     ` +
        `${String(r.spurious).padStart(3)}      ${r.detected}`,
    );
  }

  const best = results[0];
  console.log("\n\nMejor:", JSON.stringify(best.params));
  console.log(
    `recall=${best.recall.toFixed(3)} precision=${best.precision.toFixed(3)} espurias=${best.spurious} detectadas=${best.detected}`,
  );
  if (best.bad.length) {
    console.log("\nCasos imperfectos:");
    for (const b of best.bad) {
      console.log(`  ${b.name.padEnd(22)} n=${b.n} recall=${b.r.recall.toFixed(2)} esp=${JSON.stringify(b.r.spurious)}`);
    }
  } else {
    console.log("Sin casos imperfectos.");
  }

  const compare = [
    ["ORIGINAL", [0.25, 0.25, 5, true, null, null, true, 11]],
    ["USUARIO (invertido)", [0.5, 0.4, 12, true, 80, 1000, true, 11]],
    ["MEJOR", best.params],
  ];
  console.log("\n\n=== Comparación final ===");
  for (const [label, params] of compare) {
    const r = evaluate(params);
    console.log(
      `${label.padEnd(20)} recall=${r.recall.toFixed(3)} precision=${r.precision.toFixed(3)} ` +
        `espurias=${r.spurious} detectadas=${r.detected} casos-vacios=${r.empty}`,
    );
  }
};

await main();
