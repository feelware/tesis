"use client";

import { useMemo, useRef, useState } from "react";
import { generateMelody, type Difficulty, type Melody } from "@/lib/music";
import { playNotes, type PlaybackHandle } from "@/lib/audio/playback";
import { ConfigForm, type GameConfig } from "./ConfigForm";
import { PianoRoll } from "./PianoRoll";

type Activity = "dictation" | "sight_singing";

interface Round {
  index: number;
  activity: Activity;
  melody: Melody;
}

type Phase = "config" | "playing" | "summary";

const GRID_BEATS: Record<Difficulty, number> = {
  low: 1,
  medium: 0.5,
  high: 1 / 6,
};

const ACTIVITY_LABEL: Record<Activity, string> = {
  dictation: "Dictado",
  sight_singing: "Repentización",
};

const buildRounds = (config: GameConfig, sessionSeed: string): Round[] =>
  Array.from({ length: config.roundCount }, (_, index) => ({
    index,
    activity:
      index % 2 === 0 ? config.firstActivity : config.firstActivity === "dictation" ? "sight_singing" : "dictation",
    melody: generateMelody({
      difficulty: config.difficulty,
      seed: `${sessionSeed}-r${index + 1}`,
      tempoBpm: config.tempoBpm,
    }),
  }));

export const Game = () => {
  const [phase, setPhase] = useState<Phase>("config");
  const [config, setConfig] = useState<GameConfig | null>(null);
  const [sessionSeed, setSessionSeed] = useState("");
  const [rounds, setRounds] = useState<Round[]>([]);
  const [currentRound, setCurrentRound] = useState(0);
  const [playheadBeat, setPlayheadBeat] = useState<number | null>(null);
  const playbackRef = useRef<PlaybackHandle | null>(null);

  const round = rounds[currentRound];

  const rollRange = useMemo(() => {
    if (!round) return { minPitch: 55, maxPitch: 72, totalBeats: 8 };
    const pitches = round.melody.notes.map((note) => note.midiPitch);
    const lastNote = round.melody.notes[round.melody.notes.length - 1];
    return {
      minPitch: Math.max(36, Math.min(...pitches) - 2),
      maxPitch: Math.min(84, Math.max(...pitches) + 2),
      totalBeats: Math.ceil(lastNote.onsetBeats + lastNote.durationBeats) + 2,
    };
  }, [round]);

  const startGame = (nextConfig: GameConfig) => {
    const seed = crypto.randomUUID().slice(0, 8);
    setConfig(nextConfig);
    setSessionSeed(seed);
    setRounds(buildRounds(nextConfig, seed));
    setCurrentRound(0);
    setPhase("playing");
  };

  const playMelody = (melody: Melody) => {
    playbackRef.current?.stop();
    setPlayheadBeat(0);
    playbackRef.current = playNotes(melody.notes, melody.tempoBpm, setPlayheadBeat);
    void playbackRef.current.finished.then(() => setPlayheadBeat(null));
  };

  const resetGame = () => {
    playbackRef.current?.stop();
    setPhase("config");
  };

  if (phase === "config") {
    return <ConfigForm onStart={startGame} />;
  }

  if (phase === "summary") {
    return (
      <div className="mx-auto max-w-2xl space-y-6">
        <h2 className="text-2xl font-semibold">Resumen de la partida</h2>
        <p className="text-sm text-zinc-600">
          Sesión: <code className="rounded bg-zinc-100 px-1">{sessionSeed}</code>
        </p>
        <table className="w-full border-collapse text-left text-sm">
          <thead>
            <tr className="border-b border-zinc-300">
              <th className="p-2">Ronda</th>
              <th className="p-2">Actividad</th>
              <th className="p-2">Melodía</th>
            </tr>
          </thead>
          <tbody>
            {rounds.map((item) => (
              <tr key={item.index} className="border-b border-zinc-200">
                <td className="p-2">{item.index + 1}</td>
                <td className="p-2">{ACTIVITY_LABEL[item.activity]}</td>
                <td className="p-2">
                  <code className="rounded bg-zinc-100 px-1">{item.melody.seed}</code>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
        <button
          className="rounded bg-indigo-600 px-4 py-2 font-medium text-white hover:bg-indigo-700"
          onClick={resetGame}
        >
          Nueva partida
        </button>
      </div>
    );
  }

  return (
    <div className="mx-auto max-w-3xl space-y-6">
      <header className="flex items-center justify-between">
        <h2 className="text-xl font-semibold">
          Ronda {currentRound + 1} de {rounds.length} — {ACTIVITY_LABEL[round.activity]}
        </h2>
        <span className="text-sm text-zinc-600">
          Sesión: <code className="rounded bg-zinc-100 px-1">{sessionSeed}</code>
        </span>
      </header>

      {round.activity === "dictation" ? (
        <div className="space-y-4 rounded-lg border border-zinc-200 bg-white p-6">
          <p className="text-zinc-700">Escucha la melodía y transcríbela.</p>
          <button
            className="rounded bg-indigo-600 px-4 py-2 font-medium text-white hover:bg-indigo-700"
            onClick={() => playMelody(round.melody)}
          >
            Escuchar melodía
          </button>
          <p className="text-sm text-zinc-500">
            El editor de dictado llega en el siguiente hito.
          </p>
        </div>
      ) : (
        <div className="space-y-4 rounded-lg border border-zinc-200 bg-white p-6">
          <p className="text-zinc-700">Interpreta esta melodía con la voz.</p>
          <PianoRoll
            notes={round.melody.notes}
            minPitch={rollRange.minPitch}
            maxPitch={rollRange.maxPitch}
            totalBeats={rollRange.totalBeats}
            gridBeats={GRID_BEATS[config?.difficulty ?? "low"]}
            playheadBeat={playheadBeat}
          />
          <button
            className="rounded bg-indigo-600 px-4 py-2 font-medium text-white hover:bg-indigo-700"
            onClick={() => playMelody(round.melody)}
          >
            Escuchar melodía
          </button>
          <p className="text-sm text-zinc-500">
            La grabación y transcripción llegan en el siguiente hito.
          </p>
        </div>
      )}

      <nav className="flex justify-between">
        <button
          className="rounded border border-zinc-300 px-4 py-2 disabled:opacity-40"
          disabled={currentRound === 0}
          onClick={() => setCurrentRound(currentRound - 1)}
        >
          Ronda anterior
        </button>
        <button
          className="rounded bg-indigo-600 px-4 py-2 font-medium text-white hover:bg-indigo-700"
          onClick={() =>
            currentRound + 1 < rounds.length
              ? setCurrentRound(currentRound + 1)
              : setPhase("summary")
          }
        >
          {currentRound + 1 < rounds.length ? "Siguiente ronda" : "Ver resumen"}
        </button>
      </nav>
    </div>
  );
};
