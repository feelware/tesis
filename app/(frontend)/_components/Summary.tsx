"use client";

import type { LeaderboardEntry } from "@/lib/game/types";

interface SummaryProps {
  leaderboard: LeaderboardEntry[];
  onNewGame: () => void;
}

const ACTIVITY_LABEL = {
  dictation: "Dictado",
  sight_singing: "Repentización",
} as const;

const percent = (value: number) => `${Math.round(value * 1000) / 10}%`;

export const Summary = ({ leaderboard, onNewGame }: SummaryProps) => {
  const winner = leaderboard[0];

  return (
    <div className="mx-auto max-w-2xl space-y-6">
      <h2 className="text-2xl font-semibold">Resultados de la partida</h2>
      {winner ? (
        <p className="text-sm text-zinc-600">
          Ganador: <span className="font-semibold">{winner.name}</span> con{" "}
          {percent(winner.overall)} de precisión general.
        </p>
      ) : null}
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
      {leaderboard.map((entry) => (
        <div key={entry.userId} className="space-y-2">
          <h3 className="text-lg font-semibold">Rondas de {entry.name}</h3>
          <table className="w-full border-collapse text-left text-sm">
            <thead>
              <tr className="border-b border-zinc-300">
                <th className="p-2">Ronda</th>
                <th className="p-2">Actividad</th>
                <th className="p-2">Alturas</th>
                <th className="p-2">Ritmo</th>
                <th className="p-2">General</th>
              </tr>
            </thead>
            <tbody>
              {entry.rounds.map((round) => (
                <tr
                  key={round.roundNumber}
                  className="border-b border-zinc-200"
                >
                  <td className="p-2">{round.roundNumber}</td>
                  <td className="p-2">{ACTIVITY_LABEL[round.activity]}</td>
                  <td className="p-2">{percent(round.pitch)}</td>
                  <td className="p-2">{percent(round.rhythm)}</td>
                  <td className="p-2">{percent(round.overall)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      ))}
      <button
        className="rounded bg-indigo-600 px-4 py-2 font-medium text-white hover:bg-indigo-700"
        onClick={onNewGame}
      >
        Nueva partida
      </button>
    </div>
  );
};
