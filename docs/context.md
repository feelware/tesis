# Contexto integral de la tesis y guía de trabajo para un LLM

**Proyecto:** Tesis – videojuego web multijugador para entrenamiento auditivo  
**Fecha de consolidación:** 3 de noviembre de 2026  
**Última actualización:** 25 de noviembre de 2026
**Idioma principal de trabajo:** español
**Estado del desarrollo:** existe un prototipo del videojuego en la rama `prototipo` (Next.js + Payload + PostgreSQL, con generador, analizador y transcripción integrados y verificados). Desde el 25-11-2026 el prototipo es **multijugador**: cuentas de usuario, salas por código y rondas encadenadas (la salida de cada jugador es la entrada de otro en la ronda siguiente), verificado con una partida simulada de dos usuarios (ver sección 15.3). El documento de tesis está migrado a Typst (`docs/tesis/tesis.typ`) con problema y objetivos actualizados. El capítulo IV fue reescrito el 19-11-2026 para reflejar el prototipo y para separar explícitamente lo implementado de lo especificado como diseño (ver sección 21). En la rama `prototipo`, las secciones de diseño de la versión completa se renderizan; en `prototipo-no-placeholders` se comentaron temporalmente. La revisión del estado del arte se encuentra en marcha conforme a PRISMA 2020 (ver sección 6.5): búsqueda ejecutada en cuatro fuentes, cadenas restringidas, etapa 3 de screening completada y **etapa 4 (texto completo) completada** (76 incluidos de los 448; ver sección 6.5).

> Este documento sirve como contexto persistente para otro LLM que apoyará tanto la redacción académica de la tesis como el diseño e implementación de la codebase. Debe leerse como una especificación de trabajo viva. Distingue entre decisiones confirmadas, propuestas técnicas por validar y cuestiones todavía abiertas. No presentes como implementado, probado o validado aquello que aún no se ha desarrollado. **Cada interacción significativa con un agente que cause una modificación en el proyecto debe actualizarse en este documento**, con los datos relevantes para que otro agente pueda continuar el trabajo: qué se hizo, qué se decidió, qué cambió en el código o en los documentos y qué queda pendiente.

---

## 1. Resumen ejecutivo

La investigación propone desarrollar un videojuego en línea multijugador orientado al entrenamiento de habilidades auditivas musicales, especialmente el **dictado melódico** y la **repentización melódica** (lectura a primera vista e interpretación vocal de una melodía).

La propuesta combina tres capacidades computacionales:

1. **Generación procedural de melodías simbólicas** con parámetros pedagógicos explícitos.
2. **Evaluación de similitud melódica** entre una melodía de referencia y la respuesta del jugador, separando precisión de alturas y precisión rítmica.
3. **Transcripción automática de audio a una representación simbólica/MIDI**, para convertir las interpretaciones vocales de los jugadores en secuencias de notas evaluables.

Estas capacidades se integran en un videojuego web con salas multijugador creadas mediante códigos. La mecánica diferenciadora consiste en que las melodías y respuestas producidas por los jugadores se intercambian entre sí a lo largo de rondas sucesivas. El intercambio, y no la acumulación de puntos o insignias, constituye el núcleo de la experiencia lúdica.

El proyecto no entrenará modelos de aprendizaje automático desde cero. Se priorizarán algoritmos controlables y bibliotecas existentes. En particular, se propone implementar el generador procedural de forma propia con apoyo de bibliotecas musicales JavaScript, integrar un transcriptor de audio existente y construir métricas de similitud simbólica específicas para el problema.

La plataforma tendrá cuentas sencillas, salas abiertas por código, sesiones multijugador síncronas, leaderboard por partida, historial y galería final de las melodías, transcripciones e interpretaciones. También incluirá una funcionalidad docente acotada: aulas simples y consulta de resultados de estudiantes.

---

## 2. Contexto documental y fuentes que debe respetar el LLM

En el proyecto se han proporcionado los siguientes documentos:

- `tesis/tesis.typ`: borrador actual de la tesis, en Typst. Es la fuente primaria para el problema, formulación, objetivos, justificación, marco teórico, estado del arte y metodología actualmente redactados. Sustituye al antiguo `TESIS.txt`, eliminado tras la migración. Usa una plantilla de formato cercana a APA 7 (Times New Roman 12pt, interlineado doble, márgenes de 2.54 cm, sangría de 1.27 cm, rótulos de tabla/figura sobre el elemento, referencias con sangría francesa, Anexo A en páginas apaisadas). Se compila con `typst compile tesis/tesis.typ`; `tesis/tesis.pdf` es el PDF compilado y `tesis/fig1.png` / `tesis/fig2.png` son las figuras del documento.
- `Peffers_2008.md`: artículo metodológico de Peffers et al. que fundamenta el uso de Design Science Research Methodology (DSRM).
- `Troubadour.md`: antecedente cercano sobre una plataforma gamificada de entrenamiento auditivo. Debe utilizarse como referencia técnica y pedagógica, no como plantilla que deba copiarse.
- `Freire_vd.md`: tesis de referencia (Freire, 2025) asesorada por el mismo docente que asesora la presente tesis. Debe guiar el nivel de detalle, el tipo de exposición técnica, la organización y el tono académico. No debe copiarse su texto ni trasladarse mecánicamente su estructura a un proyecto diferente.

### 2.1. Reglas de uso de las fuentes

1. Cuando se redacte contenido basado en estos documentos, verificar que las afirmaciones estén realmente respaldadas por ellos.
2. No inventar resultados, pruebas, componentes, decisiones técnicas ni citas.
3. Diferenciar claramente:
   - **Información presente en el borrador o fuentes de la tesis.**
   - **Decisiones confirmadas por el tesista en conversaciones de trabajo.**
   - **Recomendaciones técnicas del LLM que todavía requieren validación.**
4. No corregir silenciosamente contradicciones entre el borrador y las decisiones nuevas. Señalarlas y proponer una actualización explícita.
5. No presentar a Troubadour como si utilizara exactamente la mecánica de intercambio encadenado aquí propuesta. Es un antecedente de entrenamiento auditivo gamificado, generación de ejercicios y multijugador, pero la mecánica concreta del presente proyecto es distinta.
6. La tesis de Freire es una referencia de estilo y profundidad. El contenido, el diseño metodológico y la arquitectura deben corresponder a esta investigación.

---

## 3. Problema de investigación

### 3.1. Situación problemática descrita en el borrador

En la educación musical formal, el desarrollo de habilidades auditivas exige práctica constante. Los cursos de entrenamiento auditivo pueden presentar una dificultad creciente y representar un obstáculo para estudiantes de música. En el borrador se plantea que las evaluaciones tradicionales de dictado suelen requerir que el estudiante escuche una grabación y transcriba las notas, mientras que la calificación puede tomar varios días. Esta demora dificulta que el estudiante reciba retroalimentación inmediata y pueda identificar oportunamente sus errores.

El borrador también señala limitaciones en ciertas aplicaciones existentes: algunas se concentran en habilidades aisladas, recurren a elementos de gamificación superficiales o no ofrecen mecánicas colaborativas y multijugador que puedan favorecer la participación sostenida.

La investigación busca abordar esta problemática mediante un videojuego que integre ejercicios de dictado y repentización, generación automática de material melódico, evaluación automatizada y una mecánica multijugador basada en el intercambio de las producciones musicales de los participantes.

### 3.2. Problema general vigente en el borrador

> ¿En qué medida el uso de un videojuego en línea basado en generación melódica procedural y análisis de similitud melódica contribuye al desarrollo de habilidades auditivas en estudiantes de música?

Esta es la formulación vigente en `tesis/tesis.typ` (actualizada por el tesista el 11 de noviembre de 2026). Sustituye a la anterior ("¿De qué manera un videojuego en línea basado en técnicas de generación y análisis de similitud melódica facilita...") y recoge parcialmente la alternativa que este documento proponía.

Observación pendiente de confirmar con el tesista y el asesor: la formulación vigente menciona generación procedural y similitud melódica, pero no menciona la transcripción automática de canto ni la mecánica de intercambio entre jugadores, que siguen siendo componentes del diseño (secciones 7 y 10). Si se desea que el problema general los refleje, debe proponerse una redacción explícita; no modificar la pregunta sin validación.

### 3.3. Problemas específicos del borrador

Problemas específicos vigentes (actualizados por el tesista el 11 de noviembre de 2026):

1. ¿Cómo influye el diseño de un algoritmo generador de estructuras melódicas simbólicas en su efectividad para la generación automática de ejercicios de dictado y repentización melódica?
2. ¿Cómo influye el diseño de un algoritmo de análisis de similitud melódica en su efectividad para la evaluación de transcripciones e interpretaciones musicales de los jugadores?
3. ¿Qué impacto tienen los componentes de un videojuego en línea que implementa mecánicas de dictado y repentización melódica en el desarrollo de habilidades auditivas en estudiantes de música?
4. ¿Cómo la validación del videojuego implementado mediante un estudio experimental con estudiantes de música demuestra la efectividad pedagógica de dicho videojuego?

La advertencia anterior sobre el "modelo generativo existente" queda resuelta: los problemas ya se formulan en términos de **algoritmos** propios (generador procedural y comparador), no de integración de modelos preexistentes.

Observaciones de redacción pendientes (no modificar sin validación):

- Ningún problema específico menciona la transcripción automática de audio a MIDI. Decisión del tesista (11-11-2026): **no tendrá problema ni objetivo propios**; queda relegada al problema/objetivo de la construcción del videojuego. El componente se implementa como parte del artefacto (sección 10).
- El problema 4 mantiene la sintaxis de pregunta ("¿Cómo la validación ... demuestra ...?"); su redacción merece revisión.

---

## 4. Objetivos de investigación

### 4.1. Objetivo general actualmente redactado

> Desarrollar un videojuego en línea basado en generación melódica procedural y análisis de similitud melódica para el desarrollo de habilidades auditivas en estudiantes de música.

Objetivo vigente en `tesis/tesis.typ` (actualizado por el tesista el 11 de noviembre de 2026). La revisión que este documento proponía ya no aplica: el objetivo refleja la generación procedural. Se mantiene la observación del apartado 3.2: la transcripción automática de canto y la mecánica multijugador no aparecen mencionadas.

### 4.2. Objetivos específicos actuales

Objetivos vigentes en `tesis/tesis.typ` (corregidos por el tesista el 11-11-2026), transcritos tal como están redactados hoy:

1. Diseñar un algoritmo generador de estructuras melódicas simbólicas para la generación automática de ejercicios de dictado y repentización melódica.
2. Diseñar un algoritmo de análisis de similitud melódica para la evaluación de transcripciones e interpretaciones musicales de los jugadores.
3. Desarrollar un videojuego en línea que implementa mecánicas de dictado y repentización melódica para el desarrollo de habilidades auditivas en estudiantes de música.
4. Validar el videojuego implementado mediante un estudio experimental con estudiantes de música para demostrar la efectividad pedagógica de dicho videojuego.

Antes había cinco objetivos; el dedicado a la transcripción musical automática (audio a MIDI) no existe como objetivo propio por decisión del tesista (ver 4.3).

### 4.3. Ajustes pendientes tras la actualización de objetivos

El tesista aplicó las correcciones de redacción el 11-11-2026 (objetivo 4 reformulado en infinitivo, "Tabla 4.1" corregido a "Tabla 3", erratas de 1.1/2.1/3.2.2 resueltas) y tomó la decisión sobre la transcripción automática: **no tendrá objetivo asociado** y queda relegada al problema/objetivo de la construcción del videojuego; se implementa igualmente como componente del artefacto (sección 10) porque es necesaria para evaluar la repentización.

Corregido el 19-11-2026: el objetivo 2 ya termina en punto ("...de los jugadores.").

El objetivo de evaluación requiere especial atención: la factibilidad de un diseño experimental con grupo control, pretest, postest e intervención suficiente debe contrastarse con el calendario, el tamaño de muestra y la disponibilidad de estudiantes.

---

## 5. Marco metodológico: DSRM y evaluación pedagógica

### 5.1. Tipo y enfoque de investigación descritos

El borrador caracteriza el estudio como:

- Investigación aplicada.
- Enfoque cuantitativo.
- Diseño experimental, con grupo experimental y grupo de control, mediciones antes y después de la intervención.

El borrador plantea que el grupo experimental utilizará el videojuego, mientras que el grupo control recibirá entrenamiento mediante métodos convencionales. Se recogerán datos numéricos de desempeño en dictado y repentización.

Estas decisiones deben revisarse según la viabilidad real. Si no es posible asignar aleatoriamente a los participantes o controlar las condiciones, podría corresponder describir el diseño como cuasi-experimental. No cambiar la clasificación sin analizar las condiciones del estudio y consultar al asesor.

### 5.2. DSRM de Peffers et al. (2008)

La tesis adopta Design Science Research Methodology, organizada en seis actividades:

1. **Identificación del problema y motivación.** Precisar la problemática del entrenamiento auditivo, la demora de retroalimentación y las limitaciones de las soluciones existentes.
2. **Definición de objetivos para la solución.** Especificar qué capacidades debe ofrecer el artefacto: generar melodías, recibir dictados, capturar interpretaciones, transcribir audio, comparar resultados y facilitar la experiencia multijugador.
3. **Diseño y desarrollo.** Diseñar e implementar el videojuego y sus componentes técnicos.
4. **Demostración.** Comprobar que el artefacto puede ejecutar el flujo de juego previsto en sesiones controladas.
5. **Evaluación.** Determinar en qué medida el artefacto satisface los objetivos. La evaluación pedagógica mediante intervención y pruebas de desempeño forma parte de esta actividad.
6. **Comunicación.** Documentar el problema, el artefacto, el proceso y los resultados en la tesis y, eventualmente, en publicaciones.

La demostración y la evaluación no son equivalentes. La demostración prueba que el sistema puede funcionar para el caso de uso; la evaluación busca determinar si cumple los objetivos y si produce los resultados esperados.

DSRM permite iteración. Si durante la evaluación técnica o demostración se descubre que el diseño no satisface los requisitos, se puede volver a actividades de diseño y desarrollo. No presentar las seis actividades como una secuencia rígida que prohíbe iteraciones.

### 5.3. Plan de evaluación descrito en el borrador

El borrador propone:

- Población: estudiantes que cursan programas de formación musical en una institución especializada.
- Muestreo: no probabilístico por conveniencia.
- Unidad de análisis: cada estudiante.
- Recolección: pruebas de desempeño de dictado y repentización antes y después de la intervención.
- Análisis: estadística descriptiva e inferencial, seleccionando pruebas según la naturaleza y distribución de los datos.

La cantidad de participantes todavía no está determinada. Tampoco debe asumirse una duración de intervención definitiva. En el borrador se citan estudios de ocho semanas (Chen y Li, 2025; Lingjie, 2025), pero esos antecedentes no demuestran por sí solos que ocho semanas sean suficientes para esta intervención ni que el diseño propuesto sea equivalente. La duración debe justificarse con literatura y con la viabilidad del estudio.

**Pendiente crítico:** definir instrumentos de pretest y postest, rúbricas, criterios de equivalencia, duración, muestra, procedimiento de asignación, consentimiento informado, tratamiento de datos y pruebas estadísticas.

---

## 6. Estrategia de búsqueda y actualización del estado del arte

### 6.1. Estrategia originalmente descrita en el borrador

La revisión se dividió en cuatro búsquedas o clusters independientes porque las técnicas necesarias para el videojuego son distintas y una búsqueda única podría omitir literatura técnica relevante:

- **C1 – Educación musical gamificada:** aplicaciones, plataformas, juegos serios y aprendizaje basado en juegos en entrenamiento auditivo.
- **C2 – Generación automática de melodías:** generación de estructuras melódicas o música simbólica.
- **C3 – Similitud melódica:** comparación de estructuras musicales simbólicas y alineamiento de secuencias.
- **C4 – Transcripción musical automática:** conversión de audio a representaciones simbólicas, detección de alturas y ataques, transcripción de canto.

Las fuentes documentales descritas en el borrador eran Springer Nature Link, IEEE Xplore, Scopus y OpenAlex (Springer y OpenAlex se descartaron, ver sección 6.5). Se justificó su selección por cobertura académica y capacidades de búsqueda booleana. El borrador menciona limitaciones de búsqueda/descarga como razones para excluir ACM Digital Library, MDPI, ScienceDirect y Web of Science en el proceso original. Si se rehace la revisión, volver a comprobar las condiciones actuales de acceso y búsqueda; no asumir que las limitaciones siguen idénticas.

Las cadenas originales incluidas en el borrador son:

**C1**

```text
("ear training" OR "aural training" OR "music dictation" OR "melodic dictation" OR "sight reading" OR "music education")
AND
("gamification" OR "gamified" OR "serious game" OR "educational game" OR "game-based learning" OR "multiplayer game" OR "online platform")
```

**C2**

```text
"melody generation" OR "melodic generation" OR "music generation" OR "symbolic music generation" OR "automatic exercise generation" OR "procedural music generation" OR "algorithmic composition" OR "computational music generation"
```

**C3**

```text
"melodic similarity" OR "music similarity" OR "symbolic music similarity" OR "melody comparison" OR "symbolic sequence similarity" OR "music sequence alignment" OR "music pattern matching"
```

**C4**

```text
"automatic music transcription" OR "audio to MIDI" OR "music transcription" OR "symbolic music transcription" OR "pitch detection" OR "note onset detection" OR "singing transcription" OR "polyphonic transcription"
```

Criterios originales:

- Exclusión: estudios anteriores a 2021, acceso cerrado e idiomas distintos del inglés y español.
- Inclusión: artículos científicos y papers de conferencia; trabajos de educación musical con gamificación/aprendizaje basado en juegos; y estudios técnicos que aplican generación, similitud o transcripción y reportan modelos preentrenados públicamente disponibles.

El procedimiento descrito fue ejecutar las cadenas, aplicar filtros, exportar resultados CSV, concatenar y deduplicar. El borrador registra 1488 estudios tras deduplicación, 832 candidatos tras revisar títulos y 40 estudios seleccionados (10 por cluster) tras revisar abstracts. Estos números describen el proceso original y **no deben reutilizarse como resultados de una revisión nueva**.

