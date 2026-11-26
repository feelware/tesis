"use client";

import { useEffect, useState, type FormEvent } from "react";
import type { ClassroomDetail, SortOrder } from "@/lib/game/types";
import { gameSortScore } from "@/lib/game/rules";
import { percent } from "./melody-view";

interface ClassroomViewProps {
  classroomId: string;
  params: URLSearchParams;
  setParams: (updates: Record<string, string | null>) => void;
  onOpenGame: (roomId: string) => void;
  onBack: () => void;
}

const formatDate = (value: string) =>
  new Date(value).toLocaleDateString("es-PE", {
    day: "2-digit",
    month: "2-digit",
    year: "numeric",
  });

export const ClassroomView = ({
  classroomId,
  params,
  setParams,
  onOpenGame,
  onBack,
}: ClassroomViewProps) => {
  const [detail, setDetail] = useState<ClassroomDetail | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [email, setEmail] = useState("");
  const [tick, setTick] = useState(0);

  const student = params.get("student");
  const metric = params.get("metric") ?? "overall";
  const order = (params.get("order") ?? "desc") as SortOrder;
  const studentMetric = params.get("studentMetric") ?? "overall";
  const studentOrder = (params.get("studentOrder") ?? "desc") as SortOrder;

  useEffect(() => {
    let cancelled = false;
    const load = async () => {
      try {
        const query = new URLSearchParams();
        if (student) query.set("student", student);
        query.set("metric", metric);
        query.set("order", order);
        query.set("studentMetric", studentMetric);
        query.set("studentOrder", studentOrder);
        const response = await fetch(
          `/api/classrooms/${classroomId}?${query.toString()}`,
          { credentials: "include" },
        );
        const body = (await response.json().catch(() => ({}))) as
          ClassroomDetail & { error?: string };
        if (!response.ok) {
          throw new Error(body.error ?? "No se pudo cargar el salón");
        }
        if (!cancelled) {
          setDetail(body);
          setError(null);
        }
      } catch (err) {
        if (!cancelled) {
          setError(err instanceof Error ? err.message : "Error de conexión");
        }
      }
    };
    void load();
    const interval = setInterval(() => void load(), 5000);
    return () => {
      cancelled = true;
      clearInterval(interval);
    };
  }, [classroomId, student, metric, order, studentMetric, studentOrder, tick]);

  const toggleSort = (
    key: string,
    currentKey: string,
    currentOrder: SortOrder,
    prefix: "" | "student",
  ) => {
    const nextOrder: SortOrder =
      key === currentKey ? (currentOrder === "desc" ? "asc" : "desc") : "desc";
    setParams({
      [prefix === "" ? "metric" : "studentMetric"]: key,
      [prefix === "" ? "order" : "studentOrder"]: nextOrder,
    });
  };

  const invite = async (event: FormEvent) => {
    event.preventDefault();
    setError(null);
    const response = await fetch(
      `/api/classrooms/${classroomId}/invitations`,
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        credentials: "include",
        body: JSON.stringify({ email }),
      },
    );
    const body = (await response.json().catch(() => ({}))) as {
      error?: string;
    };
    if (!response.ok) {
      setError(body.error ?? "No se pudo enviar la invitación");
      return;
    }
    setEmail("");
    setTick((value) => value + 1);
  };

  const sortButton = (
    key: string,
    currentKey: string,
    currentOrder: SortOrder,
    prefix: "" | "student",
    label: string,
  ) => (
    <button
      className="flex items-center gap-1 font-semibold hover:text-indigo-600"
      onClick={() => toggleSort(key, currentKey, currentOrder, prefix)}
    >
      {label}
      <span className="text-xs text-zinc-400">
        {key === currentKey ? (currentOrder === "desc" ? "▼" : "▲") : "↕"}
      </span>
    </button>
  );

  if (error && !detail) {
    return (
      <div className="space-y-4">
        <p className="text-sm text-red-600">{error}</p>
        <button
          className="rounded border border-zinc-300 px-3 py-1 text-sm"
          onClick={onBack}
        >
          ← Volver
        </button>
      </div>
    );
  }
  if (!detail) {
    return <p className="text-sm text-zinc-500">Cargando salón…</p>;
  }

  const filteredStudent = detail.students.find(
    (item) => item.userId === (student ?? ""),
  );

  return (
    <div className="space-y-8">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <div>
          <h2 className="text-2xl font-semibold">{detail.classroom.name}</h2>
          <p className="text-sm text-zinc-500">
            Docente: {detail.classroom.teacherName}
          </p>
        </div>
        <button
          className="rounded border border-zinc-300 px-3 py-1 text-sm hover:bg-zinc-50"
          onClick={onBack}
        >
          ← Volver
        </button>
      </div>

      <div className="space-y-3">
        <h3 className="text-lg font-semibold">Partidas en desarrollo</h3>
        {detail.liveGames.length === 0 ? (
          <p className="text-sm text-zinc-500">
            No hay partidas en desarrollo.
          </p>
        ) : (
          <div className="space-y-2">
            {detail.liveGames.map((game) => (
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
                    {game.players.join(", ")}
                  </p>
                </div>
                <button
                  className="rounded bg-emerald-600 px-3 py-1 text-sm font-medium text-white hover:bg-emerald-700"
                  onClick={() => onOpenGame(game.roomId)}
                >
                  Espectar
                </button>
              </div>
            ))}
          </div>
        )}
      </div>

      <div className="space-y-3">
        <h3 className="text-lg font-semibold">Partidas del salón</h3>
        {filteredStudent ? (
          <div className="flex items-center gap-2 rounded border border-indigo-200 bg-indigo-50 px-3 py-2 text-sm">
            <span>
              Filtrando por <strong>{filteredStudent.name}</strong>
            </span>
            <button
              className="rounded border border-indigo-300 px-2 py-0.5 text-xs hover:bg-indigo-100"
              onClick={() => setParams({ student: null })}
            >
              Quitar filtro
            </button>
          </div>
        ) : null}
        {detail.games.length === 0 ? (
          <p className="text-sm text-zinc-500">
            No hay partidas jugadas por estudiantes de este salón.
          </p>
        ) : (
          <table className="w-full border-collapse text-left text-sm">
            <thead>
              <tr className="border-b border-zinc-300">
                <th className="p-2">Fecha</th>
                <th className="p-2">Código</th>
                <th className="p-2">Estudiantes</th>
                <th className="p-2">
                  {sortButton("pitch", metric, order, "", "Alturas")}
                </th>
                <th className="p-2">
                  {sortButton("rhythm", metric, order, "", "Ritmo")}
                </th>
                <th className="p-2">
                  {sortButton("overall", metric, order, "", "General")}
                </th>
              </tr>
            </thead>
            <tbody>
              {detail.games.map((game) => (
                <tr
                  key={game.roomId}
                  className="cursor-pointer border-b border-zinc-200 hover:bg-zinc-50"
                  onClick={() => onOpenGame(game.roomId)}
                >
                  <td className="p-2">{formatDate(game.finishedAt)}</td>
                  <td className="p-2">
                    <code className="rounded bg-zinc-100 px-1">{game.code}</code>
                  </td>
                  <td className="p-2">
                    <span className="flex flex-wrap gap-1">
                      {game.participants.map((participant) => (
                        <span
                          key={participant.userId}
                          className="rounded bg-zinc-100 px-2 py-0.5 text-xs"
                        >
                          {participant.name} {percent(participant.overall)}
                        </span>
                      ))}
                    </span>
                  </td>
                  <td className="p-2">
                    {percent(
                      gameSortScore(
                        game.participants,
                        student ?? null,
                        "pitch",
                      ),
                    )}
                  </td>
                  <td className="p-2">
                    {percent(
                      gameSortScore(
                        game.participants,
                        student ?? null,
                        "rhythm",
                      ),
                    )}
                  </td>
                  <td className="p-2">
                    {percent(
                      gameSortScore(
                        game.participants,
                        student ?? null,
                        "overall",
                      ),
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>

      <div className="space-y-3">
        <h3 className="text-lg font-semibold">Estudiantes</h3>
        {detail.students.length === 0 ? (
          <p className="text-sm text-zinc-500">
            Ningún estudiante ha aceptado la invitación todavía.
          </p>
        ) : (
          <table className="w-full border-collapse text-left text-sm">
            <thead>
              <tr className="border-b border-zinc-300">
                <th className="p-2">Estudiante</th>
                <th className="p-2">
                  {sortButton(
                    "gamesPlayed",
                    studentMetric,
                    studentOrder,
                    "student",
                    "Partidas",
                  )}
                </th>
                <th className="p-2">
                  {sortButton(
                    "pitch",
                    studentMetric,
                    studentOrder,
                    "student",
                    "Alturas",
                  )}
                </th>
                <th className="p-2">
                  {sortButton(
                    "rhythm",
                    studentMetric,
                    studentOrder,
                    "student",
                    "Ritmo",
                  )}
                </th>
                <th className="p-2">
                  {sortButton(
                    "overall",
                    studentMetric,
                    studentOrder,
                    "student",
                    "General",
                  )}
                </th>
              </tr>
            </thead>
            <tbody>
              {detail.students.map((item) => (
                <tr
                  key={item.userId}
                  className="cursor-pointer border-b border-zinc-200 hover:bg-zinc-50"
                  onClick={() => setParams({ student: item.userId })}
                >
                  <td className="p-2">
                    {item.name}
                    <span className="block text-xs text-zinc-500">
                      {item.email}
                    </span>
                  </td>
                  <td className="p-2">{item.gamesPlayed}</td>
                  <td className="p-2">{percent(item.pitch)}</td>
                  <td className="p-2">{percent(item.rhythm)}</td>
                  <td className="p-2">{percent(item.overall)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>

      <div className="space-y-3">
        <h3 className="text-lg font-semibold">Invitaciones pendientes</h3>
        {detail.invitations.length === 0 ? (
          <p className="text-sm text-zinc-500">No hay invitaciones pendientes.</p>
        ) : (
          <ul className="space-y-2">
            {detail.invitations.map((invitation) => (
              <li
                key={invitation.id}
                className="flex items-center justify-between rounded border border-zinc-200 bg-white px-3 py-2 text-sm"
              >
                <span>
                  {invitation.name}{" "}
                  <span className="text-zinc-500">({invitation.email})</span>
                </span>
                <span className="text-xs text-zinc-500">
                  {formatDate(invitation.createdAt)}
                </span>
              </li>
            ))}
          </ul>
        )}
        <form
          className="flex flex-wrap items-end gap-2"
          onSubmit={(event) => void invite(event)}
        >
          <label className="block">
            <span className="text-sm font-medium text-zinc-700">
              Invitar por correo
            </span>
            <input
              type="email"
              className="mt-1 block w-64 rounded border border-zinc-300 p-2"
              value={email}
              onChange={(event) => setEmail(event.target.value)}
              placeholder="estudiante@correo.com"
              required
            />
          </label>
          <button
            type="submit"
            className="rounded bg-indigo-600 px-4 py-2 font-medium text-white hover:bg-indigo-700"
          >
            Invitar
          </button>
        </form>
      </div>

      {error ? <p className="text-sm text-red-600">{error}</p> : null}
    </div>
  );
};
