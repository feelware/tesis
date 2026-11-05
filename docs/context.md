# Contexto integral de la tesis y guía de trabajo para un LLM

**Proyecto:** Tesis – videojuego web multijugador para entrenamiento auditivo  
**Fecha de consolidación:** 3 de noviembre de 2026  
**Idioma principal de trabajo:** español  
**Estado del desarrollo:** todavía no iniciado

> Este documento sirve como contexto persistente para otro LLM que apoyará tanto la redacción académica de la tesis como el diseño e implementación de la codebase. Debe leerse como una especificación de trabajo viva. Distingue entre decisiones confirmadas, propuestas técnicas por validar y cuestiones todavía abiertas. No presentes como implementado, probado o validado aquello que aún no se ha desarrollado.

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

- `TESIS.txt`: borrador actual de la tesis. Es la fuente primaria para el problema, formulación, objetivos, justificación, marco teórico, estado del arte y metodología actualmente redactados.
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

> ¿De qué manera un videojuego en línea basado en técnicas de generación y análisis de similitud melódica facilita el desarrollo de habilidades auditivas en estudiantes de música?

Esta formulación debe revisarse para asegurar que refleje también la transcripción automática de canto y la mecánica de intercambio entre jugadores. Una formulación alternativa que el tesista y su asesor podrían evaluar es:

> ¿En qué medida el uso de un videojuego en línea multijugador, basado en generación procedural, transcripción automática y análisis de similitud melódica, contribuye al desarrollo de habilidades de dictado y repentización en estudiantes de música?

No sustituir la pregunta oficial sin validación del tesista y asesor.

### 3.3. Problemas específicos del borrador

El borrador plantea preguntas sobre:

- Integrar un generador de estructuras melódicas simbólicas para crear ejercicios de dictado y repentización.
- Integrar un método de análisis de similitud melódica para evaluar transcripciones e interpretaciones.
- Integrar un modelo de transcripción musical automática de audio a MIDI para evaluar la repentización.
- Desarrollar un videojuego en línea que integre los componentes anteriores.
- Evaluar la efectividad pedagógica mediante un estudio experimental con estudiantes de música.

**Advertencia de actualización:** la generación de melodías ya no se plantea necesariamente como integración de un modelo generativo preexistente. El tesista está dispuesto a implementar un generador procedural propio, con reglas y parámetros explícitos. Por tanto, el primer problema y objetivo específico deben reformularse para no prometer la integración de un modelo generativo si la solución real será algorítmica.

---

## 4. Objetivos de investigación

### 4.1. Objetivo general actualmente redactado

> Desarrollar un videojuego en línea basado en técnicas de generación y análisis de similitud melódica para el desarrollo de habilidades auditivas en estudiantes de música.

Debe considerarse una revisión para mencionar la evaluación de interpretaciones vocales mediante transcripción automática y la mecánica multijugador.

### 4.2. Objetivos específicos actuales

El borrador contiene los siguientes objetivos:

1. Integrar un modelo generador de estructuras melódicas simbólicas existente para la generación automática de ejercicios de dictado y repentización melódica.
2. Integrar un modelo de análisis de similitud de estructuras melódicas simbólicas existente para evaluar el desempeño de un jugador en ejercicios de dictado y repentización melódica.
3. Integrar un modelo de transcripción musical automática (audio a MIDI) existente para la evaluación de ejercicios de repentización melódica.
4. Desarrollar un videojuego en línea que integre los modelos descritos para implementar mecánicas de dictado y repentización melódica.
5. Evaluar la efectividad pedagógica del videojuego implementado mediante un estudio experimental con estudiantes de música.

### 4.3. Ajuste recomendado de los objetivos

Dado el cambio técnico, se recomienda discutir con el asesor una versión como la siguiente:

1. **Diseñar e implementar un algoritmo de generación procedural de estructuras melódicas simbólicas**, parametrizado por dificultad, para producir ejercicios de dictado y repentización.
2. **Diseñar e implementar un método de evaluación de similitud melódica simbólica** que permita estimar separadamente la precisión de alturas y la precisión rítmica de las respuestas.
3. **Integrar y adaptar una biblioteca o modelo existente de transcripción automática de audio a MIDI** para convertir las interpretaciones vocales de los jugadores en secuencias simbólicas evaluables.
4. **Desarrollar un videojuego web multijugador** que integre los componentes anteriores y materialice el intercambio de melodías, transcripciones e interpretaciones en rondas de dictado y repentización.
5. **Evaluar la efectividad pedagógica del videojuego** mediante un estudio experimental o cuasi-experimental con estudiantes de música, según las condiciones reales de reclutamiento y asignación de participantes.

No declarar estos objetivos como aprobados hasta que el tesista y asesor los confirmen. El objetivo 5 requiere especial atención: la factibilidad de un diseño experimental con grupo control, pretest, postest e intervención suficiente debe contrastarse con el calendario, el tamaño de muestra y la disponibilidad de estudiantes.

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

