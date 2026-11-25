"use client";

import { useEffect, useState } from "react";
import type { RoomState } from "@/lib/game/types";
import { GameRound } from "./GameRound";
import { Summary } from "./Summary";
import { WaitingRoom } from "./WaitingRoom";

interface RoomProps {
  roomId: string;
  onExit: () => void;
}

const POLL_INTERVAL_MS = 1200;

export const Room = ({ roomId, onExit }: RoomProps) => {
  const [state, setState] = useState<RoomState | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [tick, setTick] = useState(0);

  useEffect(() => {
    let cancelled = false;
    const load = async () => {
      try {
        const response = await fetch(`/api/rooms/${roomId}`, {
          credentials: "include",
        });
        const body = (await response.json().catch(() => ({}))) as RoomState & {
          error?: string;
        };
        if (!response.ok) {
          throw new Error(body.error ?? "No se pudo cargar la sala");
        }
        if (!cancelled) {
          setState(body);
          setError(null);
        }
      } catch (err) {
        if (!cancelled) {
          setError(err instanceof Error ? err.message : "Error de conexión");
        }
      }
    };
    void load();
    const interval = setInterval(() => void load(), POLL_INTERVAL_MS);
    return () => {
      cancelled = true;
      clearInterval(interval);
    };
  }, [roomId, tick]);

  const refresh = () => setTick((value) => value + 1);

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h2 className="text-xl font-semibold">
          Sala{" "}
          <code className="rounded bg-zinc-100 px-2 py-1">
            {state?.room.code ?? "…"}
          </code>
        </h2>
        <button
          className="rounded border border-zinc-300 px-3 py-1 text-sm hover:bg-zinc-50"
          onClick={onExit}
        >
          Salir de la sala
        </button>
      </div>
      {error ? <p className="text-sm text-amber-600">{error}</p> : null}
      {!state ? (
        <p className="text-sm text-zinc-500">Cargando sala…</p>
      ) : state.room.status === "waiting" ? (
        <WaitingRoom state={state} onStarted={refresh} />
      ) : state.room.status === "in_progress" && state.round ? (
        <GameRound
          key={state.round.number}
          roomId={roomId}
          round={state.round}
          settings={state.room.settings}
          roundCount={state.room.settings?.roundCount ?? 0}
          onSubmitted={refresh}
        />
      ) : state.room.status === "finished" && state.leaderboard ? (
        <Summary leaderboard={state.leaderboard} onNewGame={onExit} />
      ) : (
        <p className="text-sm text-zinc-500">Cargando…</p>
      )}
    </div>
  );
};
