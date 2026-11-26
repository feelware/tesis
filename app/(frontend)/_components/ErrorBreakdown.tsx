import type { DimensionErrors, ErrorNote, ErrorReport } from "@/lib/music";

const notePositions = (notes: ErrorNote[]): string =>
  notes.map((note) => note.position).join(", ");

const DimensionLine = ({
  label,
  unit,
  errors,
}: {
  label: string;
  unit: string;
  errors: DimensionErrors;
}) => {
  const parts = [
    errors.missed.length === 0
      ? "sin notas omitidas"
      : `${errors.missed.length} nota${errors.missed.length === 1 ? "" : "s"} omitida${errors.missed.length === 1 ? "" : "s"} (posiciones ${notePositions(errors.missed)})`,
    errors.extra.length === 0
      ? "sin notas adicionales"
      : `${errors.extra.length} nota${errors.extra.length === 1 ? "" : "s"} adicional${errors.extra.length === 1 ? "" : "es"} (posiciones ${notePositions(errors.extra)})`,
    ...(errors.meanDeviation === null
      ? []
      : [`desviación media ±${errors.meanDeviation} ${unit}`]),
  ];
  return (
    <p>
      <span className="font-medium text-zinc-700">{label}:</span>{" "}
      {parts.join(" · ")}
    </p>
  );
};

export const ErrorBreakdown = ({ report }: { report: ErrorReport | null }) => {
  if (!report) return null;
  return (
    <div className="mt-2 space-y-0.5 rounded bg-zinc-50 p-2 text-xs text-zinc-600">
      <DimensionLine label="Alturas" unit="semitonios" errors={report.pitch} />
      <DimensionLine label="Ritmo" unit="ms" errors={report.rhythm} />
    </div>
  );
};
