// Exportación de resultados de Scopus e IEEE Xplore mediante un navegador controlado.
//
// Uso: node scripts/lit-browser-export.mjs [--source scopus|ieee] [--search C2a] [--manual]
//
// Abre un navegador con perfil persistente (.lit-profile) para que el usuario
// inicie sesión UNA vez en cada plataforma; las cookies quedan guardadas y las
// corridas siguientes no requieren login. Después ejecuta cada cadena de búsqueda
// (adaptada a la sintaxis de la plataforma), lee el conteo de resultados y
// exporta el CSV a docs/estado-del-arte/raw/<fuente>/<busqueda>.csv.
//
// Si la automatización del diálogo de exportación falla (las UI cambian), el
// script se detiene e imprime la URL exacta y las instrucciones para exportar
// manualmente al mismo destino. Modo --manual: solo abre las URLs y espera.

import { parseArgs } from "node:util";
import { resolve } from "node:path";
import { mkdirSync } from "node:fs";
import { createInterface } from "node:readline/promises";
import { chromium } from "playwright";
import { sleep, writeJson } from "./lit-lib.mjs";
import { SEARCHES, YEARS_FROM, scopusQuery, ieeeQuery } from "./lit-queries.mjs";

const PROFILE_DIR = resolve(".lit-profile");
const RAW_ROOT = resolve("docs/estado-del-arte/raw");
const CURRENT_YEAR = new Date().getFullYear();

const rl = createInterface({ input: process.stdin, output: process.stdout });
let autoYes = false;
const confirm = (message) => {
  if (autoYes) {
    console.log(`${message} [--yes: continúa automáticamente]`);
    return Promise.resolve("");
  }
  return rl.question(message);
};

const debugShot = async (page, name) => {
  try {
    const path = resolve(PROFILE_DIR, `debug-${name}.png`);
    // La captura puede colgarse si la página no responde: se limita con una carrera.
    await Promise.race([
      page.screenshot({ path, fullPage: true }),
      new Promise((resolve) => setTimeout(resolve, 8000)),
    ]);
  } catch {
    // sin captura si la página ya cerró
  }
};

const dismissCookies = async (page) => {
  try {
    const button = page
      .getByRole("button", { name: /accept|agree|got it|allow all|entendido/i })
      .first();
    await button.click({ timeout: 3000 });
    await sleep(1000);
  } catch {
    // sin banner de cookies
  }
};

// innerText puede no volver si la página queda colgada; se limita con una carrera
// contra un temporizador para que la detección no se quede esperando indefinidamente.
const bodyText = async (page, ms = 5000) => {
  const read = () => page.locator("body").innerText({ timeout: ms }).catch(() => "");
  return Promise.race([read(), new Promise((resolve) => setTimeout(() => resolve(""), ms + 1000))]);
};

const resultCount = async (page) => {
  try {
    const text = await bodyText(page);
    const normalized = text.replace(/\u00a0/g, " ");
    // Scopus: "N results" / "N documents"; IEEE: "Showing 1 of N results".
    const match =
      normalized.match(/of\s+([\d.,]+)\s+results?/i) ||
      normalized.match(/([\d.,]+)\s+(?:results|documents)/i);
    return match ? Number(match[1].replace(/[.,]/g, "")) : null;
  } catch {
    return null;
  }
};

const saveDownload = async (page, trigger, outPath) => {
  const [download] = await Promise.all([
    page.waitForEvent("download", { timeout: 90000 }),
    trigger(),
  ]);
  await download.saveAs(outPath);
  console.log(`  Descargado: ${outPath}`);
};

const scopusUrl = () =>
  "https://www.scopus.com/pages/search/publications?type=advanced";

const scopusSearch = async (page, query) => {
  await page.goto(scopusUrl(), { waitUntil: "domcontentloaded", timeout: 90000 });
  await dismissCookies(page);
  // El editor de consultas de Scopus es un editor Monaco (no un textarea).
  const editor = page.locator(".monaco-editor").first();
  await editor.waitFor({ timeout: 60000 });
  await editor.click();
  await page.keyboard.press("Control+A");
  await page.keyboard.press("Delete");
  const finalQuery = /PUBYEAR/i.test(query) ? query : `${query} AND PUBYEAR AFT 2020`;
  await page.keyboard.insertText(finalQuery);
  await page.getByRole("button", { name: /^search/i }).first().click();
  await page.waitForURL(/searchId|results/i, { timeout: 90000 }).catch(() => {});
  await sleep(6000);
};

