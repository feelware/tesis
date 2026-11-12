"use client";

import { useState } from "react";
import type { Difficulty } from "@/lib/music";

export interface GameConfig {
  difficulty: Difficulty;
  firstActivity: "dictation" | "sight_singing";
  roundCount: number;
  tempoBpm: number;
}

interface ConfigFormProps {
  onStart: (config: GameConfig) => void;
}

const DEFAULT_CONFIG: GameConfig = {
  difficulty: "low",
  firstActivity: "dictation",
  roundCount: 4,
  tempoBpm: 90,
};

export const ConfigForm = ({ onStart }: ConfigFormProps) => {
  const [config, setConfig] = useState<GameConfig>(DEFAULT_CONFIG);

  return (
    <form
      className="mx-auto max-w-xl space-y-6 rounded-lg border border-zinc-200 bg-white p-6 shadow-sm"
      onSubmit={(event) => {
        event.preventDefault();
        onStart(config);
      }}
    >
      <h2 className="text-xl font-semibold">Configuración de la partida</h2>

      <label className="block">
        <span className="text-sm font-medium text-zinc-700">Dificultad</span>
        <select
          className="mt-1 w-full rounded border border-zinc-300 p-2"
          value={config.difficulty}
          onChange={(event) =>
            setConfig({ ...config, difficulty: event.target.value as Difficulty })
          }
        >
          <option value="low">Baja (8 notas, intervalos máx. 2 semitonos)</option>
          <option value="medium">Media (15 notas, intervalos máx. 5 semitonos)</option>
          <option value="high">Alta (24 notas, intervalos máx. 7 semitonos)</option>
        </select>
      </label>

      <label className="block">
        <span className="text-sm font-medium text-zinc-700">Primera actividad</span>
        <select
          className="mt-1 w-full rounded border border-zinc-300 p-2"
          value={config.firstActivity}
          onChange={(event) =>
            setConfig({
              ...config,
              firstActivity: event.target.value as GameConfig["firstActivity"],
            })
          }
        >
          <option value="dictation">Dictado</option>
          <option value="sight_singing">Repentización</option>
        </select>
      </label>

      <label className="block">
        <span className="text-sm font-medium text-zinc-700">
          Número de rondas: {config.roundCount}
        </span>
        <input
          type="range"
          min={2}
          max={8}
          step={1}
          className="mt-1 w-full"
          value={config.roundCount}
          onChange={(event) =>
            setConfig({ ...config, roundCount: Number(event.target.value) })
          }
        />
      </label>

      <label className="block">
        <span className="text-sm font-medium text-zinc-700">
          Tempo: {config.tempoBpm} BPM
        </span>
        <input
          type="range"
          min={60}
          max={120}
          step={5}
          className="mt-1 w-full"
          value={config.tempoBpm}
          onChange={(event) =>
            setConfig({ ...config, tempoBpm: Number(event.target.value) })
          }
        />
      </label>

      <button
        type="submit"
        className="w-full rounded bg-indigo-600 p-2 font-medium text-white hover:bg-indigo-700"
      >
        Iniciar partida
      </button>
    </form>
  );
};
