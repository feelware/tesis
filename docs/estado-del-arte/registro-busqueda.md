# Registro de búsqueda — nueva revisión del estado del arte

**Fecha de ejecución:** 19 de noviembre de 2026 (fuentes por API; fuentes con sesión de navegador pendientes)
**Protocolo:** context.md, secciones 6.4 (protocolo) y 6.5 (decisiones del 19-11-2026)
**Código del pipeline:** `scripts/lit-queries.mjs` (cadenas), `scripts/lit-fetch.mjs` (APIs), `scripts/lit-browser-export.mjs` (Scopus/IEEE), `scripts/lit-merge.mjs` (unión y deduplicación)
**Datos crudos:** `docs/estado-del-arte/raw/<fuente>/<busqueda>.csv` (+ `.meta.json` por búsqueda con cadena exacta, filtros y conteos)
**Datos unidos:** `docs/estado-del-arte/merged/` (`deduped.csv`, `duplicates.csv`, `report.md`)

## 1. Decisiones del protocolo (19-11-2026)

- Corte temporal ≥2022 en todo el flujo sistemático (ventana 2022–2027; decisión del tesista del 20-11-2026, antes ≥2021). Sin pista de referentes fundacionales.
- Selección final sin cupo fijo: entran todos los estudios que cumplan los criterios de inclusión (sustituye el mecanismo anterior de "10 más relevantes por cluster").
- Springer Nature se descartó (20-11-2026): sus límites de cuota diaria del plan gratuito impidieron la descarga completa; no se usó ningún resultado.
- Fuentes en uso: IEEE Xplore, Scopus, Semantic Scholar y ERIC; proceedings ISMIR/SMC (bola de nieve). Se descartan Springer Nature (cuota de API), OpenAlex (sin búsqueda booleana, aproximación por frases con sobre-recuperación) y Google Scholar.

## 2. Fuentes y estado de ejecución

| Fuente | Método de acceso | Estado |
| --- | --- | --- |
| Semantic Scholar | API `paper/search/bulk` (sin key; `S2_API_KEY` opcional) | Ejecutada |
| ERIC | API pública `api.ies.ed.gov/eric` | Ejecutada |
| Scopus | Exportación CSV con navegador (perfil persistente `.lit-profile/`, login manual único) | Ejecutada |
| IEEE Xplore | Exportación CSV con navegador (ídem; el export exige sesión iniciada) | Ejecutada (8/8; C3a completo por año: 1132) |
| ISMIR / SMC proceedings | Acceso abierto; rastreo por bola de nieve desde los estudios incluidos | Pendiente: fase de screening |

## 3. Cadenas de búsqueda (exactas)

Se transcriben las 8 búsquedas definitivas. La fuente de verdad ejecutable es `scripts/lit-queries.mjs`.

**C1 — Gamificación y plataformas digitales para entrenamiento auditivo**

```text
("ear training" OR "aural skills" OR "aural training" OR "melodic dictation" OR "sight singing" OR "sight-reading" OR "solfeggio" OR "music education") AND ("serious game" OR "gamification" OR "gamified" OR "game-based learning" OR "multiplayer" OR "collaborative game" OR "online platform" OR "web application")
```

**C1b — Multijugador, intercambio de contenido y engagement en juegos musicales**

```text
("music game" OR "ear training" OR "melodic dictation" OR "sight singing" OR "music education") AND ("multiplayer" OR "collaborative" OR "turn-based" OR "peer learning" OR "user-generated content" OR "engagement" OR "motivation" OR "competition")
```

**C2a — Generación procedural, por reglas y por restricciones de melodías**

```text
("melody generation" OR "melodic generation" OR "algorithmic composition" OR "procedural music generation" OR "procedural content generation" OR "rule-based music generation" OR "constraint-based music generation" OR "generative grammar" OR "Markov chain" OR "random walk") AND ("monophonic" OR "melody" OR "symbolic music" OR "controllable" OR "music education" OR "exercise generation")
```

**C2b — Dificultad y complejidad melódica/rítmica parametrizables; generación de ejercicios**

```text
("melodic complexity" OR "rhythmic complexity" OR "melody difficulty" OR "melodic dictation difficulty" OR "sight-reading difficulty" OR "difficulty level" OR "adaptive exercise" OR "automatic item generation") AND ("music education" OR "ear training" OR "melodic dictation" OR "sight singing" OR "melody")
```

**C3a — Métricas de evaluación nota a nota, alineamiento y correspondencia**

```text
("melodic similarity" OR "symbolic music similarity" OR "melody comparison" OR "note matching" OR "note-level evaluation" OR "transcription evaluation" OR "melody alignment" OR "sequence alignment" OR "bipartite matching" OR "mir_eval") AND ("pitch accuracy" OR "rhythm accuracy" OR "onset" OR "tolerance" OR "precision" OR "recall" OR "F-measure" OR "monophonic")
```

