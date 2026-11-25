// Tracker DSP monofónico para transcripción de canto (audio → notas).
//
// Alternativa al modelo Basic Pitch (TF.js) adoptada tras la revisión del estado
// del arte (opción A, tradeoff precisión/coste justificado en la tesis §4.6):
// para canto monofónico la precisión de altura de un tracker DSP (YIN) es
// suficiente, y su coste computacional y latencia son muy inferiores, lo que
// permite ejecutarlo en el navegador sin sobrecargar el servidor ni enviar el
// audio a terceros (privacidad). Los onsets se detectan por flujo espectral;
// la segmentación agrupa frames de altura estable en notas.
//
// Produce `BasicNoteTime[]`, el mismo contrato que devolvía Basic Pitch, de modo
// que `normalizeTranscription` y el analizador de similitud funcionan igual.

import type { BasicNoteTime } from "./protocol";

export interface DspParams {
  frameSize: number; // muestras por frame para YIN (>= 2 periodos de minFreq)
  hopSize: number; // salto entre frames
  yinThreshold: number; // umbral absoluto de YIN (voiced si d'(tau) < umbral)
  minFreq: number; // Hz — límite inferior de búsqueda (registro cantado)
  maxFreq: number; // Hz — límite superior de búsqueda
  onsetSensitivity: number; // nº de desviaciones estándar sobre la media del flujo espectral
  minOnsetGapMs: number; // separación mínima entre onsets
  minNoteLenMs: number; // duración mínima de una nota
  maxGapMs: number; // hueco máximo de frames sin voz admitido dentro de una nota
}

export const DSP_PARAMS: DspParams = {
  frameSize: 2048,
  hopSize: 512,
  yinThreshold: 0.15,
  minFreq: 75,
  maxFreq: 1500,
  onsetSensitivity: 1.2,
  minOnsetGapMs: 80,
  minNoteLenMs: 50,
  maxGapMs: 40,
};

const freqToMidi = (freq: number): number => 69 + 12 * Math.log2(freq / 440);

// ---------- FFT radix-2 in place (partes real e imaginaria) ----------
const fft = (re: Float32Array, im: Float32Array): void => {
  const n = re.length;
  for (let i = 1, j = 0; i < n; i += 1) {
    let bit = n >> 1;
    for (; j & bit; bit >>= 1) j ^= bit;
    j ^= bit;
    if (i < j) {
      [re[i], re[j]] = [re[j], re[i]];
      [im[i], im[j]] = [im[j], im[i]];
    }
  }
  for (let len = 2; len <= n; len <<= 1) {
    const angle = (-2 * Math.PI) / len;
    const wRe = Math.cos(angle);
    const wIm = Math.sin(angle);
    for (let i = 0; i < n; i += len) {
      let curRe = 1;
      let curIm = 0;
      for (let k = 0; k < len / 2; k += 1) {
        const uRe = re[i + k];
        const uIm = im[i + k];
        const vRe = re[i + k + len / 2] * curRe - im[i + k + len / 2] * curIm;
        const vIm = re[i + k + len / 2] * curIm + im[i + k + len / 2] * curRe;
        re[i + k] = uRe + vRe;
        im[i + k] = uIm + vIm;
        re[i + k + len / 2] = uRe - vRe;
        im[i + k + len / 2] = uIm - vIm;
        const nextRe = curRe * wRe - curIm * wIm;
        curIm = curRe * wIm + curIm * wRe;
        curRe = nextRe;
      }
    }
  }
};

// ---------- YIN: estimación de f0 por frame ----------
type Pitch = { freq: number; confidence: number };

