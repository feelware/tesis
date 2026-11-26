"use client";

import { type Difficulty, type NoteEvent } from "@/lib/music";
import { playNotes, type PlaybackHandle } from "@/lib/audio/playback";
import type { Activity, GalleryMessage } from "@/lib/game/types";
import { PianoRoll } from "./PianoRoll";

// Un solo MIDI sonando a la vez en toda la aplicación.
let currentPlayback: PlaybackHandle | null = null;

export const playMelodyMidi = (notes: NoteEvent[], tempoBpm: number): void => {
  currentPlayback?.stop();
  currentPlayback = playNotes(notes, tempoBpm);
};

export const stopMelodyMidi = (): void => {
  currentPlayback?.stop();
  currentPlayback = null;
};

export const GRID_BEATS: Record<Difficulty, number> = {
  low: 1,
  medium: 0.5,
  high: 1 / 6,
};

export const ACTIVITY_LABEL: Record<Activity, string> = {
  dictation: "Dictado",
  sight_singing: "Repentización",
};

export const percent = (value: number) => `${Math.round(value * 1000) / 10}%`;

export const rangeFor = (notes: NoteEvent[]) => {
  if (notes.length === 0) {
    return { minPitch: 55, maxPitch: 72, totalBeats: 8 };
  }
  const pitches = notes.map((note) => note.midiPitch);
  const lastNote = notes[notes.length - 1];
  return {
    minPitch: Math.max(36, Math.min(...pitches) - 2),
    maxPitch: Math.min(84, Math.max(...pitches) + 2),
    totalBeats: Math.ceil(lastNote.onsetBeats + lastNote.durationBeats) + 2,
  };
};

export const messageLabel = (message: GalleryMessage): string => {
  if (message.isSystem || message.roundNumber === null) return "original";
  return `ronda ${message.roundNumber} · ${
    message.activity ? ACTIVITY_LABEL[message.activity] : ""
  }`;
};

export interface MelodyPanelProps {
  notes: NoteEvent[];
  gridBeats: number;
  onPlay: () => void;
  onStop: () => void;
  recordingUrl?: string | null;
}

export const MelodyPanel = ({
  notes,
  gridBeats,
  onPlay,
  onStop,
  recordingUrl = null,
}: MelodyPanelProps) => {
  const range = rangeFor(notes);
  return (
    <div className="space-y-2">
      <PianoRoll
        notes={notes}
        minPitch={range.minPitch}
        maxPitch={range.maxPitch}
        totalBeats={range.totalBeats}
        gridBeats={gridBeats}
      />
      {recordingUrl ? (
        <audio
          controls
          preload="none"
          src={recordingUrl}
          className="h-9 w-full max-w-md"
        />
      ) : (
        <div className="flex gap-2">
          <button
            className="rounded border border-zinc-300 px-3 py-1 text-sm hover:bg-zinc-50"
            onClick={onPlay}
          >
            Escuchar melodía
          </button>
          <button
            className="rounded border border-zinc-300 px-3 py-1 text-sm hover:bg-zinc-50"
            onClick={onStop}
          >
            Detener
          </button>
        </div>
      )}
    </div>
  );
};
