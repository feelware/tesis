import type { BasicNoteTime } from "./protocol";
import type { EvaluatedNote } from "@/lib/music";

const TARGET_SAMPLE_RATE = 22050;
const MERGE_GAP_SECONDS = 0.08;

export const resampleToMono = async (
  audioBuffer: AudioBuffer,
): Promise<Float32Array> => {
  const length = Math.ceil(audioBuffer.duration * TARGET_SAMPLE_RATE);
  const context = new OfflineAudioContext(1, length, TARGET_SAMPLE_RATE);
  const source = context.createBufferSource();
  source.buffer = audioBuffer;
  source.connect(context.destination);
  source.start();
  const rendered = await context.startRendering();
  return rendered.getChannelData(0);
};

export const normalizeTranscription = (
  notes: BasicNoteTime[],
): EvaluatedNote[] => {
  const sorted = [...notes].sort(
    (a, b) =>
      a.startTimeSeconds - b.startTimeSeconds || a.pitchMidi - b.pitchMidi,
  );
  const normalized: EvaluatedNote[] = [];
  for (const note of sorted) {
    const midiPitch = Math.round(note.pitchMidi);
    const onsetSeconds = note.startTimeSeconds;
    const durationSeconds = Math.max(note.durationSeconds, 0.05);
    const previous = normalized[normalized.length - 1];
    if (
      previous &&
      previous.midiPitch === midiPitch &&
      onsetSeconds - (previous.onsetSeconds + previous.durationSeconds) <
        MERGE_GAP_SECONDS
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
