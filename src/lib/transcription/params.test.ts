import { describe, expect, it } from "vitest";
import { MODEL_PARAMS } from "./params";

const midiToHz = (midi: number): number => 440 * 2 ** ((midi - 69) / 12);

describe("parámetros del modelo de transcripción", () => {
  it("mantiene el rango de frecuencias en orden creciente", () => {
    expect(MODEL_PARAMS.minFreq).not.toBeNull();
    expect(MODEL_PARAMS.maxFreq).not.toBeNull();
    expect(MODEL_PARAMS.minFreq!).toBeLessThan(MODEL_PARAMS.maxFreq!);
  });

  it("conserva el registro grave cantado", () => {
    expect(MODEL_PARAMS.minFreq!).toBeLessThanOrEqual(midiToHz(45));
  });

  it("conserva el registro agudo cantado una octava arriba", () => {
    expect(MODEL_PARAMS.maxFreq!).toBeGreaterThanOrEqual(midiToHz(84));
  });

  it("descarta notas más cortas que un transitorio de consonante", () => {
    const frameSeconds = 256 / 22050;
    expect(MODEL_PARAMS.minNoteLen).toBeGreaterThanOrEqual(8);
    expect(MODEL_PARAMS.minNoteLen * frameSeconds).toBeGreaterThan(0.08);
  });
});
