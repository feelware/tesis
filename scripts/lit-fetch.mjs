// Fetcher de literatura por API para el estado del arte.
//
// Uso: node scripts/lit-fetch.mjs <semanticscholar|eric> [--search C2a] [--limit 500]
//
// Estrategia por fuente:
// - eric: la API interpreta booleanos (AND/OR), así que la cadena
//   canónica se traduce a su sintaxis y se pagina completa.
// - semanticscholar: endpoint `paper/search/bulk`, que acepta `|` (OR) y `+`
//   (AND); equivalente directo de la cadena canónica.
//
// El filtro de año (>= YEARS_FROM, hoy 2022) se aplica en cliente porque estas APIs no aceptan
// rangos de año en la consulta. Cada corrida escribe
// docs/estado-del-arte/raw/<fuente>/<busqueda>.csv y un .meta.json con fecha,
// cadena exacta, filtros y conteos (protocolo de context.md 6.4).

import { parseArgs } from "node:util";
import { resolve } from "node:path";
import {
  CANONICAL_COLUMNS,
  emptyRow,
  fetchJsonUntilAvailable,
  fetchWithRetry,
  loadEnv,
  normalizeDoi,
  parseYear,
  rowKey,
  sleep,
  writeCsv,
  writeJson,
} from "./lit-lib.mjs";
import { SEARCHES, YEARS_FROM, parseBlocks } from "./lit-queries.mjs";

const RAW_ROOT = resolve("docs/estado-del-arte/raw");
const env = loadEnv();

const keepRow = (row) =>
  (!row.year || Number(row.year) >= YEARS_FROM) && row.title.length > 0;

// Devuelve las frases de la cadena que aparecen literalmente en el título o
// el abstract del registro. Solo es informativo: sirve para auditar qué término
// de la cadena recuperó cada estudio.
const matchedPhrasesOf = (row, phrases) => {
  const haystack = `${row.title} ${row.abstract}`.toLowerCase();
  return phrases.filter((phrase) => haystack.includes(phrase.toLowerCase()));
};

// ---------- Semantic Scholar (bulk search con booleanos) ----------

const s2BulkQuery = (query) =>
  parseBlocks(query)
    .map((block) => `(${block.map((phrase) => `"${phrase}"`).join("|")})`)
    .join(" + ");

const runS2 = async (search, limit, stats) => {
  const bulkQuery = s2BulkQuery(search.query);
  const headers = env.S2_API_KEY ? { "x-api-key": env.S2_API_KEY } : {};
  const delayMs = env.S2_API_KEY ? 300 : 3500;
  const rows = [];
  let token = null;
  let first = true;
  // Pagina con token hasta agotar resultados (sin tope). Ante 429 espera y reintenta
  // indefinidamente: la cuota de Semantic Scholar se libera con el tiempo.
  while (first || token) {
    first = false;
    const params = new URLSearchParams({
      query: bulkQuery,
      fields: "title,abstract,year,venue,authors,externalIds,url,publicationTypes,isOpenAccess",
      limit: "1000",
    });
    if (token) params.set("token", token);
    const data = await fetchJsonUntilAvailable(
      `https://api.semanticscholar.org/graph/v1/paper/search/bulk?${params.toString()}`,
      { headers },
    );
    for (const paper of data.data ?? []) {
      const row = {
        ...emptyRow(),
        source: "semanticscholar",
        title: paper.title ?? "",
        authors: (paper.authors ?? []).map((a) => a.name).filter(Boolean).join("; "),
        year: String(paper.year ?? ""),
        venue: paper.venue ?? "",
        doc_type: (paper.publicationTypes ?? []).join("; "),
        doi: normalizeDoi(paper.externalIds?.DOI),
        url: paper.url ?? "",
        abstract: paper.abstract ?? "",
        open_access: paper.isOpenAccess ? "true" : "false",
      };
      if (!keepRow(row)) continue;
      row.matched_phrases = matchedPhrasesOf(row, parseBlocks(search.query).flat()).join("; ");
      rows.push(row);
    }
    token = data.token;
    stats.total_reported = data.total ?? stats.total_reported;
    if (!token) break;
    await sleep(delayMs);
  }
  stats.execution = "bulk search de Semantic Scholar con booleanos (| = OR, + = AND), paginación completa por token";
  return rows;
};

