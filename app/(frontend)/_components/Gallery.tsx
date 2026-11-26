"use client";

import { useEffect, useState } from "react";
import type {
  GalleryData,
  GameSettings,
  LeaderboardEntry,
  MyRoundRow,
} from "@/lib/game/types";
import {
  ACTIVITY_LABEL,
  GRID_BEATS,
  MelodyPanel,
  messageLabel,
  percent,
  playMelodyMidi,
  stopMelodyMidi,
} from "./melody-view";

interface GalleryProps {
  roomId: string;
  settings: GameSettings | null;
  leaderboard: LeaderboardEntry[];
  onNewGame: () => void;
}

export const Gallery = ({
  roomId,
  settings,
  leaderboard,
  onNewGame,
}: GalleryProps) => {
  const [data, setData] = useState<GalleryData | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [slide, setSlide] = useState(0);

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
      stopMelodyMidi();
    };
  }, [roomId]);

  useEffect(() => {
    stopMelodyMidi();
  }, [slide]);

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
            onClick={() => setSlide((value) => Math.min(finalIndex, value + 1))}
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
                  onPlay={() => playMelodyMidi(message.notes, tempoBpm)}
                  onStop={stopMelodyMidi}
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
                      onPlay={() => playMelodyMidi(row.receivedNotes, tempoBpm)}
                      onStop={stopMelodyMidi}
                    />
                  </div>
                  <div className="space-y-1">
                    <p className="text-xs text-zinc-500">Tu respuesta</p>
                    <MelodyPanel
                      notes={row.producedNotes}
                      gridBeats={gridBeats}
                      recordingUrl={row.recordingUrl}
                      onPlay={() => playMelodyMidi(row.producedNotes, tempoBpm)}
                      onStop={stopMelodyMidi}
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
