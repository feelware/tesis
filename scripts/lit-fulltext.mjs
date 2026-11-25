// Descarga de textos completos (etapa 4 del screening PRISMA) en lotes.
//
// Uso:
//   node scripts/lit-fulltext.mjs resolve
//   node scripts/lit-fulltext.mjs fetch [--size <k>]
//   node scripts/lit-fulltext.mjs export
//   node scripts/lit-fulltext.mjs clean
//
// La etapa 4 verifica, sobre los candidatos incluidos en la etapa 3, que el
// método sea replicable leyendo el texto completo. Solo se procesan estudios de
// acceso abierto: la bandera de acceso abierto se resuelve con Semantic Scholar
// (criterio documentado en context.md 6.5). Decisión del tesista (23-11-2026):
// sin Unpaywall ni recuperación manual; si un estudio no tiene un PDF
// descargable automáticamente, se excluye como "sin acceso abierto directo".
//
// Estrategia de lotes (decisión del tesista): los textos completos NO se
// guardan en el repositorio. `fetch` descarga a la carpeta temporal de la sesión
// (scratchpad) solo un lote cada vez, extrae el texto con pdftotext y se borra
// tras leerlo (`clean`). El archivo durable es el CSV de decisiones
// (docs/estado-del-arte/screening/etapa4_fulltext.csv), que se reescribe por el
// agente a medida que lee cada lote.

import { parseArgs } from "node:util";
import { resolve, join } from "node:path";
import { existsSync, readFileSync, mkdirSync, rmSync, writeFileSync } from "node:fs";
import { execFileSync } from "node:child_process";
import {
  csvToObjects,
  fetchWithRetry,
  loadEnv,
  normalizeDoi,
  normalizeTitle,
  sleep,
  writeCsv,
} from "./lit-lib.mjs";

const SCREENING = resolve("docs/estado-del-arte/screening");
const INPUT = join(SCREENING, "etapa3_lectura_titulo_abstract.csv");
const LEDGER = join(SCREENING, "etapa4_fulltext.csv");
// Carpeta temporal de la sesión: los PDF y textos extraídos viven aquí, no en el repo.
const SCRATCH = process.env.COMMANDCODE_SCRATCHPAD || resolve("/tmp/tesis-fulltext");
const FT_DIR = join(SCRATCH, "fulltext");
// Textos completos exportados como markdown (durables, para que otros agentes
// los referencien al diseñar el generador y el analizador de similitud).
const EXPORT_DIR = resolve("docs/estado-del-arte/fulltext");

const env = loadEnv();
const S2_HEADERS = env.S2_API_KEY ? { "x-api-key": env.S2_API_KEY } : {};
const S2_DELAY = env.S2_API_KEY ? 300 : 3500;
const S2_FIELDS = "title,isOpenAccess,openAccessPdf,externalIds";

// Columnas del CSV de la etapa 4. Las primeras conservan el contexto del
// registro (idéntico al CSV de la etapa 3) y las últimas son las decisiones.
export const ETAPA4_COLUMNS = [
  "etapa4_id",
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
  "etapa3_razonamiento",
  "etapa3_incluir",
  "etapa4_oa_status",
  "etapa4_fulltext_url",
  "etapa4_candidatas",
  "etapa4_acceso",
  "etapa4_replicable",
  "etapa4_razonamiento",
  "etapa4_incluir",
];

// Columnas de decisión que el agente rellena tras leer. `resolve` nunca las toca.
const DECISION_COLUMNS = ["etapa4_acceso", "etapa4_replicable", "etapa4_razonamiento", "etapa4_incluir"];

const isPdf = (buffer) => buffer && buffer.length > 4 && buffer.subarray(0, 4).toString("latin1") === "%PDF";

// ---------- resolución de acceso abierto ----------

