// Utilidades compartidas del pipeline de búsqueda del estado del arte:
// CSV (parseo/escritura sin dependencias), normalización, deduplicación y HTTP con reintentos.

import { existsSync, readFileSync, writeFileSync, mkdirSync } from "node:fs";
import { dirname } from "node:path";

export const CANONICAL_COLUMNS = [
  "source",
  "query_id",
  "matched_phrases",
  "title",
  "authors",
  "year",
  "venue",
  "doc_type",
  "doi",
  "url",
  "abstract",
  "keywords",
  "language",
  "open_access",
];

export const emptyRow = () =>
  Object.fromEntries(CANONICAL_COLUMNS.map((column) => [column, ""]));

export const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

export const loadEnv = (path = ".env") => {
  const env = {};
  if (!existsSync(path)) return env;
  for (const line of readFileSync(path, "utf8").split("\n")) {
    const match = line.match(/^\s*([A-Za-z0-9_]+)\s*=\s*(.*)\s*$/);
    if (!match) continue;
    env[match[1]] = match[2].replace(/^["']|["']$/g, "");
  }
  return env;
};

const findNextDelimiter = (text, from) => {
  let next = -1;
  // Ojo: no buscar "\r" — si el archivo usa LF, cada indexOf("\r") recorrería
  // hasta el final del texto y el parseo se volvería cuadrático. El "\r" final
  // de los finales CRLF se limpia al vaciar el campo.
  for (const char of [",", "\n", '"']) {
    const index = text.indexOf(char, from);
    if (index !== -1 && (next === -1 || index < next)) next = index;
  }
  return next === -1 ? text.length : next;
};

const stripTrailingCr = (field) => (field.endsWith("\r") ? field.slice(0, -1) : field);

export const parseCsv = (text) => {
  const rows = [];
  let row = [];
  let field = "";
  const source = text.replace(/^\uFEFF/, "");
  const length = source.length;
  let i = 0;
  while (i < length) {
    const char = source[i];
    if (char === '"') {
      let j = i + 1;
      while (j < length) {
        const quote = source.indexOf('"', j);
        if (quote === -1) {
          field += source.slice(j);
          j = length;
          break;
        }
        if (source[quote + 1] === '"') {
          field += source.slice(j, quote + 1);
          j = quote + 2;
          continue;
        }
        field += source.slice(j, quote);
        j = quote + 1;
        break;
      }
      i = j;
    } else if (char === ",") {
      row.push(stripTrailingCr(field));
      field = "";
      i += 1;
    } else if (char === "\n") {
      row.push(stripTrailingCr(field));
      rows.push(row);
      row = [];
      field = "";
      i += 1;
    } else if (char === "\r") {
      i += 1;
    } else {
      const next = findNextDelimiter(source, i);
      field += source.slice(i, next);
      i = next;
    }
  }
  if (field.length > 0 || row.length > 0) {
    row.push(stripTrailingCr(field));
    rows.push(row);
  }
  return rows;
};

export const csvToObjects = (text) => {
  const rows = parseCsv(text);
  if (rows.length === 0) return [];
  const header = rows[0].map((cell) => cell.trim());
  return rows
    .slice(1)
    .filter((row) => row.some((cell) => cell.trim().length > 0))
    .map((row) =>
      Object.fromEntries(header.map((column, index) => [column, row[index] ?? ""])),
    );
};

const quoteCell = (value) => {
  const text = value === null || value === undefined ? "" : String(value);
  return /[",\n\r]/.test(text) ? `"${text.replace(/"/g, '""')}"` : text;
};

export const writeCsv = (path, columns, rows) => {
  mkdirSync(dirname(path), { recursive: true });
  const lines = [columns, ...rows].map((row) =>
    columns.map((column) => quoteCell(Array.isArray(row) ? row[columns.indexOf(column)] : row[column])).join(","),
  );
  writeFileSync(path, `${lines.join("\n")}\n`, "utf8");
};

export const writeJson = (path, value) => {
  mkdirSync(dirname(path), { recursive: true });
  writeFileSync(path, `${JSON.stringify(value, null, 2)}\n`, "utf8");
};

export const normalizeDoi = (raw) =>
  String(raw ?? "")
    .trim()
    .replace(/^https?:\/\/(dx\.)?doi\.org\//i, "")
    .replace(/^doi:\s*/i, "")
    .toLowerCase();

export const normalizeTitle = (raw) =>
  String(raw ?? "")
    .toLowerCase()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .replace(/[^a-z0-9]+/g, " ")
    .trim();

export const rowKey = (row) =>
  row.doi
    ? `doi:${row.doi}`
    : `title:${normalizeTitle(row.title)}|${row.year}`;

export const parseYear = (raw) => {
  const match = String(raw ?? "").match(/(19|20)\d{2}/);
  return match ? match[0] : "";
};

// Une filas que comparten clave (DOI o título+año): conserva la primera y
// acumula fuentes, búsquedas y frases que la encontraron.
export const dedupeRows = (rows) => {
  const unique = new Map();
  const duplicates = [];
  for (const row of rows) {
    const key = rowKey(row);
    const existing = unique.get(key);
    if (!existing) {
      unique.set(key, {
        ...row,
        sources: new Set([row.source]),
        query_ids: new Set([row.query_id]),
        phrases: new Set(row.matched_phrases ? row.matched_phrases.split("; ") : []),
      });
      continue;
    }
    existing.sources.add(row.source);
    existing.query_ids.add(row.query_id);
    for (const phrase of row.matched_phrases ? row.matched_phrases.split("; ") : []) {
      existing.phrases.add(phrase);
    }
    if (!existing.abstract && row.abstract) existing.abstract = row.abstract;
    if (!existing.doi && row.doi) existing.doi = row.doi;
    if (!existing.keywords && row.keywords) existing.keywords = row.keywords;
    duplicates.push({ key, row });
  }
  const uniqueRows = [...unique.values()].map((row) => ({
    ...row,
    source: [...row.sources].sort().join("; "),
    query_id: [...row.query_ids].sort().join("; "),
    matched_phrases: [...row.phrases].filter(Boolean).join("; "),
    sources: undefined,
    query_ids: undefined,
    phrases: undefined,
  }));
  return { uniqueRows, duplicates };
};

// Pide JSON y, ante 429 o 5xx, espera y vuelve a intentar sin límite de intentos.
// Para cuotas diarias (la API responde 429 durante horas) el reintento queda
// activo hasta que la cuota se libere; se informa cada espera.
export const fetchJsonUntilAvailable = async (url, { headers = {}, waitMs = 60000 } = {}) => {
  for (;;) {
    const response = await fetch(url, { headers });
    if (response.ok) return response.json();
    if (response.status !== 429 && response.status < 500) {
      throw new Error(`HTTP ${response.status}: ${url}`);
    }
    const retryAfter = Number(response.headers.get("retry-after"));
    const wait = Number.isFinite(retryAfter) && retryAfter > 0 ? retryAfter * 1000 : waitMs;
    console.log(`  HTTP ${response.status}; espero ${Math.round(wait / 1000)} s y reintento`);
    await sleep(wait);
  }
};

export const fetchWithRetry = async (url, { headers = {}, tries = 4, timeoutMs = 60000 } = {}) => {
  let lastError;
  for (let attempt = 1; attempt <= tries; attempt += 1) {
    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), timeoutMs);
    try {
      const response = await fetch(url, { headers, signal: controller.signal });
      if (response.ok) return response;
      const error = new Error(`HTTP ${response.status}: ${url}`);
      error.status = response.status;
      throw error;
    } catch (error) {
      lastError = error;
      const retryable = !error.status || error.status === 429 || error.status >= 500;
      if (!retryable || attempt === tries) throw error;
    } finally {
      clearTimeout(timer);
    }
    await sleep(1500 * 2 ** (attempt - 1));
  }
  throw lastError;
};
