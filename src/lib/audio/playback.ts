import { Midi } from "tonal";
import type { NoteEvent } from "@/lib/music";

export interface PlaybackHandle {
  stop: () => void;
  finished: Promise<void>;
}

export const playNotes = (
  notes: NoteEvent[],
  tempoBpm: number,
  onBeat?: (beat: number) => void,
): PlaybackHandle => {
  const context = new AudioContext();
  const secondsPerBeat = 60 / tempoBpm;
  const startAt = context.currentTime + 0.15;
  const oscillators: OscillatorNode[] = [];
  let stopped = false;

  for (const note of notes) {
    const oscillator = context.createOscillator();
    const gain = context.createGain();
    oscillator.type = "triangle";
    oscillator.frequency.value = Midi.midiToFreq(note.midiPitch);
    const noteStart = startAt + note.onsetBeats * secondsPerBeat;
    const noteEnd = noteStart + note.durationBeats * secondsPerBeat;
    gain.gain.setValueAtTime(0.0001, noteStart);
    gain.gain.linearRampToValueAtTime(0.22, noteStart + 0.01);
    gain.gain.exponentialRampToValueAtTime(0.0001, noteEnd);
    oscillator.connect(gain);
    gain.connect(context.destination);
    oscillator.start(noteStart);
    oscillator.stop(noteEnd + 0.05);
    oscillators.push(oscillator);
  }

  const lastNote = notes[notes.length - 1];
  const totalBeats = lastNote
    ? lastNote.onsetBeats + lastNote.durationBeats
    : 0;
  const totalMs = Math.max((totalBeats * secondsPerBeat + 0.3) * 1000, 300);

  let animationFrame = 0;
  const reportBeat = () => {
    if (stopped) return;
    const beat = (context.currentTime - startAt) / secondsPerBeat;
    onBeat?.(Math.max(0, beat));
    animationFrame = requestAnimationFrame(reportBeat);
  };
  animationFrame = requestAnimationFrame(reportBeat);

  const finished = new Promise<void>((resolve) => {
    setTimeout(() => {
      stopped = true;
      cancelAnimationFrame(animationFrame);
      void context.close();
      onBeat?.(totalBeats);
      resolve();
    }, totalMs);
  });

  return {
    stop: () => {
      if (stopped) return;
      stopped = true;
      cancelAnimationFrame(animationFrame);
      for (const oscillator of oscillators) {
        oscillator.stop();
      }
      void context.close();
      onBeat?.(0);
    },
    finished,
  };
};
