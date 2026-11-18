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
    const modelJson = JSON.parse(
      readFileSync(resolve(modelDir, "model.json"), "utf8"),
    );
    const weightSpecs = modelJson.weightsManifest.flatMap((group) => group.weights);
    const weightFiles = modelJson.weightsManifest.flatMap((group) => group.paths);
    const weightData = Buffer.concat(
      weightFiles.map((path) => readFileSync(resolve(modelDir, path))),
    );
    return {
      modelTopology: modelJson.modelTopology,
      weightSpecs,
      weightData: new Uint8Array(weightData).buffer,
    };
  },
};

const sampleRate = 22050;
const durationSeconds = 2;
const frequency = 440;
const audio = new Float32Array(sampleRate * durationSeconds);
for (let i = 0; i < audio.length; i += 1) {
  const t = i / sampleRate;
  const envelope = t < 0.05 ? t / 0.05 : t > 1.8 ? Math.max(0, (2 - t) / 0.2) : 1;
  audio[i] = 0.5 * envelope * Math.sin(2 * Math.PI * frequency * t);
}

const basicPitch = new BasicPitch(tf.loadGraphModel(ioHandler));
const frames = [];
const onsets = [];
const contours = [];
const startedAt = Date.now();
await basicPitch.evaluateModel(
  audio,
  (f, o, c) => {
    frames.push(...f);
    onsets.push(...o);
    contours.push(...c);
  },
  () => {},
);
const notes = noteFramesToTime(
  addPitchBendsToNoteEvents(
    contours,
    outputToNotesPoly(frames, onsets, 0.5, 0.3, 12, true, 1500, 75, true, 11),
  ),
);
console.log(`inferencia en ${Date.now() - startedAt} ms`);
console.log(
  JSON.stringify(
    notes.map((n) => ({
      pitchMidi: Math.round(n.pitchMidi),
      startTimeSeconds: Math.round(n.startTimeSeconds * 100) / 100,
      durationSeconds: Math.round(n.durationSeconds * 100) / 100,
    })),
  ),
);
const detected = notes.map((n) => Math.round(n.pitchMidi));
if (detected.includes(69)) {
  console.log("OK: se detectó la nota La4 (MIDI 69)");
} else {
  console.error(`FALLÓ: notas detectadas ${detected.join(", ") || "(ninguna)"}`);
  process.exit(1);
}
