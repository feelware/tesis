// Unión y deduplicación de los resultados de búsqueda del estado del arte.
//
// Uso: node scripts/lit-merge.mjs
//
// Lee todos los CSV de docs/estado-del-arte/raw/** (exportaciones de Scopus e
// IEEE Xplore descargadas con el navegador y resultados de las APIs), normaliza
// nombres de columnas al esquema canónico, concatena y elimina duplicados por
// DOI (o título+año si no hay DOI). Escribe:
//   docs/estado-del-arte/merged/deduped.csv
//   docs/estado-del-arte/merged/duplicates.csv
//   docs/estado-del-arte/merged/report.md

import { readdirSync, readFileSync, existsSync, writeFileSync, mkdirSync } from "node:fs";
import { resolve, relative, basename } from "node:path";
import {
  CANONICAL_COLUMNS,
  csvToObjects,
  dedupeRows,
  emptyRow,
  normalizeDoi,
  parseYear,
  writeCsv,
} from "./lit-lib.mjs";

const RAW_ROOT = resolve("docs/estado-del-arte/raw");
const OUT_ROOT = resolve("docs/estado-del-arte/merged");

// Mapeo tolerante de encabezados de exportaciones ajenas al esquema canónico.
const COLUMN_ALIASES = {
  title: ["title", "document title", "item title", "article title"],
  authors: ["authors", "author", "author(s)", "creators"],
  year: ["year", "publication year", "date of publication", "publication date", "item publication date", "date of conference"],
  venue: ["source title", "publication title", "publication name", "journal name", "source", "container title"],
  doc_type: ["document type", "content type", "publication type", "source & document type", "type"],
  doi: ["doi", "item doi", "article doi"],
  url: ["url", "document link", "item url", "link"],
  abstract: ["abstract", "description", "summary"],
  keywords: ["author keywords", "index keywords", "indexed keywords", "ieee terms", "inspec: controlled terms", "inspec: non-controlled terms", "keywords", "keyword", "index terms"],
  language: ["language of original document", "language"],
  open_access: ["open access", "access type"],
};

const findColumn = (object, aliases) => {
  const keys = Object.keys(object);
  for (const alias of aliases) {
    const match = keys.find((key) => key.trim().toLowerCase() === alias);
    if (match !== undefined) return object[match];
  }
  for (const alias of aliases) {
    const match = keys.find((key) => key.trim().toLowerCase().includes(alias));
    if (match !== undefined) return object[match];
  }
  return "";
};

const joinValues = (object, aliases) => {
  const keys = Object.keys(object);
  const parts = [];
  for (const alias of aliases) {
    for (const key of keys) {
      const value = String(object[key] ?? "").trim();
      if (key.trim().toLowerCase().includes(alias) && value && !parts.includes(value)) {
        parts.push(value);
      }
    }
  }
  return parts.join("; ");
};

const isCanonical = (object) =>
  CANONICAL_COLUMNS.every((column) => Object.keys(object).includes(column));

const mapForeignRow = (object, fallbackSource) => {
  const row = emptyRow();
  row.source = fallbackSource;
  row.title = String(findColumn(object, COLUMN_ALIASES.title)).trim();
  row.authors = String(findColumn(object, COLUMN_ALIASES.authors)).trim();
  row.year = parseYear(findColumn(object, COLUMN_ALIASES.year));
  row.venue = String(findColumn(object, COLUMN_ALIASES.venue)).trim();
  row.doc_type = String(findColumn(object, COLUMN_ALIASES.doc_type)).trim();
  row.doi = normalizeDoi(findColumn(object, COLUMN_ALIASES.doi));
  row.url = String(findColumn(object, COLUMN_ALIASES.url)).trim();
  row.abstract = String(findColumn(object, COLUMN_ALIASES.abstract)).trim();
  row.keywords = joinValues(object, COLUMN_ALIASES.keywords);
  row.language = String(findColumn(object, COLUMN_ALIASES.language)).trim();
  row.open_access = String(findColumn(object, COLUMN_ALIASES.open_access)).trim().toLowerCase();
  return row;
};

