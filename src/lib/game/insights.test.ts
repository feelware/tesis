import { describe, expect, it } from "vitest";
import type { ErrorReport } from "@/lib/music";
import {
  buildTrendSeries,
  deriveGameHints,
  deriveHistoryInsights,
  sparklinePoints,
} from "./insights";

const emptyDimension = () => ({
  missed: [],
  extra: [],
  meanDeviation: 0,
  maxDeviation: 0,
});

const report = (overrides: Partial<ErrorReport> = {}): ErrorReport => ({
  pitch: emptyDimension(),
  rhythm: emptyDimension(),
  ...overrides,
});

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

describe("deriveGameHints", () => {
  it("sin rondas no hay pistas", () => {
    expect(deriveGameHints([])).toEqual([]);
  });

  it("señala la dimensión más débil de la partida", () => {
    const hints = deriveGameHints([
      { pitch: 0.9, rhythm: 0.4, report: report() },
      { pitch: 0.8, rhythm: 0.5, report: report() },
    ]);
    expect(hints).toHaveLength(1);
    expect(hints[0]).toContain("ritmo quedó por debajo");
  });

  it("señala las notas omitidas y las adicionales", () => {
    const withErrors = (missed: number, extra: number) =>
      report({
        pitch: {
          ...emptyDimension(),
          missed: Array.from({ length: missed }, (_, i) => ({
            position: i + 1,
            midiPitch: 60,
          })),
          extra: Array.from({ length: extra }, (_, i) => ({
            position: i + 1,
            midiPitch: 62,
          })),
        },
      });
    const omittedHints = deriveGameHints([
      { pitch: 0.7, rhythm: 0.7, report: withErrors(3, 1) },
    ]);
    expect(omittedHints.some((hint) => hint.includes("Omitiste 3 notas"))).toBe(true);
    const extraHints = deriveGameHints([
      { pitch: 0.7, rhythm: 0.7, report: withErrors(0, 2) },
    ]);
    expect(extraHints.some((hint) => hint.includes("Añadiste 2 notas"))).toBe(true);
  });

  it("señala la desviación de octava y el desplazamiento de ataques", () => {
    const hints = deriveGameHints([
      {
        pitch: 0.7,
        rhythm: 0.7,
        report: report({
          pitch: { ...emptyDimension(), meanDeviation: 12 },
          rhythm: { ...emptyDimension(), meanDeviation: 120 },
        }),
      },
    ]);
    expect(hints.some((hint) => hint.includes("una octava"))).toBe(true);
    expect(hints.some((hint) => hint.includes("100 ms"))).toBe(true);
  });

  it("con desempeño equilibrado y sin errores no hay pistas", () => {
    expect(
      deriveGameHints([{ pitch: 0.9, rhythm: 0.85, report: report() }]),
    ).toEqual([]);
  });
});

describe("deriveHistoryInsights", () => {
  it("sin partidas no hay insights", () => {
    expect(deriveHistoryInsights([])).toEqual([]);
  });

  it("describe la tendencia de cada métrica", () => {
    const insights = deriveHistoryInsights([
      { pitch: 0.4, rhythm: 0.52, overall: 0.35 },
      { pitch: 0.7, rhythm: 0.56, overall: 0.63 },
    ]);
    expect(insights).toHaveLength(3);
    expect(insights[0]).toContain("Tus alturas ha mejorado");
    expect(insights[1]).toContain("Tu ritmo se mantiene estable");
    expect(insights[2]).toContain("Tu precisión general ha mejorado");
  });

  it("señala la dimensión más débil sobre el promedio del historial", () => {
    const insights = deriveHistoryInsights([
      { pitch: 0.9, rhythm: 0.5, overall: 0.7 },
    ]);
    expect(insights).toHaveLength(1);
    expect(insights[0]).toContain("más débil es el ritmo");
  });
});