### 6.2. Por qué debe rehacerse parcialmente

La búsqueda anterior de C2 se formuló con una orientación importante hacia modelos de generación automática y modelos preentrenados. Sin embargo, la decisión de diseño cambió: se priorizará un **generador procedural basado en reglas y restricciones explícitas**.

Esto cambia la pregunta tecnológica. Ya no se busca necesariamente el modelo generativo más avanzado, sino:

- algoritmos de composición procedural de melodías monofónicas;
- generación algorítmica condicionada por escala, ambitus, intervalos, compás, ritmo y longitud;
- métodos de generación de ejercicios musicales para educación;
- bibliotecas JavaScript/TypeScript de teoría musical y manipulación MIDI;
- métodos para producir melodías musicalmente coherentes y pedagógicamente controlables.

C3 también debe reformularse. La solución ya no pretende adoptar un modelo de similitud musical general o una red neuronal para medir parecido perceptivo entre canciones. El problema es más específico: comparar dos secuencias monofónicas simbólicas producidas en un ejercicio y calcular precisión de alturas y de ataques rítmicos. Deben buscarse:

- métricas de evaluación de transcripción de notas;
- note matching y onset matching;
- precision, recall y F-measure para eventos musicales;
- tolerancias de altura, tiempo de inicio y duración;
- alineamiento de secuencias y emparejamiento bipartito;
- métricas pedagógicas de dictado y ejecución vocal.

C4 debe priorizar **transcripción monofónica de canto** y bibliotecas que puedan ejecutarse desde JavaScript/TypeScript o integrarse en una aplicación web. La transcripción polifónica general no es el caso principal de uso. Deben revisarse modelos de singing transcription, monophonic pitch tracking, onset detection y audio-to-MIDI en navegador.

C1 debe ampliarse para buscar específicamente:

- juegos multijugador para entrenamiento auditivo;
- juegos musicales con producción/transformación de contenido entre participantes;
- mecánicas de intercambio encadenado de respuestas;
- engagement, motivación, colaboración y competencia en juegos educativos;
- plataformas docentes con seguimiento de resultados.

### 6.3. Cadenas nuevas sugeridas

> Actualización 19-11-2026: estas cadenas fueron sustituidas por las cadenas definitivas de la nueva revisión, registradas en `docs/estado-del-arte/registro-busqueda.md` (ver sección 6.5). Se conservan aquí solo como antecedente del proceso.

No reemplazan automáticamente las cadenas oficiales; son punto de partida para una nueva búsqueda documentada.

**C1 – Juego y entrenamiento auditivo**

```text
("ear training" OR "aural skills" OR "melodic dictation" OR "sight singing" OR "sight-reading" OR "music education")
AND
("multiplayer" OR "collaborative game" OR "social game" OR "game-based learning" OR "serious game" OR "gamified platform" OR "online game")
```

**C2 – Generación procedural y algorítmica**

```text
("procedural melody generation" OR "algorithmic melody generation" OR "rule-based music generation" OR "constraint-based music generation" OR "algorithmic composition" OR "melodic exercise generation" OR "procedural music")
```

**C3 – Evaluación de notas y ritmo**

```text
("note-level evaluation" OR "note matching" OR "onset matching" OR "transcription evaluation" OR "melody alignment" OR "symbolic melody comparison" OR "pitch accuracy" OR "rhythm accuracy")
AND
("monophonic" OR "melody" OR "singing" OR "music transcription")
```

**C4 – Transcripción de canto**

```text
("singing transcription" OR "singing voice transcription" OR "vocal melody extraction" OR "monophonic music transcription" OR "audio to MIDI" OR "pitch tracking")
AND
("automatic music transcription" OR "note onset detection" OR "pitch estimation")
```

### 6.4. Protocolo de actualización

El LLM que rehaga el estado del arte debe:

1. Registrar fecha de búsqueda, repositorio, cadena exacta, filtros y número de resultados por búsqueda.
2. Guardar exportaciones originales (CSV/RIS/BibTeX) y una tabla de deduplicación.
3. Aplicar criterios de inclusión/exclusión consistentes y explicar cualquier cambio respecto de la revisión original.
4. Revisar título, abstract y texto completo cuando sea necesario.
5. Extraer para cada estudio: referencia, problema, método, técnica, dataset o población, disponibilidad de código/modelo, resultados, limitaciones, pertinencia y gap.
6. Distinguir artículos científicos de documentación de software, repositorios y paquetes npm. Estos últimos son evidencia para decisiones de implementación, pero no sustituyen antecedentes científicos.
7. No presentar como “estado del arte” una lista de paquetes de software sin análisis comparativo.
8. Conservar los estudios C1 que siguen siendo pertinentes, pero verificar actualidad y pertinencia. Los clusters C2–C4 requieren una revisión sustantiva.
9. Recalcular las cifras del flujo de selección; nunca copiar las cifras anteriores a la nueva revisión.
10. Asegurar que toda afirmación bibliográfica tenga referencia verificable y que las citas y referencias finales coincidan.

### 6.5. Nueva revisión del estado del arte: decisiones y estado (19-11-2026; actualizado al 23-11-2026)

Decisiones confirmadas por el tesista el 19-11-2026:

1. **Corte temporal ≥2022** para todo el flujo sistemático (actualizado el 20-11-2026; antes ≥2021). La tesis se publicará en 2027, así que la ventana es 2022–2027. Todo estudio publicado en 2021 o antes queda excluido. No habrá pista separada de "referentes fundacionales": `mir_eval` (Raffel et al., 2014) y otros trabajos anteriores a 2022 no se citarán como antecedentes del estado del arte. Las tolerancias (50 ms, 50 cents) y el matching bipartito deberán respaldarse con literatura 2022+ que las use/compare o delimitarse explícitamente como aporte propio en el capítulo IV. El paper de Basic Pitch (Bittner et al., 2022) entra en la ventana (2022) y figura en el Anexo A como última entrada de C4.
2. ~~**Springer Nature vía Metadata API**~~ **Descartada (20-11-2026, decisión del tesista).** Sus límites de cuota diaria en el plan gratuito impidieron obtener los resultados completos dentro del plazo del estudio. No se usó ningún resultado de Springer: se eliminaron sus CSV, metas, código del fetcher, claves de `.env` y registros. La tesis lo menciona como limitación del acceso a fuentes.
3. **Fuentes en uso:** IEEE Xplore y Scopus (exportación con navegador), Semantic Scholar (API) y ERIC (API pública; literatura pedagógica para C1). OpenAlex se descarta (20-11-2026, decisión del tesista): no soporta búsqueda booleana, lo que obligaba a una aproximación por frases con sobre-recuperación y desviaba la cadena de búsqueda. Springer Nature queda descartada (punto 2). Proceedings ISMIR/SMC se rastrean por bola de nieve. Se descarta Google Scholar por limitaciones de acceso.
4. **Selección final sin cupo fijo**: entran todos los estudios que cumplan los criterios de inclusión (se sustituye el mecanismo anterior de "10 más relevantes por cluster"). Ningún cluster pasa a la etapa 2 hasta que todas sus búsquedas estén completas en todas las fuentes (ver punto 6).
5. **Criterio de inclusión sobre modelos reformulado** (20-11-2026). El criterio original exigía "reportar públicamente modelos pre-entrenados", propuesto antes de cambiar el enfoque a generación procedural y análisis de similitud por algoritmos. El nuevo criterio es: estudios que describen un método de generación de melodías, de similitud o evaluación de secuencias musicales, o de transcripción de audio a notas, con detalle suficiente para replicarlo (algoritmo, pseudocódigo, parámetros o métricas definidas), mediante implementación pública, datos abiertos o descripción replicable. Los métodos basados en modelos aprendidos se incluyen cuando cumplen el mismo criterio. Está escrito en la tabla 2 de `tesis.typ`.
6. **Completitud antes del screening** (20-11-2026; Springer excluida, ver punto 2). El tesista exige que todos los estudios que cumplen las cadenas y el corte temporal estén en los CSV antes de filtrar. **Estado: cumplido el 23-11-2026.** Las cuatro fuentes (Semantic Scholar, ERIC, Scopus, IEEE) están completas y sin topes de descarga para las ocho búsquedas.

Cadenas definitivas: 8 búsquedas (C1, C1b, C2a, C2b, C3a, C3b, C4a, C4b) definidas en `scripts/lit-queries.mjs` (fuente de verdad ejecutable) y transcritas en `docs/estado-del-arte/registro-busqueda.md`. Resumen de la intención:

- **C1/C1b:** gamificación y juegos para entrenamiento auditivo; multijugador, intercambio de contenido y engagement (justifican las mecánicas del juego).
- **C2a/C2b:** generación procedural/por reglas/por restricciones, gramáticas, cadenas de Markov y random walk; y dificultad/complejidad melódica parametrizable y generación de ejercicios (justifican el generador del prototipo: selección ponderada por proximidad, restricciones de intervalo/ambitus/escala, modulación, figuras rítmicas, determinismo por semilla).
- **C3a/C3b:** métricas de evaluación nota a nota (note matching, tolerancias, precision/recall/F1, alineamiento, correspondencia bipartita) y evaluación automática de dictado/repentización/canto con retroalimentación (justifican el analizador del prototipo: dimensiones separadas de altura y ritmo, tolerancias 0.5 semitono y 50/150 ms, matching bipartito máximo, media de F1).
- **C4a/C4b:** transcripción musical automática y de canto y despliegue/inferencia en navegador (justifican la integración de `@spotify/basic-pitch` en Web Worker con TensorFlow.js). Las cadenas no incluyen nombres de productos: el estudio que introduce Basic Pitch (Bittner et al., 2022) se recupera por términos técnicos, sin sesgo circular (decisión del tesista, 19-11-2026).

Pipeline implementado (`scripts/lit-*.mjs`, con `npm run lit:fetch|lit:merge|lit:browser|lit:fulltext`):

1. `lit-fetch.mjs`: consultas por API (Semantic Scholar, ERIC) con booleanos del lado del servidor. Pagina hasta agotar resultados. Escribe `docs/estado-del-arte/raw/<fuente>/<busqueda>.csv` y `.meta.json` con fecha, cadena exacta, filtros y conteos.
2. `lit-browser-export.mjs`: navegador Playwright con perfil persistente (`.lit-profile/`, gitignoreado) para exportar CSV de Scopus e IEEE Xplore; el login manual del tesista se hace una sola vez y las credenciales no se comparten con el agente ni se guardan en el repo. Modo de operación: con `--wait-login` el navegador se muestra para iniciar sesión; sin esa bandera corre en headless. Pendiente de implementar: detectar sesión caducada en headless y reabrir una ventana visible solo para ese login (ver 6.6).
3. `lit-merge.mjs`: normaliza nombres de columnas (por ejemplo "abstract"/"Abstract"/"description"), concatena, deduplica por DOI o título+año y escribe `docs/estado-del-arte/merged/` (deduped.csv, duplicates.csv, report.md).
4. Selección en cuatro etapas (decisión del tesista, 20-11-2026; ver también `tesis.typ` sección 2.4.2):
   - **Etapa 1, mecánica (script):** descartar año ≤2021 (la ventana vigente es 2022–2027), registros sin título ni abstract, e idiomas distintos de inglés o español. Resultado: `merged/` filtrado.
   - **Etapa 2, prefiltro temático (script):** conservar registros con términos del dominio musical en título, abstract o keywords.
   - **Etapa 3, lectura de título y abstract (agente):** aplicar criterios de inclusión y exclusión, registrando motivo para cada decisión. No se usa cupo por cluster. Se valida una muestra aleatoria con criterio humano del tesista antes de confiar en el filtro.
   - **Etapa 4, texto completo (lectura manual, solo acceso abierto):** para los candidatos de la etapa 3, verificar que el método es replicable. El criterio de acceso cerrado se verifica con la bandera de acceso abierto de Semantic Scholar.
     Ninguna etapa comienza para un cluster hasta cumplir el punto 6 de la sección 6.5.

**Estado de la selección (20-11-2026, sin Springer):**

- Entrada: `merged/deduped.csv` con 43935 estudios únicos.
- **Etapa 1 (completa, script):** 41608 aprobados (`screening/etapa1_aprobados.csv`); 2327 excluidos con motivo (`screening/etapa1_excluidos.csv`): 1076 por año ≤2021 y 1251 por idioma distinto de inglés o español. Los idiomas sin dato (3325) no se excluyen por sí solos.
- **Etapa 2 (completa, script):** 18601 aprobados (`screening/etapa2_aprobados.csv`); 23007 excluidos con motivo (`screening/etapa2_excluidos.csv`). El prefiltro es amplio a propósito: una comprobación sobre los descartados encontró solo 2 con señal musical fuerte en el título, y ninguno de música técnica.
- **Etapa 3 (iniciada, pendiente de lectura):** `screening/etapa3_lectura_titulo_abstract.csv` clonado de la etapa 2 con las columnas `etapa3_razonamiento` y `etapa3_incluir` (sí/no), vacías. Una muestra de C2a mostró que de cada 15 registros, unos 6 son de música técnica y el resto es ruido de otros campos; por eso la etapa 3 es la que más descarta. Se llena por lotes; ningún registro debe marcarse sin leer título y abstract.
- **Etapa 4 (en curso, texto completo por lotes):** ver detalle abajo. Pipeline: `scripts/lit-fulltext.mjs` (comandos `resolve`, `fetch`, `clean`).
- Pendiente de validación: muestra aleatoria de la etapa 3 revisada por el tesista para medir concordancia.

**Re-ejecución con cadenas restringidas y sin OpenAlex (23-11-2026):**

- Base nueva: `merged/deduped.csv` con 4759 estudios únicos (5232 filas leídas, 473 duplicados, 4297 con abstract).
- Etapa 1: 4599 aprobados, 160 excluidos (143 por año ≤2021, 17 por idioma).
- Etapa 2b: **656 aprobados** (`screening/etapa2b_aprobados.csv`), 3943 excluidos con motivo (2721 tipo documental, 1132 sin señal musical en título, 90 señal débil en abstract).
- Por cluster: C2a 370, C4a 139, C3a 70, C3b 56, C2b 52, C4b 22, C1b 11, C1 4.
- Validación de C1: Troubadour (Pesek et al.) está entre los 4 aprobados de C1, con la cadena restringida.
- El volumen bajó de 18601 a 656, dentro del objetivo de ≤1000 fijado por el tesista.
- Corrección de pipeline (23-11-2026): se restauró `matchedPhrasesOf` en `lit-fetch.mjs` (se perdió al borrar OpenAlex), se corrigió el adaptador de ERIC (las comillas de frase anulan la combinación AND; ahora expande frases a palabras con AND, como en IEEE) y se hicieron no bloqueantes la lectura de página y la captura de diagnógico de `lit-browser-export.mjs`, que colgaban la detección de sesión.
  **Etapa 3 completada (23-11-2026):**

- 656 registros leídos (título y abstract): **448 incluidos**, **208 excluidos**, ninguno sin decidir. Cada fila de `screening/etapa3_lectura_titulo_abstract.csv` lleva `etapa3_incluir` (sí/no) y `etapa3_razonamiento`.
- Incluidos por cluster: C2a 291, C4a 108, C3a 40, C2b 20, C3b 16, C4b 12, C1b 7, C1 3.
- Exclusiones por categoría (para el resumen PRISMA): fuera de alcance del método 105; síntesis o conversión de voz 60; sin método replicable 1; otros motivos puntuales 42.
- Sobre PRISMA y la tabla de la tesis: PRISMA no exige una tabla con el razonamiento de cada estudio. Exige el conteo de excluidos en título/abstract y, en texto completo, los motivos resumidos por categoría. La tabla de técnicas/resultados/gap aplica solo a los estudios incluidos, que es lo que el tesista planea incluir. El razonamiento por registro queda como material de auditoría del proceso.
- **Etapa 4 completada (24-11-2026):** 76 incluidos / 372 excluidos (ver "Etapa 4 COMPLETA" abajo). Pendiente: poblar la tabla de técnicas/resultados/gap con los 76 incluidos, redactar el capítulo II conforme a PRISMA, y validación de una muestra de la etapa 3 y 4 por el tesista.
- **Aclaración sobre el criterio de acceso abierto (23-11-2026, observación del tesista):** la columna `open_access` de los CSV de las etapas 1–3 no es el criterio de exclusión por acceso cerrado, sino un metadato incompleto: IEEE y Scopus no la exportan (blanco = desconocido, no cerrado) y el `false` de Semantic Scholar significa "S2 no encontró copia OA", no "acceso cerrado confirmado". El criterio de exclusión por acceso cerrado **sí se aplica, en la etapa 4**, contra el resultado de la resolución OA (`etapa4_oa_status`): los 246 con estado CLOSED quedan fuera del conjunto de lectura y se documentan como excluidos por acceso cerrado. Los UNKNOWN (61) no tienen copia OA identificable y, por la decisión del 23-11-2026 (sin recuperación manual ni Unpaywall), se excluyen como "sin acceso abierto directo" (ver "Estado de la etapa 4"). Error corregido: se había excluido en etapa 3 a 11 registros por `open_access=false`, varios de ellos preprints o copias verdes; se revirtieron a incluidos y su destino lo decide la resolución OA de la etapa 4.

**Etapa 4 (texto completo por lotes, completada 24-11-2026). Pipeline `scripts/lit-fulltext.mjs`.**

Objetivo (context.md 6.5): sobre los 448 incluidos en la etapa 3, verificar leyendo el texto completo que el método es replicable (criterio del punto 5: método de generación/similitud/transcripción descrito con detalle replicable —algoritmo, pseudocódigo, parámetros o métricas— vía implementación pública, datos abiertos o descripción replicable). Solo se procesan estudios de acceso abierto; el criterio de acceso se verifica con la bandera de acceso abierto de Semantic Scholar.