const yinPitch = (
  frame: Float32Array,
  sampleRate: number,
  params: DspParams,
): Pitch => {
  const tauMin = Math.max(2, Math.floor(sampleRate / params.maxFreq));
  const tauMax = Math.min(
    Math.floor(sampleRate / params.minFreq),
    frame.length - 1,
  );
  if (tauMax <= tauMin) return { freq: 0, confidence: 0 };
  // Función de diferencia d(tau).
  const d = new Float32Array(tauMax + 1);
  for (let tau = 1; tau <= tauMax; tau += 1) {
    let sum = 0;
    for (let i = 0; i + tau < frame.length; i += 1) {
      const diff = frame[i] - frame[i + tau];
      sum += diff * diff;
    }
    d[tau] = sum;
  }
  // Diferencia normalizada por media acumulada d'(tau).
  const dPrime = new Float32Array(tauMax + 1);
  dPrime[0] = 1;
  let running = 0;
  for (let tau = 1; tau <= tauMax; tau += 1) {
    running += d[tau];
    dPrime[tau] = running > 0 ? (d[tau] * tau) / running : 1;
  }
  // Primer tau por debajo del umbral; se refina al mínimo local siguiente.
  let tauEstimate = -1;
  for (let tau = tauMin; tau <= tauMax; tau += 1) {
    if (dPrime[tau] < params.yinThreshold) {
      while (tau + 1 <= tauMax && dPrime[tau + 1] < dPrime[tau]) tau += 1;
      tauEstimate = tau;
      break;
    }
  }
  if (tauEstimate === -1) return { freq: 0, confidence: 0 };
  // Interpolación parabólica para precisión sub-muestra.
  const x0 = tauEstimate > 0 ? tauEstimate - 1 : tauEstimate;
  const x2 = tauEstimate + 1 <= tauMax ? tauEstimate + 1 : tauEstimate;
  let betterTau = tauEstimate;
  if (x0 !== tauEstimate && x2 !== tauEstimate) {
    const s0 = dPrime[x0];
    const s1 = dPrime[tauEstimate];
    const s2 = dPrime[x2];
    const denom = 2 * s1 - s2 - s0;
    if (denom !== 0) betterTau = tauEstimate + (s2 - s0) / (2 * denom);
  }
  return { freq: sampleRate / betterTau, confidence: 1 - dPrime[tauEstimate] };
};

// ---------- Onsets por flujo espectral ----------
const spectralFluxOnsets = (
  audio: Float32Array,
  sampleRate: number,
  params: DspParams,
): boolean[] => {
  const fftSize = 1024;
  const hop = params.hopSize;
  const half = fftSize / 2;
  const numFrames = Math.max(1, Math.floor((audio.length - fftSize) / hop) + 1);
  const flux = new Float32Array(numFrames);
  let prevMag = new Float32Array(half);
  const window = new Float32Array(fftSize);
  for (let i = 0; i < fftSize; i += 1) {
    window[i] = 0.5 - 0.5 * Math.cos((2 * Math.PI * i) / (fftSize - 1)); // Hann
  }
  const re = new Float32Array(fftSize);
  const im = new Float32Array(fftSize);
  for (let f = 0; f < numFrames; f += 1) {
    const start = f * hop;
    for (let i = 0; i < fftSize; i += 1) {
      re[i] = (audio[start + i] ?? 0) * window[i];
      im[i] = 0;
    }
    fft(re, im);
    let sum = 0;
    const mag = new Float32Array(half);
    for (let k = 0; k < half; k += 1) {
      const m = Math.hypot(re[k], im[k]);
      mag[k] = m;
      const diff = m - prevMag[k];
      if (diff > 0) sum += diff;
    }
    flux[f] = sum;
    prevMag = mag;
  }
  // Umbral adaptativo (media + k * desviación) + máximo local + intervalo mínimo.
  let mean = 0;
  for (let f = 0; f < numFrames; f += 1) mean += flux[f];
  mean /= numFrames || 1;
  let variance = 0;
  for (let f = 0; f < numFrames; f += 1) variance += (flux[f] - mean) ** 2;
  const std = Math.sqrt(variance / (numFrames || 1));
  const threshold = mean + params.onsetSensitivity * std;
  const minGapFrames = Math.max(
    1,
    Math.round(params.minOnsetGapMs / ((hop / sampleRate) * 1000)),
  );
  const onset = new Array<boolean>(numFrames).fill(false);
  let lastOnset = -Infinity;
  for (let f = 1; f < numFrames - 1; f += 1) {
    if (
      flux[f] >= threshold &&
      flux[f] >= flux[f - 1] &&
      flux[f] >= flux[f + 1] &&
      f - lastOnset >= minGapFrames
    ) {
      onset[f] = true;
      lastOnset = f;
    }
  }
  return onset;
};

