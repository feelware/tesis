"use client";

import { useState } from "react";
import type { RoomState } from "@/lib/game/types";
import { ConfigForm, type GameConfig } from "./ConfigForm";

interface WaitingRoomProps {
  state: RoomState;
  onStarted: () => void;
}

export const WaitingRoom = ({ state, onStarted }: WaitingRoomProps) => {
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);
  const { participants, hostUserId } = state.room;
  const isHost = state.me.userId === hostUserId;

  const startGame = async (config: GameConfig) => {
    setBusy(true);
    setError(null);
    try {
      const response = await fetch(`/api/rooms/${state.room.id}/start`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        credentials: "include",
        body: JSON.stringify({ settings: config }),
      });
      const body = (await response.json().catch(() => ({}))) as {
        error?: string;
      };
      if (!response.ok) {
        throw new Error(body.error ?? "No se pudo iniciar la partida");
      }
      onStarted();
    } catch (err) {
      setError(err instanceof Error ? err.message : "Error al iniciar");
    } finally {
      setBusy(false);
    }
  };

  return (
    <div className="space-y-6">
      <div className="rounded-lg border border-zinc-200 bg-white p-6">
        <h3 className="text-lg font-semibold">Jugadores en la sala</h3>
        <p className="text-sm text-zinc-600">
          Comparte el código <code className="rounded bg-zinc-100 px-1">{state.room.code}</code>{" "}
          con otro jugador. Se necesitan al menos 2 jugadores para iniciar.
        </p>
        <ul className="mt-3 space-y-2">
          {participants.map((participant) => (
            <li
              key={participant.userId}
              className="flex items-center gap-2 text-sm"
            >
              <span className="h-2 w-2 rounded-full bg-emerald-500" />
              <span className="font-medium">{participant.name}</span>
              {participant.userId === state.me.userId ? (
                <span className="text-zinc-500">(tú)</span>
              ) : null}
              {participant.isHost ? (
                <span className="rounded bg-zinc-100 px-2 py-0.5 text-xs text-zinc-600">
                  anfitrión
                </span>
              ) : null}
            </li>
          ))}
        </ul>
      </div>
      {isHost ? (
        <div className={busy ? "pointer-events-none opacity-50" : ""}>
          <ConfigForm onStart={(config) => void startGame(config)} />
          {busy ? (
            <p className="mt-2 text-sm text-zinc-500">Iniciando la partida…</p>
          ) : null}
        </div>
      ) : (
        <p className="rounded-lg border border-zinc-200 bg-white p-6 text-sm text-zinc-600">
          Esperando a que el anfitrión inicie la partida…
        </p>
      )}
      {error ? <p className="text-sm text-red-600">{error}</p> : null}
    </div>
  );
};
