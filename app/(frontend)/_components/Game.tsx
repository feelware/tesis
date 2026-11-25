"use client";

import { useMemo, useState } from "react";
import {
  generateMelody,
  type Difficulty,
  type EvaluationResult,
  type Melody,
  type NoteEvent,
} from "@/lib/music";
import { saveGameSession } from "@/lib/persistence";
import { ConfigForm, type GameConfig } from "./ConfigForm";
import { DictationExercise } from "./DictationExercise";
import { EvaluationPanel } from "./EvaluationPanel";
import { SightSingingExercise } from "./SightSingingExercise";

type Activity = "dictation" | "sight_singing";

interface Round {
  index: number;
  activity: Activity;
  melody: Melody;
}

interface RoundResult {
  evaluation: EvaluationResult;
  response: NoteEvent[];
  recording: Blob | null;
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

const percent = (value: number) => `${Math.round(value * 1000) / 10}%`;

const buildRounds = (config: GameConfig, sessionSeed: string): Round[] =>
  Array.from({ length: config.roundCount }, (_, index) => ({
    index,
    activity:
      index % 2 === 0
        ? config.firstActivity
        : config.firstActivity === "dictation"
          ? "sight_singing"
          : "dictation",
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
  const [results, setResults] = useState<Record<number, RoundResult>>({});
  const [saveStatus, setSaveStatus] = useState<
    "idle" | "saving" | "saved" | "error"
  >("idle");

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

  const responseRollRange = useMemo(() => {
    const responseNotes = round ? (results[round.index]?.response ?? []) : [];
    if (responseNotes.length === 0) return rollRange;
    const pitches = responseNotes.map((note) => note.midiPitch);
    const lowest = Math.min(...pitches);
    const highest = Math.max(...pitches);
    const center = (lowest + highest) / 2;
    const referenceHalfSpan = (rollRange.maxPitch - rollRange.minPitch) / 2;
    const sungHalfSpan = (highest - lowest) / 2 + 1;
    const halfSpan = Math.max(referenceHalfSpan, sungHalfSpan);
    return {
      minPitch: Math.round(center - halfSpan),
      maxPitch: Math.round(center + halfSpan),
      totalBeats: rollRange.totalBeats,
    };
  }, [round, results, rollRange]);

  const gridBeats = GRID_BEATS[config?.difficulty ?? "low"];

  const scoredResults = Object.values(results);
  const averageScore =
    scoredResults.length === 0
      ? 0
      : scoredResults.reduce((sum, item) => sum + item.evaluation.overall, 0) /
        scoredResults.length;

  const startGame = (nextConfig: GameConfig) => {
    const seed = crypto.randomUUID().slice(0, 8);
    setConfig(nextConfig);
    setSessionSeed(seed);
    setRounds(buildRounds(nextConfig, seed));
    setCurrentRound(0);
    setResults({});
    setSaveStatus("idle");
    setPhase("playing");
  };

  const persistSession = async () => {
    if (!config) return;
    setSaveStatus("saving");
    try {
      await saveGameSession({
        sessionSeed,
        difficulty: config.difficulty,
        firstActivity: config.firstActivity,
        tempoBpm: config.tempoBpm,
        averageScore,
        rounds: rounds.map((item) => ({
          roundNumber: item.index + 1,
          activity: item.activity,
          melody: item.melody,
          response: results[item.index]?.response ?? [],
          evaluation: results[item.index]?.evaluation ?? null,
        })),
      });
      setSaveStatus("saved");
    } catch {
      setSaveStatus("error");
    }
  };

  const advance = () => {
    if (currentRound + 1 < rounds.length) {
      setCurrentRound(currentRound + 1);
      return;
    }
    setPhase("summary");
    void persistSession();
  };

  const resetGame = () => {
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
        {saveStatus === "saving" ? (
          <p className="text-sm text-zinc-500">Guardando partida…</p>
        ) : null}
        {saveStatus === "saved" ? (
          <p className="text-sm text-emerald-600">Partida guardada en el CMS.</p>
        ) : null}
        {saveStatus === "error" ? (
          <p className="text-sm text-red-600">
            No se pudo guardar la partida.
          </p>
        ) : null}
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
            {rounds.map((item) => {
              const result = results[item.index];
              return (
                <tr key={item.index} className="border-b border-zinc-200">
                  <td className="p-2">{item.index + 1}</td>
                  <td className="p-2">{ACTIVITY_LABEL[item.activity]}</td>
                  <td className="p-2">
                    {result ? percent(result.evaluation.pitch.f1) : "—"}
                  </td>
                  <td className="p-2">
                    {result ? percent(result.evaluation.rhythm.f1) : "—"}
                  </td>
                  <td className="p-2">
                    {result ? percent(result.evaluation.overall) : "—"}
                  </td>
                </tr>
              );
            })}
          </tbody>
          <tfoot>
            <tr className="border-t-2 border-zinc-400 font-semibold">
              <td className="p-2" colSpan={4}>
                Promedio de precisión general
              </td>
              <td className="p-2">{percent(averageScore)}</td>
            </tr>
          </tfoot>
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

  const result = results[round.index];

  return (
    <div className="mx-auto max-w-3xl space-y-6">
      <header className="flex items-center justify-between">
        <h2 className="text-xl font-semibold">
          Ronda {currentRound + 1} de {rounds.length} —{" "}
          {ACTIVITY_LABEL[round.activity]}
        </h2>
        <span className="text-sm text-zinc-600">
          Sesión: <code className="rounded bg-zinc-100 px-1">{sessionSeed}</code>
        </span>
      </header>

      {round.activity === "dictation" ? (
        result ? (
          <>
            <EvaluationPanel
              melody={round.melody}
              response={result.response}
              evaluation={result.evaluation}
              gridBeats={gridBeats}
              minPitch={rollRange.minPitch}
              maxPitch={rollRange.maxPitch}
              totalBeats={rollRange.totalBeats}
            />
            <button
              className="rounded bg-indigo-600 px-4 py-2 font-medium text-white hover:bg-indigo-700"
              onClick={advance}
            >
              {currentRound + 1 < rounds.length ? "Siguiente ronda" : "Ver resumen"}
            </button>
          </>
        ) : (
          <DictationExercise
            melody={round.melody}
            gridBeats={gridBeats}
            minPitch={rollRange.minPitch}
            maxPitch={rollRange.maxPitch}
            totalBeats={rollRange.totalBeats}
            onComplete={(evaluation, response) =>
              setResults((current) => ({
                ...current,
                [round.index]: { evaluation, response, recording: null },
              }))
            }
          />
        )
      ) : result ? (
        <>
          <EvaluationPanel
            melody={round.melody}
            response={result.response}
            evaluation={result.evaluation}
            gridBeats={gridBeats}
            minPitch={rollRange.minPitch}
            maxPitch={rollRange.maxPitch}
            totalBeats={rollRange.totalBeats}
            responseMinPitch={responseRollRange.minPitch}
            responseMaxPitch={responseRollRange.maxPitch}
          />
          <button
            className="rounded bg-indigo-600 px-4 py-2 font-medium text-white hover:bg-indigo-700"
            onClick={advance}
          >
            {currentRound + 1 < rounds.length ? "Siguiente ronda" : "Ver resumen"}
          </button>
        </>
      ) : (
        <SightSingingExercise
          melody={round.melody}
          gridBeats={gridBeats}
          minPitch={rollRange.minPitch}
          maxPitch={rollRange.maxPitch}
          totalBeats={rollRange.totalBeats}
          onComplete={(evaluation, response, recording) =>
            setResults((current) => ({
              ...current,
              [round.index]: { evaluation, response, recording },
            }))
          }
        />
      )}
    </div>
  );
};