// ---------- Segmentation y extracción de notas ----------
export const trackMonophonic = (
  audio: Float32Array,
  sampleRate: number,
  params: DspParams = DSP_PARAMS,
): BasicNoteTime[] => {
  const hop = params.hopSize;
  const frameDur = hop / sampleRate;
  const maxGapFrames = Math.max(1, Math.round(params.maxGapMs / (frameDur * 1000)));
  const onsets = spectralFluxOnsets(audio, sampleRate, params);

  // Pitch por frame (YIN) + cuantización a semitono.
  const numFrames = onsets.length;
  const midi = new Float32Array(numFrames);
  const voiced = new Array<boolean>(numFrames).fill(false);
  const rms = new Float32Array(numFrames);
  for (let f = 0; f < numFrames; f += 1) {
    const start = f * hop;
    const frame = audio.slice(start, start + params.frameSize);
    if (frame.length < params.frameSize / 2) continue;
    let energy = 0;
    for (let i = 0; i < frame.length; i += 1) energy += frame[i] * frame[i];
    rms[f] = Math.sqrt(energy / frame.length);
    const pitch = yinPitch(frame, sampleRate, params);
    if (pitch.freq > 0 && pitch.confidence > 0) {
      const m = freqToMidi(pitch.freq);
      // Solo dentro del rango cantado buscado.
      if (pitch.freq >= params.minFreq && pitch.freq <= params.maxFreq) {
        midi[f] = m;
        voiced[f] = true;
      }
    }
  }

  // Segmentación: nueva nota en onset, cambio de altura sostenido o tras un
  // hueco sin voz. El cambio de altura debe ser sostenido (varios frames) para
  // no partir las notas a causa del vibrato, que oscila sin ser un cambio real.
  const notes: BasicNoteTime[] = [];
  let segStart = -1;
  let segEnd = -1;
  let gapRun = 0;
  let changeRun = 0;
  const pitches: number[] = [];
  const PITCH_CHANGE_SEMITONES = 0.8;
  const PITCH_CHANGE_SUSTAIN = 4;
  const medianPitch = () => {
    const sorted = [...pitches].sort((a, b) => a - b);
    return sorted[Math.floor(sorted.length / 2)];
  };
  const closeSegment = (endFrame: number) => {
    if (segStart < 0 || pitches.length === 0) return;
    const pitchMidi = Math.round(medianPitch());
    const startTimeSeconds = (segStart * hop) / sampleRate;
    const endTimeSeconds = ((endFrame + 1) * hop) / sampleRate;
    const durationSeconds = endTimeSeconds - startTimeSeconds;
    if (durationSeconds * 1000 >= params.minNoteLenMs) {
      let peak = 0;
      for (let f = segStart; f <= endFrame; f += 1) peak = Math.max(peak, rms[f]);
      notes.push({ startTimeSeconds, durationSeconds, pitchMidi, amplitude: peak });
    }
  };

  for (let f = 0; f < numFrames; f += 1) {
    const voicedNow = voiced[f];
    if (!voicedNow) {
      if (segStart >= 0) {
        gapRun += 1;
        if (gapRun > maxGapFrames) {
          closeSegment(segEnd);
          segStart = -1;
          pitches.length = 0;
          gapRun = 0;
        } else {
          segEnd = f;
        }
      }
      continue;
    }
    gapRun = 0;
    const onsetBreak = onsets[f] && segStart >= 0;
    const sustainedChange =
      segStart >= 0 &&
      pitches.length > 0 &&
      Math.abs(midi[f] - medianPitch()) > PITCH_CHANGE_SEMITONES;
    changeRun = sustainedChange ? changeRun + 1 : 0;
    const pitchBreak = changeRun >= PITCH_CHANGE_SUSTAIN;
    if (segStart >= 0 && (onsetBreak || pitchBreak)) {
      closeSegment(segEnd);
      segStart = f;
      segEnd = f;
      pitches.length = 0;
      pitches.push(midi[f]);
      changeRun = 0;
      continue;
    }
    if (segStart < 0) {
      segStart = f;
      pitches.length = 0;
    }
    segEnd = f;
    pitches.push(midi[f]);
  }
  closeSegment(segEnd);
  return notes;
};
