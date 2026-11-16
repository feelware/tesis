import * as tf from "@tensorflow/tfjs";
import {
  BasicPitch,
  addPitchBendsToNoteEvents,
  noteFramesToTime,
  outputToNotesPoly,
} from "@spotify/basic-pitch";
import type {
  BasicNoteTime,
  TranscriptionRequest,
  TranscriptionResponse,
} from "./protocol";

type WorkerScope = {
  onmessage: (event: MessageEvent<TranscriptionRequest>) => void;
  postMessage: (message: TranscriptionResponse) => void;
};

const scope = self as unknown as WorkerScope;

let basicPitchPromise: Promise<BasicPitch> | null = null;

const cpuBackendReady = async (): Promise<void> => {
  if (tf.getBackend() === "cpu") return;
  await tf.setBackend("cpu");
  await tf.ready();
};

const getBasicPitch = (modelUrl: string): Promise<BasicPitch> => {
  basicPitchPromise ??= (async () => {
    await cpuBackendReady();
    return new BasicPitch(modelUrl);
  })();
  return basicPitchPromise;
};

scope.onmessage = async (event) => {
  const { id, audio, modelUrl } = event.data;
  try {
    const basicPitch = await getBasicPitch(modelUrl);
    const frames: number[][] = [];
    const onsets: number[][] = [];
    const contours: number[][] = [];
    let lastPostedPercent = -1;
    await basicPitch.evaluateModel(
      audio,
      (nextFrames, nextOnsets, nextContours) => {
        frames.push(...nextFrames);
        onsets.push(...nextOnsets);
        contours.push(...nextContours);
      },
      (percent) => {
        if (percent - lastPostedPercent < 0.01 && percent < 1) return;
        lastPostedPercent = percent;
        scope.postMessage({ id, type: "progress", percent });
      },
    );
    const notes: BasicNoteTime[] = noteFramesToTime(
      addPitchBendsToNoteEvents(
        contours,
        outputToNotesPoly(frames, onsets, 0.25, 0.25, 5),
      ),
    ).map((note) => ({
      startTimeSeconds: note.startTimeSeconds,
      durationSeconds: note.durationSeconds,
      pitchMidi: note.pitchMidi,
      amplitude: note.amplitude,
    }));
    scope.postMessage({ id, type: "notes", notes });
  } catch (error) {
    scope.postMessage({
      id,
      type: "error",
      message: error instanceof Error ? error.message : String(error),
    });
  }
};
