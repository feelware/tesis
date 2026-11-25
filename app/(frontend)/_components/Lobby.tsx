"use client";

import { useState, type FormEvent } from "react";

interface LobbyProps {
  onEnter: (roomId: string) => void;
}

export const Lobby = ({ onEnter }: LobbyProps) => {
  const [code, setCode] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState<"create" | "join" | null>(null);

  const request = async (path: string, body?: unknown) => {
    const response = await fetch(path, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      credentials: "include",
      body: body === undefined ? undefined : JSON.stringify(body),
    });
    const data = (await response.json().catch(() => ({}))) as {
      roomId?: string;
      error?: string;
    };
    if (!response.ok || !data.roomId) {
      throw new Error(data.error ?? "No se pudo completar la operación");
    }
    onEnter(data.roomId);
  };

  const createRoom = async () => {
    setBusy("create");
    setError(null);
    try {
      await request("/api/rooms");
    } catch (err) {
      setError(err instanceof Error ? err.message : "Error al crear la sala");
    } finally {
      setBusy(null);
    }
  };

  const joinRoom = async (event: FormEvent) => {
    event.preventDefault();
    setBusy("join");
    setError(null);
    try {
      await request("/api/rooms/join", { code });
    } catch (err) {
      setError(err instanceof Error ? err.message : "Error al unirse");
    } finally {
      setBusy(null);
    }
  };

  return (
    <div className="mx-auto grid max-w-2xl gap-6 md:grid-cols-2">
      <div className="space-y-3 rounded-lg border border-zinc-200 bg-white p-6">
        <h2 className="text-lg font-semibold">Crear sala</h2>
        <p className="text-sm text-zinc-600">
          Crea una sala, comparte el código con otro jugador e inicia la partida
          cuando ambos estén dentro.
        </p>
        <button
          className="rounded bg-indigo-600 px-4 py-2 font-medium text-white hover:bg-indigo-700 disabled:opacity-50"
          disabled={busy !== null}
          onClick={() => void createRoom()}
        >
          {busy === "create" ? "Creando…" : "Crear sala"}
        </button>
      </div>
      <form
        className="space-y-3 rounded-lg border border-zinc-200 bg-white p-6"
        onSubmit={(event) => void joinRoom(event)}
      >
        <h2 className="text-lg font-semibold">Unirse a una sala</h2>
        <label className="block">
          <span className="text-sm font-medium text-zinc-700">
            Código de la sala
          </span>
          <input
            className="mt-1 w-full rounded border border-zinc-300 p-2 uppercase"
            value={code}
            onChange={(event) => setCode(event.target.value.toUpperCase())}
            placeholder="ABC123"
            maxLength={6}
            required
          />
        </label>
        {error ? <p className="text-sm text-red-600">{error}</p> : null}
        <button
          type="submit"
          disabled={busy !== null}
          className="rounded bg-emerald-600 px-4 py-2 font-medium text-white hover:bg-emerald-700 disabled:opacity-50"
        >
          {busy === "join" ? "Uniéndose…" : "Unirse"}
        </button>
      </form>
    </div>
  );
};
