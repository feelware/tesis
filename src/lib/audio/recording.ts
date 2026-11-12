export interface Recording {
  blob: Blob;
  durationMs: number;
}

export interface RecordingHandle {
  stop: () => Promise<Recording>;
  cancel: () => void;
}

export const startRecording = async (): Promise<RecordingHandle> => {
  const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
  const recorder = new MediaRecorder(stream);
  const chunks: BlobPart[] = [];
  const startedAt = performance.now();

  recorder.ondataavailable = (event) => {
    if (event.data.size > 0) chunks.push(event.data);
  };
  recorder.start();

  const releaseStream = () => {
    for (const track of stream.getTracks()) track.stop();
  };

  return {
    stop: () =>
      new Promise<Recording>((resolve) => {
        recorder.onstop = () => {
          releaseStream();
          resolve({
            blob: new Blob(chunks, { type: recorder.mimeType }),
            durationMs: performance.now() - startedAt,
          });
        };
        recorder.stop();
      }),
    cancel: () => {
      recorder.onstop = null;
      recorder.stop();
      releaseStream();
    },
  };
};

export const decodeAudio = async (blob: Blob): Promise<AudioBuffer> => {
  const context = new AudioContext();
  try {
    return await context.decodeAudioData(await blob.arrayBuffer());
  } finally {
    void context.close();
  }
};
