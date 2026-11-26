import type { ErrorReport } from "@/lib/music";
import type { MetricPoint, TrendSeries } from "./types";

// Serie temporal de métricas por partida, de la partida más antigua a la más
// reciente. La tendencia (no solo la foto puntual) es el insight que la
// literatura de plataformas de entrenamiento auditivo analiza: Troubadour
// sigue el progreso con curvas por número de partida (tiempo por ejercicio y
// puntos por partida) y Auralbook compara medias de inicio/fin por nivel.
export const buildTrendSeries = (points: MetricPoint[]): TrendSeries => ({
  pitch: points.map((point) => point.pitch),
  rhythm: points.map((point) => point.rhythm),
  overall: points.map((point) => point.overall),
});

// Coordenadas "x,y" de un sparkline SVG. El dominio se fija en [0, 1] (las
// métricas son F1 en esa escala) para que sparklines de estudiantes y partidas
// distintas sean visualmente comparables.
export const sparklinePoints = (
  values: number[],
  width: number,
  height: number,
): string => {
  const round = (value: number) => Math.round(value * 100) / 100;
  return values
    .map((value, index) => {
      const x =
        values.length === 1
          ? width / 2
          : (index / (values.length - 1)) * width;
      const y = (1 - value) * height;
      return `${round(x)},${round(y)}`;
    })
    .join(" ");
};

// ---------------------------------------------------------------------------
// Feedback formativo. LLaQo (Zhang et al., 2025) señala que el feedback solo
// summative (puntajes o juicios binarios) "fall short in educational contexts
// where formative, detailed and instructional feedback is essential": estas
// reglas derivan pistas de "qué trabajar" del historial. Los umbrales concretos
// son aporte propio (no hay valores validados en la literatura consultada).
// ---------------------------------------------------------------------------

const DIMENSION_GAP = 0.1;
const TREND_DELTA = 0.05;
const WEAK_DIMENSION_GAP = 0.05;
const OCTAVE_DEVIATION = 11;
const ONSET_SHIFT_MS = 100;

const mean = (values: number[]): number =>
  values.length === 0
    ? 0
    : values.reduce((total, value) => total + value, 0) / values.length;

const points = (value: number): string =>
  `${Math.round(value * 1000) / 10} puntos`;

export interface RoundFeedbackInput {
  pitch: number;
  rhythm: number;
  report: ErrorReport | null;
}

export const deriveGameHints = (rounds: RoundFeedbackInput[]): string[] => {
  const hints: string[] = [];
  if (rounds.length === 0) return hints;
  const meanPitch = mean(rounds.map((round) => round.pitch));
  const meanRhythm = mean(rounds.map((round) => round.rhythm));
  if (meanRhythm <= meanPitch - DIMENSION_GAP) {
    hints.push(
      "Tu ritmo quedó por debajo de tus alturas: conviene practicar con metrónomo y repasar las figuras antes de la próxima partida.",
    );
  }
  if (meanPitch <= meanRhythm - DIMENSION_GAP) {
    hints.push(
      "Tus alturas quedaron por debajo de tu ritmo: conviene practicar intervalos y memoria melódica.",
    );
  }
  const reports = rounds
    .map((round) => round.report)
    .filter((report): report is ErrorReport => report !== null);
  const omitted = reports.reduce(
    (total, report) =>
      total + Math.max(report.pitch.missed.length, report.rhythm.missed.length),
    0,
  );
  const extra = reports.reduce(
    (total, report) =>
      total + Math.max(report.pitch.extra.length, report.rhythm.extra.length),
    0,
  );
  if (omitted >= 2 && omitted >= extra) {
    hints.push(
      `Omitiste ${omitted} notas de la referencia: tiendes a dejar material sin transcribir; prueba a memorizar la melodía en frases cortas.`,
    );
  }
  if (extra >= 2 && extra > omitted) {
    hints.push(
      `Añadiste ${extra} notas que no estaban en la referencia: evita completar por intuición y vuelve a escuchar antes de escribir.`,
    );
  }
  if (
    reports.some(
      (report) =>
        report.pitch.meanDeviation !== null &&
        report.pitch.meanDeviation >= OCTAVE_DEVIATION,
    )
  ) {
    hints.push(
      "Alguna respuesta quedó a una octava de la referencia: revisa la tesitura antes de cantar o transcribir.",
    );
  }
  if (
    reports.some(
      (report) =>
        report.rhythm.meanDeviation !== null &&
        report.rhythm.meanDeviation >= ONSET_SHIFT_MS,
    )
  ) {
    hints.push(
      "Tus ataques se desplazaron más de 100 ms de media en alguna ronda: un tempo más lento puede ayudarte a afianzar el pulso.",
    );
  }
  return hints;
};

const METRIC_LABEL: Record<"pitch" | "rhythm" | "overall", string> = {
  pitch: "Tus alturas",
  rhythm: "Tu ritmo",
  overall: "Tu precisión general",
};

export const deriveHistoryInsights = (games: MetricPoint[]): string[] => {
  const insights: string[] = [];
  if (games.length === 0) return insights;
  if (games.length >= 2) {
    const first = games[0];
    const last = games[games.length - 1];
    for (const key of ["pitch", "rhythm", "overall"] as const) {
      const delta = last[key] - first[key];
      if (delta >= TREND_DELTA) {
        insights.push(
          `${METRIC_LABEL[key]} ha mejorado ${points(delta)} desde tu primera partida.`,
        );
      } else if (delta <= -TREND_DELTA) {
        insights.push(
          `${METRIC_LABEL[key]} ha bajado ${points(-delta)} desde tu primera partida.`,
        );
      } else {
        insights.push(
          `${METRIC_LABEL[key]} se mantiene estable respecto de tu primera partida.`,
        );
      }
    }
  }
  const meanPitch = mean(games.map((game) => game.pitch));
  const meanRhythm = mean(games.map((game) => game.rhythm));
  if (meanRhythm <= meanPitch - WEAK_DIMENSION_GAP) {
    insights.push(
      "Tu dimensión más débil es el ritmo: enfoca ahí tu práctica para equilibrar el desempeño.",
    );
  } else if (meanPitch <= meanRhythm - WEAK_DIMENSION_GAP) {
    insights.push(
      "Tu dimensión más débil son las alturas: enfoca ahí tu práctica para equilibrar el desempeño.",
    );
  }
  return insights;
};
