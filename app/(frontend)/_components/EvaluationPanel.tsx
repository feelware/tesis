"use client";

import { useRef } from "react";
import type {
  EvaluationResult,
  Melody,
  NoteEvent,
} from "@/lib/music";
import { playNotes, type PlaybackHandle } from "@/lib/audio/playback";
import { PianoRoll } from "./PianoRoll";

interface EvaluationPanelProps {
  melody: Melody;
  response: NoteEvent[];
  evaluation: EvaluationResult;
  gridBeats: number;
  minPitch: number;
  maxPitch: number;
  totalBeats: number;
}

const MATCHED_COLOR = "#10b981";
const MISSED_COLOR = "#ef4444";
const EXTRA_COLOR = "#f59e0b";

const percent = (value: number) => `${Math.round(value * 1000) / 10}%`;

export const EvaluationPanel = ({
  melody,
  response,
  evaluation,
  gridBeats,
  minPitch,
  maxPitch,
  totalBeats,
}: EvaluationPanelProps) => {
  const playbackRef = useRef<PlaybackHandle | null>(null);
  const matchedReference = new Set(
    evaluation.pitch.matchedPairs.map(([referenceIndex]) => referenceIndex),
  );
  const matchedEstimated = new Set(
    evaluation.pitch.matchedPairs.map(([, estimatedIndex]) => estimatedIndex),
  );

  return (
    <div className="space-y-6 rounded-lg border border-zinc-200 bg-white p-6">
      <div className="grid grid-cols-3 gap-4 text-center">
        <div className="rounded-lg border border-zinc-200 p-4">
          <p className="text-sm text-zinc-500">Precisión de alturas</p>
          <p className="text-2xl font-semibold">{percent(evaluation.pitch.f1)}</p>
        </div>
        <div className="rounded-lg border border-zinc-200 p-4">
          <p className="text-sm text-zinc-500">Precisión rítmica</p>
          <p className="text-2xl font-semibold">{percent(evaluation.rhythm.f1)}</p>
        </div>
        <div className="rounded-lg border border-indigo-200 bg-indigo-50 p-4">
          <p className="text-sm text-indigo-600">Puntuación general</p>
          <p className="text-2xl font-semibold">{percent(evaluation.overall)}</p>
        </div>
      </div>

      <div className="space-y-2">
        <div className="flex items-center justify-between">
          <h3 className="font-medium">Tu respuesta</h3>
          <button
            className="rounded border border-zinc-300 px-3 py-1 text-sm"
            onClick={() => {
              playbackRef.current?.stop();
              playbackRef.current = playNotes(response, melody.tempoBpm);
            }}
          >
            Escuchar
          </button>
        </div>
        <PianoRoll
          notes={response}
          minPitch={minPitch}
          maxPitch={maxPitch}
          totalBeats={totalBeats}
          gridBeats={gridBeats}
          colorForNote={(_, index) =>
            matchedEstimated.has(index) ? MATCHED_COLOR : EXTRA_COLOR
          }
        />
      </div>

      <div className="space-y-2">
        <div className="flex items-center justify-between">
          <h3 className="font-medium">Melodía de referencia</h3>
          <button
            className="rounded border border-zinc-300 px-3 py-1 text-sm"
            onClick={() => {
              playbackRef.current?.stop();
              playbackRef.current = playNotes(melody.notes, melody.tempoBpm);
            }}
          >
            Escuchar
          </button>
        </div>
        <PianoRoll
          notes={melody.notes}
          minPitch={minPitch}
          maxPitch={maxPitch}
          totalBeats={totalBeats}
          gridBeats={gridBeats}
          colorForNote={(_, index) =>
            matchedReference.has(index) ? MATCHED_COLOR : MISSED_COLOR
          }
        />
        <p className="text-xs text-zinc-500">
          Verde: notas correctas. Rojo: notas omitidas. Ámbar: notas de más.
        </p>
      </div>
    </div>
  );
};