const s2BatchByDoi = async (dois) => {
  const map = new Map();
  const ids = dois.map((doi) => `DOI:${doi}`);
  for (let i = 0; i < ids.length; i += 100) {
    const chunk = ids.slice(i, i + 100);
    const papers = await postJsonUntilAvailable(
      `https://api.semanticscholar.org/graph/v1/paper/batch?fields=${S2_FIELDS}`,
      { ids: chunk },
    );
    chunk.forEach((id, index) => {
      const paper = papers[index];
      if (paper) map.set(id.slice(4), paper);
    });
    console.log(`  S2 batch ${Math.min(i + 100, ids.length)}/${ids.length}`);
    await sleep(S2_DELAY);
  }
  return map;
};

const s2ByTitle = async (title) => {
  const params = new URLSearchParams({ query: title, limit: "1", fields: S2_FIELDS });
  // Búsqueda acotada: el endpoint de búsqueda de S2 está más limitado que el
  // batch, así que se rinde pronto y se marca UNKNOWN en vez de bloquear.
  try {
    const response = await fetchWithRetry(`https://api.semanticscholar.org/graph/v1/paper/search?${params}`, {
      headers: S2_HEADERS,
      tries: 2,
      timeoutMs: 10000,
    });
    const data = await response.json();
    const paper = data.data?.[0];
    if (!paper) return null;
    // Solo acepta el resultado si el título coincide; evita emparejamientos falsos.
    return normalizeTitle(paper.title) === normalizeTitle(title) ? paper : null;
  } catch {
    return null;
  }
};

// ---------- HTTP con reintento ante 429/5xx (espera y vuelve a intentar) ----------

const postJsonUntilAvailable = async (url, body) => {
  for (;;) {
    const response = await fetch(url, {
      method: "POST",
      headers: { "Content-Type": "application/json", ...S2_HEADERS },
      body: JSON.stringify(body),
    });
    if (response.ok) return response.json();
    if (response.status !== 429 && response.status < 500) throw new Error(`HTTP ${response.status}: ${url}`);
    await sleep(retryWait(response));
  }
};

const retryWait = (response) => {
  const retryAfter = Number(response.headers.get("retry-after"));
  return (Number.isFinite(retryAfter) && retryAfter > 0 ? retryAfter : 5) * 1000;
};

// ---------- descarga de PDF ----------

const downloadPdf = async (url) => {
  try {
    const response = await fetchWithRetry(url, {
      headers: { "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36" },
      tries: 2,
      timeoutMs: 45000,
    });
    const buffer = Buffer.from(await response.arrayBuffer());
    return isPdf(buffer) ? buffer : null;
  } catch {
    return null;
  }
};

const extractText = (pdfPath) => {
  try {
    return execFileSync("pdftotext", [pdfPath, "-"], { maxBuffer: 64 * 1024 * 1024 }).toString("utf8");
  } catch {
    return "";
  }
};

// ---------- utilidades de orden y candidatas ----------

// Prefiere URL descargables (repositorios/preprints y PDFs directos) antes que
// páginas de editoriales, que suelen bloquear la descarga automática.
const preferScore = (url) => {
  const u = url.toLowerCase();
  if (/arxiv\.org|\/pdf|\.pdf($|\?)/.test(u)) return 0;
  if (/doi\.org/.test(u)) return 2;
  return 1;
};

const buildCandidates = (paper) => {
  const urls = [];
  if (paper?.openAccessPdf?.url) urls.push(paper.openAccessPdf.url);
  const seen = new Set();
  return urls
    .filter((url) => {
      if (!url || seen.has(url)) return false;
      seen.add(url);
      return true;
    })
    .sort((a, b) => preferScore(a) - preferScore(b));
};

const oaStatusOf = (paper) => {
  if (paper?.openAccessPdf?.status) return paper.openAccessPdf.status;
  if (paper?.isOpenAccess) return "OPEN";
  if (paper && paper.isOpenAccess === false) return "CLOSED";
  return "UNKNOWN";
};

// ---------- resolve ----------

