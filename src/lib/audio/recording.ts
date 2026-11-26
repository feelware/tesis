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
  // En algunos sistemas el micrófono llega como estéreo con la señal solo en
  // un canal y MediaRecorder la guarda así (se reproducía solo por el oído
  // izquierdo). Se mezcla a mono antes de grabar para que el audio salga por
  // igual en ambos canales.
  const audioContext = new AudioContext();
  const source = audioContext.createMediaStreamSource(stream);
  const mono = audioContext.createGain();
  mono.channelCount = 1;
  mono.channelCountMode = "explicit";
  const destination = audioContext.createMediaStreamDestination();
  source.connect(mono);
  mono.connect(destination);
  const recorder = new MediaRecorder(destination.stream);
  const chunks: BlobPart[] = [];
  const startedAt = performance.now();

  recorder.ondataavailable = (event) => {
    if (event.data.size > 0) chunks.push(event.data);
  };
  recorder.start();

  const releaseStream = () => {
    for (const track of stream.getTracks()) track.stop();
    void audioContext.close();
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
    const buffer = await context.decodeAudioData(await blob.arrayBuffer());
    if (buffer.numberOfChannels === 1) return buffer;
    // Mezcla a mono cualquier archivo estéreo con señal en un solo canal.
    const mono = context.createBuffer(1, buffer.length, buffer.sampleRate);
    const output = mono.getChannelData(0);
    for (let channel = 0; channel < buffer.numberOfChannels; channel += 1) {
      const input = buffer.getChannelData(channel);
      for (let index = 0; index < buffer.length; index += 1) {
        output[index] += input[index] / buffer.numberOfChannels;
      }
    }
    return mono;
  } finally {
    void context.close();
  }
};
