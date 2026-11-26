import type { TrendSeries } from "@/lib/game/types";
import { sparklinePoints } from "@/lib/game/insights";

export interface SparklineSeries {
  values: number[];
  color: string;
  label: string;
}

export const TREND_METRICS: {
  key: keyof TrendSeries;
  label: string;
  color: string;
}[] = [
  { key: "pitch", label: "Alturas", color: "#6366f1" },
  { key: "rhythm", label: "Ritmo", color: "#10b981" },
  { key: "overall", label: "General", color: "#d97706" },
];

export const trendSeriesOf = (trend: TrendSeries): SparklineSeries[] =>
  TREND_METRICS.map((metric) => ({
    values: trend[metric.key],
    color: metric.color,
    label: metric.label,
  }));

interface SparklineProps {
  series: SparklineSeries[];
  width?: number;
  height?: number;
}

export const Sparkline = ({ series, width = 96, height = 28 }: SparklineProps) => {
  const visible = series.filter((item) => item.values.length > 0);
  if (visible.length === 0) return null;
  return (
    <svg
      width={width}
      height={height}
      viewBox={`0 0 ${width} ${height}`}
      role="img"
      aria-label={`Tendencia: ${visible.map((item) => item.label).join(", ")}`}
    >
      {visible.map((item) =>
        item.values.length === 1 ? (
          <circle
            key={item.label}
            cx={width / 2}
            cy={(1 - item.values[0]) * height}
            r={2.5}
            fill={item.color}
          />
        ) : (
          <polyline
            key={item.label}
            points={sparklinePoints(item.values, width, height)}
            fill="none"
            stroke={item.color}
            strokeWidth={1.5}
            strokeLinejoin="round"
            strokeLinecap="round"
          />
        ),
      )}
    </svg>
  );
};

export const SparklineLegend = () => (
  <span className="flex flex-wrap items-center gap-3 text-xs text-zinc-600">
    {TREND_METRICS.map((metric) => (
      <span key={metric.key} className="flex items-center gap-1">
        <span
          className="inline-block h-2 w-2 rounded-full"
          style={{ backgroundColor: metric.color }}
        />
        {metric.label}
      </span>
    ))}
  </span>
);
