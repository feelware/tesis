import type { MetricPoint, TrendSeries } from "./types";

// Serie temporal de métricas por partida, de la partida más antigua a la más
// reciente. La tendencia (no solo la foto puntual) es el insight que la
// literatura de plataformas de entrenamiento auditivo analiza: Troubadour
// sigue el progreso con curvas por número de partida (tiempo por ejercicio y
// puntos por partida) y Auralbook compara medias de inicio y fin por nivel.
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