const loadIncluded = () => {
  const rows = csvToObjects(readFileSync(INPUT, "utf8"));
  const included = rows
    .filter((row) => (row.etapa3_incluir || "").trim().toLowerCase().startsWith("s"))
    .map((row) => ({ ...row, doi: normalizeDoi(row.doi) }));
  // Orden determinístico para que etapa4_id sea estable entre corridas.
  included.sort((a, b) => a.query_id.localeCompare(b.query_id) || a.title.localeCompare(b.title) || a.doi.localeCompare(b.doi));
  return included;
};

// Conserva las columnas de decisión ya rellenas al regenerar el ledger.
const previousDecisions = () => {
  const map = new Map();
  if (!existsSync(LEDGER)) return map;
  for (const row of csvToObjects(readFileSync(LEDGER, "utf8"))) {
    map.set(row.etapa4_id, row);
  }
  return map;
};

const runResolve = async () => {
  const included = loadIncluded();
  const dois = [...new Set(included.map((row) => row.doi).filter(Boolean))];
  console.log(`Incluidos de la etapa 3: ${included.length} (con DOI: ${dois.length})`);

  const s2ByDoi = await s2BatchByDoi(dois);

  const prev = previousDecisions();
  const outRows = [];
  for (let i = 0; i < included.length; i += 1) {
    const row = included[i];
    const id = `E4-${String(i + 1).padStart(4, "0")}`;
    // Resuelve por DOI (batch) y, si no hay resultado, por título: así los
    // no-resueltos (UNKNOWN) adquieren candidata y pasan por `fetch`, donde se
    // adquiere la certeza de acceso que exige el criterio (decisión 23-11-2026).
    let paper = row.doi ? s2ByDoi.get(row.doi) : null;
    if (!paper) {
      paper = await s2ByTitle(row.title).catch(() => null);
      await sleep(1200);
    }
    const candidatas = buildCandidates(paper);
    const prevRow = prev.get(id) ?? {};
    const merged = { etapa4_id: id, ...row };
    merged.etapa4_oa_status = oaStatusOf(paper);
    merged.etapa4_fulltext_url = candidatas[0] ?? "";
    merged.etapa4_candidatas = candidatas.join(" | ");
    for (const column of DECISION_COLUMNS) merged[column] = prevRow[column] ?? "";
    outRows.push(merged);
    if ((i + 1) % 100 === 0) console.log(`  procesados ${i + 1}/${included.length}`);
  }
  writeCsv(LEDGER, ETAPA4_COLUMNS, outRows);

  const withPdf = outRows.filter((row) => row.etapa4_candidatas).length;
  const closed = outRows.filter((row) => row.etapa4_oa_status === "CLOSED").length;
  console.log(`\nLedger: ${LEDGER}`);
  console.log(`Registros: ${outRows.length}; con URL de texto completo: ${withPdf}; cerrados (S2): ${closed}`);
  console.log("Siguiente: node scripts/lit-fulltext.mjs fetch");
};

// ---------- fetch ----------

