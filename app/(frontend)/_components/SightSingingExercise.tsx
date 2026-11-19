"use client";

import { useRef, useState } from "react";
import {
  evaluateSimilarity,
  melodyToEvaluatedNotes,
  transcriptionTolerances,
  type EvaluationResult,
  type Melody,
  type NoteEvent,
} from "@/lib/music";
import {
  decodeAudio,
  startRecording,
  type RecordingHandle,
} from "@/lib/audio/recording";
import { playAudioBuffer, type PlaybackHandle } from "@/lib/audio/playback";
import { transcribeAudio } from "@/lib/transcription";
import { PianoRoll } from "./PianoRoll";

interface SightSingingExerciseProps {
  melody: Melody;
  gridBeats: number;
  minPitch: number;
  maxPitch: number;
  totalBeats: number;
  onComplete: (
    evaluation: EvaluationResult,
    response: NoteEvent[],
    recording: Blob | null,
  ) => void;
}

type ExercisePhase = "idle" | "recording" | "recorded" | "transcribing";

const MAX_RECORDING_MS = 30000;

export const SightSingingExercise = ({
  melody,
  gridBeats,
  minPitch,
  maxPitch,
  totalBeats,
  onComplete,
}: SightSingingExerciseProps) => {
  const [phase, setPhase] = useState<ExercisePhase>("idle");
  const [recordingBlob, setRecordingBlob] = useState<Blob | null>(null);
  const [recordedAudio, setRecordedAudio] = useState<AudioBuffer | null>(null);
  const [progress, setProgress] = useState(0);
  const [error, setError] = useState<string | null>(null);
  const recordingRef = useRef<RecordingHandle | null>(null);
  const playbackRef = useRef<PlaybackHandle | null>(null);
  const autoStopRef = useRef<ReturnType<typeof setTimeout> | null>(null);

  const clearAutoStop = () => {
    if (autoStopRef.current !== null) {
      globalThis.clearTimeout(autoStopRef.current);
      autoStopRef.current = null;
    }
  };

  const start = async () => {
    setError(null);
    try {
      recordingRef.current = await startRecording();
      setPhase("recording");
      autoStopRef.current = globalThis.setTimeout(() => {
        void stop();
      }, MAX_RECORDING_MS);
    } catch {
      setError(
        "No se pudo acceder al micrófono. Revisa los permisos del navegador e inténtalo de nuevo.",
      );
    }
  };

  const stop = async () => {
    clearAutoStop();
    const handle = recordingRef.current;
    if (!handle) return;
    const recording = await handle.stop();
    recordingRef.current = null;
    setRecordingBlob(recording.blob);
    try {
      setRecordedAudio(await decodeAudio(recording.blob));
      setPhase("recorded");
    } catch {
      setError("No se pudo decodificar la grabación. Vuelve a intentarlo.");
      setPhase("idle");
    }
  };

  const submit = async () => {
    if (!recordedAudio) return;
    setError(null);
    setProgress(0);
    setPhase("transcribing");
    try {
      const response = await transcribeAudio(recordedAudio, setProgress);
      if (response.length === 0) {
        setError(
          "No se detectaron notas en la grabación. Intenta cantar más cerca del micrófono.",
        );
        setPhase("recorded");
        return;
      }
      const evaluation = evaluateSimilarity(
        melodyToEvaluatedNotes(melody),
        response,
        transcriptionTolerances(melody.difficulty),
      );
      const responseAsNoteEvents: NoteEvent[] = response.map((note) => ({
        midiPitch: note.midiPitch,
        onsetBeats: (note.onsetSeconds * melody.tempoBpm) / 60,
        durationBeats: (note.durationSeconds * melody.tempoBpm) / 60,
      }));
      onComplete(evaluation, responseAsNoteEvents, recordingBlob);
    } catch (transcriptionError) {
      setError(
        transcriptionError instanceof Error
          ? `La transcripción falló: ${transcriptionError.message}`
          : "La transcripción falló. Vuelve a intentarlo.",
      );
      setPhase("recorded");
    }
  };

  const retake = () => {
    clearAutoStop();
    recordingRef.current?.cancel();
    recordingRef.current = null;
    playbackRef.current?.stop();
    setRecordingBlob(null);
    setRecordedAudio(null);
    setError(null);
    setPhase("idle");
  };

  return (
    <div className="space-y-4 rounded-lg border border-zinc-200 bg-white p-6">
      <p className="text-zinc-700">
        Interpreta con la voz la melodía que ves en el piano roll.
      </p>
      <PianoRoll
        notes={melody.notes}
        minPitch={minPitch}
        maxPitch={maxPitch}
        totalBeats={totalBeats}
        gridBeats={gridBeats}
      />

      {phase === "recording" ? (
        <div className="flex items-center gap-3">
          <span className="flex items-center gap-2 text-red-600">
            <span className="h-3 w-3 animate-pulse rounded-full bg-red-600" />
            Grabando… (máximo 30 segundos)
          </span>
          <button
            className="rounded bg-red-600 px-4 py-2 font-medium text-white hover:bg-red-700"
            onClick={() => void stop()}
          >
            Detener grabación
          </button>
        </div>
      ) : (
        <div className="flex flex-wrap items-center gap-3">
          {phase === "idle" ? (
            <button
              className="rounded bg-indigo-600 px-4 py-2 font-medium text-white hover:bg-indigo-700"
              onClick={() => void start()}
            >
              Iniciar grabación
            </button>
          ) : null}
          {phase === "recorded" && recordedAudio ? (
            <>
              <button
                className="rounded border border-zinc-300 px-4 py-2"
                onClick={() => {
                  playbackRef.current?.stop();
                  playbackRef.current = playAudioBuffer(recordedAudio);
                }}
              >
                Escuchar grabación
              </button>
              <button
                className="rounded border border-zinc-300 px-4 py-2"
                onClick={retake}
              >
                Repetir grabación
              </button>
              <button
                className="rounded bg-emerald-600 px-4 py-2 font-medium text-white hover:bg-emerald-700"
                onClick={() => void submit()}
              >
                Enviar y evaluar
              </button>
            </>
          ) : null}
          {phase === "transcribing" ? (
            <span className="text-zinc-600">
              Transcribiendo la grabación… {Math.round(progress * 100)}%. Puede
              tardar; no cierres la pestaña.
            </span>
          ) : null}
        </div>
      )}

      {error ? <p className="text-sm text-red-600">{error}</p> : null}
    </div>
  );
};
