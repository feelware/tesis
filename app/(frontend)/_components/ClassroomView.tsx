"use client";

import { useEffect, useState, type FormEvent } from "react";
import type { ClassroomDetail, SortOrder } from "@/lib/game/types";
import { gameSortScore } from "@/lib/game/rules";
import { percent } from "./melody-view";
import { Sparkline, trendSeriesOf } from "./Sparkline";

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
  const tab = params.get("tab") ?? "live";

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
        const body = (await response
          .json()
          .catch(() => ({}))) as ClassroomDetail & { error?: string };
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
    const response = await fetch(`/api/classrooms/${classroomId}/invitations`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      credentials: "include",
      body: JSON.stringify({ email }),
    });
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
      <span className="text-zinc-400 text-xs">
        {key === currentKey ? (currentOrder === "desc" ? "▼" : "▲") : "↕"}
      </span>
    </button>
  );

  const tabButton = (id: string, label: string) => (
    <button
      className={`rounded px-3 py-1 text-sm ${tab === id ? "bg-indigo-600 font-medium text-white" : "border border-zinc-300 hover:bg-zinc-50"}`}
      onClick={() => setParams({ tab: id })}
    >
      {label}
    </button>
  );

  if (error && !detail) {
    return (
      <div className="space-y-4">
        <p className="text-red-600 text-sm">{error}</p>
        <button
          className="px-3 py-1 border border-zinc-300 rounded text-sm"
          onClick={onBack}
        >
          ← Volver
        </button>
      </div>
    );
  }
  if (!detail) {
    return <p className="text-zinc-500 text-sm">Cargando salón…</p>;
  }

  const filteredStudent = detail.students.find(
    (item) => item.userId === (student ?? ""),
  );

  return (
    <div className="space-y-8">
      <div className="flex flex-wrap justify-between items-center gap-3">
        <div>
          <h2 className="font-semibold text-2xl">{detail.classroom.name}</h2>
          <p className="text-zinc-500 text-sm">
            Docente: {detail.classroom.teacherName}
          </p>
        </div>
        <button
          className="hover:bg-zinc-50 px-3 py-1 border border-zinc-300 rounded text-sm"
          onClick={onBack}
        >
          ← Volver
        </button>
      </div>

      <div className="flex flex-wrap gap-2">
        {tabButton("live", "Partidas en desarrollo")}
        {tabButton("games", "Partidas pasadas")}
        {tabButton("students", "Estudiantes")}
        {tabButton("invitations", "Invitaciones pendientes")}
      </div>

      {tab === "live" ? (
        <div className="space-y-3">
          {detail.liveGames.length === 0 ? (
            <p className="text-zinc-500 text-sm">
              No hay partidas en desarrollo.
            </p>
          ) : (
            <div className="space-y-2">
              {detail.liveGames.map((game) => (
                <div
                  key={game.roomId}
                  className="flex flex-wrap justify-between items-center gap-3 bg-emerald-50 p-4 border border-emerald-200 rounded-lg"
                >
                  <div>
                    <p className="font-medium">
                      <code className="bg-white px-1 rounded">{game.code}</code>{" "}
                      — Ronda {game.currentRound} de {game.roundCount}
                    </p>
                    <p className="text-zinc-600 text-sm">
                      {game.players.join(", ")}
                    </p>
                  </div>
                  <button
                    className="bg-emerald-600 hover:bg-emerald-700 px-3 py-1 rounded font-medium text-white text-sm"
                    onClick={() => onOpenGame(game.roomId)}
                  >
                    Espectar
                  </button>
                </div>
              ))}
            </div>
          )}
        </div>
      ) : null}

      {tab === "games" ? (
        <div className="space-y-3">
          {filteredStudent ? (
            <div className="flex items-center gap-2 bg-indigo-50 px-3 py-2 border border-indigo-200 rounded text-sm">
              <span>
                Filtrando por <strong>{filteredStudent.name}</strong>
              </span>
              <button
                className="hover:bg-indigo-100 px-2 py-0.5 border border-indigo-300 rounded text-xs"
                onClick={() => setParams({ student: null })}
              >
                Quitar filtro
              </button>
            </div>
          ) : null}
          {detail.games.length === 0 ? (
            <p className="text-zinc-500 text-sm">
              No hay partidas jugadas por estudiantes de este salón.
            </p>
          ) : (
            <table className="w-full text-sm text-left border-collapse">
              <thead>
                <tr className="border-zinc-300 border-b">
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
                    className="hover:bg-zinc-50 border-zinc-200 border-b cursor-pointer"
                    onClick={() => onOpenGame(game.roomId)}
                  >
                    <td className="p-2">{formatDate(game.finishedAt)}</td>
                    <td className="p-2">
                      <code className="bg-zinc-100 px-1 rounded">
                        {game.code}
                      </code>
                    </td>
                    <td className="p-2">
                      <span className="flex flex-wrap gap-1">
                        {game.participants.map((participant) => (
                          <span
                            key={participant.userId}
                            className="bg-zinc-100 px-2 py-0.5 rounded text-xs"
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
      ) : null}

      {tab === "students" ? (
        <div className="space-y-3">
          {detail.students.length === 0 ? (
            <p className="text-zinc-500 text-sm">
              Ningún estudiante ha aceptado la invitación todavía.
            </p>
          ) : (
            <table className="w-full text-sm text-left border-collapse">
              <thead>
                <tr className="border-zinc-300 border-b">
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
                  <th className="p-2">Tendencia</th>
                </tr>
              </thead>
              <tbody>
                {detail.students.map((item) => (
                  <tr
                    key={item.userId}
                    className="hover:bg-zinc-50 border-zinc-200 border-b cursor-pointer"
                    onClick={() =>
                      setParams({ student: item.userId, tab: "games" })
                    }
                  >
                    <td className="p-2">
                      {item.name}
                      <span className="block text-zinc-500 text-xs">
                        {item.email}
                      </span>
                    </td>
                    <td className="p-2">{item.gamesPlayed}</td>
                    <td className="p-2">{percent(item.pitch)}</td>
                    <td className="p-2">{percent(item.rhythm)}</td>
                    <td className="p-2">{percent(item.overall)}</td>
                    <td className="p-2">
                      <Sparkline
                        series={trendSeriesOf(item.trend)}
                        width={84}
                        height={24}
                      />
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </div>
      ) : null}

      {tab === "invitations" ? (
        <div className="space-y-3">
          {detail.invitations.length === 0 ? (
            <p className="text-zinc-500 text-sm">
              No hay invitaciones pendientes.
            </p>
          ) : (
            <ul className="space-y-2">
              {detail.invitations.map((invitation) => (
                <li
                  key={invitation.id}
                  className="flex justify-between items-center bg-white px-3 py-2 border border-zinc-200 rounded text-sm"
                >
                  <span>
                    {invitation.name}{" "}
                    <span className="text-zinc-500">({invitation.email})</span>
                  </span>
                  <span className="text-zinc-500 text-xs">
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
              <span className="font-medium text-zinc-700 text-sm">
                Invitar por correo
              </span>
              <input
                type="email"
                className="block mt-1 p-2 border border-zinc-300 rounded w-64"
                value={email}
                onChange={(event) => setEmail(event.target.value)}
                placeholder="estudiante@correo.com"
                required
              />
            </label>
            <button
              type="submit"
              className="bg-indigo-600 hover:bg-indigo-700 px-4 py-2 rounded font-medium text-white"
            >
              Invitar
            </button>
          </form>
        </div>
      ) : null}

      {error ? <p className="text-red-600 text-sm">{error}</p> : null}
    </div>
  );
};
