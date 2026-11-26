"use client";

import { useEffect, useState } from "react";
import { type NoteEvent } from "@/lib/music";
import type {
  GalleryMessage,
  GalleryStrand,
  GameSettings,
  SpectateData,
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
import { ErrorBreakdown } from "./ErrorBreakdown";

interface SpectateViewProps {
  roomId: string;
  params: URLSearchParams;
  setParams: (updates: Record<string, string | null>) => void;
  onBack: () => void;
}

const POLL_INTERVAL_MS = 1200;

const COL_WIDTH = 150;
const ROW_HEIGHT = 92;
const NODE_PAD = 14;

const hueFor = (strandIndex: number, total: number): number =>
  (strandIndex * 360) / Math.max(total, 1);

const Sparkline = ({ notes }: { notes: NoteEvent[] }) => {
  const width = COL_WIDTH - NODE_PAD * 2 - 12;
  const height = ROW_HEIGHT - NODE_PAD * 2 - 14;
  if (notes.length === 0) {
    return <svg width={width} height={height} />;
  }
  const pitches = notes.map((note) => note.midiPitch);
  const min = Math.min(...pitches);
  const max = Math.max(...pitches);
  const span = Math.max(max - min, 1);
  const step = notes.length > 1 ? width / (notes.length - 1) : 0;
  const points = notes
    .map(
      (note, index) =>
        `${notes.length > 1 ? index * step : width / 2},${height - ((note.midiPitch - min) / span) * (height - 4) - 2}`,
    )
    .join(" ");
  return (
    <svg width={width} height={height} aria-hidden>
      <polyline
        points={points}
        fill="none"
        stroke="currentColor"
        strokeWidth={2}
        strokeLinejoin="round"
      />
    </svg>
  );
};

interface GraphNode {
  strandIndex: number;
  message: GalleryMessage;
}

interface GeneralGraphProps {
  players: { userId: string; name: string }[];
  strands: GalleryStrand[];
  onSelectMelody: (strandIndex: number) => void;
  onSelectPlayer: (userId: string) => void;
}

const GeneralGraph = ({
  players,
  strands,
  onSelectMelody,
  onSelectPlayer,
}: GeneralGraphProps) => {
  let maxRound = 0;
  for (const strand of strands) {
    for (const message of strand.messages) {
      maxRound = Math.max(maxRound, message.roundNumber ?? 0);
    }
  }
  const columnCount = maxRound + 1;
  const grid: (GraphNode | null)[][] = players.map(() =>
    Array<GraphNode | null>(columnCount).fill(null),
  );
  const rowOf = (strandIndex: number, messageIndex: number): number =>
    messageIndex === 0
      ? strandIndex
      : players.findIndex(
          (player) =>
            player.userId === strands[strandIndex].messages[messageIndex].authorUserId,
        );
  strands.forEach((strand, strandIndex) => {
    strand.messages.forEach((message, messageIndex) => {
      const row = rowOf(strandIndex, messageIndex);
      const column = message.roundNumber ?? 0;
      if (row >= 0 && row < players.length && column < columnCount) {
        grid[row][column] = { strandIndex, message };
      }
    });
  });

  const edges: { x1: number; y1: number; x2: number; y2: number; hue: number }[] =
    [];
  strands.forEach((strand, strandIndex) => {
    for (let messageIndex = 0; messageIndex < strand.messages.length - 1; messageIndex += 1) {
      const row1 = rowOf(strandIndex, messageIndex);
      const row2 = rowOf(strandIndex, messageIndex + 1);
      const col1 = strand.messages[messageIndex].roundNumber ?? 0;
      const col2 = strand.messages[messageIndex + 1].roundNumber ?? 0;
      if (row1 < 0 || row2 < 0) continue;
      edges.push({
        x1: col1 * COL_WIDTH + COL_WIDTH / 2,
        y1: row1 * ROW_HEIGHT + ROW_HEIGHT / 2,
        x2: col2 * COL_WIDTH + COL_WIDTH / 2,
        y2: row2 * ROW_HEIGHT + ROW_HEIGHT / 2,
        hue: hueFor(strandIndex, strands.length),
      });
    }
  });

  return (
    <div className="flex overflow-x-auto">
      <div className="shrink-0">
        <div style={{ height: 32 }} />
        {players.map((player) => (
          <div
            key={player.userId}
            className="flex items-center pr-3"
            style={{ height: ROW_HEIGHT }}
          >
            <button
              className="text-right text-sm font-medium text-indigo-700 hover:underline"
              onClick={() => onSelectPlayer(player.userId)}
            >
              {player.name}
            </button>
          </div>
        ))}
      </div>
      <div className="relative shrink-0">
        <div
          className="flex text-xs text-zinc-500"
          style={{ height: 32, width: columnCount * COL_WIDTH }}
        >
          {Array.from({ length: columnCount }, (_, column) => (
            <div
              key={column}
              className="flex items-center justify-center"
              style={{ width: COL_WIDTH }}
            >
              {column === 0 ? "Sistema" : `Ronda ${column}`}
            </div>
          ))}
        </div>
        <div
          className="relative"
          style={{
            width: columnCount * COL_WIDTH,
            height: players.length * ROW_HEIGHT,
          }}
        >
          <svg
            className="absolute inset-0"
            width={columnCount * COL_WIDTH}
            height={players.length * ROW_HEIGHT}
            aria-hidden
          >
            {edges.map((edge, index) => (
              <line
                key={index}
                x1={edge.x1}
                y1={edge.y1}
                x2={edge.x2}
                y2={edge.y2}
                stroke={`hsl(${edge.hue}, 65%, 55%)`}
                strokeWidth={2}
                opacity={0.7}
              />
            ))}
          </svg>
          {grid.map((row, rowIndex) =>
            row.map((node, column) => {
              if (!node) return null;
              const hue = hueFor(node.strandIndex, strands.length);
              return (
                <button
                  key={`${rowIndex}-${column}`}
                  title={`${node.message.authorName} · ${messageLabel(node.message)}`}
                  className="absolute flex flex-col items-center justify-center rounded-lg border-2 text-xs shadow-sm hover:shadow"
                  style={{
                    left: column * COL_WIDTH + NODE_PAD,
                    top: rowIndex * ROW_HEIGHT + NODE_PAD,
                    width: COL_WIDTH - NODE_PAD * 2,
                    height: ROW_HEIGHT - NODE_PAD * 2,
                    borderColor: `hsl(${hue}, 65%, 55%)`,
                    backgroundColor: `hsl(${hue}, 70%, 93%)`,
                    color: `hsl(${hue}, 60%, 35%)`,
                  }}
                  onClick={() => onSelectMelody(node.strandIndex)}
                >
                  <Sparkline notes={node.message.notes} />
                  <span className="mt-0.5 text-[10px] text-zinc-500">
                    {node.message.isSystem
                      ? "original"
                      : `ronda ${node.message.roundNumber}`}
                  </span>
                </button>
              );
            }),
          )}
        </div>
      </div>
    </div>
  );
};

interface PlayerRoundRow {
  roundNumber: number;
  activity: GalleryMessage["activity"];
  receivedNotes: NoteEvent[];
  producedNotes: NoteEvent[];
  recordingUrl: string | null;
  evaluation: GalleryMessage["evaluation"];
  errorReport: GalleryMessage["errorReport"];
}

export const SpectateView = ({
  roomId,
  params,
  setParams,
  onBack,
}: SpectateViewProps) => {
  const [data, setData] = useState<SpectateData | null>(null);
  const [error, setError] = useState<string | null>(null);

  const view = params.get("view") ?? "general";
  const melodyIndex = Number(params.get("melody") ?? "0");
  const playerParam = params.get("player");

  useEffect(() => {
    let cancelled = false;
    const load = async () => {
      try {
        const response = await fetch(`/api/rooms/${roomId}/spectate`, {
          credentials: "include",
        });
        const body = (await response.json().catch(() => ({}))) as SpectateData & {
          error?: string;
        };
        if (!response.ok) {
          throw new Error(body.error ?? "No se pudo cargar la partida");
        }
        if (!cancelled) {
          setData(body);
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
      stopMelodyMidi();
    };
  }, [roomId]);

  if (error && !data) {
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
  if (!data) {
    return <p className="text-sm text-zinc-500">Cargando partida…</p>;
  }

  const settings: GameSettings | null = data.room.settings;
  const tempoBpm = settings?.tempoBpm ?? 90;
  const gridBeats = GRID_BEATS[settings?.difficulty ?? "low"];
  const selectedMelody = Math.min(
    Math.max(Number.isFinite(melodyIndex) ? melodyIndex : 0, 0),
    Math.max(data.strands.length - 1, 0),
  );
  const selectedPlayer =
    data.players.find((player) => player.userId === playerParam) ??
    data.players[0];

  const playerRounds: PlayerRoundRow[] = [];
  for (const strand of data.strands) {
    for (let index = 1; index < strand.messages.length; index += 1) {
      const message = strand.messages[index];
      if (message.authorUserId !== selectedPlayer?.userId) continue;
      playerRounds.push({
        roundNumber: message.roundNumber ?? 0,
        activity: message.activity,
        receivedNotes: strand.messages[index - 1].notes,
        producedNotes: message.notes,
        recordingUrl: message.recordingUrl,
        evaluation: message.evaluation,
        errorReport: message.errorReport,
      });
    }
  }
  playerRounds.sort((a, b) => a.roundNumber - b.roundNumber);

  const statusLabel =
    data.room.status === "finished"
      ? "finalizada"
      : data.room.status === "in_progress"
        ? `en curso · ronda ${data.room.currentRound} de ${data.room.roundCount}`
        : "esperando";

  const tab = (id: string, label: string) => (
    <button
      className={`rounded px-3 py-1 text-sm ${view === id ? "bg-indigo-600 font-medium text-white" : "border border-zinc-300 hover:bg-zinc-50"}`}
      onClick={() => setParams({ view: id })}
    >
      {label}
    </button>
  );

  return (
    <div className="space-y-6">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <div>
          <h2 className="text-2xl font-semibold">
            Espectación —{" "}
            <code className="rounded bg-zinc-100 px-2 py-1">
              {data.room.code}
            </code>
          </h2>
          <p className="text-sm text-zinc-500">Partida {statusLabel}</p>
        </div>
        <button
          className="rounded border border-zinc-300 px-3 py-1 text-sm hover:bg-zinc-50"
          onClick={onBack}
        >
          ← Volver
        </button>
      </div>

      <div className="flex flex-wrap gap-2">
        {tab("general", "Vista general")}
        {tab("melody", "Detalle por melodía")}
        {tab("player", "Detalle por jugador")}
      </div>

      {view === "general" ? (
        data.strands.length === 0 ? (
          <p className="text-sm text-zinc-500">
            La partida aún no ha generado melodías.
          </p>
        ) : (
          <GeneralGraph
            players={data.players}
            strands={data.strands}
            onSelectMelody={(index) =>
              setParams({ view: "melody", melody: String(index) })
            }
            onSelectPlayer={(userId) =>
              setParams({ view: "player", player: userId })
            }
          />
        )
      ) : null}

      {view === "melody" ? (
        <div className="space-y-4">
          <div className="flex flex-wrap gap-2">
            {data.strands.map((_, index) => (
              <button
                key={index}
                className={`rounded px-3 py-1 text-sm ${index === selectedMelody ? "bg-indigo-600 font-medium text-white" : "border border-zinc-300 hover:bg-zinc-50"}`}
                onClick={() => setParams({ melody: String(index) })}
              >
                Melodía {index + 1}
              </button>
            ))}
          </div>
          {data.strands[selectedMelody]?.messages.map((message, index) => (
            <div key={index} className="flex items-start gap-3">
              <div className="w-28 shrink-0 pt-2 text-right">
                <p
                  className={`text-sm ${message.isSystem ? "font-semibold text-indigo-600" : "font-medium text-zinc-800"}`}
                >
                  {message.authorName}
                </p>
                <p className="text-xs text-zinc-500">{messageLabel(message)}</p>
                {message.evaluation ? (
                  <p className="text-xs text-zinc-500">
                    General {percent(message.evaluation.overall)}
                  </p>
                ) : null}
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
      ) : null}

      {view === "player" && selectedPlayer ? (
        <div className="space-y-4">
          <div className="flex flex-wrap gap-2">
            {data.players.map((player) => (
              <button
                key={player.userId}
                className={`rounded px-3 py-1 text-sm ${player.userId === selectedPlayer.userId ? "bg-indigo-600 font-medium text-white" : "border border-zinc-300 hover:bg-zinc-50"}`}
                onClick={() => setParams({ player: player.userId })}
              >
                {player.name}
              </button>
            ))}
          </div>
          {playerRounds.length === 0 ? (
            <p className="text-sm text-zinc-500">
              {selectedPlayer.name} aún no ha completado rondas.
            </p>
          ) : (
            playerRounds.map((row) => (
              <div
                key={row.roundNumber}
                className="rounded-lg border border-zinc-200 bg-white p-4"
              >
                <div className="flex flex-wrap items-center justify-between gap-2">
                  <p className="text-sm font-medium">
                    Ronda {row.roundNumber} —{" "}
                    {row.activity ? ACTIVITY_LABEL[row.activity] : ""}
                  </p>
                  {row.evaluation ? (
                    <p className="text-xs text-zinc-500">
                      Alturas {percent(row.evaluation.pitch.f1)} · Ritmo{" "}
                      {percent(row.evaluation.rhythm.f1)} · General{" "}
                      {percent(row.evaluation.overall)}
                    </p>
                  ) : null}
                </div>
                <div className="mt-3 grid gap-4 md:grid-cols-2">
                  <div className="space-y-1">
                    <p className="text-xs text-zinc-500">Recibió</p>
                    <MelodyPanel
                      notes={row.receivedNotes}
                      gridBeats={gridBeats}
                      onPlay={() => playMelodyMidi(row.receivedNotes, tempoBpm)}
                      onStop={stopMelodyMidi}
                    />
                  </div>
                  <div className="space-y-1">
                    <p className="text-xs text-zinc-500">Produjo</p>
                    <MelodyPanel
                      notes={row.producedNotes}
                      gridBeats={gridBeats}
                      recordingUrl={row.recordingUrl}
                      onPlay={() => playMelodyMidi(row.producedNotes, tempoBpm)}
                      onStop={stopMelodyMidi}
                    />
                  </div>
                </div>
                <ErrorBreakdown report={row.errorReport} />
              </div>
            ))
          )}
        </div>
      ) : null}
    </div>
  );
};