- **No se almacenan los textos completos en el repo.** Decisión del tesista: descargar en lotes para no guardarlos todos. `fetch` descarga cada lote a la carpeta temporal de la sesión (scratchpad `fulltext/`), extrae el texto con `pdftotext` y se borra con `clean` tras leer. Lo durable es el CSV de decisiones.
- **Ledger:** `screening/etapa4_fulltext.csv` — clona las columnas del CSV de la etapa 3 y añade: `etapa4_id`, `etapa4_oa_status`, `etapa4_fulltext_url`, `etapa4_candidatas`, `etapa4_acceso`, `etapa4_replicable`, `etapa4_razonamiento`, `etapa4_incluir`. `resolve` (idempotente, merge-safe) resuelve OA y preserva las decisiones ya escritas; el agente rellena las columnas de decisión a medida que lee cada lote.
- **Comandos:** `npm run lit:fulltext -- resolve` (resuelve OA de los 448 vía S2 batch por DOI + búsqueda por título para no-resueltos); `npm run lit:fulltext -- fetch [--size K]` (descarga el siguiente lote, registra `etapa4_acceso` y aplica la regla de exclusión a las descargas fallidas); `npm run lit:fulltext -- clean` (borra los textos del lote leído). Sin Unpaywall (decisión 23-11-2026).

**Resolución de acceso abierto (resolve, 24-11-2026):** de los 448 incluidos de la etapa 3 (418 con DOI), S2 devuelve:

- **141 con URL de texto completo OA** (GOLD 52, GREEN 58, HYBRID 20, BRONZE 11) → conjunto de lectura de la etapa 4.
- **246 cerrados** (bandera `isOpenAccess=false` de S2; incluye 1 resuelto por título) → excluidos por acceso cerrado.
- **61 sin resolver/no OA identificado** (28 sin URL recuperable, 33 con DOI intentados contra doi.org sin éxito) → excluidos como no recuperados. Decisión del tesista (23-11-2026): sin recuperación manual ni Unpaywall; si no se descargan solos, se excluyen.
- Por cluster (conjunto OA de 141): C2a 86, C4a 39, C3a 11, C2b 6, C3b 5, C4b 4, C1b 3, C1 2.

**Etapa 4 COMPLETA (24-11-2026):** de los 448 incluidos en la etapa 3 →

- **76 incluidos** (texto completo leído, método replicable; ver `etapa4_fulltext.csv`). De ellos, 74 con `etapa4_replicable=sí` y 2 "parcial" (E4-0154 panorama pedagógico; E4-0242 ANN guiada por análisis armónico, reproducibilidad limitada). Por cluster: C2a 50, C4a 19, C3a 8, C2b 3, C3b 2, C4b 2, C1 1, C1b 1.
- **372 excluidos:** 246 por acceso cerrado (resolución OA de S2) + 126 "informe no recuperado" / "sin acceso abierto directo" (descargas fallidas: landing de editorial, sin URL recuperable, o intentos doi.org sin éxito). Entre los excluidos está Troubadour (E4-0003, Pesek et al.); su contenido queda en `docs/Troubadour.md` como antecedente, pero no como estudio incluido del SOTA.
- Tasa de descarga automática ~47% de las URLs OA (arXiv, PLOS, MDPI PDF, repositorios); el resto eran landing de editoriales, excluidas como "informe no recuperado".

**Resumen PRISMA de la etapa 4 (completo):** 448 evaluados en texto completo → excluidos: acceso cerrado 246 + informe no recuperado 126 (= 372) → **incluidos 76**.

**Decisión del tesista sobre acceso (23-11-2026): no se usa Unpaywall ni recuperación manual.** Se descarta todo estudio del que se adquiera certeza de que no tiene acceso abierto directo (PDF descargable automáticamente desde la URL resuelta). La certeza se adquiere al intentar la descarga en la etapa 4, no antes. Unpaywall queda descartado como herramienta; la opción `--unpaywall` de `resolve` no debe usarse.

**Entregables del estado del arte (24-11-2026):**

- **Textos completos de los 76 incluidos** en markdown: `docs/estado-del-arte/fulltext/E4-XXXX.md` (metadatos + texto con `pdftotext`; E4-0154 sin texto extraíble, solo metadatos). Para que otros agentes los referencien al diseñar el generador y el analizador.
- **CSV de referencia detallado para agentes:** `docs/estado-del-arte/tabla-sota-referencia.csv` (76 filas × 27 columnas: identidad, técnica, método/algoritmo, representación, parámetros, dataset, código, métricas, resultados, limitaciones, pertinencia por componente (generador/analizador/transcripción/juego), gap y takeaway de diseño, + `fulltext_path`). Generado por extracción sobre los textos completos.
- **Tabla simplificada en `tesis.typ` (Anexo A):** `anexo-filas` reemplazado con 77 filas (76 incluidos agrupados por cluster + Basic Pitch). Columnas: Cluster | Autores | Título | DOI | Técnicas | Dataset | Resultados | Gap. Las celdas son breves (estilo divulgación). El detalle completo está en el CSV.
- **Basic Pitch (Bittner et al., 2022) = excepción señalada.** Es el modelo de transcripción que integra la tesis. La etapa 4 lo **excluyó por la regla de acceso** (no se pudo descargar automáticamente: E4-0359, `sin-descarga`). Se incluyó en el Anexo A como última entrada de C4 y marcado "(modelo integrado en la tesis)" por la decisión documentada de que figure ahí. **Decisión pendiente del tesista:** mantenerlo como excepción (fundacional) o excluirlo para adherencia estricta a la regla de acceso. Su relación con la decisión de diseño debe explicitarse en la sección de transcripción (4.6).
- **Nota de compilación (resuelta 24-11-2026):** el error de compilación preexistente (`expected path or string, found array` en `cetz/src/canvas.typ`) provenía de `cetz:0.3.2` (arrastrado por `fletcher`), incompatible con Typst 0.15. Se resolvió actualizando el import a `@preview/fletcher:0.5.7`, que usa `cetz:0.3.4` (compatible). `tesis.typ` compila a PDF sin errores (93 páginas).

**Siguientes pasos (para el siguiente agente):**

1. Etapa 4 completada. El ledger `etapa4_fulltext.csv` tiene las 448 decisiones como material de auditoría.
2. ~~Poblar la tabla de técnicas/resultados/gap~~ — hecho (CSV detallado + Anexo A en tesis.typ).
3. Decidir sobre Basic Pitch (ver arriba) y explicitar su relación de diseño en la sección de transcripción.
4. Redactar el **capítulo II conforme a PRISMA**: flujo 448 → 76 (acceso cerrado 246, informe no recuperado 126), estado del arte por clusters (C2a 50, C4a 19, C3a 8, C2b 3, C3b 2, C4b 2, C1 1, C1b 1).
5. Validación de una muestra de las etapas 3 y 4 por el tesista (concordancia).

**Nota técnica sobre los 61 UNKNOWN (aplicada):** `fetch` solo procesa registros con `etapa4_candidatas` (URLs OA resueltas). Los UNKNOWN no tenían URL, así que `resolve` intentó asignarles candidata por título (sin éxito: no rescató nuevas copias OA) y luego se aplicó el criterio: los con DOI se intentaron contra `doi.org` (certeza por intento; todos fallaron) y los sin URL se excluyeron por ausencia de identificador recuperable. Resultado: los 61 excluidos como "sin acceso abierto directo", coherente con la regla del tesista (23-11-2026).

**Reducción de volumen (20-11-2026, decisiones del tesista):**

- **Etapa 2b (script, aplicada):** tipo documental admitido (artículo, conferencia, peer review) y señal musical en título, o al menos dos términos musicales distintos en el abstract. Resultado: 5567 aprobados (`screening/etapa2b_aprobados.csv`), 13034 excluidos con motivo (`screening/etapa2b_excluidos.csv`).
- **Principio fijado por el tesista:** no se excluye C1 (gamificación). Su volumen se reduce restringiendo la cadena, no excluyendo el cluster.
- **C1 y C1b restringidas (cambio de cadena, pendiente de re-ejecución):** ancla en entrenamiento auditivo o dictado, y en gamificación o juego serio (C1) o multijugador (C1b). Criterio de validación: Troubadour (Pesek et al.) debe recuperarse. Verificado en OpenAlex con tres variantes de consulta (las tres devuelven Troubadour). Semantic Scholar no pudo medirse por 429.
- **C3a restringida (opción B, cambio de cadena, pendiente de re-ejecución):** se añade un bloque obligatorio de contexto musical (music, melody, melodic, singing, pitch, MIDI) a las frases originales.
- **OpenAlex: descartada (20-11-2026, decisión del tesista).** No soporta búsqueda booleana; su aproximación por frases con sobre-recuperación desviaba la cadena. No se usó ningún resultado de OpenAlex: se eliminaron sus CSV, metas, código del fetcher y la `OPENALEX_API_KEY` de `.env`.
- **Efecto esperado:** la restricción de C1 y C3a se mide re-ejecutando esas búsquedas. Con la cadena anterior la etapa 2b dejaba 5567 candidatos; la cifra nueva debe registrarse, no estimarse.

**Estado del pipeline (20-11-2026, sesión con cambio de corte):**

- Corte temporal cambiado a ≥2022 en `scripts/lit-queries.mjs` (`YEARS_FROM = 2022`) y en `lit-browser-export.mjs`. `lit-fetch.mjs` lo lee de la misma constante.
- Completitud por fuente y búsqueda: Semantic Scholar, ERIC, Scopus e IEEE están completas (sin topes). OpenAlex y Springer se descartaron y no tienen datos.
- Completitud anterior alcanzada (20-11-2026) con las cadenas vigentes en esa fecha; pendiente re-ejecutar C1, C1b y C3a con las cadenas restringidas y re-ejecutar Semantic Scholar cuando su cuota lo permita.
- Springer: descartada (ver punto 2). Sin lote pendiente.
- Merge sin Springer (20-11-2026): 53125 filas leídas, 43935 estudios únicos, 39968 con abstract.
- Decisión de modo: todos los scripts de scraping corren en GUI (sin headless), por decisión del tesista.

Hallazgos de la primera ejecución (19-11-2026): ERIC no indexa la literatura MIR de evaluación de canto (la consulta C3b devuelve 0 resultados reales; su aporte se concentra en C1 y C2b). Semantic Scholar responde sin API key pero con límites de tasa estrictos.

### 6.6. Navegador en modo headless con reapertura por sesión caducada (diseño descartado)

**Descartado (23-11-2026, decisión del tesista):** todos los scripts de scraping corren en modo GUI. El diseño de headless con reapertura por sesión caducada no se implementa y no debe implementarse. Se conserva este párrafo solo como registro de que la opción se consideró y se rechazó.

Cambio de política del capítulo IV: las decisiones de diseño del desarrollo pasarán a delimitarse explícitamente como tomadas de trabajos previos (con cita) o como aporte propio. Esto deja sin efecto la política "sin citas externas en el desarrollo" descrita en 21.1 para el capítulo IV; la sección 21.1 debe actualizarse cuando el nuevo estado del arte esté cerrado.

---

## 7. Diseño funcional del videojuego

### 7.1. Concepto y alcance

Será una aplicación web propia. Discord es una inspiración conceptual para la experiencia social y la comunicación externa, pero **no se integrará el SDK de Discord** ni se dependerá de sus salas para ejecutar el juego.

El producto se concibe para que usuarios de distintos lugares puedan jugar. Las salas se crean manualmente y se accede a ellas mediante un código. Para el estudio experimental, el conjunto de participantes se restringirá a estudiantes que hayan aceptado participar; esto no implica que el producto final deba limitarse a una clase o institución.

Se mantendrá el multijugador síncrono. No habrá chat interno: se asume que los jugadores pueden comunicarse por plataformas externas, por ejemplo Discord.

### 7.2. Flujo de una partida

La partida tiene una configuración previa:

- código/nombre de sala;
- participantes;
- nivel de dificultad de generación;
- tipo de primera ronda: dictado o repentización;
- número de rondas o condición de finalización (pendiente de especificar);
- posiblemente tempo y otros parámetros musicales (pendientes de decisión).

El tipo de primera ronda puede ser:

**Inicio con dictado**

- El sistema genera una melodía inicial distinta para cada jugador.
- Cada jugador escucha su melodía y la transcribe mediante una interfaz musical.
- La respuesta se guarda como una secuencia simbólica.

**Inicio con repentización**

- El sistema genera una melodía inicial distinta para cada jugador.
- Cada jugador visualiza la partitura/representación de la melodía y la interpreta vocalmente.
- El audio se graba y se transcribe automáticamente a una secuencia simbólica.

En rondas posteriores:

- Las tareas se alimentan con producciones de otros jugadores de la ronda anterior.
- En dictado, el jugador escucha la melodía interpretada por otro jugador y la transcribe.
- En repentización, el jugador recibe la melodía transcrita/producida por otro jugador, la visualiza y la interpreta vocalmente.
- La asignación debe garantizar que el contenido pase entre participantes y no se devuelva accidentalmente al mismo jugador en la misma cadena, salvo que se decida expresamente.
- Cada respuesta se almacena y se asocia con su origen, autor, destinatario, ronda y ejercicio.

La mecánica central se inspira en la lógica de juegos de teléfono descompuesto como Gartic Phone: el contenido pasa de un participante a otro y puede transformarse durante el proceso. En este proyecto, el contenido es musical. La hipótesis de diseño es que esta dinámica puede generar engagement, sorpresa y conversación entre jugadores. Esto es una **hipótesis de diseño**, no un resultado empírico demostrado por el éxito de otro juego. Debe evaluarse con usuarios.

### 7.3. Rondas y alternancia

Las rondas de dictado y repentización se alternan. El tipo de la primera ronda se configura antes de iniciar la partida. El patrón exacto de alternancia debe quedar fijo y documentado (por ejemplo, dictado → repentización → dictado, o el inverso).

Debe definirse con precisión qué objeto se transfiere:

- en dictado: ¿se transfiere el audio original de la melodía o la interpretación de audio realizada por el jugador anterior?
- en repentización: ¿se transfiere la transcripción simbólica evaluada, la partitura derivada o ambas?
- ¿qué ocurre cuando el número de jugadores es impar?
- ¿cómo se evita que una ronda quede sin contenido si un jugador abandona?

La intención expresada por el tesista es que las rondas de dictado posteriores utilicen melodías interpretadas por otros jugadores en la ronda anterior y que cada jugador interprete en repentización una melodía transcrita por otro jugador en la ronda anterior. La implementación debe preservar esa cadena y su trazabilidad.

Precisión del material transferido (pedido del tesista, 25-11-2026; implementado en 15.3): en las rondas de dictado posteriores a la primera, el jugador **escucha la melodía MIDI que el navegador reproduce a partir de la transcripción AMT** de la interpretación del jugador anterior (no el audio de su canto). En las rondas de repentización, el jugador **visualiza la transcripción simbólica** producida por otro jugador en la ronda anterior y la interpreta. En ambos casos el objeto transferido es la producción simbólica final de la ronda anterior (transcripción del estudiante en dictado; transcripción AMT en repentización), y ningún jugador recibe la producción propia.

### 7.4. Dificultad

La dificultad no aumenta automáticamente durante la partida. Se configura antes de empezar y depende de la complejidad de las melodías iniciales generadas por el sistema. Las rondas posteriores pueden contener respuestas imperfectas o transformaciones, pero no cambian dinámicamente el perfil de dificultad.

### 7.5. Puntuación y leaderboard

El ganador será el jugador con mayor **promedio de precisión general** en todas las rondas jugadas, considerando dictado y repentización.

La precisión general de cada ejercicio se construirá a partir de:

- precisión de alturas;
- precisión rítmica.

Propuesta inicial:

```text
precision_general = (precision_alturas + precision_ritmica) / 2
```

Esta media aritmética asigna el mismo peso a ambas dimensiones. Es transparente y fácil de explicar, por lo que es una buena opción inicial. No obstante, debe verificarse empíricamente que ambas métricas estén normalizadas en el mismo rango y tengan interpretaciones comparables.

El leaderboard se limita a la partida actual. No se ha definido un ranking global persistente ni un sistema de progresión entre partidas.

### 7.6. Retroalimentación y galería final

El sistema debe registrar las melodías y respuestas de todas las rondas. Al terminar la partida mostrará una galería o resumen secuencial, inspirado en la galería final de Gartic Phone:

- melodía inicial;
- interpretación o audio recibido;
- transcripción realizada;
- comparación entre referencia y respuesta;
- resultado de similitud;
- autor y receptor de cada paso, de acuerdo con las reglas de privacidad;
- evolución de la cadena musical entre rondas.

La galería tiene dos finalidades:

1. Entretenimiento y revisión colectiva de las transformaciones producidas.
2. Revisión formativa: permitir que cada jugador identifique errores frecuentes de altura y ritmo y vuelva a estudiar sus partidas.

Debe permitir consultar resultados por jugador y por partida, y conservar los artefactos necesarios para reconstruir la secuencia.

**Actualización (25-11-2026):** la galería quedó implementada en el prototipo como slideshow tipo chat grupal (una slide por melodía inicial con sus N+1 versiones y el autor de cada una, más una slide final de resultados), con reproducción MIDI de solo lectura y grabaciones de voz condicionadas por la opción `showRecordings` de la configuración. Ver detalle en 15.3.

### 7.7. Cuentas y aulas

- Habrá cuentas de usuario.
- El perfil será mínimo: nombre visible y los campos imprescindibles para autenticación y auditoría.
- La colección de usuarios se gestionará mediante Payload CMS.
- Se implementarán aulas simples y una vista para que docentes consulten resultados de estudiantes.
- No se ha solicitado un LMS completo, gestión curricular compleja, mensajería docente ni personalización extensa.
- Debe definirse cómo se vincula un estudiante a un aula y quién puede consultar sus resultados.

**Actualización (25-11-2026):** aulas e invitaciones implementadas en el prototipo (colecciones `Classrooms`/`ClassroomInvitations`, invitación por correo con aceptar/rechazar, consulta de resultados por salón con filtros y orden por métricas, y espectación docente con 3 sub-vistas). Ver 15.3.

---

## 8. Parámetros del generador procedural de melodías

El diseño se ha reformulado a partir del estado del arte (sección 2.4.5, cluster de generación). Los tres primeros parámetros son los ejes de dificultad de Poćwiardowski et al. (2025): longitud, magnitud de intervalo y frecuencia de patrones (aquí, penalización de la repetición). Se complementan con la tesitura cantable (MusicAIR), la estructura de frases (Raposo y Soares; Wu y Yang; Shan et al.), la congruencia tonal y la complejidad rítmica. Los validadores deterministas siguen a Meng et al. (2026).