**C3b — Evaluación automática de dictado melódico, repentización y canto**

```text
("automatic assessment" OR "automated evaluation" OR "objective evaluation" OR "computer-assisted assessment") AND ("singing" OR "sight-singing" OR "sight reading" OR "melodic dictation" OR "vocal performance" OR "ear training") AND ("pitch accuracy" OR "rhythm accuracy" OR "intonation" OR "feedback" OR "scoring" OR "note-level")
```

**C4a — Transcripción musical automática y de canto**

```text
("automatic music transcription" OR "polyphonic note transcription" OR "multipitch estimation" OR "singing transcription" OR "singing voice transcription" OR "vocal melody extraction" OR "monophonic pitch tracking" OR "audio to MIDI") AND ("lightweight" OR "real-time" OR "in-browser" OR "note onset detection" OR "note-level" OR "singing" OR "monophonic")
```

**C4b — Transcripción e inferencia en navegador**

```text
("music transcription" OR "pitch detection" OR "audio to MIDI" OR "pitch tracking") AND ("in-browser" OR "web audio" OR "TensorFlow.js" OR "client-side" OR "JavaScript" OR "web application")
```

### 3.1. Adaptación por plataforma

- **Scopus (búsqueda experta):** cada bloque se envuelve en `TITLE-ABS-KEY("frase" OR ...)` y los bloques se unen con `AND` (más `AND PUBYEAR = <año>` cuando se exporta por año).
- **IEEE Xplore:** las comillas en IEEE son búsqueda de frase exacta y su índice las resuelve de forma muy estricta (casi ningún caso de uso matchea), así que cada frase se expande a sus palabras con `AND` explícito dentro de su bloque; el filtro de años va en `ranges=2021_<año actual>_Year`.
- **Semantic Scholar (`bulk`):** `|` como OR dentro de cada bloque y `+` como AND entre bloques.
- **ERIC (Lucene):** cada frase como `title:"..." OR description:"..."` dentro de su bloque; bloques con `AND`.

## 4. Filtros aplicados

- **Año ≥ 2022:** en cliente para Semantic Scholar y ERIC (sus APIs no aceptan rangos de año); en Scopus e IEEE con los filtros de año de cada plataforma.
- **Tipo de documento:** artículos científicos y papers de conferencia. En ERIC además solo registros con revisión por pares (`peerreviewed`); el resto se aplica en el screening.
- **Idioma (inglés y español) y acceso cerrado:** criterios de exclusión que se aplican en el screening y la verificación de full text (la bandera de acceso abierto se registra en los datos; Springer permite verificar full text con su Open Access API).

## 5. Resultados por fuente y búsqueda

Filas obtenidas con las cadenas restringidas (23-11-2026), sin OpenAlex:

| Búsqueda | Semantic Scholar | ERIC | Scopus | IEEE |
| --- | --- | --- | --- | --- |
| C1 | 3 | 15 | 4 | 7 |
| C1b | 1 | 6 | 3 | 29 |
| C2a | 3480 | 0 | 340 | 430 |
| C2b | 37 | 2 | 28 | 64 |
| C3a | 8 | 5 | 11 | 101 |
| C3b | 17 | 0 | 6 | 232 |
| C4a | 87 | 0 | 95 | 143 |
| C4b | 11 | 0 | 5 | 62 |


Notas de la ejecución:

- **Scopus** limita la lista de resultados a 2000 por búsqueda; C3a se reexportó por años para capturar el conjunto completo. Los cortes anuales de C3a son `scopus/C3a.<año>.csv` (2021–2027; los de 2021 quedan fuera de la ventana vigente y no deben usarse).
- **IEEE Xplore** limita la descarga a 1000 resultados y exige sesión iniciada para exportar; C3a se reexportó por años (suma 1132). Los cortes anuales son `ieee/C3a.<año>.csv`; el de 2021 queda fuera de la ventana vigente.
- Las cadenas se adaptaron por plataforma (Scopus `TITLE-ABS-KEY`, IEEE palabras con AND explícito porque sus comillas son búsqueda de frase exacta demasiado estricta, Semantic Scholar `bulk`, ERIC Lucene); ver sección 3.1.

## 6. Unión y deduplicación (23-11-2026, cadenas restringidas, sin OpenAlex)

- Filas leídas: 5232 (IEEE, Scopus, Semantic Scholar y ERIC).
- Estudios únicos tras deduplicar por DOI (o título+año si no hay DOI): 4759.
- Duplicados descartados: 473.
- Estudios con abstract: 4297.
- Etapa 1: 4599 aprobados, 160 excluidos.
- Etapa 2b: 656 aprobados, 3943 excluidos con motivo.

