"use client";

import { useState, type FormEvent } from "react";
import type { MyOverview } from "@/lib/game/types";
import { Lobby } from "./Lobby";
import { percent } from "./melody-view";

interface HomeProps {
  overview: MyOverview;
  onEnterRoom: (roomId: string) => void;
  onOpenClassroom: (classroomId: string) => void;
  onOpenSpectate: (roomId: string) => void;
  onRefresh: () => void;
}

const formatDate = (value: string) =>
  new Date(value).toLocaleDateString("es-PE", {
    day: "2-digit",
    month: "2-digit",
    year: "numeric",
  });

export const Home = ({
  overview,
  onEnterRoom,
  onOpenClassroom,
  onOpenSpectate,
  onRefresh,
}: HomeProps) => {
  const [classroomName, setClassroomName] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);

  const canTeach =
    overview.role === "professor" || overview.role === "admin";
  const canPlay = overview.role !== "professor";

  const respond = async (id: string, action: "accept" | "reject") => {
    setError(null);
    const response = await fetch(`/api/invitations/${id}`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      credentials: "include",
      body: JSON.stringify({ action }),
    });
    const body = (await response.json().catch(() => ({}))) as {
      error?: string;
    };
    if (!response.ok) {
      setError(body.error ?? "No se pudo responder la invitación");
      return;
    }
    onRefresh();
  };

  const createClassroom = async (event: FormEvent) => {
    event.preventDefault();
    setBusy(true);
    setError(null);
    try {
      const response = await fetch("/api/classrooms", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        credentials: "include",
        body: JSON.stringify({ name: classroomName }),
      });
      const body = (await response.json().catch(() => ({}))) as {
        error?: string;
      };
      if (!response.ok) {
        throw new Error(body.error ?? "No se pudo crear el salón");
      }
      setClassroomName("");
      onRefresh();
    } catch (err) {
      setError(err instanceof Error ? err.message : "Error al crear el salón");
    } finally {
      setBusy(false);
    }
  };

  return (
    <div className="space-y-8">
      {canTeach && overview.liveGames.length > 0 ? (
        <div className="space-y-3">
          <h2 className="text-xl font-semibold">Partidas en desarrollo</h2>
          {overview.liveGames.map((game) => (
            <div
              key={game.roomId}
              className="flex flex-wrap items-center justify-between gap-3 rounded-lg border border-emerald-200 bg-emerald-50 p-4"
            >
              <div>
                <p className="font-medium">
                  <code className="rounded bg-white px-1">{game.code}</code> —
                  Ronda {game.currentRound} de {game.roundCount}
                </p>
                <p className="text-sm text-zinc-600">
                  {game.classroomNames.join(", ")} · {game.players.join(", ")}
                </p>
              </div>
              <button
                className="rounded bg-emerald-600 px-3 py-1 text-sm font-medium text-white hover:bg-emerald-700"
                onClick={() => onOpenSpectate(game.roomId)}
              >
                Espectar
              </button>
            </div>
          ))}
        </div>
      ) : null}
      {overview.invitations.length > 0 ? (
        <div className="space-y-3">
          <h2 className="text-xl font-semibold">Invitaciones pendientes</h2>
          {overview.invitations.map((invitation) => (
            <div
              key={invitation.id}
              className="flex flex-wrap items-center justify-between gap-3 rounded-lg border border-zinc-200 bg-white p-4"
            >
              <div>
                <p className="font-medium">{invitation.classroomName}</p>
                <p className="text-sm text-zinc-500">
                  Docente: {invitation.teacherName} ·{" "}
                  {formatDate(invitation.createdAt)}
                </p>
              </div>
              <div className="flex gap-2">
                <button
                  className="rounded bg-emerald-600 px-3 py-1 text-sm font-medium text-white hover:bg-emerald-700"
                  onClick={() => void respond(invitation.id, "accept")}
                >
                  Aceptar
                </button>
                <button
                  className="rounded border border-zinc-300 px-3 py-1 text-sm hover:bg-zinc-50"
                  onClick={() => void respond(invitation.id, "reject")}
                >
                  Rechazar
                </button>
              </div>
            </div>
          ))}
        </div>
      ) : null}

      {canTeach ? (
        <div className="space-y-4">
          <h2 className="text-xl font-semibold">Mis salones de clase</h2>
          {overview.classrooms.length === 0 ? (
            <p className="text-sm text-zinc-500">
              Aún no has creado ningún salón.
            </p>
          ) : (
            <div className="space-y-2">
              {overview.classrooms.map((classroom) => (
                <button
                  key={classroom.id}
                  className="flex w-full items-center justify-between rounded-lg border border-zinc-200 bg-white p-4 text-left hover:border-indigo-300"
                  onClick={() => onOpenClassroom(classroom.id)}
                >
                  <span className="font-medium">{classroom.name}</span>
                  <span className="text-sm text-zinc-500">
                    {classroom.memberCount} estudiantes ·{" "}
                    {classroom.pendingCount} invitaciones pendientes
                  </span>
                </button>
              ))}
            </div>
          )}
          <form
            className="flex flex-wrap items-end gap-2"
            onSubmit={(event) => void createClassroom(event)}
          >
            <label className="block">
              <span className="text-sm font-medium text-zinc-700">
                Nuevo salón
              </span>
              <input
                className="mt-1 block w-64 rounded border border-zinc-300 p-2"
                value={classroomName}
                onChange={(event) => setClassroomName(event.target.value)}
                placeholder="Nombre del salón"
                required
                minLength={2}
              />
            </label>
            <button
              type="submit"
              disabled={busy}
              className="rounded bg-indigo-600 px-4 py-2 font-medium text-white hover:bg-indigo-700 disabled:opacity-50"
            >
              Crear salón
            </button>
          </form>
        </div>
      ) : null}

      {canPlay ? (
        <>
          <div className="space-y-3">
            <h2 className="text-xl font-semibold">Mis partidas</h2>
            {overview.games.length === 0 ? (
              <p className="text-sm text-zinc-500">
                Aún no has jugado ninguna partida.
              </p>
            ) : (
              <table className="w-full border-collapse text-left text-sm">
                <thead>
                  <tr className="border-b border-zinc-300">
                    <th className="p-2">Fecha</th>
                    <th className="p-2">Código</th>
                    <th className="p-2">Rondas</th>
                    <th className="p-2">Posición</th>
                    <th className="p-2">Alturas</th>
                    <th className="p-2">Ritmo</th>
                    <th className="p-2">General</th>
                  </tr>
                </thead>
                <tbody>
                  {overview.games.map((game) => (
                    <tr
                      key={game.roomId}
                      className="cursor-pointer border-b border-zinc-200 hover:bg-zinc-50"
                      onClick={() => onEnterRoom(game.roomId)}
                    >
                      <td className="p-2">{formatDate(game.finishedAt)}</td>
                      <td className="p-2">
                        <code className="rounded bg-zinc-100 px-1">
                          {game.code}
                        </code>
                      </td>
                      <td className="p-2">{game.roundCount}</td>
                      <td className="p-2">
                        {game.position} de {game.playerCount}
                      </td>
                      <td className="p-2">{percent(game.pitch)}</td>
                      <td className="p-2">{percent(game.rhythm)}</td>
                      <td className="p-2">{percent(game.overall)}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            )}
          </div>
          <Lobby onEnter={onEnterRoom} />
        </>
      ) : null}

      {error ? <p className="text-sm text-red-600">{error}</p> : null}
    </div>
  );
};