| Parámetro                                                 | Dificultad baja               | Dificultad media            | Dificultad alta          |
| --------------------------------------------------------- | ----------------------------- | --------------------------- | ------------------------ |
| Longitud (eje: longitud)                                  | 8 notas                       | 15 notas                    | 24 notas                 |
| Intervalo máximo consecutivo (eje: magnitud de intervalo) | 2 semitonos                   | 5 semitonos                 | 7 semitonos              |
| Penalización de repetición (eje: frecuencia de patrones)  | 0.35                          | 0.65                        | 1.0                      |
| Ambitus — tesitura cantable                               | 12 semitonos (1 octava)       | 19 semitonos (≈1.5 octavas) | 24 semitonos (2 octavas) |
| Estructura de frases                                      | 1 frase                       | 2 frases                    | 3 frases                 |
| Congruencia tonal                                         | Una sola escala               | Posible modulación          | Modulación               |
| Complejidad rítmica                                       | Negras/blancas, compás simple | Corcheas                    | Síncopas, tresillos      |

Nota sobre la tesitura (derivada del estado del arte): el ambitus se limita a una tesitura cantable (máximo 2 octavas, registro C3–C5). La dificultad alta se había fijado en 3 octavas (F#2–F#5), fuera de cualquier registro vocal razonable; MusicAIR (Liao et al., 2025) genera dentro de una tesitura cantable cómoda y esa restricción se adopta aquí. Además, el generador prefiere el movimiento por grado conjunto (MusicAIR), penaliza la repetición según el nivel (eje de frecuencia de patrones) y cierra cada frase en un tono estable (tónica o dominante), de modo que aumenta la variedad —el capítulo V documentó baja variedad por exceso de notas repetidas— sin perder coherencia melódica.

**Evaluación del generador re-ejecutada (24-11-2026):** la evaluación de 600 melodías (200 por nivel, patrón `resultado-{dificultad}-###`) se re-ejecutó con la versión reformada y el capítulo V (tablas 20–23, figura 12 y textos 5.1–5.2) se actualizó. Mejoras confirmadas: intervalos de 0 semitonos 19.6/9.5/0 % (antes 40.9/36.6/35.3), melodías con notas repetidas 87/82.5/0 % (antes 100 % en los tres niveles), cambios de dirección 2.1/6.5/13.1 (antes 1.8/4.4/7.4), secuencias únicas 97/100/100 % y ambitus cantable (máx. 12/19/24). Se conserva el 100 % de cumplimiento de escala, anti-triple-repetición y figura requerida. El analizador solo añadió localización de errores (las métricas no cambian), por lo que sus resultados siguen siendo válidos. La evaluación es reproducible con `src/lib/music/generator-eval.test.ts`. Pendiente menor: la Figura 13 muestra melodías de muestra generadas con la versión anterior; pueden regenerarse con la nueva para mayor exactitud.

### 8.1. Recomendación técnica

No se ha identificado una única biblioteca JavaScript que garantice la generación de melodías pedagógicamente coherentes con todas estas restricciones. La recomendación es implementar el algoritmo de generación en el propio proyecto, usando bibliotecas especializadas como soporte:

- **`tonal` / `@tonaljs/*`:** teoría musical, escalas, notas, intervalos, conversión de notas a MIDI y operaciones tonales. No es un generador de melodías.
- **`@tonejs/midi`:** lectura, creación y escritura de archivos MIDI; representación de notas con pitch, inicio y duración.
- Opcionalmente, **Tone.js** para reproducción de las melodías en el navegador. No confundir Tone.js (audio/reproducción) con `@tonejs/midi` (representación MIDI).

Documentación de referencia:

- `tonal`: https://www.npmjs.com/package/tonal
- `@tonejs/midi`: https://github.com/Tonejs/Midi

### 8.2. Representación interna

Conviene que el dominio del sistema no dependa de un archivo MIDI como única representación. Definir una estructura canónica propia, por ejemplo:

```ts
type NoteEvent = {
  midiPitch: number; // entero MIDI, 0–127
  onsetBeats: number; // inicio en pulsos musicales
  durationBeats: number; // duración en pulsos
};

type Melody = {
  id: string;
  tempoBpm: number;
  timeSignature: [number, number];
  key?: string;
  scale?: string;
  notes: NoteEvent[];
  difficulty: "low" | "medium" | "high";
  generatorVersion: string;
  seed?: string;
};
```

Los tiempos musicales se deben almacenar en pulsos o unidades racionales/enteras de subdivisión, no solo en segundos, para evitar errores de redondeo y facilitar la comparación rítmica. La conversión a segundos se deriva del tempo.

El formato MIDI será un formato de intercambio/exportación. `@tonejs/midi` puede convertir la representación interna a MIDI y leer MIDI cuando sea necesario.

### 8.3. Algoritmo de generación propuesto

Implementar un generador determinista a partir de una semilla (seed) y un conjunto de parámetros. La semilla permitirá reproducir una melodía concreta durante pruebas y auditorías.

Pasos sugeridos:

1. Seleccionar tonalidad inicial y escala compatible con el nivel de dificultad.
2. Seleccionar compás y tempo dentro de un rango pedagógico que se deberá definir.
3. Construir el conjunto de alturas permitidas dentro del ambitus.
4. Elegir una nota inicial.
5. Generar las siguientes alturas mediante selección restringida:
   - respetar el intervalo máximo entre notas consecutivas;
   - respetar el rango total;
   - favorecer movimientos conjuntos y limitar saltos;
   - mantener congruencia con la escala o modulación configurada;
   - evitar patrones mecánicos o repetición excesiva.
6. Generar duraciones y ataques rítmicos compatibles con el nivel:
   - bajo: blancas y negras;
   - medio: incorporar corcheas;
   - alto: síncopas y tresillos.
7. Verificar que la secuencia cumpla las restricciones y tenga longitud exacta en número de notas.
8. Si no cumple, reintentar con otra secuencia pseudoaleatoria o aplicar reparación local.
9. Validar musicalmente la salida y guardar metadatos de generación.

### 8.4. Cuestiones musicales que deben resolverse antes de implementar

- ¿“Longitud” cuenta notas o compases? La tabla parece indicar número de notas; confirmar.
- ¿Qué duración total debe tener una melodía? La cantidad de notas por sí sola no determina la duración.
- ¿Cuál es el rango absoluto de alturas para cada nivel? El ambitus indica extensión, pero no registro inicial.
- ¿Qué tonalidades y modos se permitirán?
- ¿Cómo se define exactamente “posible modulación” y “modulación”? Debe especificarse el mecanismo: por ejemplo, cambio de centro tonal en una sección, transición entre escalas relacionadas o cambio de escala tras cierto número de notas.
- ¿Cómo se garantiza que las notas de una melodía modulante no se perciban como errores aleatorios?
- ¿Cuál será el tempo y habrá metrónomo durante dictado y repentización?
- ¿Se permitirán silencios? La tabla no los menciona; definir si forman parte de la complejidad rítmica.
- ¿Se permitirán notas repetidas?
- ¿Qué criterio define congruencia melódica además de pertenecer a una escala?

No inventar respuestas. Mantener estas cuestiones en un registro de decisiones pendientes.

Valores provisionales adoptados en el prototipo (rama `prototipo`, 11-11-2026), implementados y cubiertos por pruebas pero aún sujetos a validación musical con docentes: "longitud" = número de notas; registro centrado en C4 con ventana igual al ambitus del nivel (12/24/36 semitonos); tonalidades C, G, D, A, F, Bb y Eb en mayor y menor natural; sin silencios; notas repetidas permitidas salvo tres iguales seguidas; modulación mediante cambio de centro tonal a la tonalidad relativa (dificultad media, opcional) o a la dominante/subdominante (dificultad alta, obligatoria) en la nota media de la melodía; tempo configurable entre 60 y 120 BPM (defecto 90); rejilla de entrada de dictado de 1, 0.5 y 1/6 de tiempo según el nivel.

### 8.5. Pruebas del generador

Crear pruebas automatizadas para cada nivel:

- número exacto de notas;
- intervalo máximo entre notas consecutivas;
- ambitus real;
- pertenencia a escala o reglas de modulación;
- valores rítmicos permitidos;
- duración total;
- ausencia de eventos superpuestos no deseados;
- reproducibilidad por seed.

Además de las pruebas de restricciones, realizar evaluación musical cualitativa con docentes o músicos. Cumplir reglas numéricas no garantiza por sí solo una melodía pedagógicamente adecuada.

---

## 9. Análisis de similitud melódica

### 9.1. Alcance deliberadamente limitado

La comparación se limitará a dos dimensiones:

1. **Similitud de alturas (pitch).**
2. **Similitud rítmica (onsets/ataques).**

No se pretende construir una métrica general de similitud perceptiva entre canciones ni evaluar timbre, expresividad, calidad vocal, afinación continua, articulación o interpretación artística.

El tesista ha mencionado `mir_eval` de Python como referencia conceptual, especialmente las funciones `match_notes` y `onset`. No se debe afirmar que `mir_eval` sea una dependencia JavaScript.

### 9.2. Estado de bibliotecas JavaScript

La búsqueda preliminar encontró `@audio/mir`, un conjunto de paquetes JavaScript/TypeScript de music information retrieval. Sus módulos incluyen análisis de chroma, tonalidad, tempo, melodía y transcripción. Sin embargo, la documentación consultada no demuestra que proporcione equivalentes directos de `mir_eval.transcription.match_notes` y `onset_precision_recall_f1`.

Por tanto, no asumir que `@audio/mir` resuelve la comparación requerida. Puede evaluarse como dependencia auxiliar, pero la primera implementación probablemente deba codificar las métricas de emparejamiento en TypeScript.

Referencia: https://www.npmjs.com/package/@audio/mir

### 9.3. Métrica propuesta

Cada respuesta se normalizará a una secuencia de eventos:

```ts
type EvaluatedNote = {
  midiPitch: number;
  onsetSeconds: number;
  durationSeconds: number;
};
```

**Precisión de alturas**

- Comparar las alturas de referencia y estimadas sin exigir que sus ataques coincidan.
- Considerar una altura correcta si la diferencia está dentro de una tolerancia predefinida.
- Una tolerancia inicial razonable para notas MIDI cuantizadas es ±50 cents (medio semitono), equivalente a la tolerancia usada en evaluación de transcripción de notas por `mir_eval`.
- Emparejar cada nota de referencia con, como máximo, una nota estimada, y viceversa.
- Calcular precision, recall y F1 para penalizar tanto notas incorrectas/adicionales como notas omitidas.

**Precisión rítmica**

- Comparar los tiempos de inicio de las notas, sin exigir que las alturas coincidan.
- Una tolerancia inicial de 50 ms puede servir como punto de partida, siguiendo el valor por defecto documentado para evaluación de onsets en `mir_eval`.
- Utilizar emparejamiento uno-a-uno máximo para impedir que una nota estimada satisfaga múltiples notas de referencia.
- Calcular precision, recall y F1.

**Métrica híbrida**

```text
score_pitch = F1 de emparejamiento de alturas
score_rhythm = F1 de emparejamiento de onsets
score_overall = (score_pitch + score_rhythm) / 2
```

La media aritmética simple es la recomendación inicial porque es transparente, interpretable y asigna peso idéntico a ambas dimensiones. No usar una media ponderada sin justificación empírica.

### 9.4. Consideraciones de implementación

- Las métricas de altura y ritmo deben ser independientes. No forzar que ambos sub-scores usen exactamente los mismos pares emparejados: una nota puede estar afinada pero temporalmente desplazada, o tener el ataque correcto pero altura incorrecta.
- El emparejamiento puede formularse como un problema de matching bipartito máximo sobre una matriz de compatibilidad.
- Si hay muchas notas, utilizar un algoritmo de matching eficiente; para melodías de 8–24 notas, una solución clara y testeable será suficiente.
- Tratar secuencias vacías y casos sin coincidencias sin producir `NaN`.
- Definir qué ocurre cuando no hay notas estimadas o cuando no hay referencia.
- Normalizar tiempos al mismo tempo o al mismo marco temporal antes de evaluar. Decidir si el sistema exige tempo fijo o permite variaciones de tempo.
- En dictado, las respuestas introducidas en la interfaz pueden cuantizarse a una rejilla. En canto, el transcriptor puede producir inicios ligeramente desplazados.
- Es posible que las tolerancias deban diferir entre respuestas MIDI introducidas manualmente y audio transcrito; cualquier ajuste debe justificarse y aplicarse consistentemente.
- No incluir duración/offset de notas en la puntuación si el alcance acordado es solamente altura y onset. La duración puede conservarse para reconstrucción y visualización, pero no forma parte de la puntuación inicial.
- La puntuación debe mostrar al jugador sub-scores de altura y ritmo, no solo un número general.
- Localización de errores para el feedback (Zhang et al., 2025): además de los sub-scores, el resultado identifica qué notas de referencia fueron omitidas, cuáles fueron adicionales y, por dimensión, el desvío de altura y de ataque, de modo que la retroalimentación señale el error en el tiempo y no solo un puntaje.
- Tolerancias configurables por perfil de evaluación (Kumar et al., 2026): los umbrales de altura y ataque deben poder ajustarse (collares de tolerancia), no fijarse en un único valor global; en el prototipo se distingue ya entre dictado (50 ms) y canto (150 ms).

Referencia metodológica para las tolerancias y el concepto de matching: documentación de `mir_eval`:
https://mir-eval.readthedocs.io/latest/api/transcription.html

Tolerancias adoptadas en el prototipo (rama `prototipo`): 0.5 semitono y 50 ms para respuestas de dictado introducidas sobre rejilla; 0.5 semitono y 150 ms para respuestas transcritas de canto, porque los ataques del transcriptor no están cuantizados. Ambas definidas en `src/lib/music/analyzer.ts` y aplicadas consistentemente en cada tipo de ejercicio, según lo permitido en este apartado.

Tolerancia de octava en repentización (decidida el 18-11-2026): en la dificultad fácil, la dimensión de altura de la repentización acepta equivalencia de octava, de modo que cantar la melodía en un registro distinto del escrito no se penaliza. Se aplica solo a esa dificultad y solo a la repentización; el dictado y las dificultades media y alta mantienen la comparación estricta. El resto de las tolerancias (0.5 semitono, 150 ms) no cambia. Implementada como `octaveTolerant` en `EvaluationTolerances` y derivada por dificultad en `transcriptionTolerances` (`src/lib/music/analyzer.ts`).

### 9.5. Pruebas del evaluador

Construir casos unitarios con:

- secuencias idénticas;
- una nota omitida;
- una nota adicional;
- una altura equivocada;
- un ataque desplazado por menos de la tolerancia;
- un ataque desplazado por más de la tolerancia;
- notas duplicadas;
- notas desordenadas;
- respuesta vacía;
- melodías con diferente número de notas.

Probar por separado `score_pitch`, `score_rhythm` y `score_overall`.

---

## 10. Transcripción de audio a MIDI para repentización

### 10.1. Requisito funcional

En la repentización, el jugador visualiza una melodía y la interpreta vocalmente. La aplicación debe:

1. capturar audio desde el micrófono;
2. guardar la grabación asociada al jugador, ronda y ejercicio;
3. transcribir el audio a eventos de notas;
4. normalizar el resultado a la estructura interna de melodía;
5. comparar la secuencia transcrita con la referencia;
6. guardar resultado, sub-scores y artefactos.

### 10.2. Opción técnica recomendada inicialmente: Spotify Basic Pitch

La biblioteca prioritaria para una prueba de concepto es **`@spotify/basic-pitch`**, la implementación TypeScript de Basic Pitch de Spotify.

Razones:

- existe una implementación oficial TypeScript/JavaScript;
- se instala mediante npm;
- fue diseñada para transcripción automática de música;
- soporta múltiples alturas y puede procesar audio de voz, aunque su rendimiento depende de la grabación;
- puede ejecutarse en el navegador mediante TensorFlow.js, evitando necesariamente enviar el audio a un servicio externo.

Documentación:

- GitHub: https://github.com/spotify/basic-pitch-ts
- Paquete: https://www.npmjs.com/package/@spotify/basic-pitch

Basic Pitch trabaja mejor con una fuente/instrumento a la vez. El caso de uso de canto monofónico es compatible en principio, pero debe probarse con grabaciones reales de estudiantes. No asumir precisión perfecta, especialmente ante ruido, reverberación, vibrato, portamentos, consonantes, respiraciones o acompañamiento.

### 10.3. Arquitectura de ejecución

Recomendación inicial: ejecutar la inferencia en el navegador, preferentemente en un Web Worker o mecanismo que no bloquee la interfaz. Razones:

- menor transferencia de datos sensibles;
- no requiere infraestructura GPU del servidor;
- evita saturar el servidor Next.js con inferencia;
- la experiencia puede informar el progreso al jugador.

Sin embargo, deben probarse rendimiento y compatibilidad en navegadores y equipos reales. Si la inferencia client-side resulta inestable, considerar un servicio de procesamiento separado. No ejecutar cargas pesadas de inferencia directamente en una ruta serverless sin verificar límites de memoria, tiempo y CPU.

### 10.4. Preprocesamiento y control de calidad

- Aceptar formatos de audio soportados por el navegador y convertir a la frecuencia de muestreo requerida.
- Recortar silencio inicial/final cuando sea necesario, preservando el tiempo de referencia o guardando el offset de recorte.
- Controlar duración máxima y tamaño de archivo.
- Normalizar el volumen solo si el método está justificado y probado.
- Rechazar o advertir ante audio demasiado corto, silencioso o saturado.
- Mantener la grabación original para la galería e inspección, sujeto a consentimiento y política de retención.
- Conservar la salida bruta del modelo además de la versión normalizada.
- Registrar versión del modelo y parámetros de inferencia para reproducibilidad. En el prototipo los parámetros ya están centralizados en `src/lib/transcription/params.ts`, pero todavía no se persisten junto con cada transcripción (pendiente).

### 10.5. Validación específica

Preparar un conjunto pequeño de grabaciones vocales con:

- melodías conocidas;
- distintas tesituras;
- distintos niveles de experiencia;
- grabaciones con y sin ruido moderado;
- diferentes micrófonos y navegadores.

Comparar la transcripción automática con MIDI de referencia y calcular precisión de altura y onset. Esta validación técnica no sustituye la evaluación pedagógica del videojuego.

Estado en el prototipo (rama `prototipo`): `@spotify/basic-pitch` quedó integrado y verificado con audio sintético (el modelo detecta correctamente el La4 de una sinusoide de 2 s; ejecutable con `npm run smoke:basic-pitch`). La inferencia corre en un Web Worker; el audio se remuestrea a 22050 Hz mono, se recorta el silencio inicial y se normalizan las notas (redondeo de altura, orden por ataque, fusión de segmentos contiguos de la misma altura con menos de 80 ms de separación). Verificado además en navegador real: la transcripción completa dos veces en una misma partida sin bloquear la interfaz. Hallazgo técnico confirmado: dentro de un Web Worker, el backend `webgl` de TensorFlow.js deja de avanzar en `model.execute`; se fuerza el backend `cpu` antes de inferir (y se fija `@tensorflow/tfjs` 3.21.0 como dependencia directa para compartir una única instancia con Basic Pitch). **Falta validar con grabaciones de voz cantada real**, que es la validación exigida en este apartado.

Hallazgo empírico del banco sintético (`npm run tune:transcription`, 25 casos): el ruido blanco puro no produce notas falsas; las notas espurias provienen del ruido tonal por debajo del registro cantado (zumbido de red de 50 Hz, ventilación, golpes de escritorio). Acotar el rango de frecuencia de inferencia (75–1500 Hz) fue la palanca decisiva: sobre los mismos casos la precisión pasó de 0,30 a 0,98 sin perder notas reales. El filtrado por amplitud no resultó útil, porque las notas espurias no tienen menor amplitud que las reales. Estas cifras provienen de audio sintético y deben confirmarse con voz cantada real.

---

## 11. Arquitectura de software propuesta

### 11.1. Stack confirmado por el tesista

- **Next.js** para la aplicación web.
- **Payload CMS** como CMS/backend de datos.
- **PostgreSQL** como base de datos.
- **Docker Compose** para levantar los servicios locales.
- Comunicación en tiempo real todavía sin decidir; el tesista solicita la alternativa más sencilla de integrar.

### 11.2. Comunicación en tiempo real: recomendación inicial

Para reducir complejidad operativa en el prototipo, se recomienda evaluar **Ably Pub/Sub** con su SDK JavaScript/React:

- canales por sala;
- publicación/suscripción de eventos;
- presencia para saber quién está conectado;
- autenticación desde backend mediante tokens, sin exponer la API key privada en el navegador.

La documentación oficial dispone de una guía de integración con Next.js y presencia:

- Next.js: https://ably.com/docs/getting-started/nextjs
- Presence: https://ably.com/docs/presence-occupancy/presence
- Cliente realtime: https://ably.com/docs/pub-sub/api/javascript/realtime/realtime-client

Ably es un servicio administrado externo, no una dependencia que se ejecute dentro de Docker Compose. Deben evaluarse plan gratuito, límites, privacidad, disponibilidad y costos antes de adoptarlo.

Alternativa: Socket.IO con un servidor Node persistente. Da mayor control y evita depender de un proveedor externo, pero exige operar el servidor de sockets, resolver despliegue y coordinarlo con Next.js/Payload. No es necesariamente la vía más sencilla para un primer prototipo.

**Recomendación:** construir un pequeño spike técnico con Ably primero. No enviar datos musicales pesados por el canal realtime. Usar el canal para eventos de juego y enviar audio/MIDI mediante almacenamiento/HTTP; los eventos transportan identificadores y metadatos.

**Decisión del prototipo (25-11-2026):** la sincronización del prototipo multijugador se implementó por **sondeo (polling)** de ~1.2 s contra PostgreSQL vía Payload, sin proveedor externo (ver 15.3): es la alternativa más sencilla de integrar para la prueba con dos usuarios, no exige cuentas ni claves de terceros y conserva al backend como autoridad (13.1). No se descartan Ably ni Socket.IO para la versión completa; el spike de Ably sigue pendiente y la sustitución del transporte no afectaría a las reglas de juego (están en `src/lib/game/rules.ts` y en los endpoints, no en la capa de comunicación).

### 11.3. Separación lógica de componentes

Arquitectura sugerida:

```text
Next.js Web App
├── UI de autenticación y perfil
├── Lobby y creación/unión por código
├── Sala y sincronización de rondas
├── Interfaz de dictado
├── Interfaz de repentización y grabación
├── Galería final y leaderboard
└── Panel docente / aulas
       |
       | API / Server Actions / endpoints autorizados
       v
Payload CMS
├── Users
├── Classrooms
├── ClassroomMemberships
├── GameRooms
├── GameParticipants
├── Games
├── Rounds
├── Exercises / Melodies
├── PlayerSubmissions
├── Transcriptions
├── EvaluationResults
└── Media / Audio assets
       |
       v
PostgreSQL

Realtime provider (provisional: Ably)
└── presencia y eventos de sala

Browser audio processing
├── Microphone capture
├── Basic Pitch (provisional)
├── Melody normalization
└── Similarity evaluator
```

### 11.4. Payload CMS

Payload debe ser la fuente persistente de verdad para entidades, usuarios, partidas, rondas, respuestas, resultados y metadatos. Los eventos realtime no deben convertirse en la única fuente de estado.

Definir permisos por rol:

- participante: consultar sus datos y partidas a las que pertenece;
- docente: consultar estudiantes y resultados de las aulas que administra;
- administrador: administrar usuarios y configuración.

Las reglas concretas dependen del esquema y deben implementarse mediante access control de Payload. No confiar en que ocultar botones en el frontend sea suficiente autorización.

### 11.5. Modelo de datos inicial

Modelo conceptual sugerido; no es un esquema final obligatorio:

**Users**

- id
- displayName
- email/identificador de autenticación
- role (`student`, `professor`, `admin`)
- createdAt

**Classrooms**

- id
- name
- teacherId
- createdAt

**ClassroomMemberships**

- classroomId
- userId
- status

**GameRooms**

- id
- roomCode
- hostUserId
- status (`waiting`, `configured`, `in_progress`, `finished`, `cancelled`)
- settings: difficulty, startingRoundType, roundCount, tempo/time signature si se definen
- createdAt

**GameParticipants**

- id
- gameId
- userId
- joinOrder
- status
- finalScore

**Games**

- id
- roomId
- status
- startedAt
- finishedAt
- winnerParticipantId

**Rounds**

- id
- gameId
- roundNumber
- exerciseType (`dictation`, `sight_singing`)
- status
- startedAt
- completedAt

**Melodies**

- id
- symbolicData JSON
- midiAsset (opcional)
- tempo
- meter
- key/scale
- difficulty
- seed
- generatorVersion
- createdAt

**PlayerSubmissions**

- id
- gameId
- roundId
- playerId
- sourceSubmissionId (referencia al material recibido, si aplica)
- inputType (`symbolic`, `audio`)
- symbolicResponse JSON
- audioAsset
- createdAt

**Transcriptions**

- id
- submissionId
- modelName
- modelVersion
- rawOutput JSON
- normalizedMelody JSON
- createdAt

**EvaluationResults**

- id
- submissionId
- referenceMelodyId
- pitchScore
- rhythmScore
- overallScore
- matchingDetails JSON
- metricVersion
- createdAt

Puede ser necesario modelar por separado el contenido que un jugador recibe y la respuesta que produce, porque una cadena puede tener varios pasos. No sobrescribir el contenido de rondas anteriores. Preservar la trazabilidad completa.

### 11.6. Persistencia de archivos

El tesista solicita registrar toda la información necesaria para reconstruir la partida, incluidas las interpretaciones vocales. Por tanto:

- guardar audios originales;
- guardar melodías iniciales;
- guardar respuestas simbólicas de dictado;
- guardar transcripciones automáticas;
- guardar resultados y detalle de comparación;
- guardar relaciones entre autor, receptor, ronda y material intercambiado.

No guardar archivos de audio directamente como blobs grandes dentro de filas PostgreSQL salvo que exista una justificación. Usar almacenamiento de objetos compatible con Payload/infraestructura elegida y guardar referencias/metadatos en PostgreSQL. Para desarrollo local puede usarse almacenamiento local persistente en Docker; para despliegue, seleccionar un servicio adecuado.

Definir límites de tamaño, duración, retención y eliminación. Obtener consentimiento informado para grabar voz. La voz puede constituir dato personal; restringir acceso, evitar exposición pública por defecto y explicar claramente el uso de las grabaciones.

**Actualización (25-11-2026):** las grabaciones de voz se persisten en el prototipo (colección `Media`, almacenamiento local `media/` gitignored, referenciadas desde `Submissions.recording`); el límite de duración es 30 s por grabación y la conversión audio→MIDI se mantiene en el navegador. Decisión del tesista: el valor para el engagement prevalece sobre la reticencia inicial por privacidad al ser un prototipo de tesis. Siguen pendientes el consentimiento informado, la política de retención/eliminación y el acceso restringido a los archivos (15.3).

---

## 12. Requisitos funcionales y no funcionales

### 12.1. Funcionales

**RF-01.** Registrar e iniciar sesión de usuarios.  
**RF-02.** Permitir al usuario definir un nombre visible.  
**RF-03.** Crear una sala de juego y generar un código único.  
**RF-04.** Permitir unirse a una sala mediante código.  
**RF-05.** Mostrar participantes conectados y estado de la sala.  
**RF-06.** Configurar dificultad antes de iniciar la partida.  
**RF-07.** Configurar si la primera ronda será dictado o repentización.  
**RF-08.** Generar una melodía inicial distinta para cada participante.  
**RF-09.** Reproducir melodías para tareas de dictado.  
**RF-10.** Permitir introducir transcripciones simbólicas mediante una interfaz musical.  
**RF-11.** Mostrar notación/representación melódica para repentización.  
**RF-12.** Capturar la interpretación vocal del participante.  
**RF-13.** Transcribir automáticamente audio a notas simbólicas.  
**RF-14.** Evaluar por separado precisión de alturas y precisión rítmica.  
**RF-15.** Calcular precisión general como media de ambas dimensiones, salvo que la validación aconseje un cambio.  
**RF-16.** Alternar rondas de dictado y repentización.  
**RF-17.** Intercambiar material entre participantes siguiendo la cadena de la partida.  
**RF-18.** Mantener sincronizados los estados de la partida.  
**RF-19.** Registrar melodías, audios, respuestas, transcripciones y resultados.  
**RF-20.** Mostrar retroalimentación inmediata al finalizar una respuesta.  
**RF-21.** Mostrar leaderboard por partida.  
**RF-22.** Calcular ganador mediante promedio de precisión general en las rondas jugadas.  
**RF-23.** Mostrar galería/resumen final de la partida.  
**RF-24.** Permitir revisar partidas y errores frecuentes.  
**RF-25.** Crear aulas simples.  
**RF-26.** Permitir al docente consultar resultados de los estudiantes de sus aulas.

### 12.2. No funcionales

- **Usabilidad:** las interfaces de dictado y repentización deben ser comprensibles para estudiantes con conocimientos básicos de teoría musical.
- **Rendimiento:** la interfaz no debe bloquearse durante la transcripción de audio.
- **Sincronización:** todos los participantes deben observar transiciones de ronda coherentes.
- **Consistencia:** los cambios críticos de estado deben persistirse y validarse en backend.
- **Seguridad:** autorización por usuario, sala y aula; claves privadas nunca expuestas al navegador.
- **Privacidad:** protección de audios e información de estudiantes.
- **Trazabilidad:** cada respuesta debe poder vincularse con su fuente y ronda.
- **Reproducibilidad:** conservar semilla, versión del generador, versión del transcriptor y versión de las métricas.
- **Mantenibilidad:** separar lógica musical, lógica de partida, persistencia y UI.
- **Compatibilidad:** probar navegadores de escritorio y micrófonos habituales.
- **Accesibilidad:** controles claros, estados visibles y alternativas para usuarios con dificultades de interacción.

---

## 13. Diseño de sincronización multijugador

### 13.1. Principio de autoridad

El backend debe ser la autoridad para:

- estado de sala;
- lista de participantes;
- configuración de partida;
- ronda activa;
- asignación del material;
- recepción de respuestas;
- finalización de ronda;
- cálculo final del leaderboard.

El proveedor realtime distribuye eventos, pero no reemplaza la persistencia ni la validación del servidor.

### 13.2. Eventos sugeridos

Ejemplos de eventos de sala:

- `participant.joined`
- `participant.left`
- `game.configured`
- `game.started`
- `round.started`
- `submission.received`
- `round.completed`
- `round.results_ready`
- `leaderboard.updated`
- `game.finished`

Cada evento debe incluir:

- `eventId`;
- `gameId`;
- `roundId` cuando corresponda;
- `sequenceNumber` o versión de estado;
- timestamp de servidor;
- payload mínimo.

Implementar idempotencia para evitar que un mismo evento o respuesta duplicada se procese dos veces. Definir qué sucede si un participante se desconecta, vuelve a entrar, envía tarde o no envía respuesta.

### 13.3. No transmitir archivos pesados por realtime

Subir audio/MIDI por HTTP o almacenamiento de archivos. Publicar por realtime solo:

- identificador de recurso;
- estado de carga;
- avance de la ronda;
- avisos de sincronización.

---

## 14. Interfaz y experiencia de usuario

Vistas mínimas esperadas:

1. **Inicio / autenticación.**
2. **Lobby:** crear sala, introducir código, ver salas/partidas propias si corresponde.
3. **Sala de espera:** participantes, configuración, dificultad y tipo de primera ronda.
4. **Dictado:** reproductor de melodía, teclado virtual o piano roll/notación para introducir notas, controles de envío.
5. **Repentización:** partitura o representación visual, grabación desde micrófono, indicador de nivel, reproducir/escuchar grabación y enviar.
6. **Evaluación:** puntuación de alturas, ritmo y total, con errores visualizados.
7. **Leaderboard:** clasificación de la partida.
8. **Galería final:** cadena de contenidos y respuestas por ronda.
9. **Historial:** partidas previas y revisión.
10. **Aulas:** gestión sencilla de estudiantes.
11. **Panel docente:** resultados y métricas de estudiantes.

No implementar chat interno. No implementar un sistema global de rankings si el alcance acordado es leaderboard por partida. No añadir personalización extensa de perfiles.

---

## 15. Estrategia de implementación de la codebase

El desarrollo de la aplicación no ha comenzado en `main`. Existe un prototipo en la rama `prototipo` (ver 15.2) construido por incrementos con un commit por hito. El LLM de programación debe trabajar por incrementos verticales y mantener la aplicación ejecutable.

### Fase 0 – Validación de decisiones y riesgos

1. Confirmar versiones compatibles de Next.js, Payload CMS y PostgreSQL.
2. Crear repositorio y Docker Compose mínimo.
3. Verificar autenticación y colección de usuarios de Payload.
4. Probar Ably en una sala mínima: presencia, publicación y suscripción.
5. Probar `@spotify/basic-pitch` con grabaciones reales de canto.
6. Probar `tonal` y `@tonejs/midi` en una melodía generada.
7. Documentar licencias y límites de los paquetes.

### Fase 1 – Dominio musical independiente

Implementar paquetes/módulos independientes de la UI:

- tipos canónicos de melodía;
- generador procedural;
- serialización y validación;
- importación/exportación MIDI;
- evaluador de altura;
- evaluador de onsets;
- puntuación general;
- pruebas unitarias.

Esta fase reduce el riesgo de mezclar errores musicales con errores de red o interfaz.

### Fase 2 – Base web y persistencia

- Next.js y Payload integrados.
- PostgreSQL en Docker Compose.
- usuarios y autenticación;
- colecciones de aulas;
- almacenamiento de archivos;
- controles de acceso.

### Fase 3 – Modo individual de ejercicios

Antes de introducir sincronización, conseguir un flujo individual funcional:

- generar melodía;
- reproducirla;
- responder dictado;
- grabar repentización;
- transcribir audio;
- evaluar;
- mostrar feedback;
- guardar todos los datos.

### Fase 4 – Partidas multijugador síncronas

- crear/unirse a sala por código;
- presencia;
- configuración previa;
- iniciar partida;
- sincronizar ronda;
- enviar y persistir respuestas;
- asignar respuestas a otros jugadores;
- avanzar rondas;
- reconexión y abandono;
- leaderboard.

### Fase 5 – Galería y aulas

- reconstrucción completa de cadenas;
- reproducción de audio;
- comparación de referencia/respuesta;
- historial;
- aula y consulta docente.

### Fase 6 – Demostración y evaluación

- pruebas técnicas y de usabilidad;
- piloto con pocos participantes;
- corrección de errores;
- protocolo de estudio;
- intervención pedagógica;
- análisis estadístico;
- documentación de resultados.

### 15.1. Prácticas obligatorias para el LLM de programación

- No construir toda la aplicación en un solo paso.
- No añadir dependencias sin explicar por qué y verificar mantenimiento/licencia.
- Mantener TypeScript estricto.
- Separar lógica de dominio de componentes React.
- Escribir pruebas unitarias para generador, matching y puntuación.
- Usar migraciones/esquemas reproducibles.
- Mantener fixtures de melodías y audios de prueba.
- Registrar decisiones arquitectónicas relevantes (ADR).
- No guardar estado crítico solo en memoria del proceso.
- No confiar en datos enviados por el cliente para calcular resultados finales sin validación.
- No exponer secretos de Payload, PostgreSQL o Ably.
- No subir grabaciones a un repositorio Git.
- No afirmar que una integración funciona hasta haberla ejecutado en el entorno real.
- Actualizar este documento cuando una decisión cambie.

### 15.2. Estado del prototipo (rama `prototipo`, noviembre de 2026)

El tesista decidió pausar la redacción y construir un prototipo muy básico del videojuego, con estas decisiones confirmadas: **partida de un solo jugador** (sin usuarios ni salas; corresponde a la Fase 3 de este plan), **Payload + PostgreSQL desde ya** (estructura de repositorio al estilo de `~/dev/docestantes`), **aplicación en la raíz del repositorio** (con `docs/` intacto) e **interfaz musical de piano roll** tanto para el dictado como para la lectura en repentización.

Contenido del prototipo, verificado con build limpia, 50 pruebas unitarias y pruebas de humo:

- `src/lib/music/`: tipos canónicos de melodía (con registro de modulaciones), generador procedural determinista por semilla y analizador de similitud con matching bipartito máximo, con pruebas de Vitest para generador (26) y analizador (20).
- `src/lib/transcription/`: transcripción con `@spotify/basic-pitch` en Web Worker, con remuestreo a 22050 Hz mono, recorte de silencio inicial y normalización de notas. Los parámetros de inferencia están centralizados en `src/lib/transcription/params.ts` (`MODEL_PARAMS`) y protegidos por 4 pruebas de Vitest que verifican el rango de frecuencias. Verificada con audio sintético (`npm run smoke:basic-pitch`) y con un banco de ajuste que barre parámetros sobre voces sintéticas con vibrato, ruido y transitorios de respiración (`npm run tune:transcription`).
- `app/(frontend)/`: página única de partida con configuración (dificultad, primera actividad, rondas, tempo), rondas alternadas de dictado y repentización, evaluación por ronda con sub-scores de alturas y ritmo, visualización de errores por color y resumen final con promedio de precisión general.
- `src/collections/`: colecciones Payload `Melodies` y `GameSessions`; la partida se guarda al terminar (acceso abierto solo a nivel de prototipo; la validación de resultados en servidor y los permisos por rol quedan para la versión completa).

Pendientes del prototipo: prueba interactiva en navegador con micrófono real, validación de la transcripción con voz cantada real, persistencia de las grabaciones de audio (junto con consentimiento y retención), y revisión con docentes de las decisiones musicales provisionales del apartado 8.4.

### 15.3. Estado multijugador del prototipo (25-11-2026)

Esta sección describe el **segundo incremento** del prototipo (rama `prototipo`): modo multijugador con usuarios, que sustituye a la partida individual descrita en 15.2 (ese texto se conserva como antecedente de la Fase 3; las colecciones `Melodies`/`GameSessions` y `src/lib/persistence.ts` ya no existen).

**Lo implementado y verificado:**

1. **Usuarios y autenticación:** registro e inicio de sesión con la autenticación de Payload (cookie httpOnly `payload-token`), panel de sesión y cierre de sesión en la interfaz. Dos navegadores distintos tienen sesiones independientes.
2. **Salas por código:** crear sala (código de 6 caracteres, sin caracteres ambiguos), unirse por código (idempotente, tolera minúsculas), lista de participantes en vivo (sondeo), anfitrión configura la partida (dificultad, primera actividad, rondas 2–8, tempo 60–120) e inicia. Mínimo 2 jugadores para iniciar; solo el anfitrión inicia.
3. **Rondas encadenadas (la mecánica central):**
   - La ronda 1 reparte una melodía generada distinta por jugador (semillas `{sessionSeed}-p{i}`).
   - En la ronda k ≥ 2 cada jugador recibe la **respuesta del jugador anterior en la rotación**: `sourceIndex = (i - 1 + N) % N` (con 2 jugadores, siempre el otro; nunca uno recibe su propia producción).
   - La salida de una ronda es la entrada de la siguiente en su forma simbólica final: para una ronda de dictado, la transcripción del estudiante; para una ronda de repentización, la transcripción AMT de su canto.
   - Presentación según la actividad recibida: dictado reproduce la melodía recibida como MIDI en el navegador; repentización la muestra en el piano roll.
   - Las actividades alternan por ronda a partir de `firstActivity` (dictado ↔ repentización).
   - La evaluación de cada respuesta se calcula **en el servidor** contra la melodía recibida (ronda 1: la generada), con las tolerancias existentes (dictado 50 ms; canto 150 ms y equivalencia de octava en dificultad baja). El cliente solo envía las notas de su respuesta.
4. **Avance de ronda:** cuando todos los participantes han enviado su respuesta, el servidor evalúa, construye las asignaciones de la ronda siguiente (con `sourceSubmission` para trazabilidad) y avanza; en la última ronda se cierra la partida y se calcula el leaderboard (promedio de precisión general, con desglose de alturas y ritmo).
5. **Sin pantallas de resultado por ronda** (decisión del tesista): tras enviar, el jugador ve una pantalla de espera con el estado de envío de los demás; los resultados se muestran solo al final (tabla de clasificación + rondas de cada jugador). La "galería con el viaje de cada melodía" sigue sin implementarse y su decisión está abierta (ver 7.6).
6. **Persistencia:** colecciones `GameRooms` (código, anfitrión, estado, configuración, semilla, participantes) y `Submissions` (una fila por jugador y ronda con `receivedMelody` autocontenido —incluye semilla y versión del generador—, `receivedFrom`, `sourceSubmission`, respuesta, evaluación y estado). Toda la cadena puede reconstruirse.

**Decisiones tomadas por el agente (25-11-2026), a validación del tesista:**

- **Sincronización por sondeo (polling) de ~1.2 s** contra la base vía Payload, sin proveedor realtime externo: es la alternativa más sencilla de integrar (decisión pendiente en 11.2), sin cuentas externas ni servidor de sockets, y mantiene al backend como autoridad (13.1). Ably y Socket.IO siguen siendo las opciones de la versión completa (ver 11.2).
- **Sin cronómetro por ronda y avance por envío de todos** (esperar a que todos acaben): política adecuada para la prueba con 2 usuarios. Para más jugadores quedan abiertas las preguntas que señaló el tesista: si poner cronómetro tipo Gartic Phone, cuánto esperar a los rezagados y qué hacer con desconexiones (ver 17.2).
- **Interpretación de la mecánica:** el flujo pedido ("si se empieza por dictado, las melodías transcritas son mostradas a los estudiantes para que las transcriban en la segunda ronda") se implementó según la alternancia ya fijada en 7.2/7.3 y RF-16: la segunda ronda es de **repentización** y las melodías recibidas se **muestran para interpretarlas** (el verbo "transcriban" del pedido se leyó como errata de "interpreten/canten", coherente con "mostradas" y con el caso paralelo de repentización→dictado). Confirmar con el tesista; el cambio de alternancia se reduce a `activityForRound` en `src/lib/game/rules.ts`.
- **Mínimo 2 jugadores** para iniciar (mantiene el invariante "nadie recibe su propia melodía"); sin máximo por ahora.
- **Acceso de las colecciones:** lectura abierta y escritura bloqueada vía REST (las mutaciones pasan por los endpoints de juego, que validan las reglas). Los permisos por rol siguen siendo pendiente de la versión completa (4.8.5).

**Qué cambió en el código:**

- Nuevos: `src/lib/game/` (`types.ts`, `rules.ts` con las reglas puras y `rules.test.ts` con 19 pruebas, `server.ts` con la orquestación), `app/api/rooms/` (crear, unirse, estado, iniciar, enviar), `src/collections/GameRooms.ts`, `src/collections/Submissions.ts`, componentes `App`, `AuthPanel`, `Lobby`, `Room`, `WaitingRoom`, `GameRound`, `Summary`.
- Eliminados: `src/collections/Melodies.ts`, `src/collections/GameSessions.ts`, `src/lib/persistence.ts`, `app/(frontend)/_components/Game.tsx` (partida individual) y `EvaluationPanel.tsx` (pantalla de resultado por ronda).
- Modificados: `Users.ts` (acceso explícito; registro abierto), `DictationExercise`/`SightSingingExercise` (devuelven solo la respuesta; la evaluación se hace en el servidor), `page.tsx`, README (puesta en marcha con `compose.dev.yaml` y prueba de dos usuarios).
- `payload-types.ts` regenerado (`GameRoom`, `Submission`).
- Utilidad `scripts/create-admin.ts` (`npm run create:admin`, vía `payload run`): crea un usuario del panel de administración con credenciales genéricas (`admin@example.com` / `admin123`, sobreescribibles con `ADMIN_EMAIL`/`ADMIN_PASSWORD`) y rol `admin`; es idempotente (no duplica si el usuario ya existe).
- Campo `role` en `users` (25-11-2026): `select` obligatorio con valores `student`, `professor` y `admin` (11.5 decía `teacher`; se adoptó `professor` por decisión del tesista) y `defaultValue: "student"`. Helpers de control de acceso tomados del proyecto de referencia `~/dev/docestantes`: `src/lib/user.ts` (`Role`, `isAdmin`, `isProfessor`) y `src/lib/access.ts` (`collectionAdminAccess`, `fieldAdminAccess`, `fieldProfessorAccess`). Reglas: panel `/admin` para admin y profesor; lectura de un usuario solo para él mismo o para admin/profesor (el rol no es legible para estudiantes); registro abierto pero el rol se fuerza a `student` al registrarse (el field access `create`/`update` del rol es solo-admin y el `defaultValue` se aplica después de que Payload elimina el valor no permitido); actualización solo del propio usuario o por admin; borrado solo admin.

**Verificación (25-11-2026):** 79 pruebas unitarias pasan (60 previas + 19 nuevas de reglas de juego); `npm run lint` sin errores; `npm run build` limpio; prueba de humo de la API con dos usuarios reales (22 comprobaciones: registro, login con cookie, sala por código, inicio solo por anfitrión, melodías distintas en ronda 1, encadenamiento exacto ronda 1→2 en ambos sentidos, bloqueo de doble envío, no fuga de respuestas ajenas antes de tiempo, cierre y leaderboard); verificación en navegador con `agent-browser` (registro por formulario, lobby, sala de espera como anfitrión y como invitado, inicio y renderizado de la ronda 1 en dos sesiones, pantalla de espera tras enviar).

**Corrección (25-11-2026, bug reportado por el tesista):** al avanzar de ronda, el encabezado mostraba la ronda nueva pero la interfaz seguía mostrando el panel de envío ("Enviando tu respuesta…") y el ejercicio de la ronda siguiente solo aparecía al salir de la sala o recargar. Causa: `GameRound` no se desmontaba entre rondas y su estado de envío quedaba fijado tras un envío exitoso (solo se restablecía en el error), de modo que la condición del panel de espera seguía cumplida. Corregido con una fase explícita de envío (`playing`/`submitting`/`submitted`) en `GameRound.tsx` y con `key={state.round.number}` en `Room.tsx` para remontar el componente en cada ronda (también limpia errores de envío de la ronda anterior). Verificado con lint y build limpios; la reproducción en navegador queda pendiente de la prueba humana del tesista.

**Verificación del acceso por roles (25-11-2026):** con el campo `role` se añadió una prueba de humo de autorización: registro con `role: "admin"` inyectado queda en `student`, el intento de autoascenso por update deja el rol en `student`, el rol no es visible para el propio estudiante, la lectura de un usuario ajeno y la actualización de un usuario ajeno devuelven 403, y el borrado como admin funciona. Asignación de roles ejecutada con un script puntual del scratchpad (`assign-roles.mts`): `admin@example.com` → `admin` y el resto de los usuarios existentes → `student`.

**Galería final y grabaciones de voz (25-11-2026):** se implementó la galería final tipo "teléfono malogrado" y el almacenamiento de las interpretaciones vocales.

- **Galería como slideshow** (decisión del tesista; sustituye a la vista previa de resultados y a `Summary.tsx`): M slides, una por melodía inicial generada (una por jugador), cada una con el "viaje" completo de esa melodía en formato de chat grupal: N+1 mensajes apilados (N rondas + la versión original del sistema), cada mensaje con su autor en un texto pequeño al costado ("Sistema" o el nombre del jugador, con ronda y actividad) y un piano roll de solo lectura con reproducción/detención. Slide final con el leaderboard (sin rondas de otros jugadores) y "Tus participaciones": N filas × 2 columnas (la melodía recibida a la izquierda, la producida por el jugador a la derecha). Navegación con botones Anterior/Siguiente y un botón "Ver resultados" que salta directo a la slide final.
- **Grabaciones de voz persistidas** (decisión del tesista): a pesar de la idea inicial de no guardarlas por privacidad, se decidió almacenarlas por su valor para el engagement (escuchar la propia voz) al tratarse de una tesis y no de un producto comercial. Nueva colección `Media` (upload local en `media/`, gitignored) y campo `Submissions.recording`; el envío acepta `recordingId` y la subida se hace por separado (`POST /api/media`) antes del envío; si la subida falla, la respuesta se envía igualmente y la galería muestra el MIDI. La conversión audio→MIDI sigue en el navegador (latencia de red).
- **Checkbox de configuración** `showRecordings` (default: activo): "Mostrar las grabaciones de voz en la galería final". Desactivado, la galería solo muestra las transcripciones MIDI (motivación: timidez ante las burlas). El filtrado es del lado servidor (`readGallery`).
- **Cambio en el código:** `src/collections/Media.ts` y campos nuevos (`Submissions.recording`, `GameRooms.settings.showRecordings`); `rules.ts` (`assembleStrands`, `parseGameSettings` con `showRecordings`) con 3 pruebas nuevas (82 en total); `server.ts` (`readGallery`, `submitResponse` con `recordingId`); ruta `GET /api/rooms/[id]/gallery`; componentes `Gallery.tsx` (slideshow), checkbox en `ConfigForm`, `SightSingingExercise` conserva el blob de audio y `GameRound` lo sube y adjunta.
- **Verificación:** prueba de humo con 38 comprobaciones: partida completa de 2 rondas con grabaciones (subida a `Media`, mensajes N+1 por cadena, mensaje de repenticón con URL de audio accesible, mensaje de dictado sin audio, encadenamiento correcto —la ronda 2 recibe la respuesta del otro jugador—, fila de participaciones con grabación solo en repentización) y segunda partida con `showRecordings: false` (ninguna URL de audio en la galería). Lint y build limpios.
- **Pendientes de este bloque:** revisión visual de la galería por el tesista; política de consentimiento, retención y eliminación de las grabaciones (11.6); permisos de lectura de `media` (hoy abiertos a nivel de prototipo, como el resto de colecciones).

**Ajustes finos (25-11-2026):** botón "Copiar código" junto al código de sala en la cabecera de la sala (con confirmación visual), y corrección del audio que se reproducía solo por el oído izquierdo: en algunos sistemas el micrófono llega como estéreo con la señal solo en el canal 0 y `MediaRecorder` guardaba el archivo así (verificado midiendo canales de una grabación real: pico −21 dB vs silencio digital −290 dB). `startRecording` ahora mezcla a mono antes de grabar y `decodeAudio` mezcla a mono al decodificar; verificado en navegador con micrófono falso (señal con el mismo nivel en ambos canales). Commits: `14b6a48` (botón) y `a617939` (audio).

**Módulo docente, salones de clase y espectación (25-11-2026):** implementación completa de la lógica de profesores según decisiones confirmadas por el tesista.

_Decisiones confirmadas (25-11-2026, preguntas al tesista):_

1. **Diagrama de espectación: filas = jugadores** (las participaciones de cada jugador se alinean horizontalmente con su nombre al costado; los edges de cada melodía cruzan de fila en zigzag cuando la melodía pasa al siguiente jugador). Color por melodía original (espectro de hues distribuido entre las M).
2. **Orden de partidas por métricas:** el puntaje de cada partida es el **promedio de los estudiantes del salón participantes**; con filtro de estudiante, su puntaje individual.
3. **Clic en partida pasada:** los **estudiantes ven la vista final** (galería + resultados); los **docentes ven las 3 sub-vistas de espectación** (la galería tipo chat se considera más de entretenimiento que analítica).
4. **Espectación en vivo y en frío:** la vista de espectación funciona en vivo y aunque la partida haya terminado; se accede desde las listas de "Partidas en desarrollo" (en vivo) o desde las partidas pasadas del salón (en frío), no por código.

_Lo implementado:_

- **Estudiantes:** pantalla de inicio con "Mis partidas" (historial con fecha, código, rondas, posición y métricas; clic → la vista final bloqueada de esa partida) e "Invitaciones pendientes" (aceptar/rechazar).
- **Docentes:** pantalla de inicio con "Partidas en desarrollo" (todas las de sus salones, con nombre de salón, código, ronda y jugadores, y botón "Espectar") y "Mis salones de clase" (lista con miembros y pendientes; crear salón). **No pueden jugar** (bloqueado en crear/unirse sala; los admins pueden jugar, enseñar y espectar). Vista de salón: "Partidas en desarrollo" del salón (con botón "Espectar"), "Partidas pasadas" (todas las partidas donde jugó al menos un estudiante del salón, con filtro por estudiante —vía `?student=`— y orden por alturas/ritmo/general —`?metric`/`?order`—, mostrando el promedio del salón o el puntaje del estudiante filtrado), "Estudiantes" (ordenable por métricas y partidas jugadas; clic → partidas filtradas por ese estudiante) e "Invitaciones pendientes" con invitación por correo (el correo debe corresponder a un usuario existente; re-invitar tras rechazo vuelve a poner la invitación en pendiente).
- **Espectación con 3 sub-vistas** (`?spectate=<roomId>&view=general|melody|player`, selección en `?melody=`/`?player=`): (a) _vista general_: diagrama de nodos tipo red neuronal, capas = rondas (columnas), filas = jugadores con su nombre clickeable (→ detalle de jugador), nodos simbólicos (contorno de alturas, sin piano roll completo) con color por melodía original y edges del flujo de cada melodía; clic en nodo → detalle de esa melodía; (b) _detalle por melodía_: el viaje tipo chat con evaluación por mensaje; (c) _detalle por jugador_: filas recibió/produjo por ronda con sub-puntajes. Funciona en vivo (sondeo) y en frío.
- **Datos y API:** colecciones `Classrooms` (docente) y `ClassroomInvitations` (estado pending/accepted/rejected; aceptada = miembro) con cascada de borrado; endpoints `GET /api/my/overview` (rol, historial, invitaciones, salones y partidas en vivo), `POST /api/classrooms`, `GET /api/classrooms/[id]` (detalle con partidas en vivo, filtros y orden por query params), `POST /api/classrooms/[id]/invitations`, `POST /api/invitations/[id]` (accept/reject) y `GET /api/rooms/[id]/spectate`. El rol del usuario no es legible por REST (acceso de campo), por lo que el frontend lo obtiene de `my/overview`.
- **Dominio:** `rules.ts` con `scoreAverages`, `gameSortScore`, `sortScores` y `assembleStrands` enriquecido (autor y evaluación por mensaje, soporte de envíos pendientes para partidas en vivo); 6 pruebas nuevas (88 en total). `teacher.ts` con la orquestación docente. Reglas de React Compiler resueltas (`useSyncExternalStore` para los query params, reproducción MIDI con estado de módulo en `melody-view.tsx` compartido).
- **Verificación:** prueba de humo con 33 comprobaciones (roles: estudiante sin salones, docente sin juego, estudiante sin espectación; invitaciones con aceptar/rechazar/re-invitar/correo inexistente; detalle de salón con filtro por estudiante usando su puntaje y orden; historial con posición; espectación en vivo con capa 0 y capa 1 con evaluaciones, y en frío con cadenas N+1 completas) y recorrido visual en navegador (inicio docente, vista de salón, diagrama de nodos con zigzag y las 3 sub-vistas con query params). Lint, build y 88 pruebas limpios.

_Pendientes de este bloque:_ revisión del tesista; crear usuarios `professor` reales (hoy solo el admin puede promoverlos desde el CMS o por API); política de acceso a `classrooms`/`classroom-invitations` vía REST (mismas restricciones que el resto: mutaciones solo por endpoints); capítulo IV: 4.8.5 (control de acceso por roles, ahora parcialmente implementado) y 4.9 (nuevas pantallas: inicio por rol, salón, espectación) pendientes de redacción.

**Ajuste (25-11-2026):** se retiró el input de "Espectar partida" por código del inicio docente. Las partidas en curso se listan en el inicio del docente (todas las de sus salones, con nombre de salón) y en la vista de cada salón bajo la sección "Partidas en desarrollo", ambas con botón "Espectar" y refresco cada 5 s (en el inicio vía sondeo del overview; en el salón, del detalle). Se eliminó `POST /api/rooms/spectate` (la resolución por código ya no se usa). Verificado con la prueba de humo (35 comprobaciones, incluidas las listas en vivo al iniciar la partida y su vaciado al finalizar) y en navegador (inicio y salón con la partida en vivo y su botón, y acceso directo a la espectación).

**Ajuste (26-11-2026):** la vista de salón ahora presenta sus cuatro secciones ("Partidas en desarrollo", "Partidas pasadas", "Estudiantes", "Invitaciones pendientes") como **tabs** en lugar de apiladas, reutilizando el patrón de pills de la espectación. La tab activa vive en la URL (`?tab=live|games|students|invitations`, default `live`); los `h3` de cada sección se quitaron por redundar con el label de la tab. Al hacer clic en un estudiante se cambia a la tab "Partidas del salón" (donde se ve el filtro por estudiante, que antes quedaba en otra sección apilada). `tab` se añadió a `APP_PARAMS` y se limpia al abrir una partida o volver. Cambios en `ClassroomView.tsx` y `App.tsx`; verificado con lint y `tsc` limpios.

**Operativa de base de datos (nota para el siguiente agente):** el `push` de esquema de Payload en desarrollo es interactivo si quedan restos de colecciones retiradas (pregunta si los enums/columnas son renombres y se cuelga). Se respaldaron y eliminaron las tablas `melodies`, `game_sessions`, `game_sessions_rounds`, sus enums y las columnas huérfanas de `payload_locked_documents_rels` (respaldo en el scratchpad de la sesión, `backup-collecciones-viejas.sql`; solo contenían datos de pruebas). Para correr `npm run dev` en el host hace falta `docker compose -f compose.yaml -f compose.dev.yaml up -d postgres` (publica el 5432); el README quedó corregido.

**Pendientes tras este incremento:**

1. **Actualizar el capítulo IV** (hecho pendiente por cambio de implementación): 4.7.3 (mecánica multijugador: ya no es solo diseño — hay implementación y pruebas de asignación), 4.7.5, 4.8.2/4.8.3 (colecciones `GameRooms`/`Submissions` sustituyen a `Melodies`/`GameSessions`; tabla 15), 4.8.5, 4.9 (pantallas: auth, lobby, sala de espera, espera entre rondas; ya no existe la pantalla de resultado por ronda), 4.10.5/4.10.6 y 21.5/21.6 (varias "correcciones" de 21.6 quedan desactualizadas).
2. Decisión del tesista sobre la pantalla de "espera" vs. alguna retroalimentación mínima (RF-20). La galería final ya está implementada (25-11-2026, ver arriba); queda abierta cualquier refinamiento de su contenido.
3. Política de tiempo por ronda y manejo de desconexiones/rezagados para más de 2 jugadores (17.2).
4. Control de acceso por rol y validación de permisos en Payload (4.8.5): los roles de `users` y su control de acceso ya están implementados (ver arriba); queda pendiente el control de acceso por rol en `game_rooms`/`submissions` — la lectura de `submissions` vía REST sigue abierta (cualquier cliente podría leer respuestas ajenas; irrelevante para la prueba del tesista, pendiente para el estudio) — y la reescritura de 4.8.5 en el capítulo IV.
5. Consentimiento, retención y eliminación de las grabaciones de audio (11.6): la persistencia ya está implementada (25-11-2026, ver arriba); falta la política.
6. Prueba real con dos usuarios en dos navegadores a cargo del tesista (la verificación automatizada cubrió el flujo completo; falta el ensayo humano con micrófono).
7. Validación de la transcripción con voz cantada real (10.5) y revisión docente de las decisiones musicales (8.4).

---

## 16. Capítulo IV: Desarrollo – orientación de redacción

El capítulo IV debe describir el artefacto efectivamente diseñado e implementado, no convertirse en una propuesta genérica ni en una lista de tecnologías.

La tesis de Freire (2025) debe orientar el nivel de detalle y el tratamiento de decisiones técnicas. Antes de redactar la versión final, revisar directamente sus apartados de desarrollo para reconocer cómo presenta:

- diseño de solución;
- arquitectura;
- componentes;
- selección y preparación de datos, si aplica;
- implementación de técnicas;
- configuración experimental;
- procedimientos de validación.

No asumir que el índice exacto de Freire debe copiarse. El capítulo de este proyecto debe reflejar su arquitectura y su proceso real.

### 16.1. Posible organización del capítulo

Los títulos son provisionales y deben ajustarse al contenido final:

- **4.1. Diseño del generador procedural de melodías**
  - requisitos musicales;
  - parámetros de dificultad;
  - representación simbólica;
  - algoritmo de generación;
  - validación de restricciones;
  - pruebas de generación.
- **4.2. Diseño del método de evaluación de similitud melódica**
  - representación de referencia y respuesta;
  - emparejamiento de alturas;
  - emparejamiento de ataques;
  - métricas de precision/recall/F1;
  - combinación de sub-scores;
  - pruebas.
- **4.3. Integración del modelo de transcripción automática**
  - selección de Basic Pitch u otra alternativa validada;
  - captura de audio;
  - inferencia;
  - normalización;
  - almacenamiento;
  - limitaciones y pruebas.
- **4.4. Arquitectura del videojuego**
  - stack;
  - arquitectura lógica;
  - persistencia;
  - realtime;
  - seguridad.
- **4.5. Diseño de las mecánicas de juego**
  - salas;
  - configuración;
  - flujo de rondas;
  - intercambio de contenido;
  - puntuación y ganador.
- **4.6. Diseño e implementación de interfaces**
  - lobby;
  - dictado;
  - repentización;
  - feedback;
  - leaderboard;
  - galería;
  - aulas y panel docente.
- **4.7. Modelo de datos y persistencia**
  - entidades;
  - relaciones;
  - archivos de audio;
  - trazabilidad de cadenas.
- **4.8. Integración y pruebas del prototipo**
  - pruebas unitarias;
  - integración;
  - pruebas de sincronización;
  - pruebas con usuarios piloto;
  - resultados técnicos.

La organización anterior fue reemplazada por la estructura de once secciones descrita en la sección 21. El capítulo IV ya no se redacta como un plan previo: distingue entre el prototipo funcional (implementado y verificado) y la especificación de la versión completa (diseño). Las subsecciones de diseño se marcan internamente con comentarios `// PLACEHOLDER` y se detallan en la sección 21.5. El texto de los placeholders se redacta en el mismo registro que una tesis finalizada, sin lenguaje de "en progreso"; la marca de placeholder es interna y sirve para saber qué debe reescribirse con evidencia.

### 16.2. Evidencias que deben recopilarse durante el desarrollo

- diagramas de arquitectura;
- diagramas de secuencia de rondas;
- modelo entidad-relación;
- capturas de interfaces;
- ejemplos de melodías generadas por nivel;
- resultados de pruebas de restricciones;
- ejemplos de audio y transcripciones (con consentimiento);
- métricas de transcripción;
- resultados de matching;
- latencia de sincronización;
- pruebas de reconexión;
- resultados de pruebas de usabilidad;
- versiones exactas de dependencias y modelos.

---

## 17. Riesgos y decisiones pendientes prioritarias

### 17.1. Riesgos técnicos

1. **Transcripción vocal:** Basic Pitch puede confundir vibrato, portamentos, armónicos, ruido y consonantes. Debe evaluarse pronto. Evidencia del prototipo con audio sintético: el ruido blanco no genera notas falsas, pero el ruido tonal bajo el registro cantado sí; acotar el rango de frecuencia (75–1500 Hz) las elimina, mientras que el filtrado por amplitud no sirve porque las espurias no son más débiles que las notas reales. Falta confirmar ambas cosas con voz cantada real.
2. **Latencia:** transcripción en navegador puede variar por dispositivo.
3. **Compatibilidad:** acceso al micrófono requiere HTTPS en despliegue y permisos del usuario.
4. **Sincronización:** desconexiones pueden romper una cadena de contenido si no se diseña recuperación.
5. **Generación:** cumplir restricciones no garantiza melodías musicalmente naturales.
6. **Métrica:** el promedio de dos F1 puede ser intuitivo, pero su validez como medida global debe justificarse.
7. **Persistencia de audio:** almacenamiento, privacidad, consentimiento y costos.
8. **Alcance:** el conjunto de funcionalidades es amplio para una tesis; priorizar un MVP que demuestre la mecánica central sin eliminar los requisitos considerados indispensables por el tesista.

### 17.2. Decisiones que deben cerrarse

- número de rondas;
- tamaño mínimo y máximo de una sala;
- comportamiento con número impar de jugadores;
- asignación exacta de jugadores a contenidos;
- si una respuesta se distribuye a un único jugador o a varios;
- qué pasa con jugadores ausentes;
- límites de tiempo por ronda;
- política de abandono y reconexión;
- tempo y compás;
- registro absoluto de alturas;
- escalas y tonalidades permitidas;
- reglas de modulación;
- silencios y patrones rítmicos;
- formato visual de la partitura;
- entrada de dictado: teclado, piano roll, pentagrama u otro;
- grabación vocal: una toma o múltiples intentos;
- si se permite escuchar la propia grabación antes de enviarla;
- número de intentos;
- definición de “todas las rondas jugadas” si hay desconexiones;
- almacenamiento y retención de audios;
- proveedor de almacenamiento;
- proveedor realtime definitivo;
- duración y protocolo de intervención pedagógica;
- instrumentos de evaluación pretest/postest;
- tamaño de muestra y análisis estadístico.

**Actualización (25-11-2026), decisión de diseño multijugador del prototipo (ver 15.3):** quedan provisionales o resueltos para la prueba con dos jugadores: número de rondas configurable (2–8); mínimo 2 jugadores por sala (sin máximo definido); asignación por rotación `(i − 1 + N) % N`, que también resuelve el número impar de jugadores y distribuye cada respuesta a un único jugador; sin cronómetro por ronda (la ronda avanza cuando todos envían su respuesta). Siguen abiertos: jugadores ausentes o rezagados, desconexión y reconexión, límites de tiempo por ronda para más jugadores, y el resto de la lista.

---

## 18. Siguientes pasos recomendados para completar la tesis

Orden recomendado, priorizando decisiones que pueden invalidar el diseño:

### Prioridad 1 – Actualizar coherencia académica

1. (Completado el 11-11-2026) Revisar problema general y problemas específicos: actualizados por el tesista en el borrador.
2. (Completado parcialmente el 11-11-2026) Actualizar objetivos: objetivos nuevos redactados en el borrador; quedan pendientes la decisión sobre la transcripción automática como objetivo y las correcciones de redacción del apartado 4.3.
3. Ajustar la sección metodológica DSRM para que distinga claramente diseño/desarrollo, demostración y evaluación.
4. Revisar alcance y criterios de evaluación con el asesor.

### Prioridad 2 – Rehacer el estado del arte (en curso; ver sección 6.5)

1. ~~Reformular C2, C3 y C4 según las técnicas que realmente se implementarán.~~ Completado.
2. ~~Ampliar C1 hacia mecánicas multijugador e intercambio de contenido.~~ Completado (C1b).
3. ~~Ejecutar búsquedas reproducibles y documentar cifras nuevas.~~ Completado (23-11-2026; ver `docs/estado-del-arte/registro-busqueda.md`).
4. Comparar opciones técnicas y justificar la selección final. **Etapa 4 completada (76 incluidos; ver 6.5). Pendiente: tabla de técnicas/resultados/gap y redacción del capítulo II conforme a PRISMA.**

### Prioridad 3 – Pruebas técnicas de factibilidad

1. Spike de generación con `tonal` y `@tonejs/midi`.
2. Spike de Basic Pitch con grabaciones monofónicas vocales.
3. Implementar prototipo del matching de alturas/onsets y probar casos límite.
4. Spike de Ably en Next.js.
5. Confirmar persistencia de audio y permisos de acceso.

### Prioridad 4 – Especificación del juego

1. Dibujar el flujo de una partida desde la sala hasta la galería final.
2. Definir la asignación de contenido entre jugadores.
3. Definir rondas, tiempos, desconexiones y reconexiones.
4. Especificar las interfaces y el modelo de datos.

### Prioridad 5 – Desarrollo y validación

1. Construir primero el modo individual.
2. Integrar la sincronización multijugador.
3. Implementar galería e historial.
4. Implementar aulas y panel docente.
5. Ejecutar pruebas técnicas y piloto.
6. Ajustar la solución.
7. Realizar estudio pedagógico.
8. Analizar resultados y completar capítulos de resultados, discusión y conclusiones.

---

## 19. Instrucciones operativas para el LLM que continúe el proyecto

1. **Trabaja en español**, salvo que se solicite expresamente otro idioma.
2. Usa `tesis/tesis.typ` como fuente primaria de lo que ya está escrito (el antiguo `TESIS.txt` ya no existe) y señala toda modificación sustantiva. El documento está escrito en Typst con plantilla de formato cercana a APA 7: conserva la estructura de encabezados por niveles, la numeración manual de figuras y tablas, las fórmulas en modo matemático de Typst y la compilación con `typst compile` para verificar que los cambios no rompan el layout.
3. Antes de redactar una sección académica, revisa los apartados relacionados del borrador y las fuentes citadas.
4. Usa `Freire_vd.md` como referencia de profundidad y estilo, no como fuente de contenido para esta investigación.
5. Usa `Peffers_2008.md` para explicar correctamente DSRM y sus seis actividades.
6. Usa `Troubadour.md` como antecedente cercano y verifica sus características concretas antes de atribuirle resultados o funcionalidades.
7. No afirmes que un modelo o librería es “el mejor” sin criterios comparativos y pruebas. La selección inicial de Basic Pitch es una hipótesis técnica razonada que debe validarse con audio vocal real.
8. No afirmes que existe una biblioteca JS equivalente a `mir_eval` hasta comprobar que implementa las métricas concretas requeridas. La alternativa inicial es implementar el matching en TypeScript.
9. No entrenar modelos desde cero salvo que el tesista cambie expresamente la decisión.
10. No convertir la dificultad en un sistema adaptativo durante la partida: se fija al crear la partida.
11. No implementar chat interno, Discord SDK, ranking global ni personalización compleja de usuarios: están fuera del alcance confirmado.
12. Sí conservar multijugador síncrono, salas por código, todas las mecánicas indicadas, galería final, historial y funcionalidad docente básica.
13. Mantener la trazabilidad de cada contenido intercambiado entre jugadores.
14. No confundir precisión de alturas con precisión rítmica; mostrar y almacenar ambas.
15. No guardar solo la puntuación final: guardar audio, respuesta simbólica, transcripción y detalle de evaluación.
16. No confundir el leaderboard por partida con evaluación pedagógica. Ganar una partida no demuestra por sí solo mejora de habilidades auditivas.
17. Distinguir siempre hipótesis de diseño, resultados de pruebas técnicas y resultados de evaluación pedagógica.
18. Si falta una decisión crítica, preguntar al tesista o registrar la cuestión como pendiente; no inventar una respuesta.
19. Mantener el alcance realizable. Si se propone una reducción, explicitar qué requisito se aplaza y pedir aprobación.
20. Cada vez que una decisión técnica cambie, actualizar este documento y las especificaciones relacionadas.
21. **Regla de mantenimiento de este documento:** toda interacción significativa con un agente que cause una modificación en el proyecto (código, documentos, datos, decisiones) debe quedar reflejada aquí antes de terminar la sesión, con los datos necesarios para que otro agente continúe sin rehacer el trabajo: qué se hizo, qué se decidió, qué cambió y qué queda pendiente.

---

## 20. Referencias técnicas iniciales consultadas para orientar la selección

Estas referencias son documentación técnica para iniciar la implementación, no sustituyen la revisión académica del estado del arte:

- Tonal, biblioteca JavaScript/TypeScript de teoría musical: https://www.npmjs.com/package/tonal
- Tonejs/Midi, lectura y escritura de archivos MIDI: https://github.com/Tonejs/Midi
- Spotify Basic Pitch TypeScript: https://github.com/spotify/basic-pitch-ts
- Spotify Basic Pitch en npm: https://www.npmjs.com/package/@spotify/basic-pitch
- `@audio/mir`, utilidades de music information retrieval en JavaScript: https://www.npmjs.com/package/@audio/mir
- `mir_eval`, documentación de evaluación de transcripción y matching de notas: https://mir-eval.readthedocs.io/latest/api/transcription.html
- Ably, guía de Pub/Sub con Next.js: https://ably.com/docs/getting-started/nextjs
- Ably, presencia en canales: https://ably.com/docs/presence-occupancy/presence

**Nota final:** la arquitectura, las bibliotecas y los algoritmos aquí propuestos son decisiones iniciales sujetas a pruebas de concepto, revisión de licencias y validación con el caso de uso real. El LLM debe conservar esta distinción durante todo el desarrollo y la redacción de la tesis.

---

## 21. Estado de redacción del capítulo IV (19-11-2026)

### 21.1. Fuente de estilo y política de fuentes

El capítulo IV se redactó tomando como referencia el capítulo 4 de Freire (2025): exposición en presente y pasado, tablas y figuras propias, y sin citas externas en el desarrollo. Freire no cita fuentes externas en su capítulo de desarrollo; por esa razón no se realizó una búsqueda bibliográfica nueva para este capítulo. Las únicas citas del capítulo son Peffers et al. (2008), ya utilizado en el capítulo III, y Pesek et al. (2020a), ya presente en el borrador. Se agregó la entrada de Peffers et al. (2008) a la lista de referencias porque faltaba. Se incluyeron dos comentarios de Typst con extractos clave: el de Peffers et al. (2008) sobre la naturaleza no rígida del DSRM y el de Pesek et al. (2020a) sobre el algoritmo de generación de secuencias.

Requisito del tesista para fuentes futuras: si una afirmación del capítulo requiere respaldo externo, usar fuentes confiables, relevantes y de acceso abierto; leer el contenido del paper y no solo el abstract; y dejar como comentario de Typst el extracto clave al que se hace referencia. No agregar citas decorativas ni afirmaciones negativas sin respaldo (por ejemplo, "no existe una biblioteca X") sin documentar la búsqueda realizada.

### 21.2. Figuras y herramientas

Las figuras 3 a 11 se generaron con `@preview/fletcher` 0.5.5, no con `plotst`. La razón es que todas son diagramas estructurales (casos de uso, arquitectura, modelo de dominio, flujos, cadena de datos y flujo de pantallas), no gráficos estadísticos. Si en el futuro se agregan gráficos cuantitativos (distribuciones de puntuaciones, comparaciones de precisión, tiempos), corresponde usar `plotst` y mantener la misma numeración correlativa.

En la rama `prototipo` la Figura 10 se renderiza con normalidad; en `prototipo-no-placeholders` quedó dentro del bloque comentado de 4.8.1.

Convenciones de las figuras:

- Los componentes implementados usan trazo continuo y relleno azul o verde.
- Los componentes de la versión completa usan trazo discontinuo o relleno gris claro. La leyenda se explica en el texto de cada sección y en el párrafo introductorio del capítulo.
- En fletcher, el eje Y crece hacia abajo. Si se edita una figura, mantener esa convención para no invertir el flujo.
- Las figuras se compilan dentro de bloques no divisibles. Si una figura no cabe en la página, se desplaza completa a la siguiente; no se parte.

Figuras del capítulo:

- Figura 3: casos de uso del sistema.
- Figura 4: arquitectura de componentes.
- Figura 5: modelo de dominio musical.
- Figura 6: flujo del generador procedural.
- Figura 7: evaluación por correspondencia bipartita.
- Figura 8: pipeline de transcripción de audio a notas.
- Figura 9: flujo de una partida individual.
- Figura 10: cadena de datos de una partida.
- Figura 11: flujo de pantallas del videojuego.

### 21.3. Tablas del capítulo

Las tablas 3 a 18 continúan la numeración de los capítulos II y III:

- Tabla 3: decisiones de diseño y alternativas.
- Tabla 4: trazabilidad entre objetivos específicos y secciones.
- Tabla 5: stack tecnológico y versiones.
- Tabla 6: organización del repositorio.
- Tabla 7: requisitos no funcionales y mecanismos.
- Tabla 8: invariantes del modelo de dominio.
- Tabla 9: parámetros de generación por dificultad.
- Tabla 10: configuración global del generador.
- Tabla 11: propiedades verificadas del generador.
- Tabla 12: tolerancias de evaluación.
- Tabla 13: casos límite del evaluador.
- Tabla 14: parámetros de inferencia y normalización.
- Tabla 15: colecciones implementadas en Payload.
- Tabla 16: estrategia de pruebas.
- Tabla 17: resultados de pruebas unitarias.
- Tabla 18: resultados del banco sintético de transcripción.

### 21.4. Redactado con seguridad (verificado contra el código)

Las siguientes secciones se redactaron a partir del código, de `package.json`, de las pruebas y del estado del prototipo documentado en la sección 15.2. No requieren reescritura salvo que cambie la implementación:

- 4.1.1: posición dentro del DSRM y naturaleza iterativa. La cita de Peffers está respaldada por el paper y se agregó la referencia.
- 4.1.2: estrategia de construcción incremental y prácticas de ingeniería de software.
- 4.1.3: alcance del prototipo, trazabilidad con los objetivos y casos de uso.
- 4.2.1: arquitectura de componentes y dependencia unidireccional.
- 4.2.2: stack y versiones exactas.
- 4.2.3: organización del repositorio.
- 4.2.5: requisitos no funcionales y mecanismos (los mecanismos de la versión completa se marcan como diseño).
- 4.3.1 a 4.3.3: modelo de dominio, invariantes, serialización, validación y reproducibilidad.
- 4.4.1 a 4.4.4: parámetros, algoritmo, validación y pruebas del generador.
- 4.5.1 a 4.5.5: métricas, correspondencia bipartita, tolerancias y casos límite del evaluador.
- 4.6.1 a 4.6.6: selección de Basic Pitch, pipeline, parámetros, integración en el Worker, manejo de errores y validación sintética.
- 4.7.1 y 4.7.2: configuración y flujo de la partida individual.
- 4.7.4: fórmula de puntuación y exclusión de respuestas no puntuadas.
- 4.8.2 y 4.8.3: colecciones implementadas y trazabilidad de la sesión.
- 4.9.1 a 4.9.6: principios de interfaz, pantallas implementadas, entrada de dictado, grabación y panel de evaluación.
- 4.10.1 a 4.10.4: estrategia de pruebas, 50 pruebas unitarias, banco sintético y flujo individual verificado.
- 4.11: síntesis del capítulo (actualizar si se implementa la versión completa).

### 21.5. Placeholders (diseño; requieren implementación y evidencia)

Los siguientes apartados están marcados en `docs/tesis/tesis.typ` con comentarios `// PLACEHOLDER`. En la rama `prototipo` se renderizan con normalidad; en `prototipo-no-placeholders` se envolvieron en comentarios de bloque `/* ... */` para generar una versión sin ellos. Su texto está redactado en el mismo registro que una tesis finalizada y no dice "en progreso"; la marca es interna. No deben interpretarse como resultados ejecutados. Cada apartado indica qué evidencia falta para reescribirlo:

**Actualización (25-11-2026):** el incremento multijugador del prototipo (ver 15.3) deja desactualizados varios apartados del capítulo IV (4.7.3, 4.7.5, 4.8.2, 4.8.3, 4.8.5, 4.9, 4.10.5, 4.10.6, la tabla 15 y las "correcciones" de 21.6 sobre persistencia y mecánica). La lista de pendientes de actualización está en 15.3.

- 4.2.4, párrafo de comunicación en tiempo real: definir el proveedor definitivo, la autenticación, los canales y la presencia; documentar límites, privacidad y pruebas de integración. Actualmente se describe el diseño y la comparación entre servicio administrado y servidor WebSocket propio.
- 4.7.3: mecánica multijugador (salas, códigos, asignación, número impar de jugadores, trazabilidad de la cadena). Reescribir con la implementación y las pruebas de asignación.
- 4.7.5: reglas de recuperación, abandono y reconexión. Reescribir con los resultados de las pruebas de sincronización y reconexión.
- 4.8.1: modelo conceptual de la versión completa. Reemplazar por el esquema final, sus relaciones y las migraciones.
- 4.8.4: almacenamiento de audio, consentimiento, retención y eliminación. Reescribir con el proveedor elegido y la política aplicada.
- 4.8.5: control de acceso por roles. Reescribir con las reglas de Payload, las pruebas de autorización y la validación en servidor.
- 4.9.7: galería final, acceso, sala de espera y vista docente. Reescribir con capturas y pruebas de usabilidad.
- 4.10.5: validación con voz cantada real. Reescribir con el conjunto de grabaciones, las métricas y los resultados.
- 4.10.6: pruebas de la versión multijugador (sincronización, reconexión, latencia). Reescribir con resultados.
- 4.10.7: limitaciones y amenazas a la validez. Actualizar a medida que se cierren las brechas anteriores.
- 4.11: síntesis. Actualizar si se implementa la versión completa.

### 21.6. Correcciones factuales aplicadas respecto de la versión anterior del capítulo

- Se eliminó el párrafo que afirmaba que la implementación no había comenzado.
- Se reemplazó el tiempo futuro por presente y pasado para los componentes construidos.
- Se ampliaron los parámetros del generador: registro absoluto, duraciones exactas, figuras requeridas, destino y probabilidad de modulación, tonalidades, compás, tempo, silencios, repetición, intentos y versión.
- Se precisó que el determinismo depende de la tupla completa (semilla, dificultad, tempo y compás), no solo de la semilla.
- Se corrigió el evaluador: precisión, exhaustividad y $F_1$; escala $[0,1]$; correspondencia bipartita máxima; tolerancias de 50 ms y 150 ms; equivalencia de octava solo en repentización de dificultad baja; casos límite.
- Se corrigió el dictado: la duración no es editable; se fija en un pulso y la evaluación rítmica se basa solo en los ataques.
- Se corrigió la transcripción: implementación oficial en TypeScript, ejecución local en Worker, backend CPU, TensorFlow.js 3.21.0, parámetros centralizados, normalización, límite de 30 s, reintentos y manejo de errores.
- Se corrigió la persistencia: el prototipo guarda melodías y sesiones con rondas embebidas; no guarda audio ni transcripciones; no existen salas, rondas, respuestas ni resultados como colecciones separadas.
- Se corrigió la mecánica: el prototipo es individual, genera una melodía nueva por ronda y muestra un promedio; no implementa salas, intercambio ni clasificación.
- Se corrigió el tiempo real: Ably no está implementado ni seleccionado; se describe como alternativa de diseño.
- Se corrigió el control de acceso: el prototipo usa acceso abierto; los roles son diseño de la versión completa.
- Se agregó la referencia de Peffers et al. (2008) a la bibliografía.

### 21.7. Riesgos y decisiones de diseño abiertas

- Registro de la dificultad alta (F#2–F#6) frente a la tesitura vocal. La equivalencia de octava solo se aplica a la dificultad baja. Definir si se limita el registro para repentización, se amplía la equivalencia o se transpone la referencia.
- Piano roll frente a pentagrama en repentización. El piano roll aísla altura y ataque, pero reduce la validez ecológica de la lectura a primera vista. Documentar la decisión y su efecto en la evaluación.
- Feedback por color y coloreado basado solo en alturas. Añadir formas o etiquetas y distinguir los errores rítmicos.
- Pistas involuntarias en el dictado: el rango visible del piano roll se deriva del mínimo y máximo de la melodía, y la longitud total revela parte de la estructura. Decidir si se usa un rango fijo por dificultad.
- Persistencia de audio y consentimiento informado antes de las sesiones con estudiantes.
- Validación de la transcripción con voz cantada real.
- Estudio de usabilidad y accesibilidad con usuarios.
- Implementación y pruebas de la versión multijugador.
- Precisión de la afirmación "síncopas" en la dificultad alta: el generador no modela ligaduras; produce ataques desplazados por suma de duraciones y garantiza al menos una figura entre 1.5 y 2/3, no ambas.
- Decidir si la duración de las notas formará parte de la puntuación o si se mantiene la evaluación exclusiva de ataques.

---

## 22. Estado del capítulo V: resultados y discusión (19-11-2026)

### 22.1. Alcance redactado

El capítulo V se redactó para el **primer objetivo específico** (generador procedural). Incluye:

- 5.1.1 Configuración de la evaluación.
- 5.1.2 Cumplimiento de restricciones y reproducibilidad.
- 5.1.3 Perfil de intervalos y ambitus.
- 5.1.4 Variedad melódica y rítmica.
- 5.1.5 Síntesis de resultados.
- 5.2.1 Sobre el cumplimiento de las restricciones.
- 5.2.2 Sobre el perfil melódico y la repetitividad.
- 5.2.3 Sobre la reproducibilidad y el uso pedagógico.
- 5.2.4 Limitaciones y mejoras.
- 5.2.5 Respuesta al primer objetivo específico.

No se redactó la sección de resultados del evaluador de similitud (segundo objetivo). El capítulo no contiene placeholders: se limita a lo evaluado.

### 22.2. Datos de la evaluación

- Generador `0.1.0`.
- 200 semillas por nivel de dificultad; 600 melodías en total.
- Tempo 90 BPM; compás 4/4.
- Patrón de semilla: `resultado-{dificultad}-###`.
- Misma ruta de código que la aplicación (`generateMelody`).
- Métricas registradas: éxito, tiempo, intervalos, ambitus, duraciones, tonalidad, escala, modulación, unicidad y variedad.

La evaluación se ejecutó con un test temporal de Vitest el 19-11-2026; el test se retiró después de generar las cifras. Para reproducirla, crear un test o script que genere las 200 semillas por nivel con ese patrón y calcule las mismas métricas. Las cifras no se inventaron: provienen de esa ejecución.

### 22.3. Resultados principales

- 600/600 melodías generadas; 0 fallos.
- 100 % de cumplimiento de escala y anti-repetición; 100 % de figura requerida en media y alta.
- Tiempo medio: 0.25 ms (baja), 0.59 ms (media), 1.09 ms (alta); p95: 0.42, 0.98 y 1.40 ms.
- Intervalos repetidos (0 semitonos): 40.9 %, 36.6 % y 35.3 %.
- Intervalos ≤2 semitonos: 100 %, 82.3 % y 80.0 %.
- Saltos de 3 a 7 semitonos: 0 %, 17.7 % y 20.0 %.
- Ambitus medio: 3.49, 8.70 y 13.53 semitonos; máximo permitido: 12, 24 y 36; uso: 29.1 %, 36.2 % y 37.6 %.
- Duración media: 9.82, 14.91 y 23.57 pulsos; 6.5, 9.9 y 15.7 s a 90 BPM.
- Modulación: 0 %, 48 % y 100 %.
- Alturas distintas por melodía: 3.1/8, 5.6/15 y 8.3/24.
- Cambios de dirección: 1.8, 4.4 y 7.4.
- Duraciones distintas: 1.9, 2.9 y 4.9.
- Secuencias únicas: 92.5 %, 100 % y 100 %.
- El 100 % de las melodías contiene al menos un par de notas repetidas; la racha máxima es 2.

### 22.4. Interpretación central

El generador cumple las restricciones, pero produce melodías poco variadas, sobre todo en dificultad baja. La causa es la ponderación $1/(1+d^2)$, que favorece la nota anterior ($d=0$) sobre el grado conjunto ($d=1$) y sobre el salto ($d=2$); la regla anti-repetición solo impide tres notas iguales consecutivas. El ambitus funciona como máximo, no como objetivo. La dificultad nominal no equivale a una dificultad musical efectiva; dos semillas pueden producir melodías con distinto ambitus y variedad.

Mejoras propuestas en 5.2.4: penalizar la repetición, controlar el perfil de intervalos y el ambitus objetivo, añadir restricciones de frase, medir la diversidad en la validación y validar con docentes.

### 22.5. Respuesta a los dos primeros objetivos

- **OE1 (generador):** cumplido en el plano del diseño y de la implementación verificada. El algoritmo existe, genera ejercicios para dictado y repentización, cumple las restricciones y es reproducible. La limitación de variedad no invalida el objetivo, pero define una línea de refinamiento.
- **OE2 (evaluador):** el algoritmo está diseñado, implementado y cubierto por pruebas (matching bipartito, F1, tolerancias de 50/150 ms y equivalencia de octava en dificultad baja). Lo que resta es trasladar esos resultados al capítulo V, en una sección de resultados y discusión del evaluador. No es un placeholder del capítulo actual; es la siguiente tarea de redacción.
- Se corrigió el “?” sobrante del objetivo 2 en `tesis.typ`.

### 22.6. Estilo, figuras y fuentes

El capítulo sigue la estructura de Freire (2025): 5.1 Resultados y 5.2 Discusión, con subsecciones por componente. No se agregaron fuentes externas nuevas; la discusión cita Pesek et al. (2020a) para comparar con Troubadour.

- **Figura 12:** gráfico de barras agrupadas de la distribución de intervalos. Se generó con `@preview/cetz-plot:0.1.4` y `@preview/cetz:0.5.2`. No se usó `plotst` porque su versión 0.2.0 usa la función `style`, retirada en Typst 0.14, y no compila.
- **Figura 13:** piano roll de tres melodías de muestra (una por dificultad), dibujado con Typst a partir de las notas generadas con el generador reformado (semillas `figura13-{baja|media|alta}`). La línea vertical gris marca la modulación. Regenerada el 24-11-2026 tras la reforma del generador.
- **Figura 1 (capítulo II):** proceso de búsqueda y selección conforme a PRISMA 2020. Se regeneró el 24-11-2026 como diagrama de Typst (`fletcher`), sustituyendo a `fig1.png` (obsoleto: mostraba la revisión anterior con Springer/OpenAlex y 10 estudios por cluster). Refleja las cifras del SOTA actualizado: 5232 → 4759 únicos → 4599 → 656 → 448 → 76 incluidos.
- **Tablas 19–23:** configuración, cumplimiento y tiempo, distribución de intervalos, ambitus/duración/modulación y variedad melódica.

Si se agrega la sección del evaluador, usar 5.1.6 y 5.2.6 (o renumerar) y continuar la numeración de tablas y figuras desde 24 y 14, respectivamente.
