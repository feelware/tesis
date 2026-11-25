"use client";

import { useCallback, useEffect, useState } from "react";
import { AuthPanel } from "./AuthPanel";
import { Lobby } from "./Lobby";
import { Room } from "./Room";

export interface AuthUser {
  id: string;
  name: string;
  email: string;
}

interface RawUser {
  id: string | number;
  name?: string | null;
  email?: string | null;
}

const toAuthUser = (raw: RawUser): AuthUser => ({
  id: String(raw.id),
  name: raw.name ?? raw.email ?? `jugador ${raw.id}`,
  email: raw.email ?? "",
});

export const App = () => {
  const [user, setUser] = useState<AuthUser | null>(null);
  const [loading, setLoading] = useState(true);
  const [roomId, setRoomId] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    const load = async () => {
      try {
        const response = await fetch("/api/users/me", {
          credentials: "include",
        });
        const body = (await response.json()) as {
          user?: RawUser | null;
          id?: string | number;
          name?: string | null;
          email?: string | null;
        };
        const raw: RawUser | null =
          body.user ??
          (body.id !== undefined
            ? { id: body.id, name: body.name, email: body.email }
            : null);
        if (!cancelled && response.ok && raw) {
          setUser(toAuthUser(raw));
        }
      } catch {
        // sin sesión iniciada
      } finally {
        if (!cancelled) setLoading(false);
      }
    };
    void load();
    return () => {
      cancelled = true;
    };
  }, []);

  const logout = useCallback(async () => {
    await fetch("/api/users/logout", {
      method: "POST",
      credentials: "include",
    });
    setUser(null);
    setRoomId(null);
  }, []);

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between border-b border-zinc-200 pb-3">
        <span className="text-sm text-zinc-600">
          {user ? `Sesión: ${user.name}` : "Sin sesión"}
        </span>
        {user ? (
          <button
            className="rounded border border-zinc-300 px-3 py-1 text-sm hover:bg-zinc-50"
            onClick={() => void logout()}
          >
            Cerrar sesión
          </button>
        ) : null}
      </div>
      {loading ? (
        <p className="text-sm text-zinc-500">Cargando…</p>
      ) : !user ? (
        <AuthPanel onAuthenticated={setUser} />
      ) : !roomId ? (
        <Lobby onEnter={setRoomId} />
      ) : (
        <Room
          roomId={roomId}
          onExit={() => setRoomId(null)}
        />
      )}
    </div>
  );
};