const listCsvFiles = (dir) => {
  const files = [];
  for (const entry of readdirSync(dir, { withFileTypes: true }).sort((a, b) => a.name.localeCompare(b.name))) {
    const path = resolve(dir, entry.name);
    if (entry.isDirectory()) files.push(...listCsvFiles(path));
    else if (entry.name.endsWith(".csv") && !entry.name.endsWith(".merged.csv")) files.push(path);
  }
  return files;
};

const main = () => {
  if (!existsSync(RAW_ROOT)) {
    console.error(`No existe ${RAW_ROOT}. Ejecuta antes lit-fetch o lit-browser-export.`);
    process.exit(1);
  }
  const rows = [];
  const perFile = [];
  for (const file of listCsvFiles(RAW_ROOT)) {
    const objects = csvToObjects(readFileSync(file, "utf8"));
    const relativePath = relative(RAW_ROOT, file);
    const fallbackSource = relativePath.split(/[\\/]/)[0];
    const queryId = basename(file).replace(/\.csv$/, "").split(".")[0];
    let mapped = 0;
    for (const object of objects) {
      const row = isCanonical(object)
        ? {
            ...emptyRow(),
            ...object,
            doi: normalizeDoi(object.doi),
            year: parseYear(object.year),
            query_id: object.query_id || queryId,
          }
        : { ...mapForeignRow(object, fallbackSource), query_id: queryId };
      if (!row.title) continue;
      mapped += 1;
      rows.push(row);
    }
    perFile.push({ file: relativePath, rows: mapped });
  }

  const { uniqueRows, duplicates } = dedupeRows(rows);
  const sorted = [...uniqueRows].sort(
    (a, b) => a.query_id.localeCompare(b.query_id) || a.title.localeCompare(b.title),
  );
  writeCsv(resolve(OUT_ROOT, "deduped.csv"), CANONICAL_COLUMNS, sorted);
  writeCsv(resolve(OUT_ROOT, "duplicates.csv"), ["key", ...CANONICAL_COLUMNS], duplicates.map(({ key, row }) => ({ key, ...row })));

  const countBy = (field) => {
    const counts = new Map();
    for (const row of sorted) {
      const value = row[field] || "(vacío)";
      counts.set(value, (counts.get(value) ?? 0) + 1);
    }
    return [...counts.entries()].sort((a, b) => b[1] - a[1]);
  };
  const withAbstract = sorted.filter((row) => row.abstract.trim().length > 0).length;
  const report = [
    "# Reporte de unión y deduplicación",
    "",
    `Generado: ${new Date().toISOString()}`,
    "",
    "## Filas por archivo de origen",
    "",
    ...perFile.map((entry) => `- ${entry.file}: ${entry.rows}`),
    "",
    `## Totales`,
    "",
    `- Filas leídas: ${rows.length}`,
    `- Estudios únicos (dedup por DOI o título+año): ${sorted.length}`,
    `- Duplicados descartados: ${duplicates.length}`,
    `- Estudios con abstract: ${withAbstract} / ${sorted.length}`,
    "",
    "## Por búsqueda (query_id)",
    "",
    ...countBy("query_id").map(([value, count]) => `- ${value}: ${count}`),
    "",
    "## Por tipo de documento",
    "",
    ...countBy("doc_type").map(([value, count]) => `- ${value}: ${count}`),
    "",
    "## Por idioma",
    "",
    ...countBy("language").map(([value, count]) => `- ${value}: ${count}`),
  ].join("\n");
  mkdirSync(OUT_ROOT, { recursive: true });
  writeFileSync(resolve(OUT_ROOT, "report.md"), `${report}\n`, "utf8");

  console.log(`Únicos: ${sorted.length} (${rows.length} leídas, ${duplicates.length} duplicados)`);
  console.log(`Salidas en ${OUT_ROOT}`);
};

main();