// Cola de descarga: candidatas presentes, sin intentar todavía (etapa4_acceso
// vacío) y sin decidir (etapa4_incluir vacío). Cada registro se intenta una vez;
// el resultado queda en etapa4_acceso y no se reintenta automáticamente.
// Además, los registros UNKNOWN sin candidatas pero con DOI entran a la cola con
// la URL de la editorial (doi.org): solo al intentar la descarga se adquiere la
// certeza de que no hay acceso abierto directo, que es el criterio de exclusión.
const runFetch = async (batchSize) => {
  if (!existsSync(LEDGER)) {
    console.error(`No existe ${LEDGER}. Ejecuta antes: node scripts/lit-fulltext.mjs resolve`);
    process.exit(1);
  }
  const rows = csvToObjects(readFileSync(LEDGER, "utf8"));
  const pending = (row) =>
    !(row.etapa4_acceso || "").trim() && !(row.etapa4_incluir || "").trim();
  const withCandidates = rows.filter((row) => (row.etapa4_candidatas || "").trim() && pending(row));
  // UNKNOWN sin URL resuelta: se intenta el DOI contra la editorial.
  const unknownWithDoi = rows.filter(
    (row) =>
      !(row.etapa4_candidatas || "").trim() &&
      (row.doi || "").trim() &&
      (row.etapa4_oa_status || "").trim() === "UNKNOWN" &&
      pending(row),
  );
  // Sin candidatas ni DOI: no hay nada que intentar; la certeza la da la propia
  // ausencia de identificador recuperable. Se excluyen sin pasar por descarga.
  let autoExcluded = 0;
  for (const row of rows) {
    if (
      !(row.etapa4_candidatas || "").trim() &&
      !(row.doi || "").trim() &&
      (row.etapa4_oa_status || "").trim() === "UNKNOWN" &&
      pending(row)
    ) {
      row.etapa4_acceso = "sin-url";
      row.etapa4_incluir = "no";
      row.etapa4_razonamiento = "sin acceso abierto directo (sin URL recuperable)";
      autoExcluded += 1;
    }
  }
  if (autoExcluded > 0) {
    writeCsv(LEDGER, ETAPA4_COLUMNS, rows);
    console.log(`Sin URL recuperable (excluidos directamente): ${autoExcluded}`);
  }
  const queue = [
    ...withCandidates.map((row) => ({ row, mode: "candidatas" })),
    ...unknownWithDoi.map((row) => ({ row, mode: "doi" })),
  ];
  const batch = queue.slice(0, batchSize);
  if (batch.length === 0) {
    console.log(`No hay candidatas por descargar (en cola: ${queue.length}).`);
    return;
  }
  mkdirSync(FT_DIR, { recursive: true });
  console.log(`Lote: ${batch.length} estudios (en cola: ${queue.length})\n`);
  const status = new Map();
  for (const { row, mode } of batch) {
    const urls =
      mode === "doi"
        ? [`https://doi.org/${row.doi}`]
        : row.etapa4_candidatas.split(" | ").map((url) => url.trim()).filter(Boolean);
    let outcome = "sin-descarga";
    let usedUrl = "";
    for (const url of urls) {
      const buffer = await downloadPdf(url);
      if (!buffer) continue;
      const pdfPath = join(FT_DIR, `${row.etapa4_id}.pdf`);
      writeFileSync(pdfPath, buffer);
      const text = extractText(pdfPath);
      if (text.trim().length < 200) {
        outcome = "pdf-sin-texto"; // PDF escaneado o casi vacío: probar otra URL
        usedUrl = url;
        continue;
      }
      writeFileSync(join(FT_DIR, `${row.etapa4_id}.txt`), text);
      outcome = "descargado";
      usedUrl = url;
      break;
    }
    // Criterio de exclusión del tesista (23-11-2026): sin descarga automática,
    // el estudio se excluye como sin acceso abierto directo. Sin Unpaywall ni
    // recuperación manual.
    if (outcome !== "descargado") {
      status.set(row.etapa4_id, {
        acceso: outcome,
        url: usedUrl || row.etapa4_fulltext_url,
        incluir: "no",
        razonamiento: "sin acceso abierto directo (descarga no disponible)",
      });
    } else {
      status.set(row.etapa4_id, { acceso: outcome, url: usedUrl || row.etapa4_fulltext_url });
    }
    console.log(`[${outcome}] ${row.etapa4_id} (${row.query_id}) ${row.title}`);
    if (outcome === "descargado") console.log(`     texto: ${join(FT_DIR, `${row.etapa4_id}.txt`)}`);
    await sleep(500);
  }
  // Registra el estado de descarga preservando las demás columnas del ledger.
  for (const row of rows) {
    const result = status.get(row.etapa4_id);
    if (result) {
      row.etapa4_acceso = result.acceso;
      if (result.url) row.etapa4_fulltext_url = result.url;
      // Solo se fija la exclusión si el agente no había decidido todavía.
      if (result.incluir && !(row.etapa4_incluir || "").trim()) {
        row.etapa4_incluir = result.incluir;
        row.etapa4_razonamiento = result.razonamiento;
      }
    }
  }
  writeCsv(LEDGER, ETAPA4_COLUMNS, rows);
  console.log(`\nLedger actualizado (${status.size} registros). Textos en ${FT_DIR}`);
  console.log("Tras leer cada lote: node scripts/lit-fulltext.mjs clean");
};

