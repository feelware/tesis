// Cadenas de búsqueda del estado del arte (revisión 19-11-2026).
// Fuente de verdad ejecutable: los fetchers y el script de navegador leen de aquí.
// Criterio temporal confirmado por el tesista (19-11-2026, actualizado): ventana de
// publicación 2022–2027; se excluyen los estudios de 2021 y anteriores.

export const YEARS_FROM = 2022;

export const SEARCHES = [
  {
    id: "C1",
    cluster: "C1",
    label: "Gamificación y plataformas digitales para entrenamiento auditivo",
    query:
      '("ear training" OR "aural training" OR "melodic dictation" OR "interval dictation") AND ("gamification" OR "gamified" OR "serious game" OR "game-based learning")',
  },
  {
    id: "C1b",
    cluster: "C1",
    label: "Multijugador, intercambio de contenido y engagement en juegos musicales",
    query:
      '("ear training" OR "aural training" OR "melodic dictation" OR "music game") AND ("multiplayer" OR "collaborative game" OR "peer learning")',
  },
  {
    id: "C2a",
    cluster: "C2",
    label: "Generación procedural, por reglas y por restricciones de melodías",
    query:
      '("melody generation" OR "melodic generation" OR "algorithmic composition" OR "procedural music generation" OR "procedural content generation" OR "rule-based music generation" OR "constraint-based music generation" OR "generative grammar" OR "Markov chain" OR "random walk") AND ("monophonic" OR "melody" OR "symbolic music" OR "controllable" OR "music education" OR "exercise generation")',
  },
  {
    id: "C2b",
    cluster: "C2",
    label: "Dificultad y complejidad melódica/rítmica parametrizables; generación de ejercicios",
    query:
      '("melodic complexity" OR "rhythmic complexity" OR "melody difficulty" OR "melodic dictation difficulty" OR "sight-reading difficulty" OR "difficulty level" OR "adaptive exercise" OR "automatic item generation") AND ("music education" OR "ear training" OR "melodic dictation" OR "sight singing" OR "melody")',
  },
  {
    id: "C3a",
    cluster: "C3",
    label: "Métricas de evaluación nota a nota, alineamiento y correspondencia",
    query:
      '("melodic similarity" OR "symbolic music similarity" OR "melody comparison" OR "note matching" OR "note-level evaluation" OR "transcription evaluation" OR "melody alignment" OR "sequence alignment" OR "bipartite matching" OR "mir_eval") AND ("pitch accuracy" OR "rhythm accuracy" OR "onset" OR "tolerance" OR "precision" OR "recall" OR "F-measure" OR "monophonic") AND ("music" OR "melody" OR "melodic" OR "singing" OR "pitch" OR "MIDI")',
  },
  {
    id: "C3b",
    cluster: "C3",
    label: "Evaluación automática de dictado melódico, repentización y canto",
    query:
      '("automatic assessment" OR "automated evaluation" OR "objective evaluation" OR "computer-assisted assessment") AND ("singing" OR "sight-singing" OR "sight reading" OR "melodic dictation" OR "vocal performance" OR "ear training") AND ("pitch accuracy" OR "rhythm accuracy" OR "intonation" OR "feedback" OR "scoring" OR "note-level")',
  },
  {
    id: "C4a",
    cluster: "C4",
    label: "Transcripción musical automática y de canto",
    query:
      '("automatic music transcription" OR "polyphonic note transcription" OR "multipitch estimation" OR "singing transcription" OR "singing voice transcription" OR "vocal melody extraction" OR "monophonic pitch tracking" OR "audio to MIDI") AND ("lightweight" OR "real-time" OR "in-browser" OR "note onset detection" OR "note-level" OR "singing" OR "monophonic")',
  },
  {
    id: "C4b",
    cluster: "C4",
    label: "Transcripción e inferencia en navegador",
    query:
      '("music transcription" OR "pitch detection" OR "audio to MIDI" OR "pitch tracking") AND ("in-browser" OR "web audio" OR "TensorFlow.js" OR "client-side" OR "JavaScript" OR "web application")',
  },
];

// Divide una cadena canónica ("a" OR "b") AND ("x" OR "y") en bloques de frases.
// Cada buscador adapta estos bloques a su sintaxis de búsqueda booleana.
export const parseBlocks = (query) =>
  query
    .split(/\)\s+AND\s+\(/i)
    .map((block) => block.replace(/^\s*\(/, "").replace(/\)\s*$/, ""))
    .map((block) =>
      block
        .split(/\s+OR\s+/i)
        .map((phrase) => phrase.trim().replace(/^"|"$/g, ""))
        .filter((phrase) => phrase.length > 0),
    );

// Adaptación para búsqueda experta de Scopus.
export const scopusQuery = (query) =>
  parseBlocks(query)
    .map((block) => `TITLE-ABS-KEY(${block.map((phrase) => `"${phrase}"`).join(" OR ")})`)
    .join(" AND ");

// Adaptación para búsqueda de IEEE Xplore. IEEE trata las comillas como frase
// exacta y su índice es muy estricto (las frases del caso de uso casi no
// matchean), así que cada frase se expande a sus palabras con AND explícito.
export const ieeeQuery = (query) =>
  parseBlocks(query)
    .map((block) => `(${block.map((phrase) => `(${phrase.split(/\s+/).join(" AND ")})`).join(" OR ")})`)
    .join(" AND ");