const scopusExport = async (page, outPath, count) => {
  if (!count || count <= 0) throw new Error("no se detectó el conteo de resultados para el rango de exportación");
  await page.getByRole("button", { name: /^export$/i }).first().click();
  const csvItem = page.getByText(/^csv$/i).first();
  try {
    await csvItem.click({ timeout: 15000 });
  } catch {
    await page.getByRole("button", { name: /^export$/i }).first().click();
    await csvItem.click({ timeout: 15000 });
  }
  await sleep(2500);
  // Rango completo (por defecto solo exporta la página visible).
  await page.locator("#select-range").check();
  await page.locator("input[aria-label='To']").fill(String(count));
  // Abstracts, palabras clave e idioma: vienen desmarcados por defecto.
  for (const id of ["#field_group_abstact", "#field_group_authorKeywords", "#field_group_indexedKeywords", "#field_group_originalLanguage"]) {
    const box = page.locator(id);
    if (!(await box.isChecked())) await box.check();
  }
  // "Truncate to optimize for Excel" viene activado y corta los abstracts.
  const truncate = page.locator("#scopusai-copilot-switch");
  if (await truncate.isChecked()) {
    await page.locator("label[for='scopusai-copilot-switch']").first().click();
  }
  await sleep(500);
  const dialogExport = page
    .locator("[role=dialog] button")
    .filter({ hasText: /^Export/ })
    .filter({ hasNotText: /Processing/ });
  await saveDownload(page, () => dialogExport.click(), outPath);
};

const ieeeUrl = (query, fromYear, toYear) =>
  `https://ieeexplore.ieee.org/search/searchresult.jsp?queryText=${encodeURIComponent(query)}&ranges=${fromYear}_${toYear}_Year`;

const ieeeSearch = async (page, query, fromYear, toYear) => {
  await page.goto(ieeeUrl(query, fromYear, toYear), { waitUntil: "domcontentloaded", timeout: 90000 });
  await dismissCookies(page);
  await sleep(5000);
};

const ieeeExport = async (page, outPath) => {
  await page.getByRole("button", { name: /^export$/i }).first().click();
  await sleep(2500);
  // A veces el modal "Download Results" abre con el formulario de login aunque la
  // sesión sea válida; se cierra y se reintenta tras un reposo.
  const passwordField = page.locator("input[type='password']").first();
  if (await passwordField.isVisible().catch(() => false)) {
    await page.keyboard.press("Escape");
    await sleep(8000);
    await page.getByRole("button", { name: /^export$/i }).first().click();
    await sleep(3000);
    if (await passwordField.isVisible().catch(() => false)) {
      throw new Error("el modal de descarga de IEEE pide iniciar sesión de nuevo");
    }
  }
  // Modal "Download Results": con sesión iniciada ofrece opciones y un botón Download.
  const csv = page.getByText(/^csv$/i).first();
  if (await csv.isVisible().catch(() => false)) {
    await csv.click();
    await sleep(1000);
  }
  await saveDownload(page, () => page.getByRole("button", { name: /^download$/i }).last().click(), outPath);
};

const PLATFORMS = {
  scopus: {
    home: "https://www.scopus.com/pages/home",
    loginHint: "https://www.scopus.com (inicia sesión con tus credenciales institucionales)",
    adapt: scopusQuery,
    search: scopusSearch,
    export: scopusExport,
    exportLimit: 2000,
    loggedOutPattern: /personal sign in/i,
    yearFilter: (query, year) => `${query} AND PUBYEAR = ${year}`,
  },
  ieee: {
    home: "https://ieeexplore.ieee.org/Xplore/home.jsp",
    loginHint: "https://ieeexplore.ieee.org (inicia sesión con tus credenciales institucionales)",
    adapt: ieeeQuery,
    search: ieeeSearch,
    export: ieeeExport,
    exportLimit: 1000,
    loggedOutPattern: /personal sign in/i,
  },
};

