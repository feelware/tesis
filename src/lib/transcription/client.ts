import type { EvaluatedNote } from "@/lib/music";
import {
  BASIC_PITCH_MODEL_URL,
  type TranscriptionRequest,
  type TranscriptionResponse,
} from "./protocol";
import {
  normalizeTranscription,
  resampleToMono,
  trimLeadingSilence,
} from "./normalize";

const STALL_TIMEOUT_MS = 30000;
const WATCHDOG_INTERVAL_MS = 5000;

type PendingRequest = {
  resolve: (notes: EvaluatedNote[]) => void;
  reject: (error: Error) => void;
  onProgress?: (percent: number) => void;
  lastActivityAt: number;
  watchdog: ReturnType<typeof setInterval> | null;
};

let worker: Worker | null = null;
let nextRequestId = 1;
const pending = new Map<number, PendingRequest>();

const clearRequest = (request: PendingRequest) => {
  if (request.watchdog !== null) globalThis.clearInterval(request.watchdog);
};

const failAll = (error: Error) => {
  for (const request of pending.values()) {
    clearRequest(request);
    request.reject(error);
  }
  pending.clear();
  worker?.terminate();
  worker = null;
};

const getWorker = (): Worker => {
  if (worker) return worker;
  worker = new Worker(new URL("./transcription.worker.ts", import.meta.url));
  worker.onerror = (event) => {
    failAll(
      new Error(
        `el proceso de transcripción falló: ${event.message || "error desconocido"}`,
      ),
    );
  };
  worker.onmessageerror = () => {
    failAll(new Error("el proceso de transcripción devolvió un mensaje ilegible"));
  };
  worker.onmessage = (event: MessageEvent<TranscriptionResponse>) => {
    const message = event.data;
    const request = pending.get(message.id);
    if (!request) return;
    request.lastActivityAt = Date.now();
    if (message.type === "progress") {
      request.onProgress?.(message.percent);
      return;
    }
    clearRequest(request);
    pending.delete(message.id);
    if (message.type === "notes") {
      request.resolve(normalizeTranscription(message.notes));
    } else {
      request.reject(new Error(message.message));
    }
  };
  return worker;
};

export const transcribeAudio = (
  audioBuffer: AudioBuffer,
  onProgress?: (percent: number) => void,
): Promise<EvaluatedNote[]> =>
  resampleToMono(audioBuffer).then((mono) => {
    const audio = trimLeadingSilence(mono, 22050);
    return new Promise<EvaluatedNote[]>((resolve, reject) => {
      const id = nextRequestId;
      nextRequestId += 1;
      const request: PendingRequest = {
        resolve,
        reject,
        onProgress,
        lastActivityAt: Date.now(),
        watchdog: null,
      };
      request.watchdog = globalThis.setInterval(() => {
        if (Date.now() - request.lastActivityAt > STALL_TIMEOUT_MS) {
          failAll(
            new Error(
              "la transcripción dejó de avanzar y fue cancelada; vuelve a intentarlo",
            ),
          );
        }
      }, WATCHDOG_INTERVAL_MS);
      pending.set(id, request);
      const message: TranscriptionRequest = {
        id,
        audio,
        modelUrl: BASIC_PITCH_MODEL_URL,
      };
      getWorker().postMessage(message, [audio.buffer]);
    });
  });
