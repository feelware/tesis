"use client";

import { useRef, useState } from "react";
import {
  beatsToSeconds,
  evaluateSimilarity,
  melodyToEvaluatedNotes,
  type EvaluatedNote,
  type EvaluationResult,
  type Melody,
  type NoteEvent,
} from "@/lib/music";
import { playNotes, type PlaybackHandle } from "@/lib/audio/playback";
import { PianoRoll } from "./PianoRoll";

interface DictationExerciseProps {
  melody: Melody;
  gridBeats: number;
  minPitch: number;
  maxPitch: number;
  totalBeats: number;
  onComplete: (evaluation: EvaluationResult, response: NoteEvent[]) => void;
}

export const DictationExercise = ({
  melody,
  gridBeats,
  minPitch,
  maxPitch,
  totalBeats,
  onComplete,
}: DictationExerciseProps) => {
  const [notes, setNotes] = useState<NoteEvent[]>([]);
  const playbackRef = useRef<PlaybackHandle | null>(null);

  const toggleNote = (midiPitch: number, onsetBeats: number) => {
    setNotes((current) => {
      const existing = current.find((note) => note.onsetBeats === onsetBeats);
      if (existing && existing.midiPitch === midiPitch) {
        return current.filter((note) => note.onsetBeats !== onsetBeats);
      }
      return [
        ...current.filter((note) => note.onsetBeats !== onsetBeats),
        { midiPitch, onsetBeats, durationBeats: 1 },
      ].sort((a, b) => a.onsetBeats - b.onsetBeats);
    });
  };

  const submit = () => {
    const response: EvaluatedNote[] = notes.map((note) => ({
      midiPitch: note.midiPitch,
      onsetSeconds: beatsToSeconds(note.onsetBeats, melody.tempoBpm),
      durationSeconds: beatsToSeconds(note.durationBeats, melody.tempoBpm),
    }));
    const evaluation = evaluateSimilarity(
      melodyToEvaluatedNotes(melody),
      response,
    );
    onComplete(evaluation, notes);
  };

  return (
    <div className="space-y-4 rounded-lg border border-zinc-200 bg-white p-6">
      <p className="text-zinc-700">
        Escucha la melodía y transcríbela: haz clic sobre el piano roll para
        colocar cada nota en su altura y ataque.
      </p>
      <div className="flex gap-3">
        <button
          className="rounded bg-indigo-600 px-4 py-2 font-medium text-white hover:bg-indigo-700"
          onClick={() => {
            playbackRef.current?.stop();
            playbackRef.current = playNotes(melody.notes, melody.tempoBpm);
          }}
        >
          Escuchar melodía
        </button>
        <button
          className="rounded border border-zinc-300 px-4 py-2 disabled:opacity-40"
          onClick={() => playbackRef.current?.stop()}
        >
          Detener
        </button>
        <button
          className="rounded border border-zinc-300 px-4 py-2 disabled:opacity-40"
          disabled={notes.length === 0}
          onClick={() => setNotes([])}
        >
          Borrar todo
        </button>
      </div>
      <PianoRoll
        notes={notes}
        minPitch={minPitch}
        maxPitch={maxPitch}
        totalBeats={totalBeats}
        gridBeats={gridBeats}
        editable
        onToggleNote={toggleNote}
      />
      <button
        className="rounded bg-emerald-600 px-4 py-2 font-medium text-white hover:bg-emerald-700 disabled:opacity-40"
        disabled={notes.length === 0}
        onClick={submit}
      >
        Enviar respuesta ({notes.length} notas)
      </button>
    </div>
  );
};