const runPlatform = async (context, platformName, searches, manual, yearList, waitLogin) => {
  const platform = PLATFORMS[platformName];
  const page = await context.newPage();
  await page.goto(platform.home, { waitUntil: "domcontentloaded", timeout: 90000 });
  console.log(`\n=== ${platformName} ===`);
  console.log(`Inicia sesión aquí si aún no lo has hecho: ${platform.loginHint}`);

  if (waitLogin) {
    console.log("Esperando inicio de sesión (máx. 30 min)...");
    const deadline = Date.now() + 30 * 60 * 1000;
    let attempts = 0;
    while (Date.now() < deadline) {
      attempts += 1;
      const text = await bodyText(page);
      if (text && !platform.loggedOutPattern.test(text)) {
        console.log("Sesión detectada; continúo con las búsquedas.");
        break;
      }
      if (attempts % 6 === 0 && !text) {
        // La página no responde: captura de diagnóstico y se reintenta.
        console.log(`  La página no responde tras ${attempts} intentos; capturo diagnóstico.`);
        await debugShot(page, `${platformName}-wait-login`);
      }
      await sleep(5000);
    }
  }

  for (const search of searches) {
    const adapted = platform.adapt(search.query);
    console.log(`\n--- ${search.id}: ${search.label}`);
    console.log(`Cadena adaptada: ${adapted}`);
    const outDir = resolve(RAW_ROOT, platformName);
    mkdirSync(outDir, { recursive: true });

    if (manual) {
      const url =
        platformName === "ieee"
          ? ieeeUrl(adapted, YEARS_FROM, CURRENT_YEAR)
          : platform.home;
      console.log(`Abre esta URL y exporta el CSV a ${resolve(outDir, `${search.id}.csv`)}`);
      console.log(url);
      await confirm("Pulsa Enter cuando el CSV esté guardado...");
      continue;
    }

    try {
      await platform.search(page, adapted, YEARS_FROM, CURRENT_YEAR);
      const count = await resultCount(page);
      console.log(`Resultados visibles: ${count ?? "(no detectado)"}`);
      if (count && (count >= platform.exportLimit || yearList)) {
        console.log(`  exportando por año: ${yearList ? yearList.join(", ") : `${YEARS_FROM}..${CURRENT_YEAR + 1}`}`);
        const years = yearList ?? Array.from({ length: CURRENT_YEAR + 1 - YEARS_FROM + 1 }, (_, i) => YEARS_FROM + i);
        for (const year of years) {
          const splitQuery = platform.yearFilter ? platform.yearFilter(adapted, year) : adapted;
          await platform.search(page, splitQuery, year, year);
          const yearCount = await resultCount(page);
          const outPath = resolve(outDir, `${search.id}.${year}.csv`);
          try {
            await platform.export(page, outPath, yearCount);
          } catch (error) {
            console.error(`  Falló la exportación de ${search.id} ${year}: ${error.message.split("\n")[0]}`);
            await debugShot(page, `${platformName}-${search.id}-${year}`);
            try {
              await platform.search(page, splitQuery, year, year);
              const retryCount = await resultCount(page);
              await platform.export(page, outPath, retryCount);
              console.log(`  Reintento de ${year} correcto`);
            } catch (error2) {
              console.error(`  Falló también el reintento de ${year}: ${error2.message.split("\n")[0]}`);
              await debugShot(page, `${platformName}-${search.id}-${year}-retry`);
            }
          }
          await sleep(2000);
        }
      } else {
        await platform.export(page, resolve(outDir, `${search.id}.csv`), count);
      }
      writeJson(resolve(outDir, `${search.id}.meta.json`), {
        source: platformName,
        search_id: search.id,
        cluster: search.cluster,
        label: search.label,
        canonical_query: search.query,
        adapted_query: adapted,
        filters: { year_from: YEARS_FROM, year_to: CURRENT_YEAR },
        retrieved_at: new Date().toISOString(),
        result_count: count,
      });
    } catch (error) {
      console.error(`  Falló la automatización: ${error.message}`);
      await debugShot(page, `${platformName}-${search.id}`);
      console.error("  Exporta manualmente desde la página de resultados a:");
      console.error(`  ${resolve(outDir, `${search.id}.csv`)}`);
      await confirm("Pulsa Enter cuando el CSV esté guardado (o para saltar)...");
    }
    await sleep(3000);
  }
  await page.close();
};

const main = async () => {
  const { values } = parseArgs({
    options: {
      source: { type: "string" },
      search: { type: "string" },
      manual: { type: "boolean", default: false },
      yes: { type: "boolean", default: false },
      years: { type: "string" },
      "wait-login": { type: "boolean", default: false },
    },
  });
  autoYes = values.yes;
  const yearList = values.years ? values.years.split(",").map((year) => Number(year.trim())) : null;
  const platformNames = values.source ? [values.source] : Object.keys(PLATFORMS);
  for (const name of platformNames) {
    if (!PLATFORMS[name]) {
      console.error(`Fuente desconocida: ${name}. Opciones: ${Object.keys(PLATFORMS).join(", ")}`);
      process.exit(1);
    }
  }
  const searches = values.search
    ? SEARCHES.filter((search) => search.id === values.search)
    : SEARCHES;

  const context = await chromium.launchPersistentContext(PROFILE_DIR, {
    headless: !values["wait-login"],
    acceptDownloads: true,
    viewport: { width: 1440, height: 900 },
  });
  try {
    await confirm(
      "Se abrió el navegador con perfil persistente. Inicia sesión en las plataformas y pulsa Enter aquí cuando estés listo...",
    );
    for (const name of platformNames) {
      await runPlatform(context, name, searches, values.manual, yearList, values["wait-login"]);
    }
    console.log("\nListo. Ejecuta `node scripts/lit-merge.mjs` para unir y deduplicar.");
  } finally {
    await context.close();
    rl.close();
  }
};

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