### 6.1. Estrategia originalmente descrita en `TESIS.txt`

La revisión se dividió en cuatro búsquedas o clusters independientes porque las técnicas necesarias para el videojuego son distintas y una búsqueda única podría omitir literatura técnica relevante:

- **C1 – Educación musical gamificada:** aplicaciones, plataformas, juegos serios y aprendizaje basado en juegos en entrenamiento auditivo.
- **C2 – Generación automática de melodías:** generación de estructuras melódicas o música simbólica.
- **C3 – Similitud melódica:** comparación de estructuras musicales simbólicas y alineamiento de secuencias.
- **C4 – Transcripción musical automática:** conversión de audio a representaciones simbólicas, detección de alturas y ataques, transcripción de canto.

Las fuentes documentales descritas en el borrador son Springer Nature Link, IEEE Xplore, Scopus y OpenAlex. Se justificó su selección por cobertura académica y capacidades de búsqueda booleana. El borrador menciona limitaciones de búsqueda/descarga como razones para excluir ACM Digital Library, MDPI, ScienceDirect y Web of Science en el proceso original. Si se rehace la revisión, volver a comprobar las condiciones actuales de acceso y búsqueda; no asumir que las limitaciones siguen idénticas.

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

### 7.7. Cuentas y aulas

- Habrá cuentas de usuario.
- El perfil será mínimo: nombre visible y los campos imprescindibles para autenticación y auditoría.
- La colección de usuarios se gestionará mediante Payload CMS.
- Se implementarán aulas simples y una vista para que docentes consulten resultados de estudiantes.
- No se ha solicitado un LMS completo, gestión curricular compleja, mensajería docente ni personalización extensa.
- Debe definirse cómo se vincula un estudiante a un aula y quién puede consultar sus resultados.

---

## 8. Parámetros del generador procedural de melodías

El tesista ha definido los siguientes niveles:

| Parámetro                                 | Dificultad baja               | Dificultad media   | Dificultad alta     |
| ----------------------------------------- | ----------------------------- | ------------------ | ------------------- |
| Intervalo máximo entre notas consecutivas | 2 semitonos                   | 5 semitonos        | 7 semitonos         |
| Congruencia tonal                         | Una sola escala               | Posible modulación | Modulación          |
| Ambitus (rango total)                     | 1 octava                      | 2 octavas          | 3 octavas           |
| Complejidad rítmica                       | Negras/blancas, compás simple | Corcheas           | Síncopas, tresillos |
| Longitud                                  | 8 notas                       | 15 notas           | 24 notas            |

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

Referencia metodológica para las tolerancias y el concepto de matching: documentación de `mir_eval`:
https://mir-eval.readthedocs.io/latest/api/transcription.html

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
- Registrar versión del modelo y parámetros de inferencia para reproducibilidad.

### 10.5. Validación específica

Preparar un conjunto pequeño de grabaciones vocales con:

- melodías conocidas;
- distintas tesituras;
- distintos niveles de experiencia;
- grabaciones con y sin ruido moderado;
- diferentes micrófonos y navegadores.

Comparar la transcripción automática con MIDI de referencia y calcular precisión de altura y onset. Esta validación técnica no sustituye la evaluación pedagógica del videojuego.

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
- role (`student`, `teacher`, `admin`)
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

El desarrollo todavía no ha comenzado. El LLM de programación debe trabajar por incrementos verticales y mantener la aplicación ejecutable.

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

No redactar como si estas secciones ya se hubieran completado. Antes de tener implementación, pueden prepararse especificaciones de diseño, pero el texto final debe usar pasado y reportar resultados solo después de ejecutar y documentar el trabajo.

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

1. **Transcripción vocal:** Basic Pitch puede confundir vibrato, portamentos, armónicos, ruido y consonantes. Debe evaluarse pronto.
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

---

## 18. Siguientes pasos recomendados para completar la tesis

Orden recomendado, priorizando decisiones que pueden invalidar el diseño:

### Prioridad 1 – Actualizar coherencia académica

1. Revisar problema general y problemas específicos.
2. Actualizar objetivos para reflejar generación procedural, evaluación propia de alturas/onsets y transcripción automática.
3. Ajustar la sección metodológica DSRM para que distinga claramente diseño/desarrollo, demostración y evaluación.
4. Revisar alcance y criterios de evaluación con el asesor.

### Prioridad 2 – Rehacer el estado del arte

1. Reformular C2, C3 y C4 según las técnicas que realmente se implementarán.
2. Ampliar C1 hacia mecánicas multijugador e intercambio de contenido.
3. Ejecutar búsquedas reproducibles y documentar cifras nuevas.
4. Comparar opciones técnicas y justificar la selección final.

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
2. Usa `TESIS.txt` como fuente primaria de lo que ya está escrito y señala toda modificación sustantiva.
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