## 7. Observaciones y cambios respecto de la revisión anterior

1. **ERIC no cubre los clusters técnicos:** sus consultas C2a/C3a/C3b/C4a/C4b devuelven 0 resultados reales (verificado con la consulta completa; su base es de educación). Su aporte se concentra en C1/C1b/C2b.
2. **C2a truncado en Semantic Scholar** (3000 de 16993 crudos). El sesgo queda documentado; la cobertura precisa de C2a dependerá de Scopus/IEEE, cuyas búsquedas booleanas por frase son exactas.
4. **Se elimina el cupo de 10 estudios por cluster**; las cifras del flujo de selección se recalcularán desde cero (nunca copiar 1488/832/40).
5. El paper de Basic Pitch (Bittner et al., 2022, *"A Lightweight Instrument-Agnostic Model for Polyphonic Note Transcription and Multipitch Estimation"*, ICASSP) ya está en el Anexo A como última entrada de C4; la nueva revisión hará explícita su relación con la decisión de diseño. Las cadenas no incluyen nombres de productos (decisión del tesista, 19-11-2026): el estudio que introduce Basic Pitch se recupera igualmente por sus términos técnicos ("polyphonic note transcription", "multipitch estimation"), evitando el sesgo circular de buscar la herramienta ya elegida.
6. `mir_eval` (Raffel et al., 2014) queda fuera por el corte ≥2021; las tolerancias de 50 ms y 0.5 semitono deberán respaldarse con literatura 2021+ que las use o delimitarse como aporte propio.

## 8. Etapa 4: texto completo por lotes (24-11-2026)

La etapa 4 verifica, leyendo el texto completo de los candidatos incluidos en la etapa 3, que el método sea replicable (criterio del punto 5 de `context.md` 6.5). Solo se procesan estudios de acceso abierto; el criterio de acceso se verifica con la bandera de acceso abierto de Semantic Scholar.

- **Pipeline:** `scripts/lit-fulltext.mjs` (comandos `resolve`, `fetch`, `clean`; accesible como `npm run lit:fulltext`). Registro de decisiones: `screening/etapa4_fulltext.csv`.
- **Estrategia de lotes (decisión del tesista):** los textos completos no se guardan en el repositorio. `fetch` descarga un lote cada vez a la carpeta temporal de la sesión, extrae el texto con `pdftotext` y se borra con `clean` tras leer. `*.pdf` ya está en `.gitignore`.
- **Resolución OA (`resolve`, con Semantic Scholar batch por DOI + búsqueda por título para no-resueltos):** de los 448 incluidos en la etapa 3 (418 con DOI), 141 tienen URL de texto completo OA (GOLD 52, GREEN 58, HYBRID 20, BRONZE 11), 246 están cerrados y 61 sin resolver/no OA. Conjunto de lectura = 141. Por cluster: C2a 86, C4a 39, C3a 11, C2b 6, C3b 5, C4b 4, C1b 3, C1 2.
- **Regla de acceso (decisión del tesista, 23-11-2026): sin Unpaywall ni recuperación manual.** Un estudio solo se incluye si tiene un PDF descargable automáticamente desde la URL resuelta. Si la descarga falla (landing de editorial) o no hay URL recuperable, se **excluye** con `etapa4_incluir` = no y motivo "sin acceso abierto directo (descarga no disponible)" o "(sin URL recuperable)" — categoría PRISMA "informe no recuperado". La certeza se adquiere al intentar la descarga en la etapa 4, no antes. Los 246 con `etapa4_oa_status=CLOSED` se excluyen por acceso cerrado (resolución OA de S2). Unpaywall queda descartado como herramienta.
- **Etapa 4 COMPLETA (24-11-2026):** de los 448 → **76 incluidos** (texto leído, método replicable; 74 "sí" + 2 "parcial"), **372 excluidos** (246 acceso cerrado + 126 "informe no recuperado"/"sin acceso abierto directo": landing de editorial, sin URL recuperable o intentos `doi.org` sin éxito). Entre los excluidos está Troubadour (E4-0003, Pesek et al.); su contenido queda en `docs/Troubadour.md` como antecedente, no como estudio incluido del SOTA. Incluidos por cluster: C2a 50, C4a 19, C3a 8, C2b 3, C3b 2, C4b 2, C1 1, C1b 1. Tasa de descarga automática ~47% de las URLs OA.
- **Flujo PRISMA etapa 4:** 448 evaluados en texto completo → 246 acceso cerrado + 126 no recuperados (= 372 excluidos) → 76 incluidos.
- **Siguientes pasos:** poblar la tabla de técnicas/resultados/gap con los 76 incluidos y redactar el capítulo II conforme a PRISMA (ver `context.md` 6.5).
