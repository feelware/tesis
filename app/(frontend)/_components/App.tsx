"use client";

import { useCallback, useEffect, useState } from "react";
import type { MyOverview } from "@/lib/game/types";
import { AuthPanel } from "./AuthPanel";
import { ClassroomView } from "./ClassroomView";
import { Home } from "./Home";
import { Room } from "./Room";
import { SpectateView } from "./SpectateView";
import { useUrlState } from "./useUrlState";

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

const APP_PARAMS = [
  "classroom",
  "student",
  "metric",
  "order",
  "studentMetric",
  "studentOrder",
  "spectate",
  "view",
  "melody",
  "player",
];

export const App = () => {
  const [user, setUser] = useState<AuthUser | null>(null);
  const [loading, setLoading] = useState(true);
  const [overview, setOverview] = useState<MyOverview | null>(null);
  const [roomId, setRoomId] = useState<string | null>(null);
  const [params, setParams] = useUrlState();

  const loadOverview = useCallback(async () => {
    try {
      const response = await fetch("/api/my/overview", {
        credentials: "include",
      });
      const body = (await response.json()) as MyOverview;
      if (response.ok) {
        setOverview(body);
      }
    } catch {
      // sin conexión; se reintenta en el próximo refresco
    }
  }, []);

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
          const overviewResponse = await fetch("/api/my/overview", {
            credentials: "include",
          });
          const overviewBody = (await overviewResponse.json()) as MyOverview;
          if (!cancelled && overviewResponse.ok) {
            setOverview(overviewBody);
          }
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

  // El inicio del docente muestra partidas en vivo: se refresca periódicamente.
  useEffect(() => {
    if (!user || roomId || params.get("spectate") || params.get("classroom")) {
      return;
    }
    const interval = setInterval(() => void loadOverview(), 5000);
    return () => clearInterval(interval);
  }, [user, roomId, params, loadOverview]);

  const clearViews = useCallback(() => {
    setParams(Object.fromEntries(APP_PARAMS.map((key) => [key, null])));
  }, [setParams]);

  const logout = useCallback(async () => {
    await fetch("/api/users/logout", {
      method: "POST",
      credentials: "include",
    });
    setUser(null);
    setOverview(null);
    setRoomId(null);
    clearViews();
  }, [clearViews]);

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
        <AuthPanel
          onAuthenticated={(nextUser) => {
            setUser(nextUser);
            void loadOverview();
          }}
        />
      ) : params.get("spectate") ? (
        <SpectateView
          roomId={params.get("spectate") ?? ""}
          params={params}
          setParams={setParams}
          onBack={clearViews}
        />
      ) : params.get("classroom") ? (
        <ClassroomView
          classroomId={params.get("classroom") ?? ""}
          params={params}
          setParams={setParams}
          onOpenGame={(id) =>
            setParams({
              classroom: null,
              student: null,
              spectate: id,
              view: "general",
            })
          }
          onBack={clearViews}
        />
      ) : roomId ? (
        <Room
          roomId={roomId}
          onExit={() => {
            setRoomId(null);
            void loadOverview();
          }}
        />
      ) : overview ? (
        <Home
          overview={overview}
          onEnterRoom={setRoomId}
          onOpenClassroom={(id) => setParams({ classroom: id })}
          onOpenSpectate={(id) => setParams({ spectate: id, view: "general" })}
          onRefresh={() => void loadOverview()}
        />
      ) : (
        <p className="text-sm text-zinc-500">Cargando…</p>
      )}
    </div>
  );
};