// ---------- ERIC (Lucene booleano) ----------
//
// ERIC combina términos con AND siempre que no se usen comillas de frase:
// una frase entre comillas anula la combinación AND del bloque y devuelve 0.
// Por eso cada frase se expande a sus palabras con AND explícito, como en IEEE.
const ericQuery = (query) =>
  parseBlocks(query)
    .map((block) => `(${block.map((phrase) => `(${phrase.split(/\s+/).join(" AND ")})`).join(" OR ")})`)
    .join(" AND ");

const runEric = async (search, limit, stats) => {
  const query = ericQuery(search.query);
  const rows = [];
  const pageSize = 100;
  let start = 0;
  let peerReviewedSkipped = 0;
  // Pagina hasta agotar numFound (sin tope de filas).
  for (;;) {
    const params = new URLSearchParams({
      search: query,
      format: "json",
      rows: String(pageSize),
      start: String(start),
      fields: "id,title,author,description,publicationdateyear,source,peerreviewed,publicationtype,doi,language",
    });
    const response = await fetchWithRetry(`https://api.ies.ed.gov/eric/?${params.toString()}`);
    const data = await response.json();
    const docs = data.response?.docs ?? [];
    for (const doc of docs) {
      const peerReviewed = ["t", "true", "yes", "1"].includes(
        String(doc.peerreviewed ?? "").trim().toLowerCase(),
      );
      if (!peerReviewed) {
        peerReviewedSkipped += 1;
        continue;
      }
      const row = {
        ...emptyRow(),
        source: "eric",
        title: doc.title ?? "",
        authors: String(doc.author ?? "").split(";").map((a) => a.trim()).filter(Boolean).join("; "),
        year: String(doc.publicationdateyear ?? ""),
        venue: doc.source ?? "",
        doc_type: Array.isArray(doc.publicationtype) ? doc.publicationtype.join("; ") : (doc.publicationtype ?? ""),
        doi: normalizeDoi(doc.doi),
        url: doc.id ? `https://eric.ed.gov/?id=${doc.id}` : "",
        abstract: doc.description ?? "",
        language: doc.language ?? "",
      };
      if (!keepRow(row)) continue;
      row.matched_phrases = matchedPhrasesOf(row, parseBlocks(search.query).flat()).join("; ");
      rows.push(row);
    }
    stats.total_reported = Number(data.response?.numFound ?? stats.total_reported ?? 0);
    if (docs.length === 0 || start + pageSize >= stats.total_reported) break;
    start += pageSize;
    await sleep(300);
  }
  stats.peerreviewed_skipped = peerReviewedSkipped;
  stats.execution = "consulta Lucene booleana (título o descripción por frase; bloques con AND), paginación completa por numFound";
  return rows;
};

const SOURCES = {
  semanticscholar: {
    run: runS2,
    requiresKey: false,
    filters: { year_from: YEARS_FROM, nota: "filtro de año en cliente" },
  },
  eric: {
    run: runEric,
    requiresKey: false,
    filters: { year_from: YEARS_FROM, peer_reviewed: true, nota: "filtro de año en cliente" },
  },
};

const main = async () => {
  const { values, positionals } = parseArgs({
    allowPositionals: true,
    options: {
      search: { type: "string" },
      limit: { type: "string" },
    },
  });
  const sourceName = positionals[0];
  const source = SOURCES[sourceName];
  if (!source) {
    console.error(`Fuente desconocida: ${sourceName}. Opciones: ${Object.keys(SOURCES).join(", ")}`);
    process.exit(1);
  }
  if (source.requiresKey && !env[source.requiresKey]) {
    console.error(`Falta ${source.requiresKey} en .env para la fuente ${sourceName}.`);
    process.exit(1);
  }
  const limit = Number(values.limit ?? 500);
  const searches = values.search
    ? SEARCHES.filter((search) => search.id === values.search)
    : SEARCHES;
  if (searches.length === 0) {
    console.error(`Búsqueda desconocida: ${values.search}`);
    process.exit(1);
  }

  for (const search of searches) {
    const stats = {
      source: sourceName,
      search_id: search.id,
      cluster: search.cluster,
      label: search.label,
      canonical_query: search.query,
      filters: source.filters,
      retrieved_at: new Date().toISOString(),
      phrase_stats: [],
    };
    const rows = await source.run(search, limit, stats);
    const outRows = rows.map((row) => ({ ...row, query_id: search.id }));
    const outBase = resolve(RAW_ROOT, sourceName, search.id);
    writeCsv(`${outBase}.csv`, CANONICAL_COLUMNS, outRows);
    stats.result_count = outRows.length;
    writeJson(`${outBase}.meta.json`, stats);
    console.log(`[${sourceName} ${search.id}] ${rows.length} estudios`);
    await sleep(500);
  }
};

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
