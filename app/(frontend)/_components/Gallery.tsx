"use client";

import { useCallback, useEffect, useRef, useState } from "react";
import { type Difficulty, type NoteEvent } from "@/lib/music";
import { playNotes, type PlaybackHandle } from "@/lib/audio/playback";
import type {
  GalleryData,
  GalleryMessage,
  GameSettings,
  LeaderboardEntry,
  MyRoundRow,
} from "@/lib/game/types";
import { PianoRoll } from "./PianoRoll";

interface GalleryProps {
  roomId: string;
  settings: GameSettings | null;
  leaderboard: LeaderboardEntry[];
  onNewGame: () => void;
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

const percent = (value: number) => `${Math.round(value * 1000) / 10}%`;

const rangeFor = (notes: NoteEvent[]) => {
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

interface MelodyPanelProps {
  notes: NoteEvent[];
  gridBeats: number;
  onPlay: () => void;
  onStop: () => void;
  recordingUrl?: string | null;
}

const MelodyPanel = ({
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
        <audio controls preload="none" src={recordingUrl} className="h-9 w-full max-w-md" />
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

const messageLabel = (message: GalleryMessage): string => {
  if (message.isSystem || message.roundNumber === null) return "original";
  return `ronda ${message.roundNumber} · ${
    message.activity ? ACTIVITY_LABEL[message.activity] : ""
  }`;
};

export const Gallery = ({
  roomId,
  settings,
  leaderboard,
  onNewGame,
}: GalleryProps) => {
  const [data, setData] = useState<GalleryData | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [slide, setSlide] = useState(0);
  const playbackRef = useRef<PlaybackHandle | null>(null);

  useEffect(() => {
    let cancelled = false;
    const load = async () => {
      try {
        const response = await fetch(`/api/rooms/${roomId}/gallery`, {
          credentials: "include",
        });
        const body = (await response.json().catch(() => ({}))) as GalleryData & {
          error?: string;
        };
        if (!response.ok) {
          throw new Error(body.error ?? "No se pudo cargar la galería");
        }
        if (!cancelled) {
          setData(body);
        }
      } catch (err) {
        if (!cancelled) {
          setError(err instanceof Error ? err.message : "Error de conexión");
        }
      }
    };
    void load();
    return () => {
      cancelled = true;
      playbackRef.current?.stop();
    };
  }, [roomId]);

  useEffect(() => {
    playbackRef.current?.stop();
  }, [slide]);

  const playMidi = useCallback((notes: NoteEvent[], tempoBpm: number) => {
    playbackRef.current?.stop();
    playbackRef.current = playNotes(notes, tempoBpm);
  }, []);

  const stopMidi = useCallback(() => {
    playbackRef.current?.stop();
  }, []);

  if (error) {
    return <p className="text-sm text-red-600">{error}</p>;
  }
  if (!data) {
    return <p className="text-sm text-zinc-500">Cargando galería…</p>;
  }

  const tempoBpm = settings?.tempoBpm ?? 90;
  const gridBeats = GRID_BEATS[settings?.difficulty ?? "low"];
  const finalIndex = data.strands.length;
  const slideCount = finalIndex + 1;
  const isFinal = slide === finalIndex;

  return (
    <div className="space-y-6">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <h2 className="text-2xl font-semibold">
          {isFinal
            ? "Resultados de la partida"
            : `Melodía ${slide + 1} de ${finalIndex}`}
        </h2>
        <div className="flex items-center gap-2">
          <button
            className="rounded border border-zinc-300 px-3 py-1 text-sm hover:bg-zinc-50 disabled:opacity-40"
            disabled={slide === 0}
            onClick={() => setSlide((value) => Math.max(0, value - 1))}
          >
            ← Anterior
          </button>
          <button
            className="rounded border border-zinc-300 px-3 py-1 text-sm hover:bg-zinc-50 disabled:opacity-40"
            disabled={isFinal}
            onClick={() =>
              setSlide((value) => Math.min(finalIndex, value + 1))
            }
          >
            Siguiente →
          </button>
          {!isFinal ? (
            <button
              className="rounded bg-indigo-600 px-3 py-1 text-sm font-medium text-white hover:bg-indigo-700"
              onClick={() => setSlide(finalIndex)}
            >
              Ver resultados
            </button>
          ) : null}
          <span className="text-sm text-zinc-500">
            {isFinal ? "Resultados" : `${slide + 1} / ${slideCount}`}
          </span>
        </div>
      </div>

      {!isFinal ? (
        <div className="space-y-4">
          {data.strands[slide].messages.map((message, index) => (
            <div key={index} className="flex items-start gap-3">
              <div className="w-28 shrink-0 pt-2 text-right">
                <p
                  className={`text-sm ${message.isSystem ? "font-semibold text-indigo-600" : "font-medium text-zinc-800"}`}
                >
                  {message.authorName}
                </p>
                <p className="text-xs text-zinc-500">{messageLabel(message)}</p>
              </div>
              <div className="flex-1 rounded-lg border border-zinc-200 bg-white p-3">
                <MelodyPanel
                  notes={message.notes}
                  gridBeats={gridBeats}
                  recordingUrl={message.recordingUrl}
                  onPlay={() => playMidi(message.notes, tempoBpm)}
                  onStop={stopMidi}
                />
              </div>
            </div>
          ))}
        </div>
      ) : (
        <div className="space-y-8">
          <div className="space-y-3">
            <h3 className="text-lg font-semibold">Clasificación</h3>
            <table className="w-full border-collapse text-left text-sm">
              <thead>
                <tr className="border-b border-zinc-300">
                  <th className="p-2">#</th>
                  <th className="p-2">Jugador</th>
                  <th className="p-2">Alturas</th>
                  <th className="p-2">Ritmo</th>
                  <th className="p-2">General</th>
                </tr>
              </thead>
              <tbody>
                {leaderboard.map((entry, index) => (
                  <tr key={entry.userId} className="border-b border-zinc-200">
                    <td className="p-2">{index + 1}</td>
                    <td className="p-2">{entry.name}</td>
                    <td className="p-2">{percent(entry.pitch)}</td>
                    <td className="p-2">{percent(entry.rhythm)}</td>
                    <td className="p-2">{percent(entry.overall)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          <div className="space-y-3">
            <h3 className="text-lg font-semibold">Tus participaciones</h3>
            {data.myRounds.map((row: MyRoundRow) => (
              <div
                key={row.roundNumber}
                className="rounded-lg border border-zinc-200 bg-white p-4"
              >
                <p className="text-sm font-medium">
                  Ronda {row.roundNumber} — {ACTIVITY_LABEL[row.activity]}
                </p>
                <div className="mt-3 grid gap-4 md:grid-cols-2">
                  <div className="space-y-1">
                    <p className="text-xs text-zinc-500">Recibiste</p>
                    <MelodyPanel
                      notes={row.receivedNotes}
                      gridBeats={gridBeats}
                      onPlay={() => playMidi(row.receivedNotes, tempoBpm)}
                      onStop={stopMidi}
                    />
                  </div>
                  <div className="space-y-1">
                    <p className="text-xs text-zinc-500">Tu respuesta</p>
                    <MelodyPanel
                      notes={row.producedNotes}
                      gridBeats={gridBeats}
                      recordingUrl={row.recordingUrl}
                      onPlay={() => playMidi(row.producedNotes, tempoBpm)}
                      onStop={stopMidi}
                    />
                  </div>
                </div>
              </div>
            ))}
          </div>

          <button
            className="rounded bg-indigo-600 px-4 py-2 font-medium text-white hover:bg-indigo-700"
            onClick={onNewGame}
          >
            Nueva partida
          </button>
        </div>
      )}
    </div>
  );
};
