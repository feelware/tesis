import type {
  BasicNoteTime,
  TranscriptionRequest,
  TranscriptionResponse,
} from "./protocol";
import { trackMonophonic } from "./dsp-tracker";

type WorkerScope = {
  onmessage: (event: MessageEvent<TranscriptionRequest>) => void;
  postMessage: (message: TranscriptionResponse) => void;
};

const scope = self as unknown as WorkerScope;

// Transcripción monofónica con el tracker DSP (YIN + onsets por flujo espectral).
// Se ejecuta en un Web Worker para no bloquear la interfaz, aunque su coste
// computacional es muy inferior al del modelo Basic Pitch que reemplaza.
scope.onmessage = (event) => {
  const { id, audio, sampleRate } = event.data;
  try {
    const notes: BasicNoteTime[] = trackMonophonic(audio, sampleRate);
    scope.postMessage({ id, type: "notes", notes });
  } catch (error) {
    scope.postMessage({
      id,
      type: "error",
      message: error instanceof Error ? error.message : String(error),
    });
  }
};
