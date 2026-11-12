import type { EvaluatedNote } from "@/lib/music";
import {
  BASIC_PITCH_MODEL_URL,
  type TranscriptionRequest,
  type TranscriptionResponse,
} from "./protocol";
import { normalizeTranscription, resampleToMono } from "./normalize";

type PendingRequest = {
  resolve: (notes: EvaluatedNote[]) => void;
  reject: (error: Error) => void;
  onProgress?: (percent: number) => void;
};

let worker: Worker | null = null;
let nextRequestId = 1;
const pending = new Map<number, PendingRequest>();

const getWorker = (): Worker => {
  if (worker) return worker;
  worker = new Worker(
    new URL("./transcription.worker.ts", import.meta.url),
  );
  worker.onmessage = (event: MessageEvent<TranscriptionResponse>) => {
    const message = event.data;
    const request = pending.get(message.id);
    if (!request) return;
    if (message.type === "progress") {
      request.onProgress?.(message.percent);
      return;
    }
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
  resampleToMono(audioBuffer).then(
    (audio) =>
      new Promise<EvaluatedNote[]>((resolve, reject) => {
        const id = nextRequestId;
        nextRequestId += 1;
        pending.set(id, { resolve, reject, onProgress });
        const request: TranscriptionRequest = {
          id,
          audio,
          modelUrl: BASIC_PITCH_MODEL_URL,
        };
        getWorker().postMessage(request, [audio.buffer]);
      }),
  );