// ---------- export (textos completos de los incluidos como markdown) ----------

const buildMarkdown = (row, text) => {
  const meta = [
    `# ${row.title}`,
    "",
    `- **etapa4_id:** ${row.etapa4_id}`,
    `- **Cluster:** ${row.query_id}`,
    `- **Autores:** ${row.authors}`,
    `- **Año:** ${row.year}`,
    `- **Venue:** ${row.venue}`,
    `- **Tipo documental:** ${row.doc_type}`,
    `- **DOI:** ${row.doi}`,
    `- **URL (registro):** ${row.url}`,
    `- **URL (texto completo):** ${row.etapa4_fulltext_url}`,
    `- **Replicable (etapa 4):** ${row.etapa4_replicable}`,
    `- **Pertinencia (etapa 4):** ${row.etapa4_razonamiento}`,
    "",
    "---",
    "",
  ].join("\n");
  const body = text.trim() || "_No se pudo extraer texto de este documento._";
  const foot = [
    "",
    "",
    "---",
    "",
    "_Texto completo descargado de la URL resuelta y convertido con `pdftotext`. Referencia de la etapa 4 del estado del arte (context.md 6.5)._",
    "",
  ].join("\n");
  return meta + body + foot;
};

const runExport = async () => {
  if (!existsSync(LEDGER)) {
    console.error(`No existe ${LEDGER}. Ejecuta antes resolve/fetch.`);
    process.exit(1);
  }
  const rows = csvToObjects(readFileSync(LEDGER, "utf8"));
  const included = rows.filter((row) => (row.etapa4_incluir || "").trim() === "sí");
  mkdirSync(EXPORT_DIR, { recursive: true });
  mkdirSync(FT_DIR, { recursive: true });
  console.log(`Exportando ${included.length} textos completos a ${EXPORT_DIR}`);
  let ok = 0;
  let fail = 0;
  for (const row of included) {
    const file = join(EXPORT_DIR, `${row.etapa4_id}.md`);
    if (existsSync(file)) {
      ok += 1;
      continue; // ya exportado (idempotente)
    }
    const urls = [row.etapa4_fulltext_url, ...(row.etapa4_candidatas || "").split(" | ")]
      .map((url) => url.trim())
      .filter(Boolean);
    let text = "";
    for (const url of urls) {
      const buffer = await downloadPdf(url);
      if (!buffer) continue;
      const tmpPdf = join(FT_DIR, `${row.etapa4_id}.export.pdf`);
      writeFileSync(tmpPdf, buffer);
      text = extractText(tmpPdf);
      rmSync(tmpPdf, { force: true });
      if (text.trim().length >= 200) break;
    }
    writeFileSync(file, buildMarkdown(row, text));
    if (text.trim().length >= 200) ok += 1;
    else fail += 1;
    console.log(`[${text.trim().length >= 200 ? "OK" : "SIN TEXTO"}] ${row.etapa4_id} ${row.title}`);
    await sleep(400);
  }
  console.log(`\nExportados: ${ok} con texto, ${fail} sin texto extraíble. En ${EXPORT_DIR}`);
};

const runClean = () => {
  rmSync(FT_DIR, { recursive: true, force: true });
  console.log(`Limpiado: ${FT_DIR}`);
};

const main = async () => {
  const { values, positionals } = parseArgs({
    allowPositionals: true,
    options: {
      size: { type: "string" },
    },
  });
  const command = positionals[0];
  if (command === "resolve") {
    await runResolve();
    return;
  }
  if (command === "fetch") {
    await runFetch(Number(values.size ?? 20));
    return;
  }
  if (command === "export") {
    await runExport();
    return;
  }
  if (command === "clean") {
    runClean();
    return;
  }
  console.error("Comando desconocido. Opciones: resolve | fetch | export | clean");
  process.exit(1);
};

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
