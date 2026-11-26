import { describe, expect, it } from "vitest";
import { buildTrendSeries, sparklinePoints } from "./insights";

describe("buildTrendSeries", () => {
  it("extrae cada métrica en orden cronológico", () => {
    expect(
      buildTrendSeries([
        { pitch: 0.2, rhythm: 0.4, overall: 0.3 },
        { pitch: 0.8, rhythm: 0.6, overall: 0.7 },
      ]),
    ).toEqual({
      pitch: [0.2, 0.8],
      rhythm: [0.4, 0.6],
      overall: [0.3, 0.7],
    });
  });

  it("devuelve series vacías sin partidas", () => {
    expect(buildTrendSeries([])).toEqual({
      pitch: [],
      rhythm: [],
      overall: [],
    });
  });
});

describe("sparklinePoints", () => {
  it("devuelve cadena vacía sin valores", () => {
    expect(sparklinePoints([], 100, 20)).toBe("");
  });

  it("centra un único valor y mapea 0 al borde inferior y 1 al superior", () => {
    expect(sparklinePoints([0], 100, 20)).toBe("50,20");
    expect(sparklinePoints([1], 100, 20)).toBe("50,0");
  });

  it("distribuye los valores en el ancho con dominio fijo [0,1]", () => {
    expect(sparklinePoints([0, 1], 100, 20)).toBe("0,20 100,0");
    expect(sparklinePoints([0.5, 0.5, 0.5], 100, 20)).toBe("0,10 50,10 100,10");
  });
});
