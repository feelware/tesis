"use client";

import { useMemo, useState } from "react";
import {
  type Difficulty,
  type Melody,
  type NoteEvent,
} from "@/lib/music";
import type { GameSettings, RoundState } from "@/lib/game/types";
import { DictationExercise } from "./DictationExercise";
import { SightSingingExercise } from "./SightSingingExercise";

interface GameRoundProps {
  roomId: string;
  round: RoundState;
  settings: GameSettings | null;
  roundCount: number;
  onSubmitted: () => void;
}

const GRID_BEATS: Record<Difficulty, number> = {
  low: 1,
  medium: 0.5,
  high: 1 / 6,
};

const ACTIVITY_LABEL = {
  dictation: "Dictado",
  sight_singing: "Repentización",
} as const;

export const GameRound = ({
  roomId,
  round,
  settings,
  roundCount,
  onSubmitted,
}: GameRoundProps) => {
  const [phase, setPhase] = useState<"playing" | "submitting" | "submitted">(
    "playing",
  );
  const [sendError, setSendError] = useState<string | null>(null);

  const melody: Melody | null = round.submission?.receivedMelody ?? null;

  const rollRange = useMemo(() => {
    if (!melody) return { minPitch: 55, maxPitch: 72, totalBeats: 8 };
    const pitches = melody.notes.map((note) => note.midiPitch);
    const lastNote = melody.notes[melody.notes.length - 1];
    return {
      minPitch: Math.max(36, Math.min(...pitches) - 2),
      maxPitch: Math.min(84, Math.max(...pitches) + 2),
      totalBeats: Math.ceil(lastNote.onsetBeats + lastNote.durationBeats) + 2,
    };
  }, [melody]);

  const gridBeats = GRID_BEATS[settings?.difficulty ?? "low"];

  const submit = async (response: NoteEvent[], recording: Blob | null = null) => {
    if (phase !== "playing") return;
    setPhase("submitting");
    setSendError(null);
    try {
      let recordingId: number | null = null;
      if (recording) {
        // La grabación se sube por separado; si falla, se envía igualmente la
        // transcripción y la galería muestra el MIDI.
        try {
          const form = new FormData();
          const extension = recording.type.includes("mp4") ? "mp4" : "webm";
          form.append("file", recording, `recording.${extension}`);
          form.append("alt", "Interpretación vocal");
          const upload = await fetch("/api/media", {
            method: "POST",
            credentials: "include",
            body: form,
          });
          if (upload.ok) {
            const body = (await upload.json()) as { doc?: { id?: number } };
            if (typeof body.doc?.id === "number") {
              recordingId = body.doc.id;
            }
          }
        } catch {
          recordingId = null;
        }
      }
      const result = await fetch(`/api/rooms/${roomId}/submit`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        credentials: "include",
        body: JSON.stringify({ response, recordingId }),
      });
      const body = (await result.json().catch(() => ({}))) as {
        error?: string;
      };
      if (!result.ok) {
        throw new Error(body.error ?? "No se pudo enviar la respuesta");
      }
      setPhase("submitted");
      onSubmitted();
    } catch (err) {
      setSendError(
        err instanceof Error ? err.message : "Error al enviar la respuesta",
      );
      setPhase("playing");
    }
  };

  const header = (
    <header>
      <h2 className="text-xl font-semibold">
        Ronda {round.number}
        {roundCount > 0 ? ` de ${roundCount}` : ""} —{" "}
        {ACTIVITY_LABEL[round.activity]}
      </h2>
    </header>
  );

  if (!melody || !round.submission) {
    return (
      <div className="space-y-4">
        {header}
        <p className="text-sm text-zinc-500">Cargando el ejercicio…</p>
      </div>
    );
  }

  if (phase !== "playing" || round.submission.status === "done") {
    return (
      <div className="space-y-4">
        {header}
        <div className="rounded-lg border border-zinc-200 bg-white p-6">
          <p className="text-zinc-700">
            {phase === "submitting"
              ? "Enviando tu respuesta…"
              : "Respuesta enviada. Esperando a que los demás jugadores terminen la ronda…"}
          </p>
          <ul className="mt-4 space-y-2">
            {round.players.map((player) => (
              <li key={player.userId} className="flex items-center gap-2 text-sm">
                <span
                  className={`h-2 w-2 rounded-full ${player.done ? "bg-emerald-500" : "bg-zinc-300"}`}
                />
                <span>{player.name}</span>
              </li>
            ))}
          </ul>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-4">
      {header}
      {sendError ? (
        <p className="rounded border border-red-200 bg-red-50 p-3 text-sm text-red-600">
          {sendError}
        </p>
      ) : null}
      {round.activity === "dictation" ? (
        <DictationExercise
          melody={melody}
          gridBeats={gridBeats}
          minPitch={rollRange.minPitch}
          maxPitch={rollRange.maxPitch}
          totalBeats={rollRange.totalBeats}
          onComplete={(response) => void submit(response)}
        />
      ) : (
        <SightSingingExercise
          melody={melody}
          gridBeats={gridBeats}
          minPitch={rollRange.minPitch}
          maxPitch={rollRange.maxPitch}
          totalBeats={rollRange.totalBeats}
          onComplete={(response, recording) => void submit(response, recording)}
        />
      )}
    </div>
  );
};
