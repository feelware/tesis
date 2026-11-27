// Tesis — documento principal (Typst)
// Conversión de TESIS.txt al formato actual del borrador.
// Plantilla con formato cercano a APA 7: Times New Roman 12pt,
// interlineado doble, márgenes de 2.54 cm, sangría de primera línea 1.27 cm,
// rótulos de tablas y figuras sobre el elemento (número en negrita, título en itálica).

// ============ Plantilla ============
#set document(
  title: "Videojuego en línea basado en técnicas de generación melódica procedural y análisis de similitud melódica para el desarrollo de habilidades auditivas en estudiantes de música",
  author: "Jesus Stevan Diaz Ingol",
)

#set text(
  font: ("Times New Roman", "Liberation Serif", "Libertinus Serif"),
  size: 12pt,
  lang: "es",
)

#set par(
  justify: false,
  leading: 1em,
  spacing: 1em,
  first-line-indent: 1.27cm,
)

#set page(
  paper: "a4",
  margin: (x: 2.54cm, y: 2.54cm),
  numbering: none,
)

#show heading.where(level: 1): it => {
  pagebreak(weak: true)
  v(1em)
  align(center)[#text(weight: "bold")[#it.body]]
  v(1em)
}

#show heading.where(level: 2): it => block(above: 1.5em, below: 1em)[
  #set par(first-line-indent: 0pt)
  #text(weight: "bold")[#it.body]
]

#show heading.where(level: 3): it => block(above: 1.5em, below: 1em)[
  #set par(first-line-indent: 0pt)
  #text(weight: "bold", style: "italic")[#it.body]
]

#let leyenda(tipo, num, titulo) = block(above: 1em, below: 0.5em)[
  #set par(first-line-indent: 0pt, leading: 0.65em, spacing: 0.65em)
  #text(weight: "bold")[#tipo #num]#linebreak()
  #text(style: "italic")[#titulo]
]

#let apatable(columns: (), header: (), rows: (), inset: (x: 8pt, y: 5pt)) = block(breakable: true)[
  #set par(first-line-indent: 0pt, leading: 0.75em, spacing: 0.75em)
  #table(
    columns: columns,
    stroke: (x, y) => (
      top: if y == 0 { 0.8pt } else { none },
      bottom: if y == 0 { 0.5pt } else if y == rows.len() { 0.8pt } else { none },
    ),
    inset: inset,
    align: left,
    ..header,
    ..rows.flatten(),
  )
]

#let listasin = body => {
  set par(first-line-indent: 0pt, leading: 1em, spacing: 1em)
  body
}

#import "@preview/fletcher:0.5.7" as fletcher: diagram, node, edge
#let caja-c4(x, y, body, fill: rgb("#eef2ff")) = node((x, y), body, shape: fletcher.shapes.rect, fill: fill)
#let pastilla-c4(x, y, body, fill: rgb("#eef2ff")) = node((x, y), body, shape: fletcher.shapes.pill, fill: fill)
#let diam-c4(x, y, body, fill: rgb("#fff7ed")) = node((x, y), body, shape: fletcher.shapes.diamond, fill: fill)

// ============ Portada ============
#align(center)[
  #v(1.5cm)
  #text(weight: "bold")[Universidad Nacional Mayor de San Marcos] \
  Universidad del Perú. Decana de América

  #v(4cm)
  #text(weight: "bold")[Videojuego en línea basado en técnicas de generación melódica procedural y análisis de similitud melódica para el desarrollo de habilidades auditivas en estudiantes de música]

  #v(4cm)
  AUTOR \
  Jesus Stevan DIAZ INGOL

  #v(1.5cm)
  ASESOR \
  Dr. Ciro RODRIGUEZ RODRIGUEZ

  #v(3cm)
  Lima, Perú \
  2025
]

// ============ Contenido ============
#pagebreak()
#set page(numbering: "1", number-align: right + top)
#counter(page).update(1)

#outline(title: [Contenido], depth: 3)

= Capítulo I: Introducción

== 1.1. Situación problemática

// ==== Fuentes nuevas de esta sección (extractos clave verificados) ====
// Hannon, A. (2015). Helping Non-Singers Overcome Fear and Anxiety in Aural Skills. Journal of Music Theory Pedagogy E-Journal, 5, art. 2. https://digitalcollections.lipscomb.edu/jmtp_ejournal/vol5/iss1/2 — "Many students feel fear and anxiety upon entering the aural skills classroom... making aural skills a feared class in the curriculum"; "attempt to avoid sight-singing quizzes altogether by dropping courses just before the first quiz... sign up multiple times for a course only to withdraw, regardless of their grade."
// Pomerleau-Turcotte, J., Moreno Sala, M. T., Dubé, F. y Vachon, F. (2021). Experiential and Cognitive Predictors of Sight-Singing Performance in Music Higher Education. Journal of Research in Music Education. https://doi.org/10.1177/00224294211049425 — "the age when students began learning music could predict sight-singing performance independently from the number of years of experience and the educational level"; la capacidad de memoria de trabajo (WMC) predice la repentización; los alumnos difieren en experiencia y capacidades cognitivas.
// Chenette, T., Davis, S. y Kleppinger, S. V. (2022). A Critical Review of Current Aural Skills Materials and Pedagogical Practices. Journal of Music Theory Pedagogy, 36(1). https://doi.org/10.71156/2994-7073.1410 — "evidence suggests that mainstream aural skills teaching has not changed all that much"; "disconnect between aural skills pedagogy scholarship and teaching practice"; "Music by white, male, European composers is overrepresented in textbooks and anthologies"; sobre el dictado: "some students will do well while others will flounder."
// Paney, A. S. y Buonviri, N. O. (2017). Developing Melodic Dictation Pedagogy: A Survey of College Theory Instructors. Update: Applications of Research in Music Education, 36(1), 51-58. https://doi.org/10.1177/8755123316686815 — "highlighted several challenges of teaching dictation and aural skills in general"; "acknowledged the difficulty of compound meter for students."
// Kavčič Pucihar, A., Habe, K., Rotar Pance, B. y Laure, M. (2024). The key reasons for dropout in Slovenian music schools – a qualitative study. Frontiers in Psychology, 15, 1385840. https://doi.org/10.3389/fpsyg.2024.1385840 — "music theory and solfége lessons" figuran entre los factores externos de abandono "más prominentes"; "Many young pupils struggle with these subjects and fail to see their practical value."

En los programas formales de educación musical, el entrenamiento auditivo —que abarca ejercicios como el dictado melódico y la entonación a primera vista (repentización)— constituye una competencia central del músico, pues su desarrollo fortalece otras destrezas como la interpretación, la composición y la lectura a primera vista (Rogers, 2013). No obstante, alcanzar un desempeño sólido en estas habilidades exige una práctica prolongada y constante: su dificultad aumenta de manera considerable a lo largo del currículo (Royston y Wilson, 2024) y las habilidades adquiridas se debilitan si no se practican con regularidad (Barlow, 2016). El dictado melódico resulta particularmente exigente porque obliga a percibir y retener a la vez alturas, ritmos y relaciones tonales, y su dificultad es reconocida tanto por los propios docentes (Paney y Buonviri, 2017) como por la investigación sobre procesamiento musical, según la cual el desempeño depende en buena medida de la memoria de trabajo, el entrenamiento previo y la familiaridad con ciertos estilos e instrumentos (Nichols y Springer, 2025). A ello se suma que los estudiantes llegan a estos cursos con niveles de preparación muy dispares, pues la edad de inicio en el estudio musical y la capacidad de memoria de trabajo predicen el rendimiento en repentización con independencia de los años de experiencia acumulados (Pomerleau-Turcotte et al., 2021).

Las formas tradicionales de evaluar estas habilidades agravan la dificultad. El dictado suele plantearse pidiendo al estudiante que escuche una grabación y transcriba las notas en papel, mientras que la calificación a cargo del docente puede demorar varios días, lo que priva al alumno de retroalimentación oportuna para identificar y corregir sus errores (Pesek et al., 2020b). Kleppinger (2017) advierte que estas evaluaciones no se alinean de manera consistente con lo que realmente se espera que los estudiantes aprendan y que su carácter "contrarreloj" genera ansiedad incluso en alumnos de alto rendimiento, lo que deriva con frecuencia en perspectivas pesimistas sobre la utilidad del propio curso; la evaluación del entrenamiento auditivo se sitúa así en una encrucijada compleja entre las expectativas docentes, las habilidades de audición del estudiante, sus percepciones y ansiedades ante la evaluación y las peculiaridades de los instrumentos evaluativos. Una revisión crítica de los materiales y las prácticas vigentes muestra que el entrenamiento auditivo sigue dominado por unas pocas tareas —identificación, repentización y dictado— que apenas han cambiado en generaciones y que revelan una marcada desconexión entre la investigación pedagógica y la enseñanza real; el propio dictado, por componerse de múltiples habilidades combinadas, resulta además una herramienta de instrucción y diagnóstico poco eficiente, en la que algunos estudiantes progresan mientras otros se estancan (Chenette et al., 2022).

Estas condiciones tienen consecuencias afectivas y académicas verificables. Numerosos estudiantes experimentan temor y ansiedad al ingresar al aula de entrenamiento auditivo, hasta el punto de que la asignatura es percibida como una de las más temidas del currículo, y quienes llegan con menor preparación suelen rezagarse desde el inicio (Hannon, 2015). El mismo autor describe un ciclo pernicioso: algunos alumnos evitan por completo los exámenes de repentización e incluso se dan de baja de la asignatura poco antes de la primera evaluación, llegando a matricularse repetidas veces solo para retirarse, con independencia de su calificación (Hannon, 2015). Este clima de evaluación centrado en el producto y en el acierto o el error, más que en el proceso de aprendizaje, nerviosa a los estudiantes y refuerza una mentalidad de incapacidad del tipo "simplemente no sirvo para el entrenamiento auditivo" (Chenette et al., 2022). En una escala más amplia, las asignaturas de teoría musical y solfeo —que engloban el entrenamiento auditivo— figuran entre las principales causas de frustración y abandono reportadas por estudiantes, familias y docentes de escuelas de música (Kavčič Pucihar et al., 2024). De este modo, los cursos de habilidades auditivas pueden convertirse en un obstáculo desalentador que contribuye a la deserción académica (Barlow, 2016).

A lo anterior se suman limitaciones de enfoque y representación. El material de estudio para entrenamiento auditivo, fuertemente enlazado a la currícula tradicional de teoría musical, hereda un enfoque eurocentrista que ignora la música popular y las tradiciones musicales internacionales (Chenette, 2021), y muchos de los métodos aplicados en la educación secundaria fueron diseñados para un contexto musical mucho menos diverso que el contemporáneo (Donn et al., 2024). La revisión crítica de Chenette et al. (2022) confirma que la música de compositores europeos, blancos y varones está sobrerrepresentada en los libros de texto y las antologías, de modo que estos materiales no reflejan la diversidad del alumnado al que se dirigen. Esta falta de pertinencia cultural se superpone a la enorme variabilidad individual: como el desempeño en dictado y repentización depende de la memoria de trabajo, la experiencia previa y la familiaridad con ciertos estilos e instrumentos, los estudiantes requieren planes de práctica diferenciados que la enseñanza tradicional, de carácter a menudo masivo y uniforme, no logra ofrecer (Nichols y Springer, 2025; Pomerleau-Turcotte et al., 2021). En conjunto, la dificultad inherente a estas habilidades, unas formas de evaluación lentas y poco alineadas con los objetivos de aprendizaje, sus efectos emocionales y sus sesgos culturales configuran un problema real que afecta de forma directa a estudiantes y docentes de la educación musical formal.

== 1.2. Formulación del problema

=== 1.2.1. Problema general

¿En qué medida el uso de un videojuego en línea basado en generación melódica procedural y análisis de similitud melódica contribuye al desarrollo de habilidades auditivas en estudiantes de música?

=== 1.2.2. Problemas específicos

#listasin[
  - ¿Cómo influye el diseño de un algoritmo generador de estructuras melódicas simbólicas en su efectividad para la generación automática de ejercicios de dictado y repentización melódica?
  - ¿Cómo influye el diseño de un algoritmo de análisis de similitud melódica en su efectividad para la evaluación de transcripciones e interpretaciones musicales de los jugadores?
  - ¿Qué impacto tienen los componentes de un videojuego en línea que implementa mecánicas de dictado y repentización melódica en el desarrollo de habilidades auditivas en estudiantes de música?
  - ¿Cómo la validación del videojuego implementado mediante un estudio experimental con estudiantes de música demuestra la efectividad pedagógica de dicho videojuego?
]

== 1.3. Justificación

=== 1.3.1. Justificación teórica

Según Vallejo (2019), muchas de las aplicaciones y plataformas de entrenamiento auditivo existentes no exploran mecánicas más allá de la simple identificación “al oído” de notas e intervalos musicales, sugiriendo una falta de innovación en el diseño de estas. El mismo autor señala que el componente gamificador de estas aplicaciones suele ser superficial y poco útil para facilitar el proceso de aprendizaje. Este fenómeno no es exclusivo al contexto musical, Almeida et al. (2022) demuestran que las plataformas gamificadas que centran su atención en elementos gamificadores superficiales, tales como puntos e insignias, provocan que los usuarios pierdan motivación intrínseca por el tema que se desea enseñar. En este sentido, la presente investigación propone mecánicas de juego poco exploradas en la literatura existente. Así mismo, se pretende aumentar la discusión sobre el uso de técnicas de aprendizaje automático para la retroalimentación automatizada en contextos de educación musical.

=== 1.3.2. Justificación práctica

Las plataformas existentes de educación musical basadas en juegos no suelen estar orientadas a contextos educativos formales, lo que hace difícil a los docentes integrarlas en la currícula (Pesek et al., 2020a). La mayor parte de estas aplicaciones se limitan al aprendizaje de instrumentos musicales, siendo muy pocas las que se centran en el desarrollo de habilidades auditivas y el aprendizaje de teoría musical. Más aún, muchas de estas aplicaciones no son gratuitas, lo que dificulta aún más su adopción en el aula (Pesek et al., 2020b). La presente investigación aborda esta brecha de mercado proponiendo una plataforma de entrenamiento auditivo basada en juegos, cuyas mecánicas de juego están diseñadas para ser de utilidad tanto a alumnos como a docentes de conservatorios. Richards (2023) señala el potencial de estas plataformas para proveer una sensación de comunidad, competencia y trabajo en equipo a estudiantes en el contexto de la educación en línea. En este sentido, la base de usuarios objetivo de la plataforma propuesta incluye también a estudiantes autodidactas. Los estudiantes en etapas escolares tempranas también se podrían beneficiar, siendo que se encuentran en un periodo crítico para el desarrollo de habilidades auditivas (Respati et al., 2021).

== 1.4. Objetivos

=== 1.4.1. Objetivo general

Desarrollar un videojuego en línea basado en generación melódica procedural y análisis de similitud melódica para el desarrollo de habilidades auditivas en estudiantes de música.

=== 1.4.2. Objetivos específicos

#listasin[
  - Diseñar un algoritmo generador de estructuras melódicas simbólicas para la generación automática de ejercicios de dictado y repentización melódica.
  - Diseñar un algoritmo de análisis de similitud melódica para la evaluación de transcripciones e interpretaciones musicales de los jugadores.
  - Desarrollar un videojuego en línea que implementa mecánicas de dictado y repentización melódica para el desarrollo de habilidades auditivas en estudiantes de música.
  - Validar el videojuego implementado mediante un estudio experimental con estudiantes de música para demostrar la efectividad pedagógica de dicho videojuego.
]

= Capítulo II: Marco teórico

== 2.1. Antecedentes del problema

Pesek et al. (2020a), en su artículo "Troubadour: A Gamified e-Learning Platform for Ear Training" abordaron los desafíos asociados al entrenamiento auditivo, concretamente al dictado musical, proponiendo una plataforma de código abierto cuyo enfoque central es la identificación de intervalos musicales. La interfaz principal de la aplicación consiste de un teclado virtual con el que el estudiante interactúa. El estudiante escucha una secuencia melódica proporcionada por la plataforma y es su deber introducir aquellas notas que identificó mediante el teclado virtual. La generación de estos ejercicios es automática y su dificultad se ajusta de forma adaptativa. Para aumentar el engagement en los estudiantes, la plataforma incluye elementos gamificadores como insignias, tablas de clasificación y un modo multijugador. Para evaluar la efectividad de esta propuesta, se realizó un estudio A/B con estudiantes de primer y segundo año del Conservatorio de Música y Ballet de Ljubljana. Los estudiantes de primer año que utilizaron la plataforma obtuvieron una puntuación media del 69.8% en sus exámenes finales de dictado, lo que supuso una mejora del 9.2% respecto al grupo de control (60.6%), el cual no utilizó la plataforma.

Chen y Li (2025) realizaron el estudio “A Quasi-Experimental Study on the Application of MuseScore Software to Improve Sight-Singing and Ear-Training Abilities in Music Education at Chuzhou University” para explorar la efectividad del software de notación musical MuseScore como herramienta de aprendizaje en cursos de dictado y repentización musical en la Universidad de Chuzhou. El objetivo fue comparar la precisión rítmica y tonal de aquellos estudiantes que usaron la aplicación con la de aquellos que recurrieron a métodos tradicionales. Se realizó una intervención de ocho semanas a 60 estudiantes de primer año: 30 en grupo experimental y 30 en control. Ambos tuvieron acceso a los mismos materiales y contenido de estudio. Al trabajar con el grupo control, los docentes hicieron uso de ciertas funcionalidades de MuseScore durante clase, tales como el metrónomo al practicar precisión de ritmo y el tempo ajustable para facilitar la repentización (sight-reading). Tras finalizar las ocho semanas, ambos grupos rindieron un examen final. Las calificaciones de este examen fueron analizadas mediante una prueba t-test. La diferencia más notoria se encontró en el dictado melódico, donde el grupo experimental logró una puntuación promedio de 34.4 frente a 32.3 del grupo control, reflejando una diferencia significativa (p < 0.01) y un tamaño de efecto alto (Cohen’s d = -0.78).

C. W. J. Chen (2014) en su estudio “Mobile learning: Using application Auralbook to learn aural skills” investigó la efectividad de la aplicación móvil Auralbook como herramienta para la adquisición de ciertas habilidades auditivas: interpretar una partitura con la voz a primera vista (sight-singing), reconocer características de la pieza escuchada (reconocimiento estilístico) y aplaudir al ritmo correcto. Esta aplicación está especialmente diseñada para que los estudiantes se preparen para las evaluaciones de la Associated Board of the Royal Schools of Music (ABRSM), siendo su plan de estudios la base para las preguntas que la aplicación genera. La metodología empleada en este estudio fue la triangulación de tres fuentes de datos: una cuestionario en línea a 73 usuarios, un análisis de archivos de la base de datos de la aplicación (196 usuarios frecuentes) y entrevistas a dos profesores de piano que utilizan la aplicación para enseñar. Las conclusiones generales confirmaron que Auralbook es una herramienta efectiva, con el 94.59% de los usuarios afirmando que mejoró sus habilidades auditivas. El análisis de datos reveló los progresos más sustanciales en el nivel principiante para reconocimiento estilístico (7.21 de diferencia media) y ritmo (6.03 de diferencia media).

Lingjie (2025), en su estudio "Effectiveness Study of Applying Earmaster for Ear Training in Chinese University Students", investigó la eficacia de la integración del software Earmaster en los cursos de habilidades auditivas en China. El estudio abordó la limitación de los métodos tradicionales en clases masivas, no logrando satisfacer necesidades particulares de los estudiantes. El objetivo principal del estudio fue evaluar la efectividad de la aplicación en la mejora de habilidades auditivas específicas: el reconocimiento de altura (pitch), la percepción de ritmo y pulso, y la discriminación de timbre. El diseño de la investigación fue cuasi-experimental, involucrando a 67 estudiantes de música de primer año en una intervención de ocho semanas, comparando un grupo de control con un grupo experimental que utilizaba Earmaster para ejercicios y tareas personalizadas. Los resultados demostraron que Earmaster mejoró significativamente el rendimiento de los estudiantes en dos áreas: la percepción de altura (Diferencia Media = 8.47, p = 0.028) y la percepción de ritmo (Diferencia Media = 7.95, p = 0.022). Aunque el grupo experimental mejoró en discriminación de timbre, la diferencia no fue estadísticamente significativa (p = 0.098).

Fernandez (2025), en su tesis “Desarrollo de una aplicación web para el entrenamiento auditivo y enseñanza musical para miembros del Club de Música de la PUCE Ibarra”, abordó la escasez de herramientas innovadoras de entrenamiento auditivo autónomo en clubes universitarios de música: la mayoría está orientada a contextos de educación musical formal. Esta carencia es especialmente notoria en el contexto latinoamericano. La aplicación propuesta ofrece retroalimentación inmediata en ejercicios de reconocimiento melódico y rítmico, así como visualización interactiva de partituras en los módulos de lectura musical. Esto gracias a las librerías Tone.js y VexFlow, respectivamente. La plataforma también integra elementos gamificadores: sesiones breves, rachas y retos que se adaptan al jugador en una estructura por niveles. El estudio empleó un enfoque mixto para la evaluación de la plataforma, valiéndose tanto de encuestas (N=36) como entrevistas. Los resultados demostraron que el 97,2 % de los participantes aprobó la combinación de teoría y práctica, y el 80,6 % demostró interés por el componente gamificador.

== 2.2. Bases teóricas

=== Entrenamiento auditivo

Entre los ejercicios de entrenamiento auditivo comúnmente desarrollados en conservatorios se encuentran la entonación a primera vista (también llamada repentización), que consiste en interpretar una melodía correctamente sin haber leído la partitura previamente, y el dictado melódico, que consiste en transcribir de forma exacta las notas y ritmo de una melodía sin haberla escuchado antes (Cervantes, 2014).#footnote[Cervantes, R. C. (2014). El desarrollo de las habilidades auditivas en la formación del músico profesional. MAGOTZI Boletín Científico de Artes del IA, 2(4). https://doi.org/10.29057/ia.v2i4.638] Otras estrategias de entrenamiento auditivo, tales como la detección de errores, suelen ser pasadas por alto en ciertos entornos. McNeil (2021) revela una discrepancia entre las perspectivas sobre el entrenamiento auditivo de los conductores de bandas sinfónicas y sus acciones al respecto. Si bien estos afirman tener interés en incorporar diversos métodos de entrenamiento auditivo a sus ensayos, sólo los métodos tradicionales terminan formando parte sustancial de estos.#footnote[McNeil, B. (2021). Aural Skills Pedagogy in the Wind Band: A Survey of Secondary and Collegiate Wind Band Conductors’ Perceptions and Strategies \[Disertación de PhD, Auburn University\]. https://etd.auburn.edu/handle/10415/7610]

Una de las principales características de la repentización es la continuidad: el intérprete debe responder en tiempo real a una secuencia de estímulos visuales (la partitura) con una secuencia análoga de acciones (la interpretación) procurando no parar en ningún momento, ya sea para descifrar la pieza o corregir errores en su interpretación (Thompson y Lehmann, 2004; Wristen, 2005).#footnote[Thompson, S. & Lehmann, A. C. (2004). Strategies for sight-reading and improvising music. En A. Williamon (Ed.), Musical excellence (pp.143-159). Oxford University Press. https://doi.org/10.1093/acprof:oso/9780198525356.003.0008]#footnote[Wristen, B. (2005). Cognition and Motor Execution in Piano Sight-Reading: A Review of Literature. Update Applications Of Research In Music Education, 24(1), 44-56. https://doi.org/10.1177/87551233050240010106] En este sentido, los intérpretes suelen “adelantar” la mirada mientras leen la partitura, es decir, fijarse en las notas próximas a ser tocadas, con el fin de anticipar puntos de mayor complejidad en la pieza (Huovinen et al., 2018).#footnote[Huovinen, E., Ylitalo, A.-K., y Puurtinen, M. (2018). Early Attraction in Temporally Controlled Sight Reading of Music. Journal of Eye Movement Research, 11(2), 1-30. https://doi.org/10.16910/jemr.11.2.3]

La adquisición de habilidades auditivas suele favorecer el desarrollo de otras destrezas musicales, incluyendo la repentización, composición e interpretación musical (Rogers, 2013).#footnote[Rogers, M. (2013). Aural dictation affects high achievement in sight singing, performance and composition skills. Australian Journal Of Music Education/Australian Journal Of Music Education (Online), 1, 34. http://files.eric.ed.gov/fulltext/EJ1061809.pdf] Demian y Nedelcut (2018) resaltan la importancia del dictado musical en las fases tempranas de la formación musical debido a su efectividad en el desarrollo de las habilidades cognitivas implicadas: la memoria musical, el pensamiento musical y el oído interno.#footnote[Demian, A.-M. y Nedelcut, N. (2018). The Mental Processes Involved in the Musical Dictation. Music Cognition, 4, 86-97.] Por otro lado, Nichols y Springer (2025) demuestran que, si bien la capacidad de memoria de trabajo influencia positivamente el desempeño en dictado melódico, este no es el único factor determinante, sino también el nivel de entrenamiento previo, experiencia con ciertos estilos musicales y los instrumentos con los que están familiarizados. Dado que estos aspectos varían de estudiante a estudiante, es recomendable que los docentes diseñen planes personalizados alineados con los objetivos propios de cada alumno.#footnote[Nichols, B. E., & Springer, D. G. (2025). Piano history, aural skills, and working memory predict melodic dictation performance. Frontiers In Psychology, 16, 1579714. https://doi.org/10.3389/fpsyg.2025.1579714]

=== Juegos serios y aprendizaje basado en juegos

Se le llama “juegos serios” a aquellos que buscan capturar la atención de cierta audiencia con un objetivo que va más allá del entretenimiento puro, mediante el uso de mecánicas propias de los videojuegos (Djaouti et al., 2011).#footnote[Djaouti, D., Alvarez, J., & Jessel, J. (2011). Classifying serious games. En Advances in game-based learning book series (pp. 118-136). https://doi.org/10.4018/978-1-60960-495-0.ch006] Entre estos objetivos se encuentran el aprendizaje de cierto tema, concientizar al jugador sobre un fenómeno social, influenciar al jugador sobre adquirir un producto o servicio, entre otros. La educación es el área donde más se han desarrollado esta clase de juegos. El aprendizaje basado en juegos se centra en el desarrollo de juegos con fines específicamente educativos (De Carvalho & Coelho, 2022).#footnote[De Carvalho, C. V., & Coelho, A. (2022). Game-Based Learning, Gamification in Education and Serious Games. Computers, 11(3), 36. https://doi.org/10.3390/computers11030036] Estos juegos suelen implementarse como aplicaciones web o de escritorio, haciéndolos más apropiados para contextos de educación remota que para entornos presenciales (Brandl y Schrader, 2024).#footnote[Brandl, L. C., & Schrader, A. (2024). Serious Games in Higher Education in the Transforming Process to Education 4.0—Systematized Review. Education Sciences, 14(3), 281. https://doi.org/10.3390/educsci14030281]

En contextos universitarios, el desarrollo del pensamiento crítico a través del aprendizaje basado en juegos está condicionado tanto por el grado de alfabetización tecnológica de los docentes y estudiantes, como por el acceso a la infraestructura tecnológica adecuada (Román-Celi, 2023).#footnote[Román-Celi, G. E. (2023). Aprendizaje Basado en Juegos (GBL) en el desarrollo del pensamiento crítico \[Games Based Learning (GBL) in the development of critical thinking\]. Cognopolis Revista de Educación y Pedagogía, 1(3), 1-14. https://doi.org/10.62574/5m9rgk11] Mingyu et al. (2024) señalan una serie de problemas asociados al aprendizaje basado en juegos en contextos de educación superior: los estudiantes a menudo necesitan ser guiados al interactuar con juegos serios por primera vez, mientras que los docentes deben ser capacitados para poder incorporar estos juegos efectivamente. En contraste, los mismos autores mencionan los beneficios asociados a la correcta incorporación de juegos serios en el contexto universitario: adquisición de conocimiento, mejoras en las estrategias de enseñanza, mejoras en la actitud y motivación de los estudiantes, entre otros beneficios.#footnote[Mingyu, G., Yunus, M. M., & Rafiq, K. R. M. (2024). Educational Games and Game-based Approaches in Higher Education: A Systematic Review (2014-2023). International Journal Of Academic Research In Progressive Education And Development, 13(1). https://doi.org/10.6007/ijarped/v13-i1/20555]

Si bien el aprendizaje basado en juegos viene siendo usado desde los últimos años para mantener la motivación y compromiso en estudiantes de distintas áreas, su presencia en educación musical varía considerablemente (Ananda et al., 2025).#footnote[Ananda, R. F., Milyartini, R., & Sukmayadi, Y. (2025). Mapping the Use of Digital Game-Based Learning in Music Education: A Scoping Review. Jurnal Pendidikan Indonesia, 6(11), 4982-4989. https://doi.org/10.59141/japendi.v6i11.8772] Los juegos educativos musicales se presentan en diversas formas y adoptan diversos elementos, en ciertos casos incorporando componentes de hardware tales como sensores de movimiento (Qian & Jiang, 2024).#footnote[Qian, C., & Jiang, M. (2024). Exploring the Effects of Digital Game-Based Learning on Music Education. Studies In Social Science & Humanities, 3(5), 6-9. https://doi.org/10.56397/sssh.2024.05.02]

=== Retroalimentación automática en educación musical

La evaluación de rendimiento en entornos de educación musical, particularmente en la interpretación de instrumentos, suele ser lenta, poco eficiente y poco imparcial (Wang y Haris, 2025).#footnote[Wang, X., & Haris, M. F. B. (2025). AI-Driven Violin Performance Evaluation: A Deep Learning Approach for Automated Assessment and Personalized Feedback in Music Education. En Proceedings of the 2025 International Conference on Generative Artificial Intelligence and Digital Media (pp. 126-132). https://doi.org/10.1145/3734921.3734941] En este sentido, la aplicación de técnicas de inteligencia artificial a la evaluación y retroalimentación automática de rendimiento musical se ha vuelto un área de creciente interés (Giraldo et al., 2019).#footnote[Giraldo, S., Waddell, G., Nou, I., Ortega, A., Mayor, O., Perez, A., Williamon, A., & Ramirez, R. (2019). Automatic Assessment of Tone Quality in Violin Music Performance. Frontiers In Psychology, 10, 334. https://doi.org/10.3389/fpsyg.2019.00334] Los sistemas de retroalimentación musical basados en aprendizaje automático son capaces de analizar la interpretación y proveer sugerencias de forma instantánea, lo que permite a los estudiantes detectar y corregir errores en tiempo real (Lu, 2025).#footnote[Lu, L. (2025). AI-powered intelligent music education systems for real-time feedback and performance assessment. International Journal Of Information And Communication Technology, 1(1). https://doi.org/10.1504/ijict.2025.10071414] Algunos de los aspectos de la interpretación que estos sistemas suelen analizar son la precisión de altura, la precisión de ritmo, y la calidad de la interpretación en general. A menudo se deja de lado otros aspectos importantes de la interpretación como la calidad del timbre (Ou et al., 2025).#footnote[Ou, J., Nogueira, J., & Qin, C. (2025). Exploring the impact of AI-assisted practice applications on music learners’ performance, self-efficacy, and self-regulated learning. Frontiers In Psychology, 16, 1675762. https://doi.org/10.3389/fpsyg.2025.1675762]

== 2.3. Marcos conceptuales

*Altura (pitch):* Atributo sonoro directamente relacionado con la frecuencia fundamental de una nota musical que permite clasificarla como “alta” o “baja” en relación a otras.

*Aprendizaje basado en juegos (ABJ):* Uso de videojuegos o mecánicas lúdicas como herramienta en contextos educativos. A diferencia de la gamificación, los elementos lúdicos son parte intrínseca de las actividades educativas.

*Controlador MIDI:* Dispositivo de hardware capaz de enviar datos MIDI a otros dispositivos, incluyendo computadoras, permitiendo interpretación y control de parámetros a través de una interfaz de usuario. Las interfaces más comunes son el teclado y los pads percusivos.

*Cuantización de tiempo:* Proceso de ajustar el inicio y duración de eventos musicales a una cuadrícula rítmica predefinida, corrigiendo desfases temporales en grabaciones MIDI. Así, los eventos son “redondeados” a la fracción de tiempo más cercana en la cuadrícula.

*DAW (Digital Audio Workstation):* Software que permite grabar, editar, mezclar y producir audio y MIDI en un entorno integrado. Estas aplicaciones suelen incluir canales o pistas, cada una puede tener su propia entrada y salida de audio o MIDI.

*Dictado musical:* Transcripción musical realizada sobre material escuchado por primera vez, en un tiempo relativamente corto. Es común en entornos académicos como método de entrenamiento auditivo y evaluación de habilidades auditivas.

*Gamificación:* Incorporación de elementos lúdicos, tales como puntos, niveles y logros, en contextos educativos convencionales para aumentar la motivación y engagement de los usuarios.

*Instrumento virtual:* Software que emula el sonido y comportamiento de instrumentos acústicos o electrónicos, permitiendo interpretación mediante controladores MIDI.

*Juego serio:* Videojuego cuyo fin principal va más allá del mero entretenimiento del jugador. A menudo busca transmitir cierta información o conocimiento al jugador, o influenciarlo a tomar ciertas decisiones.

*Latencia:* Retraso temporal entre una acción del usuario, como tocar una tecla o hablar por el micrófono, y la respuesta del sistema, crítico en aplicaciones musicales en tiempo real y más aún en plataformas web, donde la conexión de red suele ser el cuello de botella.

*MIDI (Musical Instrument Digital Interface):* Estándar que define un formato de archivo que codifica eventos musicales, tales como notas y señales de control. Este estándar también define un protocolo de comunicación para transmitir datos en formato MIDI entre dispositivos de hardware y software. MIDI se refiere tanto al formato de archivo como al protocolo de comunicación.

*MIDI overdub:* Técnica de grabación que permite añadir capas adicionales de información MIDI sobre una grabación existente sin alterar el material previo.

*Repentización (sight-reading):* Proceso de tocar una pieza musical sin haberla leído ni escuchado antes, leyendo su partitura e interpretándola en tiempo real. Al igual que el dictado musical, también es un componente central del entrenamiento auditivo.

*Tempo:* Velocidad con la que debe interpretarse una pieza musical.

*Tonalidad o clave musical (key):* Conjunto de alturas usadas como base para una composición musical.

*Transcripción musical:* Conversión de material sonoro a notación musical escrita, documentando, entre otros componentes, la tonalidad y tempo de la pieza, así como la altura y duración de cada nota.

== 2.4. Estado del arte

La revisión del estado del arte se realizó conforme a las recomendaciones de la declaración PRISMA 2020 (Page et al., 2021)#footnote[Page, M. J., McKenzie, J. E., Bossuyt, P. M., Boutron, I., Hoffmann, T. C., Mulrow, C. D., Shamseer, L., Tetzlaff, J. M., Akl, E. A., Brennan, S. E., Chou, R., Glanville, J., Grimshaw, J. M., Hróbjartsson, A., Lalu, M. M., Li, T., Loder, E. W., Mayo-Wilson, E., McDonald, S., ... Moher, D. (2021). The PRISMA 2020 statement: an updated guideline for reporting systematic reviews. BMJ, 372, n71. https://doi.org/10.1136/bmj.n71] y de las recomendaciones de reporte de búsquedas PRISMA-S (Rethlefsen et al., 2021)#footnote[Rethlefsen, M. L., Kirtley, S., Waffenschmidt, S., Ayala, A. P., Moher, D., Page, M. J., & Koffel, J. B. (2021). PRISMA-S: an extension to the PRISMA Statement for Reporting Literature Searches in Systematic Reviews. Systematic Reviews, 10, 39. https://doi.org/10.1186/s13643-020-01542-z], para asegurar que el proceso de búsqueda, selección y síntesis sea reproducible y auditable.

=== 2.4.1. Objetivo y criterios de elegibilidad

El objetivo de la revisión es identificar soluciones existentes al problema central de investigación, así como técnicas computacionales con el potencial de ser aplicadas a la construcción del sistema propuesto por este estudio: un videojuego en línea dirigido a estudiantes de música, en el que cada jugador realiza dictado melódico sobre piezas generadas por el sistema, recibe la transcripción realizada por otro jugador e interpreta la partitura en vivo (repentización), en un ciclo que se repite por rondas y que concluye con estadísticas de similitud entre la respuesta y la pieza recibida.

El sistema involucra tres técnicas: generación automática de material musical, análisis de similitud melódica y transcripción musical automática. Búsquedas preliminares revelaron que muy pocos estudios abordan estas tres técnicas en contextos de educación musical basada en juegos, de modo que la revisión se dividió en cuatro clusters independientes: C1 (plataformas gamificadas para entrenamiento auditivo), C2 (generación automática de melodías), C3 (análisis de similitud melódica) y C4 (transcripción musical automática).

La Tabla 2 resume los criterios de elegibilidad aplicados. Esta revisión no se registró formalmente en un repositorio de protocolos antes de iniciar la búsqueda; las decisiones de método (cadenas, criterios, ventana temporal y proceso de selección) quedaron documentadas en el registro de búsqueda del proyecto antes de ejecutar cada fase. La ausencia de registro previo se declara como limitación del reporte.

#block(breakable: false)[
#leyenda([Tabla], 2, [Criterios de inclusión y exclusión])
#apatable(
  columns: (4cm, 11.9cm),
  header: ([*Tipo de criterio*], [*Descripción*]),
  rows: (
    (
      [Exclusión],
      [
        Estudios publicados en 2021 o antes#linebreak()
        Estudios de acceso cerrado#linebreak()
        Estudios en idiomas distintos al inglés y español
      ],
    ),
    (
      [Inclusión],
      [
        Artículos científicos o papers de conferencia publicados entre 2022 y 2027#linebreak()
        Estudios que abordan problemas en educación musical mediante gamificación y aprendizaje basado en juegos#linebreak()
        Estudios que describen un método de generación de melodías, de similitud o evaluación de secuencias musicales, o de transcripción de audio a notas, con un nivel de detalle que permita replicarlo (algoritmo, pseudocódigo, parámetros o métricas definidas), ya sea mediante implementación pública, datos abiertos o una descripción replicable. Se incluyen los métodos basados en modelos aprendidos cuando cumplen el mismo criterio.
      ],
    ),
  ),
)]

=== 2.4.2. Fuentes de información y estrategia de búsqueda

Las fuentes de información fueron IEEE Xplore (repositorio full-text), los índices de abstracts y citas Scopus y Semantic Scholar, y el índice educativo ERIC. Estas fuentes fueron elegidas por su amplia cobertura de áreas académicas, incluyendo las relevantes a esta investigación, y por sus capacidades de búsqueda booleana. Ciertas fuentes fueron descartadas por limitaciones conocidas: Springer Nature Link, porque su API de metadatos impone límites de cuota diaria en el plan gratuito que impidieron obtener los resultados de forma completa dentro del plazo del estudio; OpenAlex, porque no soporta búsqueda booleana y obliga a una aproximación por frases que sobre-recupera resultados y desvía la cadena; MDPI, que no procesa cadenas de búsqueda de gran tamaño; ScienceDirect, que restringe el tamaño de la cadena (no más de 500 caracteres) y el número de operadores booleanos (no más de 8); ACM Digital Library, por sus limitaciones en la descarga de resultados; y Web of Science, por no permitir acceso a través de la Universidad Nacional Mayor de San Marcos.

Para cada cluster se formuló una cadena de búsqueda independiente, con dos o tres grupos de términos unidos por el operador AND para asegurar que los estudios obtenidos aborden todos los conceptos requeridos. La ventana de publicación es 2022–2027. Las cadenas se adaptaron a la sintaxis de cada fuente (búsqueda experta en Scopus, command search en IEEE Xplore, búsqueda booleana en Semantic Scholar y consulta Lucene en ERIC). La Tabla 1 muestra las cadenas canónicas por cluster.

#block(breakable: false)[
#leyenda([Tabla], 1, [Cadenas de búsqueda por cluster])
#apatable(
  columns: (3.2cm, 12.7cm),
  header: ([*Búsqueda*], [*Cadena*]),
  rows: (
    (
      [C1 — Gamificación en educación musical],
      [("ear training" OR "aural training" OR "melodic dictation" OR "interval dictation") AND ("gamification" OR "gamified" OR "serious game" OR "game-based learning")],
    ),
    (
      [C1b — Multijugador y intercambio de contenido],
      [("ear training" OR "aural training" OR "melodic dictation" OR "music game") AND ("multiplayer" OR "collaborative game" OR "peer learning")],
    ),
    (
      [C2a — Generación automática de melodías],
      [("melody generation" OR "melodic generation" OR "algorithmic composition" OR "procedural music generation" OR "procedural content generation" OR "rule-based music generation" OR "constraint-based music generation" OR "generative grammar" OR "Markov chain" OR "random walk") AND ("monophonic" OR "melody" OR "symbolic music" OR "controllable" OR "music education" OR "exercise generation")],
    ),
    (
      [C2b — Dificultad y complejidad melódica y rítmica],
      [("melodic complexity" OR "rhythmic complexity" OR "melody difficulty" OR "melodic dictation difficulty" OR "sight-reading difficulty" OR "difficulty level" OR "adaptive exercise" OR "automatic item generation") AND ("music education" OR "ear training" OR "melodic dictation" OR "sight singing" OR "melody")],
    ),
    (
      [C3a — Métricas de evaluación nota a nota],
      [("melodic similarity" OR "symbolic music similarity" OR "melody comparison" OR "note matching" OR "note-level evaluation" OR "transcription evaluation" OR "melody alignment" OR "sequence alignment" OR "bipartite matching" OR "mir_eval") AND ("pitch accuracy" OR "rhythm accuracy" OR "onset" OR "tolerance" OR "precision" OR "recall" OR "F-measure" OR "monophonic") AND ("music" OR "melody" OR "melodic" OR "singing" OR "pitch" OR "MIDI")],
    ),
    (
      [C3b — Evaluación automática de dictado y canto],
      [("automatic assessment" OR "automated evaluation" OR "objective evaluation" OR "computer-assisted assessment") AND ("singing" OR "sight-singing" OR "sight reading" OR "melodic dictation" OR "vocal performance" OR "ear training") AND ("pitch accuracy" OR "rhythm accuracy" OR "intonation" OR "feedback" OR "scoring" OR "note-level")],
    ),
    (
      [C4a — Transcripción musical automática],
      [("automatic music transcription" OR "polyphonic note transcription" OR "multipitch estimation" OR "singing transcription" OR "singing voice transcription" OR "vocal melody extraction" OR "monophonic pitch tracking" OR "audio to MIDI") AND ("lightweight" OR "real-time" OR "in-browser" OR "note onset detection" OR "note-level" OR "singing" OR "monophonic")],
    ),
    (
      [C4b — Transcripción e inferencia en navegador],
      [("music transcription" OR "pitch detection" OR "audio to MIDI" OR "pitch tracking") AND ("in-browser" OR "web audio" OR "TensorFlow.js" OR "client-side" OR "JavaScript" OR "web application")],
    ),
  ),
)]

Dos limitaciones de exportación afectaron la descarga de resultados y fueron resueltas dividiendo cada búsqueda por año de publicación: Scopus limita la exportación de resultados a 2000 registros por búsqueda y IEEE Xplore a 1000. Semantic Scholar impone límites de tasa que requirieron pausas y reintentos automáticos entre consultas. Estas desviaciones respecto de la cadena canónica se documentan en el registro de búsqueda.

=== 2.4.3. Selección de estudios

La Figura 1 muestra el proceso de selección conforme al diagrama de flujo de PRISMA 2020. Los resultados de cada fuente se normalizaron a un esquema común de columnas (título, autores, año, abstract, palabras clave, DOI) y se concatenaron. Se eliminaron los duplicados, primero por DOI y, cuando no estaba disponible, por título normalizado y año de publicación. La selección posterior se realiza en cuatro etapas: (1) exclusión mecánica de estudios publicados en 2021 o antes, sin título ni abstract, o en idiomas distintos al inglés o español; (2) prefiltrado temático sobre título, abstract y palabras clave, que conserva los registros con términos del dominio musical; (3) lectura del título y el abstract de cada registro restante, aplicando los criterios de inclusión y exclusión con registro del motivo de cada decisión; y (4) verificación del método descrito en el texto completo de los candidatos de acceso abierto, para confirmar que sea replicable. El número de estudios incluidos se determina por la aplicación de los criterios, no por un cupo fijo.

#block(breakable: false)[
  #leyenda([Figura], 1, [Proceso de búsqueda y selección de estudios conforme a PRISMA 2020])
  #align(center)[
  #set text(size: 8pt)
  #diagram(
    node-stroke: 0.7pt, edge-stroke: 0.7pt, node-corner-radius: 3pt, mark-scale: 70%,
    spacing: (5.6cm, 1.65cm),
    caja-c4(0, 0, [Registros identificados #linebreak() en 4 fuentes (n = 5232)]),
    caja-c4(0, 1, [Registros únicos tras #linebreak() deduplicación (n = 4759)]),
    caja-c4(0, 2, [Cribado por año e idioma #linebreak() (etapa 1) (n = 4599)]),
    caja-c4(0, 3, [Cribado temático #linebreak() (etapa 2b) (n = 656)]),
    caja-c4(0, 4, [Cribado de título y abstract #linebreak() (etapa 3) (n = 448)]),
    caja-c4(0, 5, [Texto completo #linebreak() (etapa 4) (n = 76)]),
    caja-c4(0, 6, [Estudios incluidos #linebreak() en la síntesis (n = 76)], fill: rgb("#dcfce7")),
    caja-c4(2, 2, [Excluidos (n = 160): #linebreak() año ≤ 2021 o idioma], fill: rgb("#fee2e2")),
    caja-c4(2, 3, [Excluidos (n = 3943): #linebreak() sin señal musical #linebreak() o tipo documental], fill: rgb("#fee2e2")),
    caja-c4(2, 4, [Excluidos (n = 208): #linebreak() fuera de alcance #linebreak() o sin método replicable], fill: rgb("#fee2e2")),
    caja-c4(2, 5, [Excluidos (n = 372): #linebreak() acceso cerrado (246) / #linebreak() informe no recuperado (126)], fill: rgb("#fee2e2")),
    edge((0, 0), (0, 1), "->"),
    edge((0, 1), (0, 2), "->"),
    edge((0, 2), (0, 3), "->"),
    edge((0, 3), (0, 4), "->"),
    edge((0, 4), (0, 5), "->"),
    edge((0, 5), (0, 6), "->"),
    edge((0, 2), (2, 2), "->"),
    edge((0, 3), (2, 3), "->"),
    edge((0, 4), (2, 4), "->"),
    edge((0, 5), (2, 5), "->"),
  )
  ]
]

=== 2.4.4. Extracción de datos y síntesis

Por cada estudio incluido se extraen las técnicas implementadas en la propuesta de solución, el dataset utilizado para el entrenamiento de los modelos pertinentes o la población de interés en el caso de estudios que no utilizaron modelos de aprendizaje automático, los resultados obtenidos, las limitaciones reportadas y el research gap identificado. Dado que los estudios abordan clusters de naturaleza distinta y no se busca estimar un efecto común, la síntesis es narrativa: los estudios se agrupan por cluster y se comparan según la técnica aplicada, el nivel de detalle del método y su pertinencia para el diseño del sistema propuesto. Los estudios seleccionados se listan en el Anexo A.

=== 2.4.5. Síntesis del estado del arte

La síntesis de los estudios incluidos se organiza por los cuatro clusters de búsqueda. Para cada uno se describen los enfoques predominantes, los resultados representativos, las limitaciones observadas y el hueco que la propuesta de esta tesis busca cubrir. El detalle técnico de cada estudio (técnicas, datasets, resultados y brechas) se recoge en el Anexo A.

*Juegos y educación musical (C1).*

El corpus revisado evidencia que la investigación sobre juegos y plataformas de entrenamiento auditivo asistido por computadora es aún escasa y se concentra en el diseño de experiencias individuales con gamificación de superficie. El antecedente más directo es el juego de ear training técnico de (Kim et al., 2023), una plataforma gamificada de cuatro módulos (identificación espectral, localización auditiva, consistencia y memoria de mezcla) implementada en Unity con secuenciación adaptativa por niveles, incentivos tipo star tokens y retroalimentación inmediata mediante un bucle audiomotor cerrado, cuya dificultad se regula con tablas explícitas de parámetros por nivel (ganancias de filtro, número de fuentes, radios de tolerancia). En una línea complementaria orientada al videojuego, (Amaral et al., 2022) proponen una arquitectura de generación musical adaptativa basada en un Transformer que modula la intensidad y el carácter de la música según el estado del juego y las emociones del jugador (modelo arousal/valence con hasta cuatro capas superpuestas), lo que ilustra cómo el contenido sonoro puede adaptarse dinámicamente a la partida. Fuera del estricto ámbito lúdico, diversos trabajos aportan piezas funcionales para la retroalimentación pedagógica que un juego de entrenamiento auditivo requiere: (Zhang et al., 2025) desarrollan un coach basado en un modelo de lenguaje que genera evaluación y comentarios formativos sobre la interpretación musical; (Kumar et al., 2026) proponen la detección y el análisis automático de errores de canto en tareas de aprendizaje por imitación; y (Andono et al., 2022) clasifican la dificultad de melodías a partir de patrones frecuentes y distancias entre notas, aportando un mecanismo de adaptación de dificultad directamente utilizable en la secuenciación de niveles.

En cuanto a los resultados representativos, (Kim et al., 2023) reportan que el grupo entrenado durante catorce semanas exclusivamente con el juego mejoró significativamente frente al grupo de referencia en la tarea más difícil (comprensión de habla de fondo colocalizada, ANOVA F(2,79) = 6,35, p = 0,003) y respondió con mayor rapidez en las condiciones separadas, con una transferencia del beneficio a una habilidad no entrenada (habla en ruido), lo cual respalda la eficacia del bucle de práctica gamificada con retroalimentación inmediata. En el terreno de la retroalimentación automática, (Zhang et al., 2025) muestran que su modelo supera a otros sistemas de lenguaje-audio en métricas objetivas (MAE 0,97 en escala de 6 puntos) y que sus sugerencias obtienen valoraciones significativamente más altas en un estudio con estudiantes y docentes, lo que demuestra el valor pedagógico del feedback textual formativo frente a la puntuación sumativa. (Kumar et al., 2026) alcanzan F1 con collar de tolerancia del 82,5 \% al 88,1 \% en errores de frecuencia y alrededor del 91 \% en amplitud, y observan que los collars de tolerancia mejoran las métricas por marco, aunque la transferencia entre docentes degrada el rendimiento por diferencias en los criterios de error (12 frente a 22 cents). Por su parte, (Andono et al., 2022) logran un 82 \% de exactitud en la clasificación de dificultad melódica frente al criterio experto, y (Biesinger et al., 2025) demuestran la viabilidad de un análisis espectral de baja latencia (aproximadamente 0,31 µs por muestra y menos del 2 \% de CPU) apto para dar respuesta auditiva o visual inmediata durante la ejecución en vivo, condición técnica indispensable para juegos de dictado o repentización.

No obstante, el estado del arte revela limitaciones y brechas consistentes. Desde la perspectiva lúdica, ni (Kim et al., 2023) ni (Amaral et al., 2022) incluyen mecánicas multijugador reales: la práctica es individual, no existe intercambio de producciones ni de contenido generado por los jugadores entre rondas, y la gamificación se reduce a incentivos y niveles sin dinámicas sociales ni competitivas colaborativas. Además, el juego de (Kim et al., 2023) opera en el dominio de la ingeniería de audio (no melódico), con una muestra muy pequeña (cuatro participantes de tratamiento y cuatro de control) y sin evaluación nota a nota, mientras que la arquitectura de (Amaral et al., 2022) es un proof of concept sin métricas perceptuales ni cuantitativas y con integración en un juego real aún pendiente. En el plano de la evaluación automática, (Zhang et al., 2025) reconocen que su feedback carece de localización temporal del error (no señala compás o pulso), limitando su accionabilidad pedagógica; (Kumar et al., 2026) documentan que la anotación de errores es subjetiva y dependiente del docente, que solo se modelan frecuencia y amplitud (no timing) y que las métricas a nivel de evento siguen siendo bajas; y (Andono et al., 2022) validan su clasificador solo sobre un conjunto de 50 piezas del repertorio gamelan, sin parámetros psicofísicos del aprendiz. En síntesis, el gap transversal es la ausencia de plataformas de entrenamiento auditivo en el dominio melódico (dictado y repentización) que combinen evaluación nota a nota, retroalimentación formativa localizada y, sobre todo, mecánicas multijugador con intercambio real de contenido producido por los propios jugadores.

El insight para el presente trabajo es doble. Por un lado, los estudios revisados respaldan decisiones de diseño centrales del juego propuesto: la retroalimentación inmediata tras cada intento y la secuenciación adaptativa por niveles con tablas explícitas de parámetros de dificultad (Kim et al., 2023), la combinación de métricas objetivas nota a nota con explicaciones textuales por dimensión —altura y ritmo— en lugar de un simple puntaje (Zhang et al., 2025), la evaluación con umbrales de tolerancia ajustables (collars de 80–200 ms y 12–22 cents) que refleje la percepción humana del error (Kumar et al., 2026), la puntuación procedural de dificultad basada en longitud, magnitud de intervalos y frecuencia de patrones (Andono et al., 2022) y la viabilidad de un analizador de audio en vivo de baja latencia ejecutable en navegador (Biesinger et al., 2025). Por otro lado, la mecánica diferenciadora de la tesis —el intercambio encadenado de melodías y producciones entre jugadores entre rondas, en la línea de Gartic Phone— llena un hueco que la literatura no ha cubierto: hasta ahora la gamificación del entrenamiento auditivo es superficial y estrictamente individual, sin dinámicas sociales, sin leaderboard por partida ni circulación de material musical generado por los estudiantes. Al trasladar el feedback automático inmediato a un contexto multijugador de intercambio encadenado, el juego propuesto no solo capitaliza los hallazgos sobre retroalimentación formativa y adaptación de dificultad, sino que introduce una capa de motivación social y de aprendizaje entre pares que el estado del arte del dominio aún no ha explorado.

*Generación de melodías (C2).*

El análisis del corpus permite identificar dos grandes familias de enfoques para la generación de melodías y música simbólica: los enfoques procedurales y basados en reglas —gramáticas, cadenas de Markov, sistemas dinámicos, algoritmos genéticos y métodos estadísticos ligeros— frente a los enfoques de aprendizaje automático basados en redes neuronales profundas —Transformers autorregresivos, LLM, GAN, VAE y modelos de difusión—. La primera familia, aunque minoritaria en número de publicaciones, demuestra que es posible generar material musical válido y controlable sin entrenamiento de modelos, mientras que la segunda concentra la mayor parte del esfuerzo investigador reciente y logra altos niveles de calidad perceptual a costa de la opacidad, el coste computacional y la pérdida de control paramétrico explícito. Esta dualidad resulta directamente relevante para la presente tesis, cuyo generador de melodías para dictado melódico y repentización se inscribe deliberadamente en la primera familia: generación procedural simbólica monofónica por reglas y restricciones, determinista por semilla.

Dentro de los enfoques procedurales y basados en reglas, los estudios confirman la vigencia de las cadenas de Markov, las gramáticas generativas y la codificación explícita de conocimiento musical. Kamberaj, Kadriu y Besimi (2025) combinan gramática generativa para la construcción de acordes con cadenas de Markov para las líneas de solo sobre un dataset MIDI propio, logrando que las generaciones se mantengan dentro de los parámetros del corpus (escala, octavas, tempo, compás 4/4) con sincronización exacta entre solo y acordes, y validación positiva por profesionales. En la misma línea, Raposo y Soares (2025) generan patrones rítmicos frase a frase para solos de jazz mediante cadenas de Markov de primer orden (bigrams), y demuestran que no existen diferencias estadísticamente significativas entre las frases generadas y las del conjunto de prueba (notes p=0.808; length p=0.946; pattern p=0.925), reproduciendo medias y distribuciones del corpus original. El núcleo algorítmico de MusicAIR (Liao, Liao y Zhang, 2025) prescinde por completo de redes neuronales: reglas de teoría musical determinan tonalidad, construcción rítmica y de alturas, con una confianza tonal media (correlación de Krumhansl-Schmuckler) de 0.85 frente a 0.79 de los compositores humanos y un rhythm matching del 73.6\%. Asimismo, Nakayama et al. (2024) formalizan reglas de progresión de grados y modulación (acorde pivote o compulsiva) que, aplicadas a un contexto de diseño sonoro, superan al método convencional en coincidencia con la frecuencia de pico (77.8\% vs 67.5\%; 94.9\% vs 35.9\%) y en confort percibido (3.8 vs 3.4 en escala 1–5). Otras aproximaciones procedurales amplían el repertorio de operadores: plantillas con conocimiento experto y reglas de ritmo para la generación poema-canción (Shan et al., 2023), sistemas dinámicos de la teoría KAM que producen melodías y variaciones coherentes con solo dos parámetros ajustables (Agustín-Aquino y Santiago-Santos, 2024), la codificación de transformaciones melódicas cromáticas, diatónicas y mutacionales de clara raíz pedagógica aún sin formalizar algorítmicamente (Pitombeira, 2026), gramáticas And-Or atribuidas con muestreo por modelo de energía que, con solo 3 piezas y 289 parámetros, obtienen las mejores puntuaciones subjetivas de ejecutabilidad (9.27/10) frente a modelos neuronales entrenados con millones de piezas (Qian et al., 2025), y métodos estadísticos ligeros basados en compresión LZ78 que generan secuencias monofónicas con calidad distributiva competitiva (Wasserstein 8.57 vs 27.91 de un baseline de difusión) y una velocidad de generación \~300× superior en CPU (Ding et al., 2025, LzMidi). Incluso en un sistema híbrido que integra algoritmos genéticos, cadenas de Markov y un LLM, el control de la dificultad y la validez musical se articulan mediante métricas musicales explícitas con función de fitness gaussiana sobre \~21 indicadores, alcanzando una consistencia de escala del 98.8\% (Poćwiardowski, Modrzejewski y Tatara, 2025).

En el bloque de aprendizaje automático, los Transformers autorregresivos y los LLM dominan la generación simbólica. Compose & Embellish (Wu y Yang, 2023) emplea dos Transformers con representación REMI —tokens de compás, tiempo, altura, duración, acorde y marcas explícitas de frase/repetición— y reduce a la mitad la brecha de estructura de largo alcance frente a un baseline (SI\_long 35.1 vs 29.9 vs 43.1 del corpus real), con MOS global 3.18 vs 2.33. Theme Transformer (Shih et al., 2023) condiciona la generación a material temático recuperado contrastivamente, logrando theme inconsistency 0.27 frente a 1.01 del baseline seq2seq. En el preentrenamiento masivo, PianoBART (Liang et al., 2024) alcanza 96.67\% de reconstrucción con codificación Octuple (tuplas de tiempo, tempo, compás, posición, instrumento, altura, duración y velocidad). En el terreno de los LLM, SongComposer (Ding et al., 2025) supera a GPT-4 en generación letra-melodía (PD 50.75\% vs 36.43\%; MD 2.20 vs 2.87) con tuplas de texto por nota (altura, duración, silencio), y la alineación de un LLM con cinco restricciones musicales formales (formato, letra, monotonía, duración, registro vocal) mediante preferencia DPO/KTO eleva la similaridad de distribución de alturas y duraciones (32.37/37.11 en inglés; 33.94/43.44 en chino) con un MOS de 3.42 frente a 3.50 del corpus real y una reducción drástica de violaciones de reglas (Meng et al., 2026). Cabe destacar que este último trabajo, aun siendo neuronal, formaliza validadores deterministas con umbrales configurables, lo que evidencia una tendencia a reinsertar reglas musicales verificables dentro de los propios modelos generativos.

Los modelos de difusión, VAE y GAN constituyen la tercera corriente, orientada al control fino y la calidad de textura. En difusión simbólica, MelodyDiffusion (Li y Sung, 2023) condicionada por acordes alcanza 72.41\% de Hits\@1 en restauración melódica (vs 71.78\% de un baseline de difusión estándar), y la variante VQ-VAE con difusión discreta de Zhang, Fazekas y Saitis (2024) logra un control de estilo del 72.36\% (vs 60.67\% de MusicTransformer) y un Overlapping Area medio de 0.92 sobre rasgos estadísticos (densidad de notas, rango, media y varianza de altura y duración). Su extensión Mamba-Diffusion (Zhang, Fazekas y Saitis, 2025) mejora el OA medio a 0.939 y el Chord F1 a 0.541 con preferencia subjetiva del 80.16/100. En el dominio audio, Music ControlNet (Wu et al., 2024) sigue controles temporales de melodía, dinámica y ritmo con hasta un 49\% más de fidelidad melódica que MusicGen pese a tener 35× menos parámetros, con tolerancias de evaluación explícitas (70 ms en ritmo) de directa traslación al cotejo de respuestas. En VAE, Multi-View MidiVAE (Lin et al., 2024) alcanza 0.969 de accuracy de reconstrucción global con representación OctupleMIDI, que reduce la longitud de secuencia un 75\% y multiplica por 4.57 la velocidad de inferencia. Finalmente, los GAN y los enfoques híbridos muestran tanto potencial como fragilidad: ConL2M (Zhang, Yu y Takasu, 2023) controla estilo melódico mediante atributos estadísticos interpretables (rango, media y varianza) con puntuaciones de control de 4.92/5 en distribución de altura, pero su control de contorno y patrón rítmico decae notablemente (3.63 y 3.52/5); y un GAN con atención de canal (He, 2024) obtiene la mejor puntuación de teoría musical (7.9/10 vs 6.575–6.925 de baselines) pero repite notas excesivamente en tempo lento. En conjunto, las representaciones de datos predominantes son los tokens de eventos MIDI tipo REMI/Octuple y sus extensiones modales (Chen et al., 2025), los pianorolls, la notación ABC (Zhou et al., 2025) y las tuplas de texto (altura, duración, silencio), con una clara tendencia a representar cada nota como tupla compacta para acortar las secuencias.

En cuanto a resultados y métricas, el estado del arte revela un desplazamiento desde la evaluación puramente cualitativa hacia métricas musicales interpretables, aunque sin consenso. Se emplean métricas distributivas (PD, DD, MD; Overlapping Area sobre ambitus, IOI y duración; entropía de clases de altura), métricas de estructura y coherencia (SSMD, Chroma Similarity, Grooving Similarity, Note Density Distance; Structureness Indicators), métricas de control condicional (accuracy de estilo, Chord F1, Hits\@k, melody accuracy frame a frame) y pruebas de escucha con MOS. Resultados representativos son la indistinguibilidad estadística de los patrones rítmicos de Markov frente al corpus (Raposo y Soares, 2025), la confianza tonal de MusicAIR por encima de compositores humanos (Liao, Liao y Zhang, 2025), el MOS 3.42 casi al nivel del corpus real en el LLM alineado por reglas (Meng et al., 2026), y las ganancias de eficiencia de los enfoques ligeros (Ding et al., 2025, LzMidi: entrenamiento \~30× y generación \~300× más rápidos que un baseline de difusión). Sin embargo, la evaluación objetiva de la música generada sigue siendo un problema abierto (Zhang, Fazekas y Saitis, 2025), y varios trabajos advierten que las métricas distributivas no capturan la validez nota a nota que exige la retroalimentación educativa (Ding et al., 2025, SongComposer; Huang et al., 2026).

Las limitaciones recurrentes del campo son consistentes entre familias. En los enfoques de aprendizaje automático destacan: la impredecibilidad y la dificultad de control de la generación (Amaral et al., 2022), la dependencia de datasets escasos, sesgados al compás 4/4 y a progresiones comunes (Poćwiardowski, Modrzejewski y Tatara, 2025), la pérdida de coherencia estructural de largo alcance (Wu y Yang, 2023), la acumulación de error autorregresivo, el coste computacional, la no determinabilidad de la salida y la ausencia de parámetros pedagógicos de dificultad y de generación determinista por semilla, un gap que múltiples estudios enuncian de forma explícita (Li y Sung, 2023; Lin et al., 2024; Liang et al., 2024; Wu, Liu y Fan, 2023; Yi et al., 2025). En los enfoques procedurales, en cambio, las limitaciones son de alcance: control reducido a la dimensión de altura (Agustín-Aquino y Santiago-Santos, 2024), dependencia de reglas heurísticas diseñadas manualmente, ausencia de métricas objetivas y de evaluación con usuarios finales (Kamberaj, Kadriu y Besimi, 2025), y escasez de formalización algorítmica de las transformaciones melódicas de tradición pedagógica (Pitombeira, 2026). De manera transversal, ningún trabajo del corpus genera melodías monofónicas didácticas con parámetros explícitos de dificultad y determinismo por semilla para entrenamiento auditivo, carencia que se repite como oportunidad declarada en estudios tan dispares como los de Raposo y Soares (2025), Liao, Liao y Zhang (2025), Zhang, Fazekas y Saitis (2025) y Qian et al. (2025).

El insight para la presente tesis se desprende directamente de esta evidencia. Los estudios procedurales y estadísticos muestran que los enfoques por reglas, gramáticas y cadenas de Markov generan melodías musicalmente válidas, controlables y reproducibles —con restricciones explícitas de escala, ambitus, tonalidad, compás y sincronización— con coste computacional despreciable, apto para ejecución en navegador (Kamberaj, Kadriu y Besimi, 2025; Liao, Liao y Zhang, 2025; Ding et al., 2025, LzMidi; Raposo y Soares, 2025). Asimismo, los propios trabajos neuronales respaldan decisiones de diseño trasladables a un generador por reglas: el control por atributos interpretables (rango, media y varianza de altura y duración) como parámetros de dificultad (Zhang, Yu y Takasu, 2023; Zhou et al., 2025), las marcas explícitas de frase y repetición para controlar longitud y coherencia (Wu y Yang, 2023; Shan et al., 2023), los validadores deterministas con umbrales configurables de registro, duraciones y repeticiones (Meng et al., 2026), la codificación de restricciones de bien-formación en una gramática explícita (Qian et al., 2025), la calibración de la dificultad como conjunto de métricas musicales con valores objetivo (Poćwiardowski, Modrzejewski y Tatara, 2025) y la generación como motivo base con variaciones procedurales controladas (transposición diatónica, cambios rítmicos) que escalan el reto manteniendo la reconocibilidad (Shih et al., 2023; Agustín-Aquino y Santiago-Santos, 2024). El hueco que llena el generador de esta tesis es, precisamente, el que el estado del arte deja abierto: un generador procedural monofónico, determinista por semilla, que expone parámetros pedagógicos explícitos —intervalo máximo, ambitus, tonalidad y modulación, complejidad rítmica y longitud— para producir ejercicios de dictado melódico y repentización calibrados por nivel de dificultad, validados por reglas musicales verificables y evaluables con métricas nota a nota, sin depender de modelos de aprendizaje automático opacos, no reproducibles ni desplegables en el navegador.

*Similitud y evaluación musical (C3).*

El estado del arte en evaluación y similitud musical se organiza en torno a cuatro familias de enfoques. La primera y más consolidada es la métrica nota a nota basada en precision, recall y F1 con tolerancias de matching, heredada del estándar mir\_eval y aplicada tanto a la transcripción de canto como a la comparación entre una referencia y una respuesta: Kim et al. (2025) evalúan onsets, offsets y conjuntos onset+pitch con umbrales de tolerancia explícitos, y Yong et al. (2023) descomponen la evaluación en métricas de onset (COn), offset (COff) y combinadas (COnP, COnPOff). La segunda familia corresponde al matching o emparejamiento de eventos: Lukoianov et al. (2025) emparejan onsets mediante un two-way mismatch (distancia mínima en ambos sentidos con varianza σ y tolerancia de ±40 ms en el peak-picking), un antecedente directo de la correspondencia bipartita entre notas de referencia y notas ejecutadas. La tercera familia es el alineamiento temporal flexible tipo DTW: Krause et al. (2023) proponen Soft Dynamic Time Warping como función de pérdida y métrica diferenciable que alinea secuencias con desfases temporales sin requerir correspondencias exactas. La cuarta familia aborda la evaluación automática con sentido pedagógico: la detección de errores de canto para aprendizaje por imitación (Kumar et al., 2026), la evaluación de la interpretación expresiva con retroalimentación formativa mediante modelos audio-lenguaje (Zhang et al., 2025) y la clasificación de dificultad melódica a partir de parámetros estructurales como la distancia entre notas y la frecuencia de patrones (Andono et al., 2022).

En cuanto a métricas y tolerancias representativas, los estudios convergen en un rango notablemente estrecho. Kim et al. (2025) fijan umbrales de 50 ms para onset y offset (o 20 \% de la duración en offset) y 50 cents (0,5 semitono) para la altura, y reportan F1 de 0,806 en onset, 0,771 en onset+pitch y 0,610 en la métrica nota completa sobre el dataset ST500. Yong et al. (2023) usan tolerancias equivalentes (50 y 100 ms en onset, 50 ms o 20 \% en offset, 50 cents en pitch) y alcanzan F1 de onset de 0,9305 y COnP de 0,8975, mostrando que la tolerancia de 50 ms es el umbral de facto del campo. En evaluación de errores de canto, Kumar et al. (2026) introducen collars de tolerancia de 80 ms (nivel frame) y 200 ms (nivel evento) y umbrales de error de frecuencia entre 12 y 22 cents calibrados por docente, logrando F1 con collar del 82,5–88,1 \% en errores de frecuencia y cerca del 91 \% en amplitud. En el plano rítmico, Wachter et al. (2025) evalúan onset y valor de nota como métricas independientes (onset F1 de 97,3 \% y note value accuracy de 83,3 \%), y Lukoianov et al. (2025) aplican tolerancias de 50 ms para onsets y 70 ms para compases con F1 de 96,9 \% en detección de eventos. En clasificación de dificultad, Andono et al. (2022) obtienen 82 \% de accuracy con un modelo por reglas basado en longitud de melodía, distancia entre notas consecutivas y soporte de patrones frecuentes.

En alineamiento y emparejamiento, Krause et al. (2023) demuestran que el SoftDTW iguala a las extensiones multi-etiqueta de CTC (AP de 0,737 frente a 0,734 en SWD; AP de 0,896 en Bach10 con la red mayor) para alinear secuencias solo débilmente alineadas, lo que lo convierte en una alternativa tolerante al matching exacto cuando la respuesta del jugador presenta desfases o duraciones variables respecto a la referencia. Sin embargo, el propio trabajo advierte que el alineamiento colapsa (F = 0,00) cuando la secuencia objetivo es mucho más corta que la entrada, lo que limita su uso como única estrategia de comparación. Lukoianov et al. (2025) aportan, desde el matching de onsets, una lección complementaria: el emparejamiento por distancia mínima bidireccional con tolerancia explícita produce correspondencias robustas y decodificables en patrones rítmicos legibles (F1 de 94,7 \% en la secuencia de patrones). Finalmente, Weiß et al. (2022) alertan sobre la rigurosidad metodológica de estas comparaciones: al evaluar estrategias de estimación multipitch, encuentran que la variabilidad entre corridas de entrenamiento y entre particiones train/test supera con frecuencia las diferencias atribuibles al algoritmo, por lo que cualquier métrica de similitud debe reportarse con múltiples corridas, splits limpios y validación cruzada entre datasets.

Las limitaciones y gaps del campo son consistentes entre líneas de investigación. En primer lugar, la elección de tolerancias sigue siendo empírica y dependiente del evaluador: Kumar et al. (2026) documentan que los umbrales de error aceptable varían entre docentes (12 frente a 22 cents) y que la transferencia entre evaluadores degrada el F1, lo que revela que no existe un criterio único de "nota correcta". En segundo lugar, la mayoría de los esquemas nota a nota fusionan dimensiones musicales en una sola métrica combinada (COnP, onset+pitch), y solo recientemente se han propuesto desgloses que evalúan por separado la dimensión temporal y la de altura o valor de nota (Wachter et al., 2025) o la frecuencia y la amplitud del error (Kumar et al., 2026), sin que haya consenso sobre cómo ponderarlas. En tercer lugar, la utilidad pedagógica queda sistemáticamente sin evaluar: Kim et al. (2025) reconocen la falta de estudios sobre la utilidad pedagógica de sus métricas, y Zhang et al. (2025) señalan que los sistemas de retroalimentación no localizan el error en el tiempo (compás o pulso), lo que impide generar feedback accionable. A ello se suma la escasez de datos anotados con figuras rítmicas (Kim et al., 2025), la dependencia de vocabularios curados y supuestos de tempo estable (Lukoianov et al., 2025) y la ausencia de modelos de dificultad validados fuera de contextos musicales específicos como el gamelan (Andono et al., 2022).

En materia de retroalimentación y dificultad, Zhang et al. (2025) demuestran que una rúbrica multidimensional (12 dimensiones, entre ellas altura, ritmo y tempo) combinada con feedback textual formativo supera en valoración humana a las puntuaciones globales sumativas, aunque sus propias métricas objetivas (MAE de 0,97; PFR de 0,99) exigen desglosar la evaluación por dimensión en lugar de emitir un único puntaje. Andono et al. (2022), por su parte, cuantifican la dificultad melódica como combinación de longitud, magnitud de intervalos entre notas consecutivas y frecuencia de patrones, con umbrales calibrados por expertos que permiten clasificar material en niveles básico, intermedio y avanzado. Juntos, estos estudios sugieren que la evaluación automática es pedagógicamente útil solo cuando es a la vez multidimensional, localizada y ajustada al perfil del aprendiz.

El insight para la tesis es directo y convergente. El estándar mir\_eval con métricas precision/recall/F1 nota a nota y tolerancias de 50 ms y 50 cents (0,5 semitono) está respaldado por Kim et al. (2025) y Yong et al. (2023) como esquema de evaluación exacto para comparar una melodía de referencia con la respuesta del jugador. La correspondencia bipartita máxima entre notas encuentra respaldo en el two-way mismatch con tolerancias de Lukoianov et al. (2025), mientras que el SoftDTW de Krause et al. (2023) se perfila como mecanismo complementario para absorber desfases temporales sin penalizar en exceso. La separación de dimensiones —altura y ritmo evaluados independientemente— está respaldada por la evaluación disociada de onset y valor de nota de Wachter et al. (2025) y por la separación de errores de frecuencia y de ritmo/amplitud de Kumar et al. (2026); a ello se suma la recomendación de tolerancias ajustables por perfil de evaluador (collars de 80–200 ms y umbrales de 12–22 cents), que en el juego se traduce en tolerancias configurables (0,5 semitono; 50/150 ms) y en feedback por dimensión con localización temporal (Zhang et al., 2025). El hueco que llena el analizador propuesto es, precisamente, el que la literatura identifica pero no resuelve: un sistema de evaluación nota a nota que combine matching bipartito con tolerancias explícitas en cents y milisegundos, mantenga separadas las dimensiones de altura y ritmo para una retroalimentación interpretable, y reporte su variabilidad metodológica con la rigurosidad exigida por Weiß et al. (2022), aportando evaluación pedagógica útil para dictado melódico y repentización en un entorno de videojuego web, un escenario que ninguno de los estudios revisados aborda de forma integrada.

*Transcripción musical (C4).*

El cluster de transcripción musical agrupa un cuerpo de literatura que aborda la conversión de audio en representación simbólica (pitch + onset → MIDI/partitura) desde tres frentes complementarios: (i) modelos de aprendizaje automático de gran capacidad para transcripción automática de música (AMT) polifónica y de canto; (ii) modelos ligeros orientados a tiempo real; y (iii) métodos de procesamiento digital de señales (DSP) basados en transformadas de Fourier y en pipelines de estimación de F0 seguida de decodificación de notas. En el contexto de esta tesis —un videojuego web que debe transcribir la voz monofónica del jugador en el navegador, sin servidor y con baja latencia— el examen de este corpus permite caracterizar con precisión qué logra cada familia de enfoques, dónde están los cuellos de botella del canto y qué compensación de diseño es técnicamente justificable.

Los modelos de transcripción de canto end-to-end constituyen el grupo de mayor actividad reciente. Kim et al. (2025) proponen un Transformer secuencia-a-secuencia que predice autoregresivamente tokens de onset, pitch, offset y figura rítmica directamente desde el espectrograma STFT, sin separación de fuentes, alcanzando una F1 de 0,806 en onset, 0,771 en onset+pitch y 0,610 a nivel de nota completa sobre MIR-ST500, con pseudo-etiquetado de figuras rítmicas vía beat tracking. En la misma línea, Guo et al. (2025) unifican transcripción y alineamiento de canto en un codificador jerárquico de cinco niveles que combina mel-espectrograma y contorno F0, con un COnPOff de 71,0 y una Raw Pitch Accuracy de 86,7 frente a ROSVOT (70,2/83,8). Las formulaciones basadas en visión por computadora confirman el potencial del enfoque: Wang et al. (2023) tratan cada nota como un objeto detectable sobre la imagen CQT (MusicYOLO) y reportan, sobre el dataset SSVD de lectura a primera vista, una F1 de onset del 96,17 \%, de nota (onset+pitch) del 85,92 \% y de nota con offset del 84,60 \%, con mejor generalización que los métodos frame-based. Los modelos informados por fonemas muestran además que las pistas lingüísticas ayudan justo donde el canto es difícil: Yong et al. (2023) combinan un CRNN de dos ramas (mel-espectrograma + posteriorgrama fonético) y obtienen una F1 de onset de 0,9305 y un COnP de 0,8975 en ISMIR2014, superando a TONY, Omnizart y MusicYOLO, mientras que Yamamoto (2023) demuestra que frontends auto-supervisados (MERT, MapMusic2Vec) igualan a los modelos supervisados con pocos datos etiquetados (COnP de 71,6 con MERT; COnPOff de 50,7 con MapMusic2Vec).

En el ámbito polifónico, las arquitecturas CNN/CRNN, con atención y Transformers alcanzan las métricas nota-a-nota más altas del corpus, aunque sobre instrumentos y datasets concretos. Cao et al. (2024) integran atención dual tiempo-frecuencia con redes de atención de grafos (DAFE-MSGAT) y logran una F1 de nota del 84,36 \% en MAPS y una F1 de frame del 92,79 \% en MAESTRO; Mi et al. (2024) alcanzan una F1 de onset del 97,34 \% en MAESTRO v2 y de onset+offset del 84,76 \% en v3 con convoluciones dilatadas sobre CQT; Li et al. (2025) combinan codificadores de pianoroll preentrenados con decodificación jerárquica tipo modelo de lenguaje (On Off Vel F1 de 0,832) y observan que escalar el modelo de lenguaje no mejora el rendimiento. Kim et al. (2025), con la red de fusión frecuencia-periodicidad PF2N, mejoran el Onset F1 de YMT3/YPTF en +3,3 \% en Slakh2100, y Chang et al. (2024) muestran con YourMT3+ que la aumentación cross-stem eleva la transcripción de canto sin separación de fuentes de una F1 de 3,6 \% a cerca del 64 \%. La evaluación rigurosa de estos sistemas es un asunto en sí mismo: Berendes et al. (2026) construyen el benchmark BSED y demuestran que la calidad de las anotaciones de entrenamiento decide el resultado (F1 de onset de 71,1 \% con alineación a nivel de nota frente a 36,5 \% con alineación por secuencia), dejando a BasicPitch en 24,9 \% y a YMT3+ en 42,3 \%; Weiß et al. (2022) advierten que, en estimación multipitch, la variación por aleatorización y por split supera con frecuencia la mejora atribuible a la arquitectura, y Krause et al. (2023) muestran que el alineamiento con SoftDTW permite entrenar transcriptores con pares audio-MIDI solo débilmente alineados (AP de 0,737 en SWD; 0,896 en Bach10). Estos resultados, sin embargo, se obtienen en su mayoría con modelos de millones de parámetros y evaluación offline, muy lejos de las restricciones de ejecución en navegador.

Frente a ellos, el subgrupo de modelos ligeros en tiempo real fija el estándar de eficiencia perseguible. Fernandez (2023) propone una CNN sin capas recurrentes (Onsets and Velocities) que alcanza una F1 de onset del 96,78 —estado del arte en MAESTRO v3— y de onset+velocity del 94,50 \% con unos 3,1 M de parámetros (cuatro veces menos que el baseline de regresión), corriendo en tiempo real sobre una CPU modesta (menos de 2 s de proceso para 120 s de audio), si bien su latencia práctica en la demo en vivo ronda los 4 s y el campo receptivo implicaría una latencia teórica superior a 9 s. En la misma dirección, Mi et al. (2024) logran precisión de alta resolución con 2,7 M de parámetros frente a los 20 M del baseline (y variantes de 0,9 M), y Korade et al. (2025) confirman que, para retroalimentación musical en vivo, un modelo compacto sobre espectrogramas basta (accuracy del 96 \% con AlexNet para acordes de guitarra), mientras que arquitecturas más profundas sobreajustan con datos pequeños. El patrón que emerge es claro: no se necesitan modelos masivos ni resoluciones temporales extremas (24 ms bastan), pero incluso estos modelos ligeros se evalúan como transcripción offline, y la cuestión de la latencia punta a punta en el navegador queda sin resolver.

El tercer frente lo forman los métodos DSP y los pipelines híbridos F0 + decodificación de notas. Minor et al. (2022) demuestran que la segmentación por onsets combinada con FFT por ventana es suficiente para canto monofónico: errores de pitch del 0–2,9 \% y de valor de nota del 1,6–4,2 \%, con 0 \% de notas extra, aunque el método colapsa en polifonía (50–58 \% de notas extra por armónicos). Biesinger et al. (2025) llevan el análisis espectral al tiempo real estricto con una DFT sin función de ventana y bins exponencialmente alineados a notas: 0,31 µs por muestra, menos del 2 \% de un núcleo de CPU, ventanas a la mitad de latencia y lóbulos laterales eliminados por completo. Los pipelines de estimación de F0 seguida de decodificación confirman la robustez del desacoplamiento: Bhattarai et al. (2024) estiman el F0 con un codificador-decodificador con atención sobre representación CFP y convierten la curva en notas mediante un HMM con decodificación Viterbi (estados silencio/onset/sostenido), con una puntuación de expertos de 2,32/5 comparable a la de pYIN (2,56) y superior a PyWorld (2,04); Kumar et al. (2026) resuelven la detección de errores de canto a partir de contornos de pitch (Praat) y segmentación de notas por umbral de semitonos con mediana móvil, con umbrales de tolerancia de 12–22 cents y collares de 80–200 ms. Lukoianov et al. (2025) completan el cuadro del lado de los onsets: el fine-tuning de un modelo fundacional (MERT) para detección de onsets alcanza una F1 del 96,9 \% con tolerancia de ±40 ms, y la decodificación de patrones rítmicos por Viterbi recupera la secuencia con F1 del 94,7 \%. Es significativo que los propios modelos neuronales de canto deleguen el pitch a trackers DSP: Yong et al. (2023) estiman la altura de nota con pYIN y una mediana ponderada por ventana Hann sobre el contorno F0, Guo et al. (2025) usan RMVPE para el contorno de entrada y Kumar et al. (2026) recurren a Praat.

Los recursos de datos y los protocolos de evaluación del cluster delimitan, a su vez, el margen de mejora. Liu et al. (2024) publican HumTrans, el mayor dataset de tarareo hasta la fecha (56,22 h, 14.614 grabaciones de 10 estudiantes, con MIDI de referencia como autolabels), y sus cuatro modelos baseline de transcripción vocal quedan muy lejos de lo satisfactorio (mejor F1 de 6,74 en validación con JDC-STP), lo que señala un dominio ampliamente sin resolver. Fu et al. (2022) aportan HSD, con anotación jerárquica frase-nota de calidad equivalente a MIR-ST500 (COnP de 97,07 \% a 50 ms y 98,53 \% a 100 ms), y Berendes et al. (2026) añaden BSED/BSD para transcripción orquestal. En cuanto a la evaluación, se consolida el uso de mir\_eval con tolerancias de 50 ms y 50 cents (Kim et al., 2025; Yong et al., 2023; Wang et al., 2023; Chang et al., 2024), junto con métricas invariantes a octava (Liu et al., 2024) y collares de tolerancia temporales y de altura (Kumar et al., 2026), que reflejan mejor la percepción humana del error que el matching exacto.

Las limitaciones recurrentes del corpus configuran un gap muy definido. En primer lugar, los onsets de canto son el cuello de botella declarado: Wang et al. (2023) lo formulan explícitamente («el pitch es fácil pero los onsets son el cuello de botella»), pues el portamento y el legato funden notas sucesivas; Yong et al. (2023) describen los onsets vocales como suaves y las transiciones/re-onsets como especialmente difíciles, y Kim et al. (2025) muestran que incluso con Transformers el F1 nota-a-nota completo se queda en 0,610. En segundo lugar, la escasez de datos de canto anotados limita a todos los modelos (Liu et al., 2024; Fu et al., 2022; Yamamoto, 2023). En tercer lugar, la eficiencia computacional: los sistemas más precisos son polifónicos, pesados y pensados para GPU (Chang et al., 2024; Li et al., 2025; Jung et al., 2026), y los pocos modelos ligeros logran su eficiencia en tareas de piano, no de canto (Fernandez, 2023; Mi et al., 2024). No existe, en el corpus, un transcriptor de canto monofónico ligero, de baja latencia y evaluable en el navegador: incluso BasicPitch, el modelo ligero de referencia, rinde apenas un 24,9 \% de F1 de onset en el benchmark de Berendes et al. (2026), y su despliegue vía TF.js es justamente la fuente de lentitud del prototipo actual.

El insight de diseño para esta tesis se deriva con claridad de este cuadro: existe un tradeoff estructural entre precisión bruta (modelos neuronales) y velocidad, privacidad y ejecución en navegador (DSP), y para el caso concreto del canto monofónico la balanza se inclina del lado DSP por tres razones empíricas del corpus. Primero, el pitch monofónico es un problema resuelto para los métodos DSP: Minor et al. (2022) reportan errores de pitch del 0–2,9 \% en monofónico con un simple análisis FFT por ventana, y Biesinger et al. (2025) demuestran que el análisis espectral puede ejecutarse con ventanas de \~0,125 s, latencia mínima y un coste de CPU despreciable, con bins ya alineados a notas. Segundo, los propios modelos de canto de mayor rendimiento recurren a trackers DSP para la altura: pYIN en Yong et al. (2023), RMVPE en Guo et al. (2025) y contornos de Praat en Kumar et al. (2026), es decir, la precisión de pitch atribuida a los modelos neuronales se apoya en un estimador de F0 clásico; lo que los modelos aportan de verdad es la detección de onsets y límites de nota, que es precisamente donde su F1 nota-a-nota se degrada (Wang et al., 2023; Kim et al., 2025) y donde HumTrans muestra que el dominio del canto está aún sin resolver (Liu et al., 2024). Tercero, las restricciones de la tesis —ejecución en el navegador sin servidor, privacidad del audio del usuario y baja latencia frente a la queja de lentitud de Basic Pitch/TF.js— descartan de facto los modelos polifónicos tipo Transformer/Perceiver (Chang et al., 2024; Li et al., 2025; Jung et al., 2026) e incluso aminoran la ventaja de los modelos ligeros de piano, que ni están entrenados para voz ni garantizan latencia interactiva (Fernandez, 2023). Por ello, el diseño contemplado —un tracker DSP monofónico (pYIN/YIN + detección de onsets) que convierte la voz en notas simbólicas para compararlas con la melodía de referencia— no es una simplificación ingenua sino una compensación justificada: traslada al cliente una tarea (pitch monofónico) que DSP resuelve con exactitud y coste mínimo, acepta deliberadamente el punto débil compartido por todo el campo (los onsets de canto) y llena el gap identificado en la literatura: un módulo de transcripción de canto monofónico ligero, privado y de baja latencia en el navegador, evaluado con el protocolo consolidado del cluster —matching nota a nota con tolerancias de 50 ms y 50 cents, evaluación sensible a octava y collares de tolerancia ajustables (Kim et al., 2025; Yong et al., 2023; Liu et al., 2024; Kumar et al., 2026)— y con la representación simbólica (onset, offset, pitch, duración por frase) que HSD y STARS muestran como adecuada tanto para la evaluación como para la retroalimentación al alumno (Fu et al., 2022; Guo et al., 2025).


= Capítulo III: Metodología

== 3.1. Tipo de investigación

=== 3.1.1. Nivel de investigación

Este estudio aborda las dificultades asociadas a los métodos tradicionales de entrenamiento auditivo en contextos de educación musical formal. Debido a esto, se le considera investigación aplicada: utiliza conocimiento y técnicas existentes para implementar una propuesta de solución de un problema práctico, en lugar de únicamente generar conocimiento teórico al respecto.

=== 3.1.2. Enfoque de investigación

Esta investigación posee un enfoque cuantitativo, pues la efectividad de la propuesta se mide mediante una intervención experimental de la cual se recolectarán datos numéricos. Se evalúa el desempeño en tareas de dictado y repentización musical de dos grupos de estudiantes de música: aquellos que utilizaron la plataforma propuesta durante un tiempo definido (grupo experimental) y aquellos que nunca usaron la plataforma (grupo control). Esta medición es efectuada antes y después del tiempo estipulado para el uso de la plataforma, permitiendo analizar tanto el impacto académico relativo al tiempo de uso de la plataforma (como ocurriría en un estudio pre- y post-test), como el efecto relativo al no-uso de la plataforma (para lo cual se requiere de un grupo control).

=== 3.1.3. Diseño de investigación

De acuerdo a lo previamente descrito, este diseño adopta un diseño experimental, pues involucra la implementación de un producto de software y la comparación del desempeño académico de un grupo experimental, el cual hace uso de la plataforma, y un grupo control, el cual recibe entrenamiento auditivo tradicional.

== 3.2. Metodología de ciencias del diseño

Este estudio sigue el Design Science Research Methodology (DSRM) propuesto por Peffers et al. en 2008, el cual organiza el proceso de desarrollo en una serie de seis etapas bien definidas, tal como se muestra en la Figura 2.

=== 3.2.1. Identificación del problema y motivación

Esta primera etapa consiste en identificar el problema y motivar a la búsqueda de su solución. En la presente investigación, el problema está asociado a las limitaciones del entrenamiento auditivo en el contexto de la educación musical formal. En dicho contexto, la retroalimentación sobre el trabajo de los estudiantes no se suele realizar de manera rápida, menos aún de forma inmediata. Como resultado, los estudiantes pueden presentar dificultades para mantenerse motivados por alcanzar las competencias esperadas.

Al respecto, uno de los propósitos de este estudio es proponer un enfoque de solución alternativo que aborde estas limitaciones. La revisión de literatura del capítulo anterior reveló la existencia de soluciones digitales y gamificadas para educación musical. Sin embargo, la mayoría de estos se enfocan en el desarrollo de habilidades muy concretas y aisladas entre sí. Más aún, muy pocas propuestas involucran a más de un solo jugador, generación automática de ejercicios y retroalimentación automática. Es evidente la existencia de una brecha en el diseño de soluciones que aprovechen técnicas computacionales contemporáneas.

#block(breakable: false)[
  #leyenda([Figura], 2, [Las seis fases del Design Science Research Methodology (DSRM) de Peffers et al. (2008)])
  #align(center)[#image("fig2.png", width: 100%)]
]

=== 3.2.2. Definir los objetivos para la solución

En la segunda etapa se establecen los objetivos que la solución propuesta debe satisfacer. El principal objetivo respecto a la plataforma propuesta es que su uso sea capaz de mejorar el desempeño académico de estudiantes de música en cursos de entrenamiento auditivo. En este sentido, esta plataforma debe proveer ejercicios de dictado y repentización melódica, así como un sistema que permita eva3luar automáticamente el desempeño de los jugadores en dichos ejercicios.

Desde una perspectiva técnica, la plataforma debe ser capaz de generar material melódico, en formato MIDI o algún otro formato simbólico, idóneo para su uso en ejercicios de dictado y repentización musical. También debe ser capaz de analizar la similitud de dos estructuras melódicas en formato simbólico: una de ellas correspondiendo al material recibido por el jugador; y la otra, al material producido por el jugador en respuesta. Esto con el fin de evaluar la precisión del jugador en ambos tipos de ejercicios: a mayor similitud, más fiel es su transcripción (en el caso de dictado) o interpretación (en el caso de repentización) al material recibido. Finalmente, la plataforma debe ser capaz de convertir interpretaciones musicales en formato de audio a formato simbólico para permitir el análisis de similitud descrito. Estas capacidades se implementarán mediante la integración de modelos existentes o pre-entrenados, en lugar del entrenamiento de nuevos modelos desde cero.

Desde una perspectiva pedagógica, la plataforma debe ser capaz de generar engagement en los jugadores y proveerles retroalimentación inmediata y acumulativa sobre su desempeño. Así, el resultado esperado de esta etapa es una serie de requisitos funcionales y no funcionales que definen a detalle las características de la solución propuesta y, por tanto, guiarán su diseño y desarrollo subsecuente.

=== 3.2.3. Diseño y desarrollo

La tercera etapa involucra el diseño y construcción de la plataforma con la que se desea abordar el problema identificado. En este caso, dicha plataforma es un videojuego en línea multijugador diseñado para que estudiantes de música desarrollen habilidades auditivas a través de mecánicas de juego divididas en rondas intercaladas de dictado y repentización melódica.

El proceso de diseño incluye la definición de la arquitectura del sistema, mecánicas de juego, interacciones de usuario, y el resto de componentes computacionales requeridos para implementar la funcionalidad propuesta. Se le brinda atención especial a la integración de módulos responsables de la generación automática de estructuras melódicas, análisis de similitud melódica y transcripción musical automática, siendo que, como ya fue descrito, estos componentes permiten al sistema generar ejercicios y proveer retroalimentación a los jugadores. Esta etapa culmina con la implementación de un prototipo funcional de la solución, el cual debe integrar todos los componentes necesarios para hacer uso de la mecánica principal de juego en entornos educativos controlados.

=== 3.2.4. Demostración

Una vez la propuesta ha sido desarrollada, la cuarta etapa requiere demostrar su viabilidad para resolver el problema identificado. Durante esta etapa se busca demostrar que el sistema propuesto puede ser usado en el contexto para el que fue diseñado. La demostración consistirá en la implementación del videojuego desarrollado y la realización de sesiones de juego con estudiantes de música. Durante estas sesiones, los participantes interactuarán con el sistema realizando ejercicios de dictado melódico y lectura a primera vista, mientras que la plataforma generará ejercicios, registrará las respuestas y evaluará el rendimiento de forma automática. El objetivo de esta actividad no es medir la eficacia, sino demostrar la viabilidad de la solución propuesta y verificar que el artefacto implementado puede respaldar con éxito el flujo de trabajo previsto durante la fase de diseño.

=== 3.2.5. Evaluación

La quinta actividad se centra en evaluar en qué medida el artefacto cumple los objetivos definidos anteriormente. Para ello, el estudio llevará a cabo una evaluación experimental en la que participarán tanto un grupo de control como un grupo experimental.

Los participantes asignados al grupo experimental realizarán actividades de entrenamiento utilizando el videojuego propuesto, mientras que los participantes del grupo de control recibirán instrucción mediante métodos de entrenamiento convencionales. Ambos grupos serán sometidos a evaluaciones equivalentes antes y después de la intervención, lo que permitirá comparar los resultados de aprendizaje en ambas condiciones.

Los datos recopilados se analizarán para determinar si el sistema propuesto produce mejoras cuantificables en las habilidades auditivas objetivo. Además de evaluar la eficacia educativa, los resultados obtenidos durante esta actividad proporcionarán evidencia sobre la utilidad práctica de los mecanismos computacionales integrados en el artefacto.

=== 3.2.6. Comunicación

La actividad final de la metodología de investigación en ciencia del diseño consiste en comunicar el problema abordado, el artefacto propuesto, el proceso de desarrollo y los resultados obtenidos a los públicos pertinentes.

En el contexto de este estudio, la comunicación se lleva a cabo mediante la elaboración del presente documento de tesis. El documento describe el problema de investigación, los fundamentos teóricos que sustentan la propuesta, el diseño y la implementación del artefacto, y los resultados obtenidos durante su evaluación. A través de este proceso, el conocimiento generado durante la investigación queda a disposición de futuros estudios en los campos de la educación musical, la tecnología educativa y la informática.

Los hallazgos recogidos en este trabajo también pueden servir de base para futuros desarrollos relacionados con entornos colaborativos de aprendizaje musical, la evaluación musical automatizada y la aplicación de técnicas de música computacional a contextos educativos.

== 3.3. Objetivos de la evaluación

De acuerdo con la metodología de investigación en ciencia del diseño (DSRM) adoptada en este estudio, la etapa de evaluación tiene como propósito determinar en qué medida el artefacto desarrollado satisface los objetivos definidos durante la segunda actividad de la metodología. En consecuencia, la presente investigación no plantea hipótesis de investigación en el sentido tradicional de los estudios explicativos, sino que orienta su proceso de evaluación a obtener evidencia empírica sobre la utilidad del artefacto propuesto para abordar el problema identificado. En este contexto, la evaluación busca determinar si el videojuego desarrollado (variable independiente) constituye una herramienta efectiva para apoyar el desarrollo de habilidades auditivas en estudiantes de música dentro de un contexto de educación musical formal (variable dependiente). Para ello, se comparará el desempeño de estudiantes que utilicen la plataforma propuesta con el de estudiantes que reciban entrenamiento mediante métodos convencionales.

== 3.4. Población de estudio

La población de estudio estará conformada por estudiantes que cursan programas de formación musical en una institución educativa especializada en enseñanza musical. Dichos estudiantes participan regularmente en actividades formales orientadas al desarrollo de habilidades auditivas, incluyendo ejercicios de reconocimiento melódico, dictado musical y entrenamiento del oído. Así, se asume que los estudiantes poseen conocimientos básicos de teoría musical y experiencia previa en actividades de entrenamiento auditivo, condiciones necesarias para la utilización y evaluación del videojuego propuesto.

== 3.5. Selección de muestra

La muestra estará conformada por un subconjunto de estudiantes pertenecientes a la población de estudio que cumplan con los criterios establecidos para participar en la investigación. La selección se realizará mediante un muestreo no probabilístico por conveniencia, considerando la disponibilidad de los participantes y su disposición para formar parte de las actividades de evaluación de la propuesta. La cantidad final de participantes será determinada de acuerdo con la disponibilidad de estudiantes durante el periodo de ejecución de la investigación.

== 3.6. Unidad de análisis

La unidad de análisis corresponde a cada estudiante participante de la investigación. Sobre cada uno de ellos se recopilarán los datos necesarios para evaluar el efecto de la propuesta, concretamente, las métricas registradas durante la interacción con el videojuego.

== 3.7. Técnicas de recolección de datos

Para la recolección de datos se empleará la técnica de evaluación mediante pruebas de desempeño, aplicadas a los participantes antes y después de la intervención educativa. Estas evaluaciones serán similares en naturaleza a aquellas propuestas por docentes de cursos formales de entrenamiento auditivo, incluyendo actividades de dictado y repentización musical. La participación será voluntaria y requerirá consentimiento informado (Anexo B), que cubre el uso de las grabaciones de voz de las tareas de repentización y su retención durante el estudio.

== 3.8. Técnicas de análisis de datos

Los datos recopilados serán procesados mediante técnicas de análisis estadístico descriptivo e inferencial. Inicialmente se emplearán medidas descriptivas, tales como promedios, frecuencias y desviaciones estándar, con el fin de caracterizar el desempeño de los participantes y resumir los resultados obtenidos durante las evaluaciones. Posteriormente, se compararán los resultados obtenidos por el grupo experimental y el grupo de control en las evaluaciones realizadas antes y después de la intervención, con el propósito de determinar el grado de cumplimiento de los objetivos definidos para la solución propuesta. Para ello se utilizarán pruebas estadísticas apropiadas según la naturaleza y distribución de los datos recolectados

// ============ Capítulo IV ============
// Estilo: el capítulo sigue el registro del capítulo de desarrollo de Freire
// (2025): exposición en presente y pasado, tablas y figuras propias, sin
// citas externas adicionales. Las secciones marcadas con PLACEHOLDER describen
// el diseño de la versión completa y deberán reescribirse cuando exista
// implementación y evidencia empírica. Ver docs/context.md, sección 21.

= Capítulo IV: Desarrollo de la propuesta

El presente capítulo documenta el diseño y la construcción del artefacto propuesto, correspondiente a la tercera actividad del Design Science Research Methodology (DSRM): diseño y desarrollo (Peffers et al., 2008). La exposición se organiza en once secciones que recorren el enfoque de desarrollo, la arquitectura, el modelo de dominio musical, el generador procedural, el evaluador de similitud, la transcripción automática, las mecánicas de juego, la persistencia, la interfaz, las pruebas técnicas y la síntesis del capítulo.

El capítulo distingue entre el prototipo funcional, que implementa el núcleo individual del videojuego, y la especificación de la versión multijugador completa. Esta distinción responde a la naturaleza iterativa del DSRM: el núcleo musical y de interacción se construyó y verificó primero, y sobre esa base se definió la mecánica multijugador. En las figuras de arquitectura y de flujo, los componentes de la versión completa se representan con trazo discontinuo o con relleno diferenciado; en el texto, se emplea el verbo *implementar* únicamente para los componentes construidos y verificados, y el verbo *definir* o *especificar* para los que forman parte del diseño de la versión completa.

== 4.1. Enfoque de desarrollo y alcance del artefacto

=== 4.1.1. Posición dentro del DSRM

El DSRM organiza la investigación en seis actividades: identificación del problema y motivación, definición de objetivos para la solución, diseño y desarrollo, demostración, evaluación y comunicación (Peffers et al., 2008). El presente capítulo se ubica en la tercera actividad. Las actividades de demostración y evaluación se abordan en el capítulo III, en la medida en que definen el protocolo experimental, y en el capítulo V, donde se reportan los resultados.

La construcción del artefacto no siguió una secuencia lineal. Durante la implementación surgieron hallazgos que obligaron a revisar decisiones de diseño: la lentitud del primer prototipo de transcripción, basado en un modelo de TensorFlow.js ejecutado en el navegador, motivó su sustitución por un tracker DSP monofónico (sección 4.6); el ruido tonal por debajo del registro cantado produjo notas espurias, lo que llevó a acotar el rango de frecuencia del transcriptor (75–1500 Hz); y la diferencia entre los ataques introducidos sobre una rejilla y los ataques producidos por el transcriptor obligó a separar las tolerancias de dictado y de canto. Estos retornos a la actividad de diseño son consistentes con el DSRM, que se concibe como un modelo nominal y no como una secuencia rígida.

// Extracto clave de Peffers et al. (2008), manuscrito, p. 1117:
// «we are suggesting that the DSRM should not be used as a rigid orthodoxy
// to criticize work that does not follow it explicitly».

=== 4.1.2. Estrategia de construcción

La construcción se organizó en incrementos verticales. Cada incremento incorporó una capacidad completa —dominio, persistencia, interfaz y pruebas— y mantuvo la aplicación ejecutable. El orden fue el siguiente: primero el dominio musical, después la persistencia, luego la interfaz de dictado, a continuación la transcripción y la interfaz de repentización, y finalmente la integración y el resumen de la partida. Los incrementos posteriores añadieron el modo multijugador con intercambio encadenado de producciones, la galería final y el módulo docente con salones de clase y espectación. Esta secuencia redujo el riesgo de mezclar errores musicales con errores de red, de persistencia o de interfaz.

Desde el punto de vista de la ingeniería de software, el desarrollo adoptó las siguientes prácticas:

#listasin[
  + *Separación de capas.* El dominio musical (`src/lib/music`) no depende de React, de Next.js ni de Payload. Recibe y devuelve estructuras tipadas, lo que permite probarlo sin navegador y sin base de datos.
  + *Tipado estricto.* La aplicación se implementó en TypeScript con comprobación estricta, incluyendo los tipos canónicos de melodía, los resultados de evaluación y los mensajes del Web Worker.
  + *Pruebas automatizadas.* El generador, el evaluador y los parámetros de transcripción se cubrieron con pruebas unitarias de Vitest. Las pruebas de humo y el barrido de parámetros se ejecutaron con scripts independientes.
  + *Reproducibilidad.* El generador es determinista a partir de una semilla y un conjunto de parámetros; la versión del generador y los parámetros de inferencia se registran junto con los datos que producen.
  + *Entorno reproducible.* PostgreSQL y la aplicación se levantan con Docker Compose, de modo que la configuración local no depende de instalaciones manuales.
  + *Decisiones registradas.* Las decisiones de diseño con impacto estructural se documentaron antes de implementarlas. La Tabla 3 resume las principales.
]

#block(breakable: false)[
#leyenda([Tabla], 3, [Decisiones de diseño y alternativas consideradas])
#apatable(
  columns: (3.4cm, 5.5cm, 7cm),
  header: ([*Decisión*], [*Alternativa considerada*], [*Criterio de selección*]),
  rows: (
    ([Generación procedural por reglas], [Modelo generativo entrenado], [Control explícito de intervalo, ambitus, ritmo, tonalidad y longitud; determinismo y bajo costo computacional.]),
    ([Comparador propio], [Dependencia de `mir_eval`], [No existe una implementación JavaScript equivalente; el comparador propio permite fijar tolerancias y devolver los pares emparejados.]),
    ([Transcripción con tracker DSP], [Servicio externo de transcripción o modelo preentrenado], [Inferencia local en el navegador (YIN + onsets); no se transfiere audio ni se requiere modelo ni GPU del servidor.]),
    ([Piano roll], [Pentagrama], [Permite aislar altura y ataque; reduce la influencia de la lectoescritura en la medición de habilidades auditivas.]),
    ([Payload CMS], [Backend propio], [Autenticación, colecciones, administración y API disponibles sin desarrollar un backend desde cero.]),
    ([Modelo monofónico], [Modelo polifónico], [Los ejercicios son melódicos; el emparejamiento uno a uno es suficiente y verificable.]),
    ([Inferencia en cliente], [Inferencia en servidor], [Menor transferencia de datos personales y menor carga para la aplicación Next.js.]),
    ([Sincronización por sondeo], [Proveedor de tiempo real administrado o servidor WebSocket propio], [Alternativa más simple para el prototipo, sin servicios externos; el backend sigue siendo la autoridad del estado y la sustitución del transporte no afecta a las reglas de juego.]),
  ),
)]

=== 4.1.3. Alcance y trazabilidad

El prototipo implementa el flujo completo del juego: acceso y cuentas, salas multijugador por código, configuración de la partida, generación de melodías, rondas alternadas de dictado y repentización con transcripción, intercambio encadenado de producciones entre jugadores, evaluación en el servidor, galería final, historial del estudiante y módulo docente con salones de clase, invitaciones y espectación de partidas. Las reglas de abandono y reconexión y el control de acceso a nivel de las colecciones de juego quedan especificados como diseño de la versión completa (secciones 4.7.5 y 4.8.5); la política de datos de las grabaciones de voz está definida con un alcance acotado al estudio experimental (sección 4.8.4). La Tabla 4 relaciona los objetivos específicos con las secciones del capítulo.

#block(breakable: false)[
#leyenda([Tabla], 4, [Trazabilidad entre objetivos específicos y secciones del capítulo])
#apatable(
  columns: (2cm, 4cm, 9.9cm),
  header: ([*Objetivo*], [*Sección*], [*Componente*]),
  rows: (
    ([OE1], [4.3 y 4.4], [Modelo de dominio musical y generador procedural de melodías.]),
    ([OE2], [4.5], [Evaluador de similitud melódica.]),
    ([OE3], [4.2 y 4.6 a 4.9], [Arquitectura, transcripción, mecánicas de juego, persistencia e interfaz.]),
    ([OE4], [Capítulos III y V], [Diseño experimental y validación pedagógica.]),
  ),
)]

La Figura 3 presenta los casos de uso del sistema. Las relaciones discontinuas representan inclusiones entre casos de uso; la distinción entre lo implementado y lo especificado se desarrolla en las secciones siguientes. La figura permite observar que el núcleo del sistema es la tríada formada por la generación de melodías, la evaluación de similitud y la transcripción de audio, y que las actividades de juego se apoyan en ella.

#block(breakable: false)[
#leyenda([Figura], 3, [Casos de uso del sistema de entrenamiento auditivo])
#align(center)[
#set text(size: 8.5pt)
#diagram(
  node-stroke: 0.7pt, edge-stroke: 0.7pt, node-corner-radius: 3pt, mark-scale: 70%,
  spacing: (1.3cm, 0.75cm),
  caja-c4(0, 0, [Estudiante], fill: rgb("#f1f5f9")),
  caja-c4(0, 1.6, [Docente], fill: rgb("#f1f5f9")),
  caja-c4(0, 3.2, [Administrador], fill: rgb("#f1f5f9")),
  pastilla-c4(2.8, 0, [Configurar partida]),
  pastilla-c4(2.8, 0.8, [Realizar dictado]),
  pastilla-c4(2.8, 1.6, [Realizar repentización]),
  pastilla-c4(2.8, 2.4, [Consultar resultados]),
  pastilla-c4(2.8, 3.2, [Gestionar aula]),
  pastilla-c4(5.6, 0.4, [Generar melodía], fill: rgb("#f0fdf4")),
  pastilla-c4(5.6, 1.2, [Evaluar similitud], fill: rgb("#f0fdf4")),
  pastilla-c4(5.6, 2.0, [Transcribir audio], fill: rgb("#f0fdf4")),
  edge((0,0), (2.8,0), "->"),
  edge((0,0), (2.8,0.8), "->"),
  edge((0,0), (2.8,1.6), "->"),
  edge((0,0), (2.8,2.4), "->"),
  edge((0,1.6), (2.8,2.4), "->"),
  edge((0,1.6), (2.8,3.2), "->"),
  edge((0,3.2), (2.8,3.2), "->"),
  edge((2.8,0), (5.6,0.4), "->", stroke: (dash: "dashed")),
  edge((2.8,0.8), (5.6,0.4), "->", stroke: (dash: "dashed")),
  edge((2.8,0.8), (5.6,1.2), "->", stroke: (dash: "dashed")),
  edge((2.8,1.6), (5.6,1.2), "->", stroke: (dash: "dashed")),
  edge((2.8,1.6), (5.6,2.0), "->", stroke: (dash: "dashed")),
)
]
]

== 4.2. Arquitectura del sistema

=== 4.2.1. Vista de componentes

La arquitectura se organiza en tres capas. La primera es la interfaz web, construida con Next.js y React, que contiene el piano roll, los controles de reproducción y grabación y el Web Worker de transcripción. La segunda es el dominio musical, implementado en TypeScript con apoyo de Tonal, que contiene el modelo canónico de melodía, el generador procedural y el evaluador de similitud. La tercera es la capa de persistencia, formada por la API de Payload y PostgreSQL.

La dependencia entre capas es unidireccional: la interfaz depende del dominio y de la API; el dominio no depende de la interfaz ni de la base de datos. Esta separación permite que el generador y el evaluador se ejecuten en pruebas unitarias sin navegador y sin conexión a PostgreSQL, y permite reemplazar la interfaz sin modificar la lógica musical. La Figura 4 muestra los componentes y sus relaciones.

#block(breakable: false)[
#leyenda([Figura], 4, [Arquitectura de componentes del sistema])
#align(center)[
#set text(size: 8.5pt)
#diagram(
  node-stroke: 0.7pt, edge-stroke: 0.7pt, node-corner-radius: 3pt, mark-scale: 70%,
  spacing: (1.5cm, 0.8cm),
  caja-c4(0, 0, [Interfaz web #linebreak() Next.js]),
  caja-c4(0, 1.0, [Piano roll]),
  caja-c4(0, 2.0, [Reproducción #linebreak() y grabación]),
  caja-c4(0, 3.0, [Web Worker #linebreak() transcripción]),
  caja-c4(3.0, 1.0, [Dominio musical #linebreak() Tonal], fill: rgb("#f0fdf4")),
  caja-c4(3.0, 2.6, [Transcripción #linebreak() tracker DSP], fill: rgb("#f0fdf4")),
  caja-c4(6.0, 0, [API de Payload]),
  caja-c4(6.0, 1.2, [PostgreSQL]),
  caja-c4(6.0, 2.4, [Almacenamiento #linebreak() de audio], fill: rgb("#fafafa")),
  caja-c4(6.0, 3.6, [Tiempo real #linebreak() (diseño)], fill: rgb("#fafafa")),
  edge((0,0), (3.0,1.0), "->", label: [invoca]),
  edge((0,1.0), (3.0,1.0), "->"),
  edge((0,2.0), (3.0,1.0), "->"),
  edge((0,0), (6.0,0), "->", label: [consulta]),
  edge((0,3.0), (3.0,2.6), "->", label: [transcribe]),
  edge((3.0,2.6), (3.0,1.0), "->", label: [devuelve #linebreak() notas]),
  edge((6.0,0), (6.0,1.2), "->"),
  edge((6.0,0), (6.0,2.4), "->", stroke: (dash: "dashed")),
  edge((6.0,0), (6.0,3.6), "->", stroke: (dash: "dashed")),
)
]
]

=== 4.2.2. Stack tecnológico

La Tabla 5 resume las tecnologías empleadas y su función. Las versiones se consignan porque afectan la reproducibilidad de los resultados: una actualización de Tonal puede alterar la construcción de escalas, y los parámetros del tracker de transcripción (Tabla 14) determinan su salida.

#block(breakable: false)[
#leyenda([Tabla], 5, [Stack tecnológico y versiones])
#apatable(
  columns: (3.8cm, 2.2cm, 4.6cm, 5.3cm),
  header: ([*Tecnología*], [*Versión*], [*Función*], [*Criterio de selección*]),
  rows: (
    ([Next.js], [16.3.4], [Aplicación web y rutas de API], [Integración con React y despliegue unificado.]),
    ([React], [19.2.0], [Interfaz de usuario], [Ecosistema y componentes reutilizables.]),
    ([TypeScript], [5.9.2], [Tipado del dominio y de la interfaz], [Detección temprana de errores.]),
    ([Payload CMS], [3.88.0], [Colecciones, autenticación y API], [Administración y persistencia sin backend propio.]),
    ([PostgreSQL], [Contenedor Docker], [Base de datos relacional], [Integridad y consultas estructuradas.]),
    ([Tonal], [6.5.1], [Teoría musical: notas, escalas e intervalos], [Cobertura de operaciones tonales en JavaScript.]),
    ([Tracker DSP (YIN + onsets)], [propio], [Transcripción de audio a notas], [Implementación TypeScript propia (YIN, flujo espectral y segmentación) ejecutable en navegador, sin dependencias de aprendizaje automático.]),
    ([Vitest], [5.1.0], [Pruebas unitarias], [Integración con el ecosistema Vite y TypeScript.]),
    ([Docker Compose], [—], [Entorno local reproducible], [Aislamiento de PostgreSQL y de la aplicación.]),
  ),
)]

=== 4.2.3. Organización del repositorio

El repositorio se organiza por responsabilidad, no por tipo de archivo. La Tabla 6 describe los directorios principales. Esta organización facilita la localización de los componentes y refuerza la separación entre dominio, interfaz y persistencia.

#block(breakable: false)[
#leyenda([Tabla], 6, [Organización del repositorio y responsabilidades])
#apatable(
  columns: (4.2cm, 11.7cm),
  header: ([*Directorio*], [*Responsabilidad*]),
  rows: (
    ([`app/(frontend)`], [Interfaz: acceso, lobby, sala, ejercicios, galería, historial y vistas docentes.]),
    ([`app/(payload)`], [Panel administrativo y rutas de Payload.]),
    ([`app/api`], [Endpoints de juego, salones e invitaciones con validación en servidor.]),
    ([`src/lib/music`], [Dominio musical: tipos canónicos, validación, generador, evaluador e informe de errores.]),
    ([`src/lib/game`], [Reglas de partida, agregación de métricas, feedback, orquestación de servidor y consultas docentes.]),
    ([`src/lib/transcription`], [Captura, normalización, protocolo, tracker DSP (YIN + onsets) y Web Worker.]),
    ([`src/lib/audio`], [Grabación con `MediaRecorder` y reproducción con Web Audio.]),
    ([`src/collections`], [Colecciones `Users`, `GameRooms`, `Submissions`, `Media`, `Classrooms` y `ClassroomInvitations`.]),
    ([`scripts`], [Pruebas de humo y barrido de parámetros de transcripción.]),
  ),
)]

=== 4.2.4. Comunicación y despliegue

En el prototipo, la aplicación Next.js sirve la interfaz y las rutas de API; Payload expone la API de las colecciones y el panel administrativo; PostgreSQL almacena los datos estructurados. El audio no sale del navegador: se captura con `MediaRecorder`, se decodifica con Web Audio y se procesa en un Web Worker con el tracker DSP, sin servir ningún modelo.

La sincronización multijugador del prototipo se resuelve por sondeo (polling) de aproximadamente 1,2 s contra la base de datos a través de la API de Payload, sin proveedor externo. El backend es la autoridad del estado de la partida (sección 4.7.3); el sondeo solo distribuye cambios a los clientes, de modo que una recarga de página recupera el estado completo y un cliente desconectado no afecta a la partida. Esta es la alternativa más simple de integrar para la escala del prototipo y no exige cuentas ni claves de terceros. La versión completa puede sustituir el transporte por un servicio de publicación y suscripción con canales por sala y presencia, o por un servidor WebSocket propio, sin alterar las reglas de juego, que residen en el dominio y en los endpoints; el canal transportaría únicamente identificadores, estados y avisos de sincronización, mientras que las melodías, las respuestas y el audio se transfieren por la API o por almacenamiento de archivos.

=== 4.2.5. Requisitos no funcionales

Los requisitos no funcionales se tradujeron en decisiones concretas de arquitectura. La Tabla 7 resume los principales. Algunos mecanismos, como el control de acceso por rol o la retención de grabaciones, corresponden al diseño de la versión completa y se detallan en las secciones 4.8.4 y 4.8.5.

#block(breakable: false)[
#leyenda([Tabla], 7, [Requisitos no funcionales y mecanismos de diseño])
#apatable(
  columns: (3cm, 6.2cm, 6.7cm),
  header: ([*Requisito*], [*Mecanismo*], [*Efecto esperado*]),
  rows: (
    ([Usabilidad], [Piano roll, instrucciones por ronda y feedback inmediato], [Comprensión de la tarea sin conocimientos de notación.]),
    ([Rendimiento], [Inferencia en Web Worker y watchdog de 30 s], [La interfaz no se bloquea durante la transcripción.]),
    ([Seguridad], [Validación en servidor, roles de usuario y control de acceso por campo; mutaciones solo por endpoints de juego], [Evitar que el cliente altere resultados o consulte datos ajenos; pendiente el acceso a nivel de colección.]),
    ([Privacidad], [Procesamiento local del audio, lectura de `Media` restringida a usuarios autenticados y retención acotada al estudio], [Protección de las grabaciones de voz sin exposición pública.]),
    ([Trazabilidad], [`sessionSeed`, `roundNumber` y relación melodía-respuesta], [Reconstruir la cadena de una partida.]),
    ([Reproducibilidad], [Semilla, `generatorVersion` y parámetros del modelo], [Repetir una melodía o una inferencia.]),
    ([Mantenibilidad], [Dominio separado de React y de Payload], [Probar sin navegador ni base de datos.]),
    ([Compatibilidad], [Navegadores de escritorio con Web Audio y micrófono], [Verificación en Chrome durante el prototipo.]),
    ([Accesibilidad], [Controles visibles y estados textuales], [Revisión de contraste y alternativas al color (diseño).]),
  ),
)]

== 4.3. Modelo de dominio musical

=== 4.3.1. Representación canónica

El dominio musical se representa mediante estructuras independientes del formato MIDI y del audio. La estructura `NoteEvent` almacena la altura como número MIDI, el inicio y la duración en pulsos musicales. La estructura `Melody` añade el tempo, el compás, la tonalidad, la escala, las modulaciones, la dificultad, la versión del generador y la semilla. La Figura 5 muestra las relaciones entre estas estructuras y las que se emplean en la evaluación.

#block(breakable: false)[
#leyenda([Figura], 5, [Modelo de dominio musical])
#align(center)[
#set text(size: 8pt)
#diagram(
  node-stroke: 0.7pt, edge-stroke: 0.7pt, node-corner-radius: 3pt, mark-scale: 70%,
  spacing: (1.3cm, 0.9cm),
  caja-c4(0, 1.4, [Melody #linebreak() id · tempoBpm #linebreak() timeSignature · key #linebreak() scale · difficulty #linebreak() seed]),
  caja-c4(3.2, 0, [NoteEvent #linebreak() midiPitch #linebreak() onsetBeats #linebreak() durationBeats]),
  caja-c4(3.2, 2.8, [Modulation #linebreak() atNoteIndex #linebreak() key · scale]),
  caja-c4(6.4, 0, [EvaluatedNote #linebreak() midiPitch #linebreak() onsetSeconds #linebreak() durationSeconds]),
  caja-c4(6.4, 2.8, [EvaluationResult #linebreak() pitch: F1 #linebreak() rhythm: F1 #linebreak() overall]),
  edge((0,1.4), (3.2,0), "->", label: [1..\*]),
  edge((0,1.4), (3.2,2.8), "->", label: [0..\*]),
  edge((3.2,0), (6.4,0), "->", label: [convierte]),
  edge((3.2,0), (6.4,2.8), "->", label: [evalúa], bend: 20deg),
)
]
]

La decisión de almacenar los tiempos en pulsos y no en segundos responde a dos razones. Primero, los pulsos permiten representar subdivisiones como corcheas, tresillos y valores con puntillo sin acumular errores de redondeo. Segundo, la comparación rítmica se realiza sobre una rejilla musical, no sobre marcas de tiempo absolutas. La conversión a segundos se deriva del tempo cuando se reproduce una melodía o se compara con una transcripción de audio.

=== 4.3.2. Invariantes y validación

El modelo se protege mediante validaciones explícitas. La Tabla 8 resume los invariantes. La validación se aplica tanto a las melodías generadas como a las melodías recibidas desde la API o desde un archivo JSON, de modo que una estructura inválida no llega al generador ni al evaluador.

#block(breakable: false)[
#leyenda([Tabla], 8, [Invariantes del modelo de dominio musical])
#apatable(
  columns: (3.6cm, 7.5cm, 4.8cm),
  header: ([*Campo*], [*Invariante*], [*Verificación*]),
  rows: (
    ([`midiPitch`], [Entero entre 0 y 127], [`validateNote`]),
    ([`onsetBeats`], [Mayor o igual a 0], [`validateNote`]),
    ([`durationBeats`], [Mayor que 0], [`validateNote`]),
    ([Orden], [`onsetBeats` no decreciente entre notas], [`validateMelody`]),
    ([`modulations`], [`atNoteIndex` dentro del rango de notas], [`validateMelody`]),
    ([Notas], [Al menos una nota], [`validateMelody`]),
    ([Tempo y compás], [Tempo mayor que 0; compás de enteros positivos], [`validateMelody`]),
  ),
)]

=== 4.3.3. Reproducibilidad y versionado

El generador es determinista a partir de una semilla y de un conjunto de parámetros. La melodía depende de la tupla formada por la semilla, la dificultad, el tempo y el compás; no depende únicamente de la semilla. Esta precisión es relevante para la reproducibilidad: dos ejecuciones con la misma tupla producen la misma melodía, pero cambiar el tempo altera la secuencia aunque la semilla se conserve. El identificador de la melodía se deriva de un hash de la misma tupla, y la versión del generador se almacena junto con la melodía para distinguir resultados producidos por versiones distintas.

== 4.4. Generador procedural de melodías

=== 4.4.1. Requisitos y parámetros de dificultad

// Extracto clave de Pesek et al. (2020a), sección «Automatic generation of exercises»:
// «We developed a sequence generation algorithm, which considers several aspects
// of sequence complexity: the length of sequence, the size of intervals,
// and the frequency of interval occurrences.»

El generador produce ejercicios de dictado y repentización con restricciones musicales explícitas. Se optó por un enfoque algorítmico, en lugar de entrenar un modelo de generación, porque los ejercicios requieren control directo sobre el intervalo entre notas, la tonalidad, el registro, el ritmo y la longitud, y porque el mismo conjunto de parámetros debe producir melodías reproducibles. La decisión sigue un principio similar al de Troubadour, donde las secuencias se generan a partir de la longitud y de la distribución de intervalos para producir ejercicios con distintos niveles de dificultad (Pesek et al., 2020a).

La Tabla 9 define los tres niveles de dificultad, reformulada según el estado del arte (sección 2.4.5, cluster de generación): los ejes de dificultad siguen a Poćwiardowski et al. (2025) —longitud, magnitud de intervalo y frecuencia de patrones (aquí, penalización de la repetición)— y se complementan con la tesitura cantable de MusicAIR (Liao et al., 2025), la estructura de frases (Raposo y Soares, 2025; Wu y Yang, 2023) y los validadores deterministas de Meng et al. (2026). La Tabla 10 completa la configuración global del generador. Los valores de registro se expresan como números MIDI y corresponden a una ventana centrada en C4 (MIDI 60); el ambitus se limita a una tesitura cantable (máximo 2 octavas, registro C3–C5). La dificultad alta se había fijado en 3 octavas (F#2–F#5), fuera de cualquier registro vocal razonable; la restricción de tesitura cantable de MusicAIR se adopta aquí.

#block(breakable: false)[
#leyenda([Tabla], 9, [Parámetros de generación melódica por nivel de dificultad])
#apatable(
  columns: (4.4cm, 3.3cm, 3.8cm, 4.4cm),
  header: ([*Parámetro*], [*Dificultad baja*], [*Dificultad media*], [*Dificultad alta*]),
  rows: (
    ([Longitud (notas)], [8], [15], [24]),
    ([Intervalo máximo consecutivo], [2 semitonos], [5 semitonos], [7 semitonos]),
    ([Penalización de repetición], [0.35], [0.65], [1.0]),
    ([Ambitus — tesitura cantable], [12 semitonos (1 octava)], [19 semitonos (≈1.5 octavas)], [24 semitonos (2 octavas)]),
    ([Registro MIDI (C3–C5)], [54–66], [51–70], [48–72]),
    ([Frases], [1], [2], [3]),
    ([Duraciones (pulsos)], [1 y 2], [0.5, 1 y 2], [0.5, 1, 1.5, 2 y 2/3]),
    ([Figura rítmica requerida], [—], [Al menos una corchea], [Al menos una figura de 1.5 o 2/3]),
    ([Modulación], [Ninguna], [Opcional (50 %), a la tonalidad relativa], [Obligatoria, a dominante o subdominante]),
    ([Congruencia tonal], [Una escala], [Hasta dos escalas], [Dos escalas]),
    ([Complejidad rítmica], [Negras y blancas], [Corcheas], [Valores de 1.5 y 2/3; ataques desplazados por suma de duraciones]),
  ),
)]

#block(breakable: false)[
#leyenda([Tabla], 10, [Configuración global del generador])
#apatable(
  columns: (4.6cm, 11.3cm),
  header: ([*Parámetro*], [*Valor*]),
  rows: (
    ([Tonalidades], [C, G, D, A, F, Bb y Eb]),
    ([Modos], [Mayor y menor natural]),
    ([Compás], [4/4]),
    ([Tempo], [Entre 60 y 120 BPM; 90 BPM por defecto]),
    ([Silencios], [No se generan]),
    ([Notas repetidas], [Permitidas; no se admiten tres notas iguales consecutivas]),
    ([Intervalos repetidos], [No se admiten tres intervalos iguales consecutivos]),
    ([Intentos de generación], [Hasta 50; si ninguno cumple, se lanza un error]),
    ([Versión del generador], [`0.1.0`]),
  ),
)]

=== 4.4.2. Algoritmo de generación

La Figura 6 resume el algoritmo. A partir de la semilla y de la dificultad se construye un generador pseudoaleatorio determinista. El generador selecciona una tonalidad y un modo, planifica las modulaciones, divide la melodía en segmentos con una escala activa, genera las alturas, genera las duraciones, construye los eventos de nota y valida el resultado. Si la validación falla, se reinicia el proceso con otra secuencia pseudoaleatoria, hasta un máximo de 50 intentos.

#block(breakable: false)[
#leyenda([Figura], 6, [Flujo del generador procedural de melodías])
#align(center)[
#set text(size: 8.5pt)
#diagram(
  node-stroke: 0.7pt, edge-stroke: 0.7pt, node-corner-radius: 3pt, mark-scale: 70%,
  spacing: (1.3cm, 0.75cm),
  caja-c4(0, 0, [Semilla + #linebreak() dificultad]),
  caja-c4(0, 1.0, [Hash y PRNG]),
  caja-c4(0, 2.0, [Tonalidad #linebreak() y escala]),
  caja-c4(0, 3.0, [Plan de #linebreak() modulación]),
  caja-c4(0, 4.0, [Segmentos #linebreak() por escala]),
  caja-c4(0, 5.0, [Selección #linebreak() de alturas]),
  caja-c4(0, 6.0, [Generación #linebreak() rítmica]),
  caja-c4(0, 7.0, [Construcción #linebreak() de notas]),
  diam-c4(0, 8.0, [Validación]),
  caja-c4(2.4, 8.0, [Melodía], fill: rgb("#f0fdf4")),
  edge((0,0), (0,1.0), "->"),
  edge((0,1.0), (0,2.0), "->"),
  edge((0,2.0), (0,3.0), "->"),
  edge((0,3.0), (0,4.0), "->"),
  edge((0,4.0), (0,5.0), "->"),
  edge((0,5.0), (0,6.0), "->"),
  edge((0,6.0), (0,7.0), "->"),
  edge((0,7.0), (0,8.0), "->"),
  edge((0,8.0), (2.4,8.0), "->", label: [válida]),
)
]
]

La selección de alturas es restringida. En cada paso, el algoritmo construye el conjunto de alturas pertenecientes a la escala activa dentro del registro permitido y descarta las que superan el intervalo máximo respecto de la nota anterior. Dentro de ese conjunto, pondera cada candidata por el inverso del cuadrado de la distancia a la nota anterior, de modo que los movimientos conjuntos son más probables que los saltos, y multiplica por 1.5 el peso de la tónica. Además, evita tres notas iguales consecutivas y tres intervalos iguales consecutivos. La primera nota se elige a no más de tres semitonos de C4.

La generación rítmica selecciona duraciones de un conjunto permitido con pesos definidos por nivel. Si el nivel exige una figura que no apareció, el algoritmo reemplaza una duración por la figura requerida. Las notas se construyen de forma monofónica: cada ataque comienza al finalizar la duración de la nota anterior, de modo que no hay superposición.

=== 4.4.3. Validación de restricciones

La validación comprueba la cantidad de notas, el ambitus, el registro, el intervalo máximo, la pertenencia a la escala de cada segmento, los valores rítmicos permitidos, la presencia de la figura requerida, la ausencia de superposición y la validez estructural del modelo. Si alguna comprobación falla, la melodía se descarta y se genera otra. Esta estrategia de *generar y verificar* es adecuada para melodías de 8 a 24 notas: el espacio de soluciones es suficientemente grande y el costo de reintentar es bajo.

=== 4.4.4. Pruebas y resultados

El generador se cubrió con 29 pruebas unitarias. Cada propiedad estructural se verificó sobre 25 semillas por nivel de dificultad, lo que permitió detectar casos límite en la modulación, en el ritmo y en el ambitus. La Tabla 11 resume las propiedades verificadas.

#block(breakable: false)[
#leyenda([Tabla], 11, [Propiedades verificadas del generador])
#apatable(
  columns: (4.3cm, 7.4cm, 4.2cm),
  header: ([*Propiedad*], [*Criterio*], [*Cobertura*]),
  rows: (
    ([Longitud], [8, 15 o 24 notas según el nivel], [25 semillas por nivel]),
    ([Intervalo máximo], [≤ 2, 5 o 7 semitonos], [25 semillas por nivel]),
    ([Ambitus], [≤ 12, 19 o 24 semitonos (tesitura cantable)], [25 semillas por nivel]),
    ([Pertenencia a la escala], [Cada segmento usa su escala activa], [25 semillas por nivel]),
    ([Valores rítmicos], [Solo duraciones permitidas], [25 semillas por nivel]),
    ([Figura requerida], [Al menos una figura del nivel], [25 semillas por nivel]),
    ([Superposición], [Sin notas superpuestas], [25 semillas por nivel]),
    ([Modulación], [Regla de modulación del nivel], [25 semillas por nivel]),
    ([Reproducibilidad], [Misma tupla de parámetros, misma melodía], [2 casos]),
    ([Sensibilidad], [Semillas distintas, melodías distintas], [2 casos]),
    ([Tesitura cantable], [Ambitus ≤ 24 semitonos en todos los niveles], [3 niveles]),
    ([Frases], [Número de frases del nivel], [3 niveles]),
    ([Variedad], [La repetición de notas decrece al aumentar la dificultad], [25 semillas por nivel]),
  ),
)]

=== 4.4.5. Discusión de decisiones

El enfoque procedural ofrece tres ventajas frente a un modelo generativo. Primero, permite imponer restricciones pedagógicas verificables, como el intervalo máximo o la longitud. Segundo, produce melodías reproducibles y auditables. Tercero, no requiere entrenamiento ni infraestructura de inferencia. La desventaja es que la corrección estructural no garantiza calidad musical: una melodía puede cumplir todas las restricciones y resultar poco idiomática. Por esta razón, la validación automática se complementa con la revisión de docentes, que se aborda en el diseño experimental.

El registro se acotó a una tesitura cantable (C3–C5, máximo dos octavas) siguiendo la restricción de MusicAIR (Liao et al., 2025), lo que resuelve la limitación previa en que la dificultad alta abarcaba tres octavas (F#2–F#5), fuera de la extensión cómoda de muchas voces. En la evaluación de repentización, la dificultad baja admite equivalencia de octava; en media y alta se exige correspondencia estricta. La selección de melodías para repentización debe considerar esta restricción, y la posibilidad de transponer la referencia a la tesitura cómoda del jugador queda como una línea de mejora del generador.

== 4.5. Evaluación de similitud melódica

=== 4.5.1. Definición del problema

La evaluación compara dos secuencias monofónicas: la melodía de referencia y la respuesta del jugador. La respuesta puede tener notas omitidas, notas añadidas, alturas incorrectas o ataques desplazados. Por este motivo, la comparación no puede reducirse a contrastar posiciones de dos listas: es necesario establecer primero una correspondencia entre eventos y luego calcular las métricas sobre esa correspondencia.

La evaluación se limita a dos dimensiones: precisión de alturas y precisión rítmica. No se evalúa el timbre, la expresividad, la calidad vocal ni la duración de las notas. La duración se conserva para la visualización y la reproducción, pero no forma parte de la puntuación. Esta delimitación concentra la medición en los objetivos del videojuego y evita introducir juicios subjetivos.

=== 4.5.2. Métricas

Para cada dimensión se calculan precisión, exhaustividad y medida $F_1$. La precisión mide la proporción de notas de la respuesta que encontraron correspondencia; la exhaustividad, la proporción de notas de referencia que fueron encontradas. La medida $F_1$ combina ambas y penaliza tanto las notas de más como las notas omitidas. Además de las puntuaciones, el resultado localiza el error para la retroalimentación (Zhang et al., 2025): identifica qué notas de referencia fueron omitidas, cuáles fueron adicionales y el desvío de altura y de ataque de cada correspondencia, de modo que el feedback señale dónde está el error y no solo cuánto se erró.

$ "precisión" = P = n_"aciertos" / n_"estimadas" $

$ "exhaustividad" = R = n_"aciertos" / n_"referencia" $

$ F_1 = (2 P R) / (P + R) $

Las puntuaciones se normalizan en el intervalo $[0, 1]$ y se presentan al jugador como porcentajes. La puntuación de cada dimensión es su $F_1$. La puntuación global de una respuesta es el promedio aritmético de las dos dimensiones:

$ S_"global" = (F_1^"alturas" + F_1^"ritmo") / 2 $

Se asignó el mismo peso a ambas dimensiones porque las dos constituyen objetivos explícitos de los ejercicios. Una media ponderada requeriría una justificación empírica que todavía no se ha reunido.

=== 4.5.3. Correspondencia entre eventos

La correspondencia se modela como un problema de emparejamiento bipartito máximo. Para cada dimensión se construye una matriz de compatibilidad entre las notas de referencia y las notas estimadas; una celda es compatible si la diferencia de altura o de ataque está dentro de la tolerancia. Sobre esa matriz se calcula un emparejamiento uno a uno, de modo que ninguna nota se usa más de una vez. La Figura 7 muestra el proceso.

#block(breakable: false)[
#leyenda([Figura], 7, [Evaluación por correspondencia bipartita])
#align(center)[
#set text(size: 8pt)
#diagram(
  node-stroke: 0.7pt, edge-stroke: 0.7pt, node-corner-radius: 3pt, mark-scale: 70%,
  spacing: (1.5cm, 0.9cm),
  caja-c4(0, 0, [Notas de #linebreak() referencia]),
  caja-c4(3.0, 0, [Notas #linebreak() estimadas]),
  caja-c4(1.5, 1.4, [Matriz de #linebreak() compatibilidad]),
  caja-c4(0, 2.8, [Matching de #linebreak() alturas], fill: rgb("#f0fdf4")),
  caja-c4(3.0, 2.8, [Matching de #linebreak() ritmo], fill: rgb("#f0fdf4")),
  caja-c4(0, 4.2, [$F_1$ alturas]),
  caja-c4(3.0, 4.2, [$F_1$ ritmo]),
  caja-c4(1.5, 5.6, [Puntuación #linebreak() global], fill: rgb("#eef2ff")),
  edge((0,0), (1.5,1.4), "->"),
  edge((3.0,0), (1.5,1.4), "->"),
  edge((1.5,1.4), (0,2.8), "->"),
  edge((1.5,1.4), (3.0,2.8), "->"),
  edge((0,2.8), (0,4.2), "->"),
  edge((3.0,2.8), (3.0,4.2), "->"),
  edge((0,4.2), (1.5,5.6), "->"),
  edge((3.0,4.2), (1.5,5.6), "->"),
)
]
]

Las dos dimensiones se emparejan de forma independiente. Una nota puede tener la altura correcta pero el ataque desplazado, o el ataque correcto pero la altura incorrecta. Forzar un único emparejamiento para ambas dimensiones mezclaría los dos tipos de error y dificultaría la interpretación del resultado pedagógico. Por esta razón, el evaluador devuelve dos conjuntos de pares emparejados y dos puntuaciones separadas.

=== 4.5.4. Tolerancias

Las tolerancias dependen del tipo de ejercicio. En el dictado, la respuesta se introduce sobre una rejilla y los ataques son exactos; en la repentización, la respuesta proviene de un transcriptor y los ataques presentan un desplazamiento mayor. La Tabla 12 resume los valores adoptados.

#block(breakable: false)[
#leyenda([Tabla], 12, [Tolerancias de evaluación por tipo de ejercicio])
#apatable(
  columns: (4cm, 3.4cm, 3.6cm, 4.9cm),
  header: ([*Ejercicio*], [*Tolerancia de altura*], [*Tolerancia de ataque*], [*Equivalencia de octava*]),
  rows: (
    ([Dictado], [±0.5 semitonos], [±50 ms], [No]),
    ([Repentización], [±0.5 semitonos], [±150 ms], [Solo en dificultad baja]),
  ),
)]

La tolerancia de altura de ±0.5 semitonos equivale, en la práctica, a exigir la misma altura MIDI, porque las alturas se redondean a enteros antes de comparar. La tolerancia de 50 ms en dictado corresponde al espaciado de la rejilla; la de 150 ms en repentización absorbe la variabilidad de los ataques detectados por el transcriptor. La equivalencia de octava en dificultad baja permite que el jugador cante en un registro distinto del escrito sin ser penalizado; en las demás dificultades se exige correspondencia estricta.

=== 4.5.5. Casos límite y pruebas

El evaluador se cubrió con 21 pruebas unitarias. La Tabla 13 resume los casos límite y el comportamiento esperado. Además de los casos de la tabla, se verificó que el resultado no dependa del orden de las notas y que los empates se resuelvan de forma uno a uno.

#block(breakable: false)[
#leyenda([Tabla], 13, [Casos límite del evaluador de similitud])
#apatable(
  columns: (5cm, 5.2cm, 5.7cm),
  header: ([*Caso*], [*Dimensión de alturas*], [*Dimensión de ritmo*]),
  rows: (
    ([Secuencias idénticas], [$F_1 = 1$], [$F_1 = 1$]),
    ([Nota omitida], [Exhaustividad < 1], [Exhaustividad < 1]),
    ([Nota adicional], [Precisión < 1], [Precisión < 1]),
    ([Altura incorrecta], [$F_1$ de altura < 1], [$F_1$ de ritmo = 1]),
    ([Ataque dentro de la tolerancia], [Sin cambio], [$F_1 = 1$]),
    ([Ataque fuera de la tolerancia], [$F_1$ de altura = 1], [$F_1$ de ritmo < 1]),
    ([Notas duplicadas], [Un solo emparejamiento], [Un solo emparejamiento]),
    ([Orden alterado], [Sin cambio], [Sin cambio]),
    ([Respuesta vacía], [0], [0]),
    ([Ambas secuencias vacías], [1], [1]),
  ),
)]

=== 4.5.6. Discusión de decisiones

La medida $F_1$ se adoptó porque penaliza simétricamente las omisiones y las notas de más, a diferencia de una precisión simple. El promedio aritmético de las dos dimensiones es transparente para el jugador y fácil de explicar, aunque no distingue si un error de altura es más grave que un error rítmico. La separación de dimensiones permite que el jugador identifique el tipo de error, y las vistas de resultados muestran ambas puntuaciones además de la global. La decisión de no puntuar la duración de las notas reduce la complejidad del dictado, pero limita la evaluación del ritmo a la ubicación de los ataques.

Además de las puntuaciones, el resultado de la evaluación incluye un informe de errores derivado de los mismos pares emparejados: por dimensión, las notas de referencia omitidas, las notas estimadas adicionales y la desviación media y máxima de los pares emparejados (semitonios en altura y milisegundos en ataque). Este informe no recalcula la evaluación: la describe para la retroalimentación, de modo que el error se señala en el tiempo y no solo como un puntaje. La localización de errores por categorías y la magnitud del desvío se apoyan en Kumar et al. (2026), que separa las dimensiones de error del canto con collares de tolerancia ajustables, y en Kim y Cozzarin (2023), cuyo juego de entrenamiento auditivo muestra cuánto fue el error para que el jugador pueda re-estrategizar. El desglose se presenta en la sección 4.9.7.

// Extracto clave de Kim y Cozzarin (2023), sección 2 («Design and Development
// of a New Technical Ear Training Game»):
// «If the player failed to shoot the target down, the game would show how much
// of an error was made. This feedback would help the player to learn and
// re-strategize for the next trial».

// Extracto clave de Kumar et al. (2026), sobre las categorías de error anotadas
// por los docentes:
// «the teachers annotate instances of pitch, amplitude, pronunciation, and
// rhythm errors in learners' [singing]», con detección orientada a «providing
// detailed corrective feedback to learners».

== 4.6. Transcripción automática de audio a MIDI

=== 4.6.1. Selección del método

La evaluación de la repentización requiere transformar la interpretación vocal monofónica en una secuencia de notas. La revisión del estado del arte (sección 2.4.5, cluster de transcripción) describe un tradeoff estructural entre precisión y coste computacional: los modelos de aprendizaje automático de canto logran la mayor precisión nota a nota (F1 de onset+pitch del 86–93 %), pero su inferencia en el navegador es lenta —como ocurría con Spotify Basic Pitch mediante TensorFlow.js, origen de la queja de latencia del prototipo— o exige servidor; en cambio, los métodos de procesamiento digital de señales (DSP) son muy rápidos y privados, aunque tradicionalmente más débiles en la segmentación de notas. Para el caso concreto del canto monofónico, la balanza se inclina del lado DSP por tres razones empíricas del corpus: la altura monofónica es un problema resuelto para los métodos DSP (errores de pitch del 0–2,9 % con análisis espectral por ventana); los propios modelos de canto de mayor rendimiento delegan la estimación de altura a trackers DSP (pYIN), de modo que la precisión atribuida a las redes se apoya en un estimador de F0 clásico; y las restricciones de ejecución en el navegador —sin servidor, sin exponer el audio del jugador y con baja latencia— descartan los modelos polifónicos pesados y aminoran la ventaja de los modelos ligeros de piano, no entrenados para voz.

Por ello se seleccionó un tracker DSP monofónico propio: estimación de altura con el algoritmo YIN, detección de ataques por flujo espectral y segmentación de notas por altura estable y ataques. La decisión es una compensación deliberada entre precisión y coste computacional: se renuncia a parte de la precisión de los onsets —el cuello de botella declarado del canto, incluso para las redes neuronales— a cambio de una ejecución nativa en el navegador, sin modelo preentrenado, sin TensorFlow.js y con una latencia mínima. El resultado es código TypeScript puro, auditable y determinista, coherente con el enfoque de la tesis y con la decisión de no entrenar modelos propios.

=== 4.6.2. Pipeline de procesamiento

La Figura 8 muestra el pipeline. El jugador graba su interpretación con `MediaRecorder`; el audio se decodifica con Web Audio, se remuestrea a 22 050 Hz mono y se recorta el silencio inicial. La señal resultante se transfiere a un Web Worker, donde el tracker DSP la procesa en tres pasos: estimación de altura por frame con el algoritmo YIN (acotada al rango 75–1500 Hz), detección de ataques por flujo espectral con umbral adaptativo, y segmentación en notas agrupando frames de altura estable y dividiendo en ataques o cambios de altura sostenidos, lo que la hace robusta al vibrato. La salida se normaliza y se convierte en una secuencia de `EvaluatedNote`, que se compara con la melodía de referencia mediante el evaluador descrito en la sección 4.5.

#block(breakable: false)[
#leyenda([Figura], 8, [Pipeline de transcripción de audio a notas])
#align(center)[
#set text(size: 8pt)
#diagram(
  node-stroke: 0.7pt, edge-stroke: 0.7pt, node-corner-radius: 3pt, mark-scale: 70%,
  spacing: (1.2cm, 0.9cm),
  caja-c4(0, 0, [Micrófono]),
  caja-c4(2.0, 0, [MediaRecorder #linebreak() máx. 30 s]),
  caja-c4(4.0, 0, [Decodificación]),
  caja-c4(6.0, 0, [Remuestreo #linebreak() 22 050 Hz mono]),
  caja-c4(6.0, 1.4, [Recorte de #linebreak() silencio]),
  caja-c4(4.0, 1.4, [Web Worker #linebreak() tracker DSP]),
  caja-c4(2.0, 1.4, [YIN + onsets]),
  caja-c4(0, 1.4, [Normalización]),
  caja-c4(0, 2.8, [EvaluatedNote]),
  caja-c4(2.0, 2.8, [Evaluador]),
  edge((0,0), (2.0,0), "->"),
  edge((2.0,0), (4.0,0), "->"),
  edge((4.0,0), (6.0,0), "->"),
  edge((6.0,0), (6.0,1.4), "->"),
  edge((6.0,1.4), (4.0,1.4), "->"),
  edge((4.0,1.4), (2.0,1.4), "->"),
  edge((2.0,1.4), (0,1.4), "->"),
  edge((0,1.4), (0,2.8), "->"),
  edge((0,2.8), (2.0,2.8), "->"),
)
]
]

=== 4.6.3. Parámetros y normalización

Los parámetros de inferencia se centralizaron en un único módulo para que el ajuste sea reproducible y para que las pruebas verifiquen sus rangos. La Tabla 14 resume los valores. La normalización redondea la altura al semitono más cercano, ordena las notas por ataque, fusiona segmentos contiguos de la misma altura separados por menos de 80 ms y asigna una duración mínima de 0.05 s.

#block(breakable: false)[
#leyenda([Tabla], 14, [Parámetros de inferencia y normalización])
#apatable(
  columns: (4cm, 3.4cm, 8.5cm),
  header: ([*Parámetro*], [*Valor*], [*Función*]),
  rows: (
    ([`frameSize`], [2048 muestras], [Ventana de análisis de YIN (unos 93 ms).]),
    ([`hopSize`], [512 muestras], [Salto entre frames (unos 23 ms).]),
    ([`yinThreshold`], [0.15], [Umbral de YIN para considerar una altura válida.]),
    ([`minFreq`–`maxFreq`], [75–1500 Hz], [Acota el rango de búsqueda y elimina ruido tonal grave.]),
    ([`onsetSensitivity`], [1.2 σ], [Umbral adaptativo del flujo espectral de ataques.]),
    ([`minNoteLenMs`], [50 ms], [Descarta transitorios de consonante.]),
    ([`maxGapMs`], [40 ms], [Hueco sin voz admitido dentro de una nota.]),
    ([Frecuencia de muestreo], [22 050 Hz], [Entrada del tracker.]),
    ([Fusión de segmentos], [< 80 ms], [Une notas contiguas de igual altura.]),
  ),
)]

=== 4.6.4. Integración en el navegador

El tracker DSP se ejecuta en un Web Worker para no bloquear la interfaz, aunque su coste computacional es muy inferior al del modelo que reemplaza: no carga un modelo preentrenado ni depende de TensorFlow.js, y procesa unos 2 s de audio en menos de 0,2 s. El audio del jugador no sale del navegador: se procesa localmente, sin conexión a servicios externos ni envío a un tercero, lo que protege la privacidad y evita sobrecargar el servidor. El cliente mantiene un watchdog de 30 s como salvaguarda: si la transcripción dejara de avanzar, la solicitud se cancela y se informa al jugador.

=== 4.6.5. Manejo de errores

El flujo distingue entre errores de captura, de decodificación, de transcripción y de resultado vacío. Si el permiso del micrófono se deniega, se informa al jugador y se le permite reintentar. Si la grabación no puede decodificarse, se descarta y se solicita una nueva toma. Si la transcripción no detecta notas, se informa que no se detectaron eventos y se permite repetir la grabación. Si la transcripción falla o se estanca, se cancela y se muestra el error. En ninguno de estos casos se asigna automáticamente una puntuación de cero: la respuesta no puntuada se excluye del promedio y se muestra como ausente en el resumen.

=== 4.6.6. Validación técnica

El tracker se verificó con pruebas unitarias sobre audio sintético: secuencias de notas distintas (altura y ataque correctos), notas repetidas separadas por ataques, robustez ante vibrato moderado y respeto del rango 75–1500 Hz, además de una prueba de latencia (unos 2 s de audio transcritos en menos de 0,2 s). El banco de 25 casos sintéticos con vibrato, ruido y transitorios de respiración se reporta en la sección 4.10.3. La validación con voz cantada real se especifica en la sección 4.10.5.

== 4.7. Mecánicas de juego y flujo de partida

=== 4.7.1. Configuración de la partida

La partida se configura antes de comenzar. El jugador selecciona la dificultad, la actividad inicial (dictado o repentización), el número de rondas (entre 2 y 8) y el tempo (entre 60 y 120 BPM). La dificultad permanece fija durante toda la partida y no se incrementa automáticamente entre rondas. Cada ronda recibe una melodía nueva generada con la semilla de la sesión y el número de ronda, de modo que la partida es reproducible.

=== 4.7.2. Flujo de la partida individual

La Figura 9 muestra el flujo. La primera ronda ejecuta la actividad seleccionada; las rondas siguientes alternan dictado y repentización. Al finalizar cada ronda, el sistema evalúa la respuesta y muestra las puntuaciones de alturas, ritmo y global. Cuando se completa el número de rondas, se muestra un resumen con la puntuación de cada ronda y el promedio de precisión general.

#block(breakable: false)[
#leyenda([Figura], 9, [Flujo de una partida individual])
#align(center)[
#set text(size: 8pt)
#diagram(
  node-stroke: 0.7pt, edge-stroke: 0.7pt, node-corner-radius: 3pt, mark-scale: 70%,
  spacing: (1.0cm, 0.85cm),
  caja-c4(0, 0.8, [Configuración]),
  caja-c4(1.8, 0.8, [Ronda $n$]),
  caja-c4(3.6, 0, [Dictado]),
  caja-c4(3.6, 1.6, [Repentización]),
  caja-c4(5.4, 0.8, [Evaluación]),
  diam-c4(7.2, 0.8, [¿Quedan #linebreak() rondas?]),
  caja-c4(7.2, 2.4, [Resumen], fill: rgb("#f0fdf4")),
  edge((0,0.8), (1.8,0.8), "->", label: [melodía #linebreak() nueva]),
  edge((1.8,0.8), (3.6,0), "->"),
  edge((1.8,0.8), (3.6,1.6), "->"),
  edge((3.6,0), (5.4,0.8), "->"),
  edge((3.6,1.6), (5.4,0.8), "->"),
  edge((5.4,0.8), (7.2,0.8), "->"),
  edge((7.2,0.8), (1.8,0.8), "->", bend: 35deg, label: [sí]),
  edge((7.2,0.8), (7.2,2.4), "->", label: [no]),
)
]
]

En el dictado, el jugador puede reproducir la melodía tantas veces como desee antes de enviar la respuesta. En la repentización, puede grabar, escuchar la grabación, repetir la toma y enviar cuando esté conforme. La grabación tiene un límite de 30 s y se descarta si el jugador decide repetirla. Estas reglas no introducen penalización por reintentos dentro de la misma ronda.

=== 4.7.3. Mecánica multijugador

La partida multijugador se organiza en salas identificadas por un código de seis caracteres sin caracteres ambiguos. El anfitrión crea la sala, configura la dificultad, la actividad inicial, el número de rondas (entre 2 y 8), el tempo y la visibilidad de las grabaciones, e inicia la partida cuando al menos dos jugadores se han incorporado; solo el anfitrión puede iniciarla. Cada jugador recibe en la ronda 1 una melodía generada con su propia semilla derivada de la semilla de sala, de modo que las melodías iniciales son distintas y la partida es reproducible.

La mecánica central es el intercambio encadenado de producciones musicales entre jugadores. En la ronda $k >= 2$, cada jugador recibe la respuesta del jugador anterior en la rotación, $s(i) = (i - 1 + N) mod N$ donde $i$ es su posición y $N$ el número de jugadores; con esta asignación ningún jugador recibe su propia producción, se resuelve el caso de número impar de jugadores y cada respuesta se entrega a un único destinatario. El objeto transferido es la producción simbólica final de la ronda anterior: en una ronda de dictado, el jugador escucha como MIDI la transcripción que otro jugador realizó de su melodía y la transcribe; en una ronda de repentización, visualiza la transcripción que otro jugador produjo al cantar y la interpreta. Las actividades alternan por ronda a partir de la actividad inicial.

La evaluación de cada respuesta se calcula en el servidor contra la melodía recibida —la generada en la ronda 1 o la producción del jugador anterior— con las tolerancias de la sección 4.5.4; el cliente solo envía las notas de su respuesta. La ronda avanza cuando todos los jugadores han enviado su respuesta: el servidor evalúa, construye las asignaciones de la ronda siguiente y persiste cada envío con su autor, su destinatario, su material de referencia y su envío de origen (sección 4.8.3), de modo que la cadena completa puede reconstruirse. En la última ronda se cierra la partida y se calcula la clasificación. Los resultados de cada ronda no se muestran hasta el final de la partida (decisión de diseño): tras enviar, el jugador ve una pantalla de espera con el estado de envío de los demás participantes.

El modo multijugador de las plataformas de entrenamiento auditivo existentes reparte la misma secuencia a todos los jugadores, que compiten en paralelo (Pesek et al., 2020a). El intercambio encadenado de producciones, en el que la respuesta de un jugador se convierte en el ejercicio del siguiente, es una mecánica propia, inspirada en juegos de teléfono descompuesto, que se plantea como hipótesis de diseño sobre el engagement y debe evaluarse con usuarios.

// Extracto clave de Pesek et al. (2020a), sección «The interval dictation
// application», sobre el modo multijugador previo:
// «The interval dictation application can be played in multiplayer mode where
// two or more players play a single exercise (all players are given the same
// melodic sequences)».

=== 4.7.4. Puntuación y cierre

La puntuación de cada respuesta es el promedio de las medidas $F_1$ de alturas y ritmo. La puntuación final del jugador es el promedio aritmético de las puntuaciones de sus respuestas puntuadas:

$ S_"jugador" = (sum_(i = 1)^n S_i) / n $

donde $n$ es el número de respuestas puntuadas y $S_i$ es la puntuación global de la respuesta $i$. Las respuestas no puntuadas por fallos técnicos se excluyen del promedio y se muestran como ausentes; no se incorporan como ceros. La clasificación se limita a la partida y no se extiende a un ranking global.

=== 4.7.5. Reglas de recuperación y abandono

// PLACEHOLDER (parcial): el prototipo documenta su comportamiento real ante
// recargas y envíos duplicados; las reglas de abandono y de tiempos por ronda
// siguen abiertas y deben reescribirse con pruebas de reconexión.

En el prototipo, el estado de la partida reside en el servidor y los clientes lo observan por sondeo, de modo que una recarga de la página o una desconexión temporal no afectan a la partida: el jugador reanuda la vista en el punto en que se encuentra la ronda y su envío previo se conserva. Un jugador no puede enviar dos respuestas en la misma ronda: el segundo envío se rechaza en el servidor. Estas dos reglas se verifican en la prueba de humo de la sección 4.10.6.

Quedan abiertos los casos de un jugador que abandona sin enviar, la tolerancia a rezagados cuando hay más de dos jugadores y los tiempos por ronda. La versión completa definirá si la ronda se cierra con las respuestas disponibles —con ausencia, no con puntuación de cero, para el jugador que no envió—, si se introduce un cronómetro por ronda y qué ocurre si el anfitrión abandona la sala. Estas reglas se verificarán con pruebas de sincronización y de reconexión antes de la sesión con estudiantes.

== 4.8. Persistencia y modelo de datos

=== 4.8.1. Modelo conceptual

El modelo implementado organiza los datos en seis colecciones de Payload. La Figura 10 muestra la cadena principal de una partida: una sala de juego contiene los envíos de sus rondas, cada envío referencia la melodía recibida, la respuesta del jugador y el resultado de su evaluación, y puede encadenarse con el envío del que deriva mediante `sourceSubmission`. Las entidades de usuario, salón de clase e invitación se mantienen separadas de la cadena de juego para que un docente consulte los resultados de sus estudiantes sin mezclarlos con los datos de las partidas; las grabaciones de voz se almacenan como archivos y los envíos las referencian.

#block(breakable: false)[
#leyenda([Figura], 10, [Cadena de datos de una partida])
#align(center)[
#set text(size: 7.5pt)
#diagram(
  node-stroke: 0.7pt, edge-stroke: 0.7pt, node-corner-radius: 3pt, mark-scale: 70%,
  spacing: (1.1cm, 0.8cm),
  caja-c4(0, 0, [Users #linebreak() id · email · role]),
  caja-c4(0, 1.6, [Classrooms #linebreak() id · name · teacher]),
  caja-c4(0, 3.2, [ClassroomInvitations #linebreak() classroom · user #linebreak() status]),
  caja-c4(3.0, 0, [GameRooms #linebreak() id · code · host #linebreak() settings · participants[]]),
  caja-c4(3.0, 2.2, [Submissions #linebreak() room · roundNumber · player #linebreak() receivedMelody · response #linebreak() evaluation · sourceSubmission]),
  caja-c4(6.2, 3.4, [Media #linebreak() id · url]),
  edge((0,0), (0,1.6), "->", label: [administra]),
  edge((0,1.6), (0,3.2), "->"),
  edge((0,0), (3.0,0), "->", label: [juega]),
  edge((3.0,0), (3.0,2.2), "->", label: [N envíos #linebreak() por ronda]),
  edge((3.0,2.2), (6.2,3.4), "->", label: [grabación]),
  edge((0,1.6), (3.0,2.2), "->", stroke: (dash: "dashed"), bend: 15deg, label: [consulta]),
)
]
]

=== 4.8.2. Implementación en Payload

El prototipo implementa seis colecciones: `Users`, `GameRooms`, `Submissions`, `Media`, `Classrooms` y `ClassroomInvitations`. La Tabla 15 describe sus campos principales. Cada envío es una fila por jugador y ronda, con la melodía recibida embebida como JSON autocontenido —incluye semilla y versión del generador—, lo que reduce el número de consultas al reconstruir la partida a costa de duplicar los datos de la melodía entre envíos. El resultado de la evaluación se embebe también como JSON, en su forma completa, con los pares emparejados y las notas omitidas y adicionales que alimentan el informe de errores.

#block(breakable: false)[
#leyenda([Tabla], 15, [Colecciones implementadas en Payload])
#apatable(
  columns: (3.6cm, 6.4cm, 5.9cm),
  header: ([*Colección*], [*Campos*], [*Propósito*]),
  rows: (
    ([`Users`], [`email`, `name`, `role`], [Autenticación, perfil mínimo y rol (`student`, `professor`, `admin`).]),
    ([`GameRooms`], [`code`, `host`, `status`, `settings`, `participants[]`, `currentRound`, `sessionSeed`], [Sala, configuración, participantes y estado de la partida.]),
    ([`Submissions`], [`room`, `roundNumber`, `player`, `receivedMelody`, `receivedFrom`, `sourceSubmission`, `response`, `evaluation`, `recording`, `status`], [Un envío por jugador y ronda: material recibido, respuesta, evaluación y trazabilidad.]),
    ([`Media`], [`url`], [Grabaciones de voz referenciadas desde los envíos.]),
    ([`Classrooms`], [`name`, `teacher`], [Salones de clase administrados por un docente.]),
    ([`ClassroomInvitations`], [`classroom`, `user`, `status`, `invitedBy`], [Pertenencia al salón por invitación aceptada; pendientes y rechazadas.]),
  ),
)]

=== 4.8.3. Trazabilidad de la partida

La trazabilidad se sostiene en tres relaciones de cada envío: `receivedMelody` conserva el material de referencia completo (notas, tempo, semilla y versión del generador), `receivedFrom` identifica al jugador que produjo ese material y `sourceSubmission` apunta al envío del que deriva, de modo que las producciones de una misma melodía inicial forman una cadena reconstruible. La evaluación embebida referencia exactamente las notas que se compararon. El orden de los envíos por sala, ronda y posición de jugador permite reconstruir tanto el viaje de cada melodía como el recorrido de cada jugador; las vistas de galería y de espectación se construyen sobre estas relaciones sin datos derivados adicionales.

=== 4.8.4. Archivos de audio y retención

El prototipo conserva las grabaciones de voz: se almacenan como archivos en la colección `Media` (almacenamiento local en el entorno de desarrollo) y el envío las referencia por identificador; si la subida falla, la respuesta se registra igualmente y las vistas muestran la transcripción simbólica. Cada grabación tiene un límite de 30 s, y la configuración de la sala controla si las grabaciones se muestran en la galería, de modo que un docente puede desactivarlas en contextos sensibles a las burlas.

La política de datos de las grabaciones se define con un alcance acotado al estudio experimental y comprende tres medidas. En cuanto al consentimiento, la participación en la sesión es voluntaria y exige consentimiento informado (Anexo B), que describe el uso de las grabaciones y el derecho del participante a retirarlas. En cuanto al acceso, el audio se trata como dato personal y no se expone públicamente: la lectura de `Media` exige sesión iniciada —también para los archivos servidos— y las vistas de galería y espectación solo muestran grabaciones a los participantes de la partida y a los docentes, mientras que el borrado está reservado al administrador. En cuanto a la retención, las grabaciones se conservan únicamente durante el desarrollo del estudio y se eliminan desde el panel administrativo una vez completado el análisis.

La delimitación del alcance de la política es una decisión consciente: el artefacto es un prototipo de investigación y no se despliega como producto, de modo que la gobernanza de datos propia de un servicio comercial —almacenamiento de objetos, retención por lotes, portabilidad y procedimientos de ejercicio de derechos— queda fuera de las actividades de diseño del artefacto en el DSRM. Esta delimitación se declara como limitación en la sección 4.10.7 y no afecta a las obligaciones del investigador respecto de los participantes del estudio, que el consentimiento informado y la eliminación posterior cubren.

=== 4.8.5. Control de acceso

El prototipo define tres roles en `Users`: estudiante, docente y administrador. El rol se fija como estudiante en el registro —el campo de rol solo puede escribirlo un administrador— y determina el alcance de las vistas: el estudiante consulta sus datos y sus partidas; el docente consulta los salones que administra, sus estudiantes y sus partidas; el administrador gestiona usuarios. La lectura de un usuario está limitada al propio usuario, al docente y al administrador, y el rol no es legible para los estudiantes. Estas reglas se implementan con el control de acceso por campo y por colección de Payload y se verifican con una prueba de autorización que incluye el rechazo de la auto-promoción de rol, la lectura y actualización de usuarios ajenos (403) y el borrado reservado al administrador.

Las consultas de juego y de salones pasan por endpoints propios que validan las reglas en servidor —el docente solo accede al detalle de sus salones, la espectación exige rol docente o administrador y las mutaciones de juego se rechazan fuera de la secuencia de la partida—; el cliente no puede alterar resultados. Queda pendiente restringir la lectura de `GameRooms` y `Submissions` a nivel de API, hoy abierta para facilitar la verificación funcional del prototipo; `Media` ya limita su lectura —incluidos los archivos servidos— a usuarios con sesión iniciada (sección 4.8.4). Ninguna de estas configuraciones provisionales se traslada a la versión completa.

== 4.9. Interfaz y retroalimentación

=== 4.9.1. Principios de diseño

La interfaz se diseñó para computadoras de escritorio, porque las tareas requieren escuchar melodías, leer una representación musical, introducir notas y grabar la voz. La adaptación a dispositivos móviles se considera una línea de trabajo posterior y requiere probar la grabación y la edición musical en esos entornos.

La representación musical elegida es el piano roll, tanto para el dictado como para la lectura en repentización. Esta decisión aísla la altura y el ataque, que son las dos dimensiones evaluadas, y reduce la influencia de la lectoescritura en la medición. En repentización, el piano roll sustituye al pentagrama tradicional; esta simplificación favorece la comparabilidad entre jugadores con distinto nivel de lectura, pero reduce la validez ecológica respecto de la repentización sobre partitura. La tensión se reconoce como una limitación del diseño y se retoma en la sección 4.10.7.

=== 4.9.2. Flujo de pantallas

La Figura 11 muestra el flujo de pantallas, todas implementadas en el prototipo. Tras el acceso, el inicio presenta el lobby de juego y, según el rol, el historial del estudiante o las vistas docentes. La sala de espera concentra la configuración y la lista de jugadores; durante la partida, las pantallas de dictado y de repentización alternan por ronda y se separan por una pantalla de espera con el estado de envío de los demás jugadores. Al terminar la última ronda se abre la galería final, que también se consulta desde el historial. Los resultados por ronda no tienen pantalla propia: se muestran al final, en la galería.

#block(breakable: false)[
#leyenda([Figura], 11, [Flujo de pantallas del videojuego])
#align(center)[
#set text(size: 8pt)
#diagram(
  node-stroke: 0.7pt, edge-stroke: 0.7pt, node-corner-radius: 3pt, mark-scale: 70%,
  spacing: (1.0cm, 0.8cm),
  caja-c4(-1.8, 0.8, [Acceso]),
  caja-c4(0, 0.8, [Inicio #linebreak() lobby e historial]),
  caja-c4(2.0, 0, [Sala de espera]),
  caja-c4(4.2, 0, [Dictado]),
  caja-c4(4.2, 1.6, [Repentización]),
  caja-c4(6.4, 0.8, [Espera entre rondas]),
  caja-c4(8.6, 0.8, [Galería final]),
  caja-c4(0, 2.8, [Salón y espectación #linebreak() (docente)]),
  edge((-1.8,0.8), (0,0.8), "->"),
  edge((0,0.8), (2.0,0), "->", label: [crear #linebreak() o unirse]),
  edge((2.0,0), (4.2,0), "->"),
  edge((2.0,0), (4.2,1.6), "->"),
  edge((4.2,0), (6.4,0.8), "->", label: [enviar]),
  edge((4.2,1.6), (6.4,0.8), "->", label: [enviar]),
  edge((6.4,0.8), (4.2,0), "->", bend: 30deg, label: [siguiente ronda]),
  edge((6.4,0.8), (4.2,1.6), "->", bend: -30deg),
  edge((6.4,0.8), (8.6,0.8), "->", label: [última ronda]),
  edge((0,0.8), (8.6,0.8), "->", stroke: (dash: "dashed"), bend: 30deg, label: [mis partidas]),
  edge((0,0.8), (0,2.8), "->", label: [rol docente]),
)
]
]

=== 4.9.3. Pantalla de configuración

La sala de espera concentra la configuración de la partida, con cinco controles: dificultad, actividad inicial, número de rondas, tempo y visibilidad de las grabaciones de voz en la galería. La dificultad se muestra con su número de notas y su intervalo máximo, de modo que el jugador comprenda el efecto de la selección. El número de rondas se ajusta entre 2 y 8 y el tempo entre 60 y 120 BPM. La lista de jugadores y el código de la sala, con botón para copiarlo, completan la pantalla; el anfitrión inicia la partida cuando hay al menos dos jugadores.

=== 4.9.4. Pantalla de dictado

La pantalla de dictado reproduce la melodía y muestra un piano roll editable. El jugador coloca una nota por ataque; si coloca otra nota en el mismo ataque, la anterior se reemplaza, de modo que la respuesta es monofónica. La duración de cada nota se fija en un pulso y no es editable: la evaluación rítmica se basa en la ubicación de los ataques, no en la duración. Esta decisión simplifica la entrada y evita penalizar la notación de duraciones, que no forma parte del objetivo del ejercicio.

La rejilla de entrada depende de la dificultad: un pulso en dificultad baja, medio pulso en dificultad media y un sexto de pulso en dificultad alta. El jugador puede reproducir la melodía, detener la reproducción y borrar la respuesta antes de enviarla. Al enviar, la respuesta se registra en el servidor, que la evalúa al completarse la ronda; el jugador pasa entonces a la pantalla de espera, donde observa quién ha enviado su respuesta (Figura 14). Los resultados se muestran al final de la partida.

=== 4.9.5. Pantalla de repentización

La pantalla de repentización muestra la melodía en un piano roll y habilita la grabación. Durante la grabación se muestra un indicador y se informa del límite de 30 s. Al detenerla, el jugador puede escuchar la grabación, repetirla o enviarla. Al enviar, se muestra el progreso de la transcripción y, si el proceso falla, se informa del error y se permite reintentar. La interfaz no bloquea la edición ni la navegación durante la inferencia, porque esta ocurre en un Worker.

=== 4.9.6. Evaluación y resumen

La evaluación se calcula en el servidor al completarse cada ronda, pero sus resultados se muestran únicamente al final de la partida (decisión de diseño): tras enviar, el jugador solo observa el estado de envío de los demás participantes, lo que evita que la retroalimentación interrumpa el flujo del juego. La galería final reúne los resultados en dos niveles. El primero es el recorrido de cada melodía: una diapositiva por melodía inicial con todas sus versiones encadenadas —la original del sistema y la producción de cada ronda, con su autor—, cada una con su piano roll de solo lectura, su reproducción MIDI y, cuando está habilitada, la grabación de voz correspondiente. El segundo es la diapositiva de resultados: la clasificación de la partida con las puntuaciones de alturas, ritmo y global de cada jugador, y la sección de participaciones propias, con la melodía recibida y la producida en cada ronda, acompañadas del informe de errores de la sección 4.5.6. Debajo, un bloque de pistas resume qué trabajar para la próxima partida (sección 4.9.7).

El informe de errores es textual y por dimensión —notas omitidas y adicionales con su posición, y desviación media de altura y de ataque—, de modo que la retroalimentación no depende del color; con él se mitiga la limitación de accesibilidad que planteaba el coloreado del piano roll en la versión individual.

=== 4.9.7. Vistas de historial, docentes y de espectación

El inicio del estudiante presenta el historial de partidas —fecha, código, rondas, posición y las puntuaciones de alturas, ritmo y global de cada partida, con acceso a la galería correspondiente—, las invitaciones pendientes a salones y el lobby de juego. Sobre la tabla del historial, un panel de progreso muestra la evolución de las tres métricas entre partidas como líneas temporales (sparklines) e insights derivados del historial: la tendencia de cada métrica entre la primera y la última partida y la dimensión más débil del promedio (Figura 16).

El inicio del docente lista las partidas en desarrollo de sus salones, con acceso a la espectación, y sus salones de clase. La vista de salón organiza cuatro secciones en pestañas, cuyo estado se refleja en la URL: partidas en desarrollo, partidas pasadas —filtrables por estudiante y ordenables por alturas, ritmo o global, con el puntaje del estudiante filtrado o el promedio del salón—, estudiantes —ordenable por partidas jugadas y por cada métrica, con su serie temporal de progreso— e invitaciones pendientes, con invitación por correo (Figuras 17 y 18). La espectación, accesible solo para docentes y administradores en vivo o sobre partidas terminadas, ofrece tres sub-vistas: una vista general del intercambio de melodías entre jugadores como diagrama de nodos por rondas, el detalle por melodía con el viaje completo de cada cadena y el detalle por jugador con lo que recibió y produjo en cada ronda, sus sub-puntuaciones y su informe de errores (Figura 19).

El diseño de estas vistas se apoya en los antecedentes revisados. En Troubadour, los docentes solicitaron explícitamente supervisar el progreso de los estudiantes y observar los tipos de error que cometían al resolver los ejercicios, y la plataforma implementó un panel de administración con vistas detalladas de la interacción de cada estudiante (Pesek et al., 2020a); el propio estudio observa que las plataformas comerciales existentes implementaban pocos módulos para crear grupos de estudiantes y monitorear su progreso. Los antecedentes recientes coinciden: el trabajo de Fernández (2025) recomienda incorporar métricas de seguimiento del progreso estudiantil —con amplio respaldo de sus encuestados a medir tiempo de práctica y ejercicios acertados— y Lingjie (2025) concluye que deben elaborarse planes de aprendizaje individualizados a partir de las necesidades específicas de cada estudiante, lo que exige al docente consultar el desempeño por dimensión. La comparación entre estudiantes se mantiene reservada al docente: Troubadour halló que a los estudiantes les gustaba ver que su rendimiento era mejor que el de otros, pero desaprobaban que sus puntuaciones fueran públicas (Pesek et al., 2020a).

// Extracto clave de Pesek et al. (2020a), sección III-A.1 («Teacher's point of
// view»), sobre las necesidades del docente:
// «the teachers wished to oversee the students' progress... Moreover, the
// teachers requested to observe the different types of mistakes the students
// made and they also proposed to gather more information about the individual
// student's problems while solving the exercises».

// Extracto clave de Pesek et al. (2020a), sección V-C.1, sobre la privacidad
// del ranking:
// «the students liked to see they performed better than others, but they did
// not approve of their scores to be public».

La tendencia temporal por partida se apoya en el análisis de uso de Troubadour, que siguió el progreso de los estudiantes con curvas por número de partida —el tiempo medio para completar un ejercicio disminuía y los puntos por partida aumentaban con el uso— (Pesek et al., 2020a), y en los estudios cuasi-experimentales del dominio, que comparan medias de inicio y fin por dimensión para medir la mejora (Chen y Li, 2025; Lingjie, 2025). La representación concreta —una línea por métrica con dominio fijo en el rango de las puntuaciones, de modo que los sparklines sean comparables entre estudiantes y vistas— es una decisión propia, igual que la derivación de insights de tendencia y de dimensión débil a partir del historial.

// Extracto clave de Pesek et al. (2020a), sección V-D («Evaluation of engagement
// through usage data»):
// «With continued use, the average time needed to complete an exercise gradually
// decreased, and the average points collected per game increased.»

El bloque de pistas de la galería es feedback formativo, no summative: señala qué trabajar en lugar de solo cuánto se puntuó. El estado del arte es explícito sobre esta distinción: los sistemas de evaluación musical tradicionales se apoyan en métricas cuantitativas que ofrecen feedback summative —puntuaciones o juicios binarios— y fallan en contextos educativos donde el feedback formativo, detallado e instructivo es esencial para el desarrollo del estudiante (Zhang et al., 2025). Las pistas del prototipo se derivan por reglas de las métricas de la partida y del informe de errores: la dimensión más débil de la partida, las notas omitidas o adicionales que tienden a acumularse, la desviación de octava en la repentización y el desplazamiento de ataques. Los umbrales concretos de estas reglas son una decisión propia; la literatura consultada no valida valores específicos.

// Extracto clave de Zhang et al. (2025) —LLaQo—, sección I, sobre el feedback
// formativo:
// «traditional systems for music performance assessment have primarily relied on
// quantitative metrics that provide summative feedback, often in the form of
// scores or binary judgments. Such approaches... fall short in educational
// contexts where formative, detailed and instructional feedback is essential for
// student development».

A continuación se documentan las vistas implementadas con capturas del prototipo en ejecución.

#block(breakable: false)[
#leyenda([Figura], 12, [Acceso: (a) inicio de sesión y (b) creación de cuenta])
#align(center)[
#grid(
  columns: (1fr, 1fr),
  gutter: 8pt,
  image("capturas/01-autenticacion.png", width: 100%),
  image("capturas/01b-registro.png", width: 100%),
)
]
]

#block(breakable: false)[
#leyenda([Figura], 13, [Lobby de juego y sala de espera con la configuración de la partida])
#align(center)[
#grid(
  columns: (1fr, 1fr),
  gutter: 8pt,
  image("capturas/02-lobby.png", width: 100%),
  image("capturas/03-sala-espera.png", width: 100%),
)
]
]

#block(breakable: false)[
#leyenda([Figura], 14, [Rondas de una partida: (a) dictado, (b) espera entre rondas y (c) repentinización])
#align(center)[
#image("capturas/04-dictado.png", width: 78%)
#image("capturas/05-espera-entre-rondas.png", width: 78%)
#image("capturas/06-repentinizacion.png", width: 78%)
]
]

#block(breakable: false)[
#leyenda([Figura], 15, [Galería final: (a) recorrido de una melodía y (b) resultados con desglose de errores y pistas de mejora])
#align(center)[
#grid(
  columns: (1fr, 1fr),
  gutter: 8pt,
  image("capturas/07-galeria-melodia.png", width: 100%),
  image("capturas/08-galeria-resultados.png", width: 100%),
)
]
]

#block(breakable: false)[
#leyenda([Figura], 16, [Inicio del estudiante: historial de partidas, progreso temporal e insights])
#align(center)[
#image("capturas/09-inicio-estudiante.png", width: 90%)
]
]

#block(breakable: false)[
#leyenda([Figura], 17, [Vista docente: (a) inicio con partidas en desarrollo y salones, (b) partidas del salón en vivo, (c) partidas pasadas y (d) filtro por estudiante])
#align(center)[
#grid(
  columns: (1fr, 1fr),
  gutter: 8pt,
  image("capturas/10-inicio-docente.png", width: 100%),
  image("capturas/11-salon-partidas-en-vivo.png", width: 100%),
  image("capturas/12-salon-partidas-pasadas.png", width: 100%),
  image("capturas/12b-salon-filtro-estudiante.png", width: 100%),
)
]
]

#block(breakable: false)[
#leyenda([Figura], 18, [Vista de salón: (a) estudiantes con métricas y progreso temporal y (b) invitaciones pendientes])
#align(center)[
#grid(
  columns: (1fr, 1fr),
  gutter: 8pt,
  image("capturas/13-salon-estudiantes.png", width: 100%),
  image("capturas/14-salon-invitaciones.png", width: 100%),
)
]
]

#block(breakable: false)[
#leyenda([Figura], 19, [Espectación: (a) vista general del intercambio, (b) detalle por melodía, (c) detalle por jugador con informe de errores y (d) espectación en vivo])
#align(center)[
#grid(
  columns: (1fr, 1fr),
  gutter: 8pt,
  image("capturas/15-espectacion-vista-general.png", width: 100%),
  image("capturas/16-espectacion-detalle-melodia.png", width: 100%),
  image("capturas/17-espectacion-detalle-jugador.png", width: 100%),
  image("capturas/18-espectacion-en-vivo.png", width: 100%),
)
]
]

== 4.10. Integración, pruebas y validación técnica

=== 4.10.1. Estrategia de pruebas

Las pruebas se organizaron en cinco niveles: unitarias, de humo, de barrido de parámetros, de compilación y de navegador. La Tabla 16 resume el alcance de cada nivel. Las pruebas unitarias cubren el dominio musical, las reglas de juego y el feedback; las de humo cubren la transcripción y el flujo multijugador completo contra la API; el barrido cubre los parámetros de transcripción; la compilación verifica la integración de Next.js, Payload y TypeScript; y la prueba de navegador verifica el flujo de juego y las vistas docentes.

#block(breakable: false)[
#leyenda([Tabla], 16, [Estrategia de pruebas])
#apatable(
  columns: (3.6cm, 5.8cm, 6.5cm),
  header: ([*Nivel*], [*Alcance*], [*Herramienta y evidencia*]),
  rows: (
    ([Unitarias], [Generador, evaluador, informe de errores, reglas de juego, feedback y parámetros de transcripción], [Vitest; 107 pruebas.]),
    ([Humo], [Transcripción de una sinusoide de 2 s y flujo multijugador contra la API (roles, salas, rondas, invitaciones, espectación)], [Pruebas del tracker DSP y script de humo con 35 comprobaciones.]),
    ([Barrido], [25 casos sintéticos con ruido y vibrato], [`tune:transcription`; ajuste de parámetros.]),
    ([Compilación], [Build de producción de Next.js], [`next build`; sin errores.]),
    ([Navegador], [Flujo multijugador completo, galería, historial y vistas docentes], [Recorrido manual en Chrome con capturas de la Figura 12 a la Figura 19.]),
  ),
)]

=== 4.10.2. Pruebas unitarias

La Tabla 17 resume las 107 pruebas unitarias. El generador concentra 30 pruebas porque cada propiedad estructural se verifica sobre 25 semillas por nivel y su evaluación reproducible añade una prueba más; el evaluador concentra 21, incluyendo los casos límite de la Tabla 13; las reglas de juego —actividad por ronda, asignación encadenada, evaluación de respuestas, puntuación, ordenaciones y reconstrucción de cadenas— concentran 29; el informe de errores y el feedback del historial concentran 18; y la transcripción concentra 9, entre parámetros de inferencia y pruebas del tracker DSP.

#block(breakable: false)[
#leyenda([Tabla], 17, [Resultados de las pruebas unitarias])
#apatable(
  columns: (4.8cm, 2.8cm, 8.3cm),
  header: ([*Módulo*], [*Pruebas*], [*Cobertura*]),
  rows: (
    ([Generador], [30], [Propiedades estructurales, modulación, reproducibilidad y evaluación reproducible del capítulo V.]),
    ([Evaluador], [21], [Emparejamiento, tolerancias y casos límite.]),
    ([Reglas de juego], [29], [Rondas, asignación encadenada, puntuación, ordenaciones y cadenas.]),
    ([Informe de errores y feedback], [18], [Localización de errores, tendencias y pistas de mejora.]),
    ([Transcripción], [9], [Parámetros de inferencia y tracker DSP.]),
    ([Total], [107], [—]),
  ),
)]

=== 4.10.3. Pruebas de transcripción

La transcripción se verificó con una señal sinusoidal y con un banco de 25 casos sintéticos. El hallazgo principal fue que el ruido blanco no produce notas falsas, pero el ruido tonal por debajo del registro cantado sí: el zumbido de red, la ventilación o los golpes de escritorio generan notas espurias. Acotar el rango de inferencia a 75–1500 Hz fue la medida decisiva. La Tabla 18 resume el efecto.

#block(breakable: false)[
#leyenda([Tabla], 18, [Resultados del banco sintético de transcripción])
#apatable(
  columns: (4.2cm, 4cm, 7.7cm),
  header: ([*Condición*], [*Precisión*], [*Observación*]),
  rows: (
    ([Sin filtro de frecuencia], [0.30], [El ruido tonal genera notas espurias.]),
    ([Con rango 75–1500 Hz], [0.98], [Sin pérdida de notas reales.]),
    ([Filtrado por amplitud], [Sin mejora], [Las notas espurias no son más débiles que las reales.]),
  ),
)]

Estos resultados provienen de audio sintético y deben confirmarse con voz cantada real. El filtrado por amplitud no se adoptó porque las notas espurias no presentan una amplitud menor que las notas reales; el filtrado por frecuencia sí se adoptó porque elimina el ruido fuera del registro vocal sin afectar las notas del ejercicio.

=== 4.10.4. Integración del flujo de juego

La compilación de producción se ejecutó sin errores. En el navegador se verificó el flujo completo: acceso, sala con configuración, ronda de dictado con piano roll, espera entre rondas, ronda de repentización con grabación, transcripción en Worker y galería final con resultados. Se verificó que la transcripción puede ejecutarse dos veces en una misma partida sin bloquear la interfaz. El cliente incorpora un watchdog que cancela una solicitud estancada. Cada envío se persiste en `Submissions` al completarse la ronda, y las grabaciones en `Media` al enviarse; si la subida de audio falla, la respuesta se registra igualmente y la galería muestra la transcripción simbólica.

=== 4.10.5. Validación con voz cantada

// PLACEHOLDER: protocolo de validación pendiente de ejecución. Reescribir con
// las grabaciones, métricas y resultados reales.

El protocolo de validación con voz cantada real comprende un conjunto de grabaciones de melodías conocidas, interpretadas por participantes de distintas tesituras y niveles de experiencia. El conjunto incluye grabaciones con y sin ruido moderado, diferentes micrófonos y distintos navegadores. Para cada grabación se compara la transcripción automática con la referencia y se calculan la precisión de altura y la precisión de ataques. Esta validación técnica no sustituye la evaluación pedagógica del capítulo V.

=== 4.10.6. Pruebas de la versión multijugador

El flujo multijugador se verificó con una prueba de humo de la API de 35 comprobaciones y con un recorrido en navegador con dos sesiones independientes. La prueba de humo cubre: registro e inicio de sesión con cookie, sala por código, inicio reservado al anfitrión, melodías iniciales distintas por jugador, encadenamiento exacto de la ronda 1 a la 2 en ambos sentidos —cada jugador recibe la respuesta del otro y ninguno la propia—, bloqueo del doble envío en una misma ronda, ausencia de fuga de respuestas ajenas antes de tiempo, cierre de la partida y cálculo de la clasificación. Sobre el módulo docente cubre además la autorización por rol —el estudiante no accede a la espectación ni al detalle de salones ajenos, y el docente no puede jugar—, las invitaciones con aceptar, rechazar y re-invitar, el filtrado por estudiante con su puntaje individual, el historial con posición y la espectación en vivo y en frío con sus tres sub-vistas. Las invariantes de la asignación encadenada, la puntuación y la reconstrucción de cadenas se verifican además en las 29 pruebas unitarias de reglas de juego (Tabla 17).

El recorrido en navegador verificó la creación y unión a salas desde dos sesiones, la alternancia de rondas, la pantalla de espera, la galería con grabaciones y el filtrado por configuración, además de las vistas docentes y de espectación en vivo y sobre partidas terminadas. Quedan pendientes las pruebas de reconexión y abandono y la medición de latencia del transporte de sincronización (sección 4.7.5).

=== 4.10.7. Limitaciones y amenazas a la validez

La validación de la transcripción se realizó con audio sintético; la voz cantada introduce vibrato, portamentos, consonantes y respiración que pueden alterar la detección. La evaluación de usabilidad se limitó a recorridos manuales en un navegador de escritorio; no se realizó un estudio con usuarios. La evaluación pedagógica corresponde al capítulo V y no se deduce de las pruebas técnicas. El prototipo implementa el flujo completo —multijugador, galería, historial y vistas docentes—, pero las reglas de abandono y reconexión y el control de acceso a nivel de las colecciones de juego siguen abiertos (secciones 4.7.5 y 4.8.5). La política de datos de las grabaciones se delimita al estudio experimental (sección 4.8.4): la gobernanza de datos propia de un producto comercial queda fuera del alcance del artefacto, y las grabaciones se eliminarán tras el análisis. El piano roll simplifica la lectura respecto del pentagrama y puede reducir la validez ecológica de la repentización. El registro de la dificultad alta y la validez del puntaje compuesto global son limitaciones reconocidas del diseño actual; las reglas del feedback formativo usan umbrales propios que requieren validación con docentes.

== 4.11. Síntesis del capítulo

El prototipo integra un generador procedural determinista, un evaluador de similitud con emparejamiento bipartito y localización de errores, una transcripción de audio en el navegador, la mecánica multijugador de intercambio encadenado de producciones, la galería final con retroalimentación formativa, el historial del estudiante con tendencias temporales y un módulo docente con salones de clase, métricas por estudiante y espectación de partidas, todo sobre Payload y PostgreSQL. Las pruebas unitarias, las pruebas de humo de la API y el banco sintético de transcripción evidencian el funcionamiento de los componentes implementados; la efectividad pedagógica se evalúa en el capítulo V.

// ============ Capítulo V ============
// Resultados y discusión del primer objetivo específico: generador procedural.
// Datos: 200 semillas por dificultad, generador 0.1.0, tempo 90, compás 4/4.
// Fuente de los datos: evaluación ejecutada sobre src/lib/music/generator.ts.

#import "@preview/cetz:0.5.2": canvas, draw
#import "@preview/cetz-plot:0.1.4": chart

#let colores-intervalos = (rgb("#6366f1"), rgb("#22c55e"), rgb("#f59e0b"))

= Capítulo V: Resultados y discusión

El presente capítulo reporta los resultados de la evaluación del generador procedural de melodías, correspondiente al primer objetivo específico. La evaluación se organizó en dos partes: una verificación estructural sobre un conjunto de 200 melodías por nivel de dificultad y un análisis de la variedad melódica y rítmica de las secuencias producidas. Los resultados se presentan en la sección 5.1 y se discuten en la sección 5.2.

== 5.1. Resultados

=== 5.1.1. Configuración de la evaluación

La evaluación se ejecutó sobre el generador en su versión 0.1.0, con 200 semillas por nivel de dificultad, lo que produjo un total de 600 melodías. Se fijaron un tempo de 90 BPM y un compás de 4/4 para aislar el efecto de la dificultad. Las semillas siguieron el patrón `resultado-{dificultad}-###` y se procesaron con la misma ruta de código que utiliza la aplicación. Para cada melodía se registraron el éxito de generación, el tiempo de cómputo, la distribución de intervalos, el ambitus, las duraciones, la tonalidad, la escala, la modulación y la unicidad de la secuencia. La Tabla 19 resume la configuración.

#block(breakable: false)[
#leyenda([Tabla], 19, [Configuración de la evaluación del generador])
#apatable(
  columns: (4.5cm, 11.4cm),
  header: ([*Parámetro*], [*Valor*]),
  rows: (
    ([Versión del generador], [`0.1.0`]),
    ([Semillas por dificultad], [200]),
    ([Total de melodías], [600]),
    ([Tempo], [90 BPM]),
    ([Compás], [4/4]),
    ([Tonalidades], [C, G, D, A, F, Bb y Eb]),
    ([Modos], [Mayor y menor natural]),
    ([Patrón de semilla], [`resultado-{dificultad}-###`]),
  ),
)]

=== 5.1.2. Cumplimiento de restricciones y reproducibilidad

Las 600 melodías se generaron sin fallos. En los tres niveles, el 100 % de las melodías cumplió la pertenencia a la escala activa y la regla de no repetición triple. La figura rítmica requerida se cumplió en el 100 % de las melodías de dificultad media y alta; en dificultad baja no se exige. El tiempo medio de generación fue de 0.14 ms en baja, 0.30 ms en media y 0.51 ms en alta; el percentil 95 no superó 0.59 ms. La Tabla 20 resume estos resultados.

#block(breakable: false)[
#leyenda([Tabla], 20, [Cumplimiento de restricciones y tiempo de generación])
#set text(size: 10.5pt)
#apatable(
  columns: (2.4cm, 2.2cm, 1.5cm, 1.8cm, 2.0cm, 1.8cm, 2.2cm, 2.0cm),
  inset: (x: 4pt, y: 5pt),
  header: (
    [*Dificultad*],
    [*Generadas*],
    [*Fallos*],
    [*Escala (%)*],
    [*Anti-rep. (%)*],
    [*Figura (%)*],
    [*Tiempo medio (ms)*],
    [*Tiempo p95 (ms)*],
  ),
  rows: (
    ([Baja], [200], [0], [100], [100], [—], [0.14], [0.23]),
    ([Media], [200], [0], [100], [100], [100], [0.30], [0.39]),
    ([Alta], [200], [0], [100], [100], [100], [0.51], [0.59]),
    ([Total], [600], [0], [—], [—], [—], [—], [—]),
  ),
)]

La reproducibilidad se verificó con la misma tupla de parámetros: dos ejecuciones producen la misma melodía. La sensibilidad a la semilla se verificó con semillas distintas, que producen secuencias distintas. La combinación de ambas propiedades es la base de la auditabilidad del generador: una melodía puede reconstruirse a partir de su semilla, su dificultad, su tempo y su compás.

=== 5.1.3. Perfil de intervalos y ambitus

La Tabla 21 y la Figura 20 muestran la distribución de intervalos. Predominan los intervalos de 1 a 2 semitonos, es decir, el movimiento por grado conjunto que impone el generador. Los intervalos de 0 semitonos, es decir, las notas repetidas, se reducen de forma notable a medida que crece la dificultad —19.6 % en baja, 9.5 % en media y 0 % en alta— como consecuencia de la penalización de repetición. Los saltos de 3 a 7 semitonos aparecen solo en media (21.6 %) y alta (26.3 %); en baja no hay saltos, como exige el límite de intervalo máximo de 2 semitonos.

#block(breakable: false)[
#leyenda([Tabla], 21, [Distribución de intervalos por nivel de dificultad])
#apatable(
  columns: (3cm, 4.3cm, 4.3cm, 4.3cm),
  header: ([*Intervalo (semitonos)*], [*Baja (%)*], [*Media (%)*], [*Alta (%)*]),
  rows: (
    ([0], [19.6], [9.5], [0.0]),
    ([1], [34.1], [31.1], [32.1]),
    ([2], [46.2], [37.8], [41.6]),
    ([3], [0.0], [11.6], [12.9]),
    ([4], [0.0], [4.9], [4.6]),
    ([5], [0.0], [5.1], [5.4]),
    ([6], [0.0], [0.0], [0.8]),
    ([7], [0.0], [0.0], [2.6]),
  ),
)]

#block(breakable: false)[
#leyenda([Figura], 20, [Distribución de intervalos por nivel de dificultad])
#align(center)[
#set text(size: 9pt)
#canvas({
  draw.set-style(legend: (fill: white), barchart: (bar-width: .75, cluster-gap: 0))
  chart.barchart(
    (
      ([0], 19.6, 9.5, 0.0),
      ([1], 34.1, 31.1, 32.1),
      ([2], 46.2, 37.8, 41.6),
      ([3], 0, 11.6, 12.9),
      ([4], 0, 4.9, 4.6),
      ([5], 0, 5.1, 5.4),
      ([6], 0, 0, 0.8),
      ([7], 0, 0, 2.6),
    ),
    mode: "clustered",
    size: (13, 6),
    label-key: 0,
    value-key: (..range(1, 4)),
    y-tick-step: 10,
    x-label: [Porcentaje de intervalos (%)],
    y-label: [Intervalo (semitonos)],
    labels: ([Baja], [Media], [Alta]),
    bar-style: (idx => (fill: colores-intervalos.at(idx))),
    legend: "inner-south-west",
  )
})
]
]

El ambitus medio fue de 4.0, 8.72 y 13.23 semitonos, por debajo del máximo permitido (12, 19 y 24 semitonos, la tesitura cantable). El uso del ambitus fue del 33.0 %, 46.0 % y 55.0 %: el registro se acota a una tesitura cantable (C3–C5) y el uso crece con la dificultad. La duración media fue de 9.8, 14.9 y 23.6 pulsos, equivalentes a 6.5, 9.9 y 15.7 s a 90 BPM. La modulación apareció en el 48 % de las melodías de dificultad media y en el 100 % de las de dificultad alta; en baja no se aplica. La Tabla 22 resume estos valores.

#block(breakable: false)[
#leyenda([Tabla], 22, [Ambitus, duración y modulación por nivel de dificultad])
#apatable(
  columns: (2.2cm, 2.2cm, 2.2cm, 2.0cm, 2.4cm, 2.4cm, 2.5cm),
  header: (
    [*Dificultad*],
    [*Ambitus medio (st)*],
    [*Ambitus máx. (st)*],
    [*Uso (%)*],
    [*Duración (pulsos)*],
    [*Duración (s)*],
    [*Modulación (%)*],
  ),
  rows: (
    ([Baja], [4.0], [12], [33.0], [9.8], [6.5], [0]),
    ([Media], [8.72], [19], [46.0], [14.9], [9.9], [48]),
    ([Alta], [13.23], [24], [55.0], [23.6], [15.7], [100]),
  ),
)]

Las tonalidades y los modos se distribuyeron de forma equilibrada: las siete tonalidades aparecieron entre 20 y 40 veces por nivel, y la proporción entre mayor y menor se mantuvo cerca de 50/50. Esto indica que la selección de tonalidad no está sesgada por el generador.

=== 5.1.4. Variedad melódica y rítmica

La Tabla 23 y la Figura 21 muestran la variedad melódica. El número medio de alturas distintas por melodía fue de 3.5 en baja (de 8 notas), 5.9 en media (de 15) y 8.9 en alta (de 24). La repetición de notas disminuye con la dificultad: el 87 % de las melodías de baja, el 82.5 % de las de media y ninguna de las de alta contienen al menos un par de notas repetidas; la longitud máxima de una racha de notas iguales fue 2 en baja y media y 1 en alta. Los cambios de dirección del contorno fueron 2.1, 6.5 y 13.1 en promedio, muy por encima de los valores anteriores, lo que indica un contorno más variado. La variedad rítmica, medida como número de duraciones distintas por melodía, fue de 1.9, 2.9 y 4.9. Las secuencias únicas fueron 97 %, 100 % y 100 %.

#block(breakable: false)[
#leyenda([Tabla], 23, [Variedad melódica y rítmica por nivel de dificultad])
#set text(size: 10.5pt)
#apatable(
  columns: (2.2cm, 2.8cm, 2.2cm, 2.2cm, 2.4cm, 2.2cm, 1.9cm),
  inset: (x: 4pt, y: 5pt),
  header: (
    [*Dificultad*],
    [*Alturas / notas*],
    [*Repetidos (%)*],
    [*Saltos ≥3 st*],
    [*Cambios de dir.*],
    [*Dur. distintas*],
    [*Únicas (%)*],
  ),
  rows: (
    ([Baja], [3.5 / 8], [19.6], [0.0], [2.1], [1.9], [97.0]),
    ([Media], [5.9 / 15], [9.5], [21.6], [6.5], [2.9], [100]),
    ([Alta], [8.9 / 24], [0.0], [26.3], [13.1], [4.9], [100]),
  ),
)]

La Figura 21 presenta una melodía de muestra por nivel, con la modulación marcada por la línea vertical. En las tres se observa un contorno dominado por el grado conjunto, con saltos ocasionales y cambios de dirección que crecen con la dificultad; el detalle de las notas depende de la semilla.

#block(breakable: false)[
#leyenda([Figura], 21, [Melodías generadas por nivel de dificultad])
#align(center)[
#set text(size: 9pt)
#text(weight: "bold")[Baja — Mi bemol mayor — 8 notas (MIDI 58–65)]
#v(0.15em)
#block(width: 15cm, height: 2.6cm, stroke: 0.5pt + rgb("#d4d4d8"), fill: rgb("#fafafa"), clip: true)[
  #place(dx: 0.00%, dy: 62.50%, rect(width: 9.09%, height: 12.50%, fill: rgb("#6366f1"), radius: 0.4pt))
  #place(dx: 9.09%, dy: 37.50%, rect(width: 9.09%, height: 12.50%, fill: rgb("#6366f1"), radius: 0.4pt))
  #place(dx: 18.18%, dy: 62.50%, rect(width: 18.18%, height: 12.50%, fill: rgb("#6366f1"), radius: 0.4pt))
  #place(dx: 36.36%, dy: 87.50%, rect(width: 9.09%, height: 12.50%, fill: rgb("#6366f1"), radius: 0.4pt))
  #place(dx: 45.45%, dy: 62.50%, rect(width: 18.18%, height: 12.50%, fill: rgb("#6366f1"), radius: 0.4pt))
  #place(dx: 63.64%, dy: 37.50%, rect(width: 18.18%, height: 12.50%, fill: rgb("#6366f1"), radius: 0.4pt))
  #place(dx: 81.82%, dy: 25.00%, rect(width: 9.09%, height: 12.50%, fill: rgb("#6366f1"), radius: 0.4pt))
  #place(dx: 90.91%, dy: 0.00%, rect(width: 9.09%, height: 12.50%, fill: rgb("#6366f1"), radius: 0.4pt))
]
#v(0.7em)
#text(weight: "bold")[Media — Si bemol menor — 15 notas (MIDI 58–70)]
#v(0.15em)
#block(width: 15cm, height: 2.6cm, stroke: 0.5pt + rgb("#d4d4d8"), fill: rgb("#fafafa"), clip: true)[
  #place(dx: 48.00%, dy: 0%, rect(width: 0.6pt, height: 100%, fill: rgb("#a1a1aa")))
  #place(dx: 0.00%, dy: 92.31%, rect(width: 4.00%, height: 7.69%, fill: rgb("#22c55e"), radius: 0.4pt))
  #place(dx: 4.00%, dy: 69.23%, rect(width: 4.00%, height: 7.69%, fill: rgb("#22c55e"), radius: 0.4pt))
  #place(dx: 8.00%, dy: 53.85%, rect(width: 16.00%, height: 7.69%, fill: rgb("#22c55e"), radius: 0.4pt))
  #place(dx: 24.00%, dy: 53.85%, rect(width: 4.00%, height: 7.69%, fill: rgb("#22c55e"), radius: 0.4pt))
  #place(dx: 28.00%, dy: 92.31%, rect(width: 8.00%, height: 7.69%, fill: rgb("#22c55e"), radius: 0.4pt))
  #place(dx: 36.00%, dy: 69.23%, rect(width: 8.00%, height: 7.69%, fill: rgb("#22c55e"), radius: 0.4pt))
  #place(dx: 44.00%, dy: 38.46%, rect(width: 4.00%, height: 7.69%, fill: rgb("#22c55e"), radius: 0.4pt))
  #place(dx: 48.00%, dy: 30.77%, rect(width: 8.00%, height: 7.69%, fill: rgb("#22c55e"), radius: 0.4pt))
  #place(dx: 56.00%, dy: 38.46%, rect(width: 8.00%, height: 7.69%, fill: rgb("#22c55e"), radius: 0.4pt))
  #place(dx: 64.00%, dy: 15.38%, rect(width: 8.00%, height: 7.69%, fill: rgb("#22c55e"), radius: 0.4pt))
  #place(dx: 72.00%, dy: 0.00%, rect(width: 4.00%, height: 7.69%, fill: rgb("#22c55e"), radius: 0.4pt))
  #place(dx: 76.00%, dy: 15.38%, rect(width: 4.00%, height: 7.69%, fill: rgb("#22c55e"), radius: 0.4pt))
  #place(dx: 80.00%, dy: 0.00%, rect(width: 4.00%, height: 7.69%, fill: rgb("#22c55e"), radius: 0.4pt))
  #place(dx: 84.00%, dy: 15.38%, rect(width: 8.00%, height: 7.69%, fill: rgb("#22c55e"), radius: 0.4pt))
  #place(dx: 92.00%, dy: 30.77%, rect(width: 8.00%, height: 7.69%, fill: rgb("#22c55e"), radius: 0.4pt))
]
#v(0.7em)
#text(weight: "bold")[Alta — Mi bemol mayor — 24 notas (MIDI 62–72)]
#v(0.15em)
#block(width: 15cm, height: 2.6cm, stroke: 0.5pt + rgb("#d4d4d8"), fill: rgb("#fafafa"), clip: true)[
  #place(dx: 47.34%, dy: 0%, rect(width: 0.6pt, height: 100%, fill: rgb("#a1a1aa")))
  #place(dx: 0.00%, dy: 90.91%, rect(width: 2.37%, height: 9.09%, fill: rgb("#f59e0b"), radius: 0.4pt))
  #place(dx: 2.37%, dy: 81.82%, rect(width: 3.55%, height: 9.09%, fill: rgb("#f59e0b"), radius: 0.4pt))
  #place(dx: 5.92%, dy: 18.18%, rect(width: 2.37%, height: 9.09%, fill: rgb("#f59e0b"), radius: 0.4pt))
  #place(dx: 8.28%, dy: 36.36%, rect(width: 5.33%, height: 9.09%, fill: rgb("#f59e0b"), radius: 0.4pt))
  #place(dx: 13.61%, dy: 45.45%, rect(width: 7.10%, height: 9.09%, fill: rgb("#f59e0b"), radius: 0.4pt))
  #place(dx: 20.71%, dy: 36.36%, rect(width: 1.78%, height: 9.09%, fill: rgb("#f59e0b"), radius: 0.4pt))
  #place(dx: 22.49%, dy: 45.45%, rect(width: 5.33%, height: 9.09%, fill: rgb("#f59e0b"), radius: 0.4pt))
  #place(dx: 27.81%, dy: 36.36%, rect(width: 5.33%, height: 9.09%, fill: rgb("#f59e0b"), radius: 0.4pt))
  #place(dx: 33.14%, dy: 45.45%, rect(width: 5.33%, height: 9.09%, fill: rgb("#f59e0b"), radius: 0.4pt))
  #place(dx: 38.46%, dy: 63.64%, rect(width: 5.33%, height: 9.09%, fill: rgb("#f59e0b"), radius: 0.4pt))
  #place(dx: 43.79%, dy: 81.82%, rect(width: 1.78%, height: 9.09%, fill: rgb("#f59e0b"), radius: 0.4pt))
  #place(dx: 45.56%, dy: 90.91%, rect(width: 1.78%, height: 9.09%, fill: rgb("#f59e0b"), radius: 0.4pt))
  #place(dx: 47.34%, dy: 63.64%, rect(width: 3.55%, height: 9.09%, fill: rgb("#f59e0b"), radius: 0.4pt))
  #place(dx: 50.89%, dy: 0.00%, rect(width: 7.10%, height: 9.09%, fill: rgb("#f59e0b"), radius: 0.4pt))
  #place(dx: 57.99%, dy: 18.18%, rect(width: 5.33%, height: 9.09%, fill: rgb("#f59e0b"), radius: 0.4pt))
  #place(dx: 63.31%, dy: 27.27%, rect(width: 3.55%, height: 9.09%, fill: rgb("#f59e0b"), radius: 0.4pt))
  #place(dx: 66.86%, dy: 18.18%, rect(width: 3.55%, height: 9.09%, fill: rgb("#f59e0b"), radius: 0.4pt))
  #place(dx: 70.41%, dy: 27.27%, rect(width: 7.10%, height: 9.09%, fill: rgb("#f59e0b"), radius: 0.4pt))
  #place(dx: 77.51%, dy: 18.18%, rect(width: 1.78%, height: 9.09%, fill: rgb("#f59e0b"), radius: 0.4pt))
  #place(dx: 79.29%, dy: 27.27%, rect(width: 5.33%, height: 9.09%, fill: rgb("#f59e0b"), radius: 0.4pt))
  #place(dx: 84.62%, dy: 18.18%, rect(width: 5.33%, height: 9.09%, fill: rgb("#f59e0b"), radius: 0.4pt))
  #place(dx: 89.94%, dy: 27.27%, rect(width: 2.37%, height: 9.09%, fill: rgb("#f59e0b"), radius: 0.4pt))
  #place(dx: 92.31%, dy: 0.00%, rect(width: 5.33%, height: 9.09%, fill: rgb("#f59e0b"), radius: 0.4pt))
  #place(dx: 97.63%, dy: 27.27%, rect(width: 2.37%, height: 9.09%, fill: rgb("#f59e0b"), radius: 0.4pt))
]
#v(0.4em)
#text(size: 8pt)[La línea vertical gris marca la modulación. Cada barra representa una nota; el ancho indica su duración.]
]
]

=== 5.1.5. Síntesis de resultados

En síntesis, el generador cumple las restricciones estructurales en el 100 % de los casos, es reproducible y computacionalmente barato. La contrapartida es una variedad melódica limitada: predominan los intervalos de 0 a 2 semitonos, el ambitus utilizado es menor que el permitido y todas las melodías contienen notas repetidas. Esta brecha entre cumplimiento y variedad es el eje de la discusión.

== 5.2. Discusión

=== 5.2.1. Sobre el cumplimiento de las restricciones

El cumplimiento del 100 % es consecuencia directa del diseño de generar y verificar. La función de validación rechaza cualquier melodía que viole las restricciones y el generador reintenta con otra secuencia pseudoaleatoria. La ausencia de fallos en 600 melodías indica que el espacio de soluciones es factible para los tres niveles y que el presupuesto de 50 intentos es suficiente. El tiempo medio de 0.14 a 0.51 ms confirma que el costo de reintentar es despreciable para melodías de 8 a 24 notas.

La reproducibilidad refuerza la utilidad del generador en un contexto educativo y de investigación. Una melodía puede reconstruirse a partir de su semilla, su dificultad, su tempo y su compás, lo que permite auditar una partida, repetir un experimento o generar el mismo ejercicio para distintos jugadores. La sensibilidad a la semilla evita que todas las partidas compartan el mismo material.

=== 5.2.2. Sobre el perfil melódico y la repetitividad

El perfil melódico es consecuencia de las decisiones de diseño, ahora derivadas del estado del arte. La ponderación de selección de alturas sitúa el peso máximo en el grado conjunto (un semitono), por encima de la repetición (distancia 0) y de los saltos; la penalización de repetición crece con la dificultad (eje de frecuencia de patrones de Poćwiardowski et al., 2025) y la estructura de frases cierra cada frase en un tono estable. Como resultado, el contorno está dominado por el movimiento por grado conjunto: los intervalos de 1 a 2 semitonos representan el 80.3 %, 68.9 % y 73.7 % en baja, media y alta.

La repetición de notas es escasa y decreciente con la dificultad: los intervalos de 0 semitonos representan el 19.6 %, 9.5 % y 0 %, y solo el 87 %, 82.5 % y 0 % de las melodías contienen un par de notas repetidas (la racha máxima fue de 2). Los cambios de dirección del contorno (2.1, 6.5 y 13.1) y las alturas distintas (3.5, 5.9 y 8.9) confirman un contorno variado. El ambitus real (4.0, 8.72 y 13.23 semitonos) sigue por debajo del máximo permitido, coherente con que el ambitus es un límite y no un objetivo: el generador no busca ocupar todo el registro, sino producir melodías cantables dentro de la tesitura.

Esta variación es relevante para el uso pedagógico: los ejercicios ejercitan la identificación de grados conjuntos, la de saltos y la memoria de contornos, y la escasa repetición evita secuencias estáticas. La comparación con Troubadour es consistente con este diseño: allí la dificultad modula la presencia de intervalos específicos y de movimientos en direcciones alternadas (Pesek et al., 2020a); aquí ese efecto se logra mediante la ponderación por grado conjunto y la penalización de repetición, que escalan con el nivel.

=== 5.2.3. Sobre la reproducibilidad y el uso pedagógico

La reproducibilidad y el bajo costo computacional hacen que el generador sea adecuado para la generación de ejercicios en tiempo real y para la investigación replicable. La semilla permite reconstruir una melodía y verificar que la evaluación corresponde al material generado. La distribución equilibrada de tonalidades y modos evita un sesgo sistemático hacia una tonalidad o un modo, y la tasa de modulación coincide con la configuración: 48 % en media frente al 50 % previsto y 100 % en alta.

No obstante, la reproducibilidad no garantiza la equidad entre jugadores. Dos semillas distintas pueden producir melodías con distinto ambitus real, distinta proporción de saltos y distinta variedad rítmica. En los datos, el ambitus real de la dificultad alta varía entre 3 y 26 semitonos, y el de la baja entre 1 y 6. Si dos jugadores reciben semillas distintas, la dificultad nominal es la misma, pero la dificultad efectiva puede diferir. Esta observación sugiere que la asignación de melodías debería estratificarse por el perfil real de la melodía, o que el generador debería aceptar solo melodías dentro de una banda de variedad.

=== 5.2.4. Limitaciones y mejoras

La evaluación es estructural y computacional. No se realizó una valoración perceptual con docentes ni una comparación con ejercicios compuestos por humanos; por tanto, los resultados no establecen que las melodías sean musicalmente idiomáticas o pedagógicamente adecuadas. La muestra de 200 semillas por nivel describe el comportamiento del generador, pero no agota el espacio de semillas posibles.

El generador tampoco modela silencios, ligaduras ni una gramática rítmica explícita. La variedad rítmica se limita a las duraciones permitidas y a los ataques que resultan de su suma; la dificultad alta incluye valores de 1.5 y 2/3, pero las síncopas no se generan como una estructura intencional.

De las mejoras propuestas en la versión anterior, dos se han incorporado en esta revisión —la penalización de la repetición y la estructura de frases— y una se aborda parcialmente, al controlar el perfil mediante la ponderación por grado conjunto. Quedan por delante tres mejoras:

#listasin[
  + *Fijar un perfil objetivo, no solo un máximo.* Definir una distribución objetivo de intervalos y un ambitus objetivo por nivel, y aceptar una melodía solo si su perfil cae dentro de una banda.
  + *Medir la diversidad en la validación.* Incluir el número de alturas distintas, la proporción de intervalos repetidos y los cambios de dirección como criterios de aceptación automáticos.
  + *Validar con docentes y comparar con ejercicios humanos.* Complementar la verificación estructural con una valoración musical y pedagógica, y contrastar las melodías generadas con ejercicios compuestos por especialistas.
]

=== 5.2.5. Respuesta al primer objetivo específico

El primer objetivo específico se cumple en el plano del diseño y de la implementación verificada. El algoritmo existe, genera ejercicios para dictado y repentización, satisface las restricciones estructurales en el 100 % de los casos evaluados, es reproducible y su costo computacional es despreciable. La evidencia también muestra que la reforma derivada del estado del arte mejoró la variedad melódica: la repetición de notas se redujo de forma acusada (los intervalos de 0 semitonos pasaron del 35–41 % al 0–19.6 %) y los contornos son más variados, todo ello dentro de una tesitura cantable. La dificultad nominal se aproxima así a una dificultad musical efectiva, aunque la equivalencia exacta entre ambas y la idoneidad pedagógica siguen requiriendo la validación con docentes y la comparación con ejercicios humanos.

La evaluación de la calidad musical con docentes y la comparación con ejercicios humanos son actividades que complementan este resultado y permiten pasar de la verificación estructural a la validación pedagógica.

= Referencias

#[
  #set par(first-line-indent: 0pt, hanging-indent: 1.27cm, leading: 1em, spacing: 1em)

  Almeida, C., Kalinowski, M., Uchôa, A., & Feijó, B. (2022). Negative effects of gamification in education software: Systematic mapping and practitioner perceptions. Information And Software Technology, 156, 107142. https://doi.org/10.1016/j.infsof.2022.107142

  Ananda, R. F., Milyartini, R., & Sukmayadi, Y. (2025). Mapping the Use of Digital Game-Based Learning in Music Education: A Scoping Review. Jurnal Pendidikan Indonesia, 6(11), 4982-4989. https://doi.org/10.59141/japendi.v6i11.8772

  Barlow, S. (2016). Improving Aural Skills within the Curriculum: A Literature Review. Victorian Journal Of Music Education/Victorian Journal Of Music Education (Online), 1, 23. http://files.eric.ed.gov/fulltext/EJ1146509.pdf

  Brandl, L. C., & Schrader, A. (2024). Serious Games in Higher Education in the Transforming Process to Education 4.0—Systematized Review. Education Sciences, 14(3), 281. https://doi.org/10.3390/educsci14030281

  Cervantes, R. C. (2014). El desarrollo de las habilidades auditivas en la formación del músico profesional. MAGOTZI Boletín Científico de Artes del IA, 2(4). https://doi.org/10.29057/ia.v2i4.638

  Chen, B., & Li, C. (2025). A Quasi-Experimental Study on the Application of MuseScore Software to Improve Sight-Singing and Ear-Training Abilities in Music Education at Chuzhou University. International Journal Of Sociologies And Anthropologies Science Reviews, 5(5), 609-626. https://doi.org/10.60027/ijsasr.2025.6482

  Chen, C. W. J. (2014). Mobile learning: Using application Auralbook to learn aural skills. International Journal Of Music Education, 33(2), 244-259. https://doi.org/10.1177/0255761414533308

  Chenette, T. (2021). What Are the Truly Aural Skills? Music Theory Online, 27(2). https://doi.org/10.30535/mto.27.2.2

  Chenette, T., Davis, S., & Kleppinger, S. V. (2022). A Critical Review of Current Aural Skills Materials and Pedagogical Practices. Journal of Music Theory Pedagogy, 36(1). https://doi.org/10.71156/2994-7073.1410

  De Carvalho, C. V., & Coelho, A. (2022). Game-Based Learning, Gamification in Education and Serious Games. Computers, 11(3), 36. https://doi.org/10.3390/computers11030036

  Demian, A.-M. y Nedelcut, N. (2018). The Mental Processes Involved in the Musical Dictation. Music Cognition, 4, 86-97.

  Djaouti, D., Alvarez, J., & Jessel, J. (2011). Classifying serious games. En Advances in game-based learning book series (pp. 118-136). https://doi.org/10.4018/978-1-60960-495-0.ch006

  Donn, R., Stillie, B., & Moir, Z. (2024). The shifting sands of UK secondary music curricula: problematising relationships between aural training and music literacy. Music Education Research, 26(1), 58-70. https://doi.org/10.1080/14613808.2024.2309204

  Fernandez, A. D. (2025). Desarrollo de una aplicación web para el entrenamiento auditivo y enseñanza musical para miembros del Club de Música de la PUCE Ibarra \[Trabajo de titulación\]. Pontificia Universidad Católica del Ecuador.

  Giraldo, S., Waddell, G., Nou, I., Ortega, A., Mayor, O., Perez, A., Williamon, A., & Ramirez, R. (2019). Automatic Assessment of Tone Quality in Violin Music Performance. Frontiers In Psychology, 10, 334. https://doi.org/10.3389/fpsyg.2019.00334

  Hannon, A. (2015). Helping Non-Singers Overcome Fear and Anxiety in Aural Skills. Journal of Music Theory Pedagogy E-Journal, 5, Article 2. https://digitalcollections.lipscomb.edu/jmtp_ejournal/vol5/iss1/2

  Huovinen, E., Ylitalo, A.-K., y Puurtinen, M. (2018). Early Attraction in Temporally Controlled Sight Reading of Music. Journal of Eye Movement Research, 11(2), 1-30. https://doi.org/10.16910/jemr.11.2.3

  Kavčič Pucihar, A., Habe, K., Rotar Pance, B., & Laure, M. (2024). The key reasons for dropout in Slovenian music schools – a qualitative study. Frontiers in Psychology, 15, 1385840. https://doi.org/10.3389/fpsyg.2024.1385840

  Kim, S., & Cozzarin, J. (2023). A new technical ear training game and its effect on critical listening skills. Applied Sciences, 13(9), 5357. https://doi.org/10.3390/app13095357

  Kleppinger, N. S. V. (2017). Practical and Philosophical Reflections Regarding Aural Skills Assessment. Indiana Theory Review, 33(1-2), 153. https://doi.org/10.2979/inditheorevi.33.1-2.06

  Kumar, S., Jaiswal, S., Singh, P., & Arora, V. (2026). Automatic detection and analysis of singing mistakes for music learning by imitation. IEEE Transactions On Audio, Speech, And Language Processing. https://doi.org/10.1109/taslpro.2026.3682047

  Lingjie, A. (2025). Effectiveness Study of Applying Earmaster for Ear Training in Chinese University Students. International Journal Of Sociologies And Anthropologies Science Reviews, 5(2), 29-38. https://doi.org/10.60027/ijsasr.2025.5514

  Lu, L. (2025). AI-powered intelligent music education systems for real-time feedback and performance assessment. International Journal Of Information And Communication Technology, 1(1). https://doi.org/10.1504/ijict.2025.10071414

  McNeil, B. (2021). Aural Skills Pedagogy in the Wind Band: A Survey of Secondary and Collegiate Wind Band Conductors’ Perceptions and Strategies \[Disertación de PhD, Auburn University\]. https://etd.auburn.edu/handle/10415/7610

  Mingyu, G., Yunus, M. M., & Rafiq, K. R. M. (2024). Educational Games and Game-based Approaches in Higher Education: A Systematic Review (2014-2023). International Journal Of Academic Research In Progressive Education And Development, 13(1). https://doi.org/10.6007/ijarped/v13-i1/20555

  Nichols, B. E., & Springer, D. G. (2025). Piano history, aural skills, and working memory predict melodic dictation performance. Frontiers In Psychology, 16, 1579714. https://doi.org/10.3389/fpsyg.2025.1579714

  Ou, J., Nogueira, J., & Qin, C. (2025). Exploring the impact of AI-assisted practice applications on music learners’ performance, self-efficacy, and self-regulated learning. Frontiers In Psychology, 16, 1675762. https://doi.org/10.3389/fpsyg.2025.1675762

  Page, M. J., McKenzie, J. E., Bossuyt, P. M., Boutron, I., Hoffmann, T. C., Mulrow, C. D., Shamseer, L., Tetzlaff, J. M., Akl, E. A., Brennan, S. E., Chou, R., Glanville, J., Grimshaw, J. M., Hróbjartsson, A., Lalu, M. M., Li, T., Loder, E. W., Mayo-Wilson, E., McDonald, S., ... Moher, D. (2021). The PRISMA 2020 statement: an updated guideline for reporting systematic reviews. BMJ, 372, n71. https://doi.org/10.1136/bmj.n71

  Paney, A. S., & Buonviri, N. O. (2017). Developing Melodic Dictation Pedagogy: A Survey of College Theory Instructors. Update: Applications of Research in Music Education, 36(1), 51-58. https://doi.org/10.1177/8755123316686815

  Peffers, K., Tuunanen, T., Rothenberger, M. A., & Chatterjee, S. (2008). A design science research methodology for information systems research. Journal of Management Information Systems, 24(3), 45-77. https://doi.org/10.2753/MIS0742-1222240302

  Pesek, M., Vucko, Z., Savli, P., Kavcic, A., & Marolt, M. (2020a). Troubadour: A Gamified e-Learning Platform for Ear Training. IEEE Access, 8, 97090-97102. https://doi.org/10.1109/access.2020.2994389

  Pesek, M., Suhadolnik, L., Šavli, P., & Marolt, M. (2020b). Motivating Students for Ear-Training with a Rhythmic Dictation Application. Applied Sciences, 10(19), 6781. https://doi.org/10.3390/app10196781

  Pomerleau-Turcotte, J., Moreno Sala, M. T., Dubé, F., & Vachon, F. (2021). Experiential and Cognitive Predictors of Sight-Singing Performance in Music Higher Education. Journal of Research in Music Education. https://doi.org/10.1177/00224294211049425

  Qian, C., & Jiang, M. (2024). Exploring the Effects of Digital Game-Based Learning on Music Education. Studies In Social Science & Humanities, 3(5), 6-9. https://doi.org/10.56397/sssh.2024.05.02

  Respati, R., Apriyaningsih, E., & Muslihin, H. Y. (2021). The development of Aurilio games to facilitate the ear training of early childhood. Proceedings of the 3rd International Conference on Arts and Design Education (ICADE 2020).

  Rethlefsen, M. L., Kirtley, S., Waffenschmidt, S., Ayala, A. P., Moher, D., Page, M. J., & Koffel, J. B. (2021). PRISMA-S: an extension to the PRISMA Statement for Reporting Literature Searches in Systematic Reviews. Systematic Reviews, 10, 39. https://doi.org/10.1186/s13643-020-01542-z

  Richards, J. (2023). Discovering the Pedagogy and Secrets of Gamification and Game-Based Learning Applied to the Music Theory Classroom \[Disertación\]. Liberty University.

  Rogers, M. (2013). Aural dictation affects high achievement in sight singing, performance and composition skills. Australian Journal Of Music Education/Australian Journal Of Music Education (Online), 1, 34. http://files.eric.ed.gov/fulltext/EJ1061809.pdf

  Román-Celi, G. E. (2023). Aprendizaje Basado en Juegos (GBL) en el desarrollo del pensamiento crítico \[Games Based Learning (GBL) in the development of critical thinking\]. Cognopolis Revista de Educación y Pedagogía, 1(3), 1-14. https://doi.org/10.62574/5m9rgk11

  Royston, N., & Wilson, J. (2024). Do You Want to Major in Music?: A Guide to Majoring in Music or Music Education in American Colleges and Universities. https://doi.org/10.31274/isudp.2024.157

  Thompson, S. & Lehmann, A. C. (2004). Strategies for sight-reading and improvising music. En A. Williamon (Ed.), Musical excellence (pp.143-159). Oxford University Press. https://doi.org/10.1093/acprof:oso/9780198525356.003.0008

  Vallejo, D. (2019). Allegra: Gamification-based Tool to Practice Melodic Dictation \[Trabajo de fin de grado\]. Universidad de Castilla-La Mancha.

  Wang, X., & Haris, M. F. B. (2025). AI-Driven Violin Performance Evaluation: A Deep Learning Approach for Automated Assessment and Personalized Feedback in Music Education. En Proceedings of the 2025 International Conference on Generative Artificial Intelligence and Digital Media (pp. 126-132). https://doi.org/10.1145/3734921.3734941

  Wristen, B. (2005). Cognition and Motor Execution in Piano Sight-Reading: A Review of Literature. Update Applications Of Research In Music Education, 24(1), 44-56. https://doi.org/10.1177/87551233050240010106

  Zhang, H., Cheung, V. K. M., Nishioka, H., Dixon, S., & Furuya, S. (2025). LLaQo: Towards a query-based coach in expressive music performance assessment. En ICASSP 2025 - 2025 IEEE International Conference on Acoustics, Speech and Signal Processing (ICASSP). https://doi.org/10.1109/icassp49660.2025.10890522
]

= Anexos

== Anexo A. Estudios seleccionados del estado del arte

#set page(flipped: true, margin: (x: 1.5cm, y: 2cm))
#set text(size: 8pt)
#set par(first-line-indent: 0pt, leading: 0.75em, spacing: 0.75em)

#let anexo-filas = (
  (
    [C1],
    [Kim S.; Cozzarin J.],
    [A New Technical Ear Training Game and Its Effect on Critical Listening Skills],
    [10.3390/app13095357],
    [juego gamificado ear training (sin ML)],
    [n/d (CRM solo evaluación)],
    [mejora significativa habla en ruido (p=0.003)],
    [no cubre dictado melódico],
  ),
  (
    [C1b],
    [G. Amaral; A. Baffa; J. -P. Briot; B. Feijó; A. Furtado],
    [An adaptive music generation architecture for games based on the deep learning Transformer model],
    [10.1109/sbgames56371.2022.9961081],
    [Transformer adaptativo por emociones],
    [playlist Spotify ambient (~20 h)],
    [prueba de concepto funcional en juego],
    [control en tiempo real aún abierto],
  ),
  (
    [C2a],
    [H. Meng; S. Zheng; S. Zhou; Q. Wang; Y. Song],
    [Aligning Language Models for Lyric-to-Melody Generation with Rule-Based Musical Constraints],
    [10.1109/icassp55912.2026.11462728],
    [LLM con reglas + DPO/KTO],
    [~800k pares letra-melodía],
    [supera SongMASS; MOS 3.42],
    [sin evaluación nota a nota],
  ),
  (
    [C2a],
    [Guo Y.; Liu Y.; Zhou T.; Xu L.; Zhang Q.],
    [An automatic music generation and evaluation method based on transfer learning],
    [10.1371/journal.pone.0283103],
    [GPT-2 transfer + evaluación MEM],
    [POP909],
    [0.536 en tests vs 0.099 LSTM],
    [sin calibración de dificultad],
  ),
  (
    [C2a],
    [Nakayama M.; Hayashi T.; Takahashi T.; Nishiura T.],
    [Comfortable Sound Design Based on Auditory Masking with Chord Progression and Melody Generation Corresponding to the Peak Frequencies of Dental Treatment Noises],
    [10.3390/app142210467],
    [generación procedural por reglas],
    [n/d (paletas Flow Machines)],
    [PFMR 77.8% vs 67.5%; más confort],
    [pocas reglas formales con dificultad],
  ),
  (
    [C2a],
    [S. -L. Wu; Y. -H. Yang],
    [Compose & Embellish: Well-Structured Piano Performance Generation via A Two-Stage Approach],
    [10.1109/icassp49357.2023.10095098],
    [dos Transformers REMI (dos etapas)],
    [Lakh MIDI, Pop1K7],
    [mejor estructura; MOS 3.18 vs 2.33],
    [coherencia estructural aún inferior],
  ),
  (
    [C2a],
    [J. Zhang; G. Fazekas; C. Saitis],
    [Composer Style-Specific Symbolic Music Generation using Vector Quantized Discrete Diffusion Models],
    [10.1109/mlsp58920.2024.10734713],
    [VQ-VAE + difusión discreta],
    [MAESTRO (3 compositores)],
    [control de estilo 72.4% (SOTA)],
    [sin control fino de dificultad],
  ),
  (
    [C2a],
    [Zhang Z.; Yu Y.; Takasu A.],
    [Controllable lyrics-to-melody generation],
    [10.1007/s00521-023-08728-1],
    [LSTM-GAN multirrama con estilo],
    [~13k pares letra-melodía],
    [control altura/tempo ~4.9/5],
    [poco explorado en educación],
  ),
  (
    [C2a],
    [S. Hou; S. Liu; R. Yuan; W. Xue; Y. Shan; M. Zhao; C. Zhang],
    [Editing Music with Melody and Text: Using ControlNet for Diffusion Transformer],
    [10.1109/icassp49660.2025.10890309],
    [Diffusion Transformer + ControlNet],
    [MTG-Jamendo, FMA, WikiMuTe],
    [melody accuracy 56.6% vs 44.7%],
    [faltan métricas melódicas simbólicas],
  ),
  (
    [C2a],
    [M. Zhou; X. Li; F. Yu; W. Li],
    [EMelodyGen: Emotion-Conditioned Melody Generation in ABC Notation with the Musical Feature Template],
    [10.1109/icmew68306.2025.11152266],
    [Transformer con plantilla rasgo-emoción],
    [Rough4Q (~234k melodías)],
    [99% parseo; 91% alineación emocional],
    [escasez de datos simbólicos etiquetados],
  ),
  (
    [C2a],
    [He S.],
    [Exploring Music Style Transfer and Innovative Composition using Deep Learning Algorithms],
    [10.14569/ijacsa.2024.01505101],
    [GAN con atención de canal],
    [POP909],
    [mejor teoría musical (7.9/10)],
    [sin control explícito de parámetros],
  ),
  (
    [C2a],
    [M. Agarwal; C. Wang; G. Richard],
    [F-StrIPE: Fast Structure-Informed Positional Encoding for Symbolic Music Generation],
    [10.1109/icassp49660.2025.10888904],
    [positional encoding estructural F-StrIPE],
    [POP909 (con alineación)],
    [mejor CS 16.61; complejidad lineal],
    [elección de prior estructural abierta],
  ),
  (
    [C2a],
    [Z. Xie; Q. He; Y. Zhu; Q. He; M. Li],
    [FilmComposer: LLM-Driven Music Production for Silent Film Clips],
    [10.1109/cvpr52734.2025.01262],
    [multi-agente LLM + MusicGen],
    [MusicPro-7k (cine mudo)],
    [SOTA FAD 0.207; 60% preferencia],
    [faltaban datasets/métricas de cine],
  ),
  (
    [C2a],
    [Kamberaj V.; Kadriu A.; Besimi N.],
    [From Dataset to Melody: Enhancing Music Composition with Computational Models],
    [10.56345/ijrdv12n2007],
    [Markov + gramática generativa],
    [MIDI propio ethno-fusion],
    [dentro de parámetros; útil a profesionales],
    [sin métricas nota a nota],
  ),
  (
    [C2a],
    [Qiu Y.; Zhang J.; Ren H.; Shan Y.; Zhou J.],
    [Humming2Music: Being A Composer As Long As You Can Humming],
    [10.24963/ijcai.2023/840],
    [transcripción MusicYOLO + plantillas],
    [SSVD, Opencpop, POP909],
    [tarareo reflejado; 46% valora bien],
    [pocos completan tarareos de calidad],
  ),
  (
    [C2a],
    [K. Bhandari; S. Chang; T. Lu; F. R. Enus; L. B. Bradshaw; D. Herremans; S. Colton],
    [ImprovNet - Generating Controllable Musical Improvisations with Iterative Corruption Refinement],
    [10.1109/ijcnn64981.2025.11229312],
    [Transformer con refinamiento iterativo],
    [ATEPP, MAESTRO, PiJAMA],
    [79% identifica transferencia jazz],
    [sin unificación de tareas musicales],
  ),
  (
    [C2a],
    [Duan W.; Zhang Z.; Yu Y.; Oyama K.],
    [Interpretable Melody Generation from Lyrics with Discrete-Valued Adversarial Training],
    [10.1145/3503161.3547742],
    [GAN Gumbel-Softmax letra→melodía],
    [dataset letra-melodía Yu et al.],
    [embeddings de sílabas más precisos],
    [consistencia letra-melodía débil],
  ),
  (
    [C2a],
    [Shan Y.; Zhang J.; Ren H.; Qiu Y.; Zhou J.],
    [LingGe: An Automatic Ancient Chinese Poem-to-Song Generation System],
    [10.24963/ijcai.2023/842],
    [plantillas por reglas poema→canción],
    [28.9k melodías, POP909, OpenSinger],
    [ritmo/estructura coherentes (demo)],
    [datos pareados letra-melodía escasos],
  ),
  (
    [C2a],
    [J. Poćwiardowski; M. Modrzejewski; M. S. Tatara],
    [M6(GPT)3: Generating Multitrack Modifiable Multi-Minute MIDI Music from Text using Genetic Algorithms, Probabilistic Methods and GPT Models in any Progression and Time Signature],
    [10.1109/icmew68306.2025.11152218],
    [algoritmos genéticos + Markov + LLM],
    [n/d (sin entrenamiento)],
    [supera MMT en 4/5 criterios],
    [datasets sesgados a compás 4/4],
  ),
  (
    [C2a],
    [J. Zhang; G. Fazekas; C. Saitis],
    [Mamba-Diffusion Model with Learnable Wavelet for Controllable Symbolic Music Generation],
    [10.1109/ijcnn64981.2025.11228274],
    [difusión Mamba con wavelet],
    [POP909 (64k muestras)],
    [OA 0.939; preferencia 80/100],
    [sin consenso en evaluación objetiva],
  ),
  (
    [C2a],
    [Pitombeira L.],
    [Melodic generation via computational processes: a preliminary and pedagogical overview; \[Geração melódica via processos computacionais: um panorama preliminar e pedagógico\]],
    [10.20504/opus2026.32.06],
    [panorama pedagógico transformaciones],
    [n/d],
    [n/d (solo valor pedagógico)],
    [transformaciones sin formalizar algoritmos],
  ),
  (
    [C2a],
    [Agustín-Aquino O.A.; Santiago-Santos A.],
    [Melody and Variation Generation Through KAM Theory],
    [10.1007/978-3-031-60638-0\_14],
    [sistemas dinámicos (teoría KAM)],
    [n/d (método sin datos)],
    [variaciones sutiles con 2 parámetros],
    [sin control de ritmo ni dificultad],
  ),
  (
    [C2a],
    [Li S.; Sung Y.],
    [MelodyDiffusion: Chord-Conditioned Melody Generation Using a Transformer-Based Diffusion Model],
    [10.3390/math11081915],
    [difusión Transformer por acordes],
    [OpenEWLD (13.9k pares)],
    [Hits\@1 72.4% con acordes],
    [sin parámetros pedagógicos ni semilla],
  ),
  (
    [C2a],
    [Z. Lin; J. Chen; B. Tang; B. Sha; J. Yang; Y. Ju; F. Fan; S. Kang; Z. Wu; H. Meng],
    [Multi-View Midivae: Fusing Track- and Bar-View Representations for Long Multi-Track Symbolic Music Generation],
    [10.1109/icassp48485.2024.10448249],
    [VAE multivista OctupleMIDI],
    [CocoChorales (240k corales)],
    [accuracy 0.969; MOS 3.46],
    [sin dificultad pedagógica ni determinismo],
  ),
  (
    [C2a],
    [S. -L. Wu; C. Donahue; S. Watanabe; N. J. Bryan],
    [Music ControlNet: Multiple Time-Varying Controls for Music Generation],
    [10.1109/taslp.2024.3399026],
    [difusión ControlNet musical],
    [~1800 h instrumental propio],
    [49% más fiel a melodía que MusicGen],
    [no conecta con evaluación del alumno],
  ),
  (
    [C2a],
    [C. C. Liao; D. Liao; E. L. Zhang],
    [MusicAIR: A Multimodal AI Music Generation Framework Powered by an Algorithm-Driven Core],
    [10.1109/bigdata66926.2025.11400911],
    [algoritmos/reglas puros (sin ML)],
    [n/d (método sin datos)],
    [key confidence 0.85 vs 0.79 humano],
    [no aplicado a entrenamiento auditivo],
  ),
  (
    [C2a],
    [Y. Qian; T. Wang; J. Chen; P. Yu; D. Xu; X. Jin; F. Yu; S. -C. Zhu],
    [MusicAOG: An Energy-Based Model for Learning and Sampling a Hierarchical Representation of Symbolic Music],
    [10.1109/tcss.2024.3521445],
    [gramática And-Or + modelo de energía],
    [3 corales de Bach],
    [mejor subjetivo con solo 3 piezas],
    [sin ejercicios de dictado calibrados],
  ),
  (
    [C2a],
    [S. Rouard; R. S. Roman; Y. Adi; A. Roebel],
    [MusicGen-Stem: Multi-stem music generation and edition through autoregressive modeling],
    [10.1109/icassp49660.2025.10890052],
    [Transformer autorregresivo multistem],
    [MMI, ShutterStock, Pond5 (17k h)],
    [HAR 66-68% en edición de stems],
    [coherencia no ligada a evaluación docente],
  ),
  (
    [C2a],
    [J. Chen; X. Tang; T. Xie; J. Wang; W. Dong; B. Shi],
    [MusicMamba: A Dual-Feature Modeling Approach for Generating Chinese Traditional Music with Modal Precision],
    [10.1109/icassp49660.2025.10890633],
    [Mamba+Transformer dual REMI-M],
    [POP909, FolkDB],
    [estilo 85.3%; modo 66.1%],
    [precisión modal no usada como dificultad],
  ),
  (
    [C2a],
    [M. Agarwal; C. Wang; G. Richard],
    [Of All StrIPEs: Investigating Structure-Informed Positional Encoding for Efficient Music Generation],
    [10.1109/taslpro.2026.3662483],
    [positional encoding estructural RoPEPool],
    [POP909 (anotaciones)],
    [RoPEPool-BIN mejor GS/NDD],
    [priors no usados para graduar dictado],
  ),
  (
    [C2a],
    [Y. Yi; W. Li; M. M. Y. Kuo; Q. Bai],
    [PerceiverS: A Multi-Scale Perceiver With Effective Segmentation for Long-Term Expressive Symbolic Music Generation],
    [10.1109/taslpro.2025.3611836],
    [Perceiver multi-escala con segmentación],
    [MAESTRO (1.251 secuencias)],
    [OA +40%; expertos prefieren (3.29)],
    [sin control por dificultad ni semilla],
  ),
  (
    [C2a],
    [Raposo A.N.; Soares V.N.G.J.],
    [Phrase-Oriented Generative Rhythmic Patterns for Jazz Solos],
    [10.3390/app152011058],
    [Markov/bigrams rítmicos frase a frase],
    [Weimar Jazz (~289k notas)],
    [frases indistinguibles del test],
    [sin melodías didácticas con semilla],
  ),
  (
    [C2a],
    [X. Liang; Z. Zhao; W. Zeng; Y. He; F. He; Y. Wang; C. Gao],
    [PianoBART: Symbolic Piano Music Generation and Understanding with Large-Scale Pre-Training],
    [10.1109/icme57554.2024.10688332],
    [pre-entrenamiento BART (PianoBART)],
    [Pop1K7, ASAP, POP909, MAESTRO],
    [reconstrucción 96.7% vs 79.6%],
    [sin control de dificultad ni semilla],
  ),
  (
    [C2a],
    [J. Choi; K. Lee],
    [Pop2Piano : Pop Audio-Based Piano Cover Generation],
    [10.1109/icassp49357.2023.10095653],
    [T5 audio→MIDI (cover de piano)],
    [PSP (4.989 tracks)],
    [MCA 0.402 comparable a humano],
    [falta transcripción de canto en navegador],
  ),
  (
    [C2a],
    [Zhang C.; Chang L.; Wu S.; Tan X.; Qin T.; Liu T.-Y.; Zhang K.],
    [ReLyMe: Improving Lyric-to-Melody Generation by Incorporating Lyric-Melody Relationships],
    [10.1145/3503161.3548357],
    [decodificación con reglas (soft constraints)],
    [TeleMelody/SongMASS (EN, ZH)],
    [transición tonal 0.45→0.61],
    [reglas no aplicadas a evaluación],
  ),
  (
    [C2a],
    [Z. Wang; L. Ma; C. Zhang; B. Han; Y. Xu; Y. Wang; X. Chen; H. Hong; W. Liu; X. Wu; K. Zhang],
    [REMAST: Real-Time Emotion-Based Music Arrangement With Soft Transition],
    [10.1109/taffc.2024.3486224],
    [arreglo emocional MLP+Transformer],
    [11 datasets (~34k piezas)],
    [mejor coherencia; ansiedad −21.6%],
    [sin evaluación del desempeño del usuario],
  ),
  (
    [C2a],
    [Mazurkiewicz J.],
    [Sofcomputing approach to melody generation based on harmonic analysis],
    [10.24425/ijet.2024.149516],
    [red feedforward por análisis armónico],
    [2 secuencias propias],
    [mejor melodía: 11% de error],
    [sin parámetros de dificultad explícitos],
  ),
  (
    [C2a],
    [Ding S.; Liu Z.; Dong X.; Zhang P.; Qian R.; Huang J.; He C.; Lin D.; Wang J.],
    [SongComposer: A Large Language Model for Lyric and Melody Generation in Song Composition],
    [10.18653/v1/2025.acl-long.352],
    [LLM musical InternLM2 multinivel],
    [SongCompose (283k letras, 20k MIDI)],
    [PD 50.75% vs 36.43% GPT-4],
    [faltan métricas nota a nota],
  ),
  (
    [C2a],
    [M. Agarwal; C. Wang; G. Richard],
    [Structure-Informed Positional Encoding for Music Generation],
    [10.1109/icassp48485.2024.10448149],
    [PE estructural para Transformers],
    [POP909 (alineaciones corregidas)],
    [mejor SSMD y CS que baselines],
    [sin métricas melódico-rítmicas interpretables],
  ),
  (
    [C2a],
    [S. Sulun; M. E. P. Davies; P. Viana],
    [Symbolic Music Generation Conditioned on Continuous-Valued Emotions],
    [10.1109/access.2022.3169744],
    [Transformer con emociones continuas],
    [Lakh-Spotify, LPD-5],
    [supera a discrete-token; menor error emocional],
    [no aplicado a dificultad adaptativa],
  ),
  (
    [C2a],
    [G. Wu; S. Liu; X. Fan],
    [The Power of Fragmentation: A Hierarchical Transformer Model for Structural Segmentation in Symbolic Music Generation],
    [10.1109/taslp.2023.3263797],
    [Transformer jerárquico con segmentación],
    [Bach, MAESTRO, GuitarPro propio],
    [supera baselines; menos acumulación de error],
    [sin control de dificultad ni semillas],
  ),
  (
    [C2a],
    [Y. -J. Shih; S. -L. Wu; F. Zalkow; M. Müller; Y. -H. Yang],
    [Theme Transformer: Symbolic Music Generation With Theme-Conditioned Transformer],
    [10.1109/tmm.2022.3161851],
    [Transformer condicionado por tema],
    [POP909],
    [temas coherentes, cercanos a originales],
    [sin variación determinista ni evaluación nota a nota],
  ),
  (
    [C2a],
    [S. Rhyu; H. Choi; S. Kim; K. Lee],
    [Translating Melody to Chord: Structured and Flexible Harmonization of Melody With Transformer],
    [10.1109/access.2022.3155467],
    [Transformer de armonización con VAE],
    [CMD, HLSD],
    [acordes más estructurados; control de complejidad],
    [sin control paramétrico de dificultad],
  ),
  (
    [C2a],
    [L. Zhuo; Z. Wang; B. Wang; Y. Liao; C. Bao; S. Peng; S. Han; A. Zhang; F. Fang; S. Liu],
    [Video Background Music Generation: Dataset, Method and Evaluation],
    [10.1109/iccv51070.2023.01433],
    [generación por vídeo en 3 etapas],
    [SymMV, POP909],
    [supera a CMT; preferencia >50%],
    [sin métricas nota a nota ni control estructural],
  ),
  (
    [C2a],
    [X. Yi; Q. He; G. Xia; Z. Wang],
    [ViTex: Visual Texture Control for Multi-Track Symbolic Music Generation via Discrete Diffusion Models],
    [10.1109/icassp55912.2026.11463443],
    [difusión discreta por textura visual],
    [Lakh MIDI, MetaMIDI],
    [mejor control y calidad que baselines],
    [textura bajo nivel; sin control de dificultad],
  ),
  (
    [C2a],
    [S. Tian; C. Zhang; W. Yuan; W. Tan; W. Zhu],
    [XMusic: Towards a Generalized and Controllable Symbolic Music Generation Framework],
    [10.1109/tmm.2025.3590912],
    [framework multimodal con prompts],
    [XMIDI (108k MIDI)],
    [supera a CP, EMOPIA y CMT],
    [sin control paramétrico determinista],
  ),
  (
    [C2a; C2b; C3a],
    [S. Li; Y. Qin; M. Zheng; X. Jin; Y. Liu],
    [Diff-BGM: A Diffusion Model for Video Background Music Generation],
    [10.1109/cvpr52733.2024.02582],
    [difusión latente condicionada por vídeo],
    [BGM909, SymMV],
    [supera a CMT; casi música humana],
    [sin métricas nota a nota con tolerancias],
  ),
  (
    [C2a; C3a],
    [J. Huang; Z. Novack; P. Long; Y. Hou; K. Chen; T. Berg-Kirkpatrick; J. McAuley],
    [MuseTok: Symbolic Music Tokenization for Generation and Semantic Understanding],
    [10.1109/icassp55912.2026.11463020],
    [tokenización por compás con RQ-VAE],
    [PDMX, POP909 y otros],
    [excelente PPL; débil en melodía],
    [sin evaluación nota a nota en cents/ms],
  ),
  (
    [C2a; C3a; C3b; C4a],
    [L. Kim; S. Jeon; W. Heo; J. Park],
    [Note-Level Singing Melody Transcription for Time-Aligned Musical Score Generation],
    [10.1109/taslpro.2025.3544064],
    [transcripción de canto end-to-end],
    [ST500, DALI, HSD],
    [F1 0.771 onset+pitch; SOTA],
    [pocos datos con figuras rítmicas],
  ),
  (
    [C2a; C4a],
    [C. Ding; A. R. Gorle; S. Bhattacharya; D. Hasteer; N. Sagan; T. Weissman],
    [LzMidi: Compression-Based Symbolic Music Generation],
    [10.1109/isit63088.2025.11195229],
    [generación por compresión LZ78],
    [Lakh MIDI],
    [rápido y competitivo en WD/FAD],
    [sin control paramétrico de dificultad],
  ),
  (
    [C2a; C4a],
    [Y. Ye; W. Zheng; Y. Zang],
    [Pitch-Class Steering For Diffusion-Based Music Generation Via Latent-Space Probes],
    [10.1109/mlsp68619.2026.11772565],
    [steering por probe en difusión],
    [MAESTRO],
    [coherencia melódica ×2.4 sin degradar],
    [sin control fino de ritmo/registro],
  ),
  (
    [C2a; C4b],
    [S. Liu; X. Li; D. Li; Y. Shan],
    [Humtrans: A Novel Open-Source Dataset for Humming Melody Transcription and Beyond],
    [10.1109/icassp48485.2024.10445818],
    [dataset de tarareo (sin método)],
    [HumTrans propio (56 h)],
    [mayor dataset; transcriptores muy pobres],
    [escasez de datos; transcripción sin resolver],
  ),
  (
    [C2b],
    [H. Zhang; V. K. M. Cheung; H. Nishioka; S. Dixon; S. Furuya],
    [LLaQo: Towards a Query-Based Coach in Expressive Music Performance Assessment],
    [10.1109/icassp49660.2025.10890522],
    [LLM audio-lingüístico para evaluación],
    [10+ datasets + NeuroPiano],
    [supera LLM; aún bajo no-LLM],
    [feedback sin timestamps del error],
  ),
  (
    [C2b],
    [Andono P.N.; Noersasongko E.; Shidik G.F.; Hastuti K.; Sudaryanto S.; Syarif A.M.],
    [Melody Difficulty Classification using Frequent Pattern and Inter-Notes Distance Analysis],
    [10.14569/ijacsa.2022.0130215],
    [clasificación de dificultad por reglas],
    [50 piezas gamelan],
    [82% accuracy vs expertos],
    [no validado fuera de gamelan],
  ),
  (
    [C3a],
    [C. Weiß; G. Peeters],
    [Comparing Deep Models and Evaluation Strategies for Multi-Pitch Estimation in Music Recordings],
    [10.1109/taslp.2022.3200547],
    [comparación de modelos de multi-pitch],
    [MusicNet, SWD y mixto],
    [arquitecturas similares; split domina diferencias],
    [sin consenso en splits y métricas],
  ),
  (
    [C3a],
    [M. Krause; C. Weiß; M. Müller],
    [Soft Dynamic Time Warping for Multi-Pitch Estimation and Beyond],
    [10.1109/icassp49357.2023.10095907],
    [pérdida SoftDTW para multi-pitch],
    [SWD, MAESTRO, MusicNet],
    [iguala o supera a MCTC],
    [faltan alineamientos simples multi-etiqueta],
  ),
  (
    [C3a],
    [A. Lukoianov; A. Klapuri],
    [Transcribing Rhythmic Patterns of the Guitar Track in Polyphonic Music],
    [10.1109/waspaa66052.2025.11230935],
    [MERT fine-tuneado + Viterbi rítmico],
    [931 grabaciones propias (4 niveles)],
    [F1 96.9% rasgueos; patrones 94.7%],
    [vocabularios curados; tempo no estable],
  ),
  (
    [C3a],
    [M. Wachter; S. Murgul; M. Heizmann],
    [Transformer-Based Rhythm Quantization of Performance MIDI Using Beat Annotations],
    [10.1109/icsm64417.2025.11541508],
    [Transformer T5 para cuantización rítmica],
    [ASAP, Leduc],
    [onset F1 97.3%; generaliza compases],
    [poco explorado vs beat implícito],
  ),
  (
    [C3a; C4a],
    [S. Yong; L. Su; J. Nam],
    [A Phoneme-Informed Neural Network Model For Note-Level Singing Transcription],
    [10.1109/icassp49357.2023.10096707],
    [CRNN mel + fonemas (PPG)],
    [SSVD, CSD, TIMIT],
    [F1 onset 0.93; supera a TONY],
    [re-onsets difíciles; datasets pequeños],
  ),
  (
    [C3b],
    [S. Kumar; S. Jaiswal; P. Singh; V. Arora],
    [Automatic Detection and Analysis of Singing Mistakes for Music Learning by Imitation],
    [10.1109/taslpro.2026.3682047],
    [detección de errores de canto (TCN)],
    [M3 propio (teacher-learner)],
    [F1 82-91% con collar],
    [criterios variables entre docentes],
  ),
  (
    [C4a],
    [Minor K.A.; Kartowisastro I.H.],
    [Automatic Music Transcription Using Fourier Transform for Monophonic and Polyphonic Audio File],
    [10.18280/isi.270413],
    [transcripción DSP por FFT],
    [5 canciones conocidas],
    [bueno en monofónico; falla polifonía],
    [FFT falla en polifónico por armónicos],
  ),
  (
    [C4a],
    [Berendes H.-U.; Saha A.; Maman B.; Arifi-Müller V.; Müller M.],
    [Beethoven Symphony Excerpt Dataset (BSED): An Evaluation Dataset for Orchestral Music Transcription],
    [10.5334/tismir.343],
    [benchmark orquestal + baseline AMT],
    [BSD, MusicNet, BSED],
    [F1 onset 71%; alineación por nota clave],
    [faltan métricas para unísonos/multi-instrumento],
  ),
  (
    [C4a],
    [Cao R.; Liang Z.; Yan Z.; Liu B.],
    [DAFE-MSGAT: Dual-Attention Feature Extraction and Multi-Scale Graph Attention Network for Polyphonic Piano Transcription],
    [10.3390/electronics13193939],
    [CNN doble atención + grafos],
    [MAPS, MAESTRO],
    [F1 nota 84%; alto recall],
    [offset débil; armónicos en texturas densas],
  ),
  (
    [C4a],
    [X. Fu; X. Yuan; J. Hu],
    [HSD: A hierarchical singing annotation dataset],
    [10.1109/ism55400.2022.00054],
    [dataset de canto jerárquico],
    [HSD propio (68 canciones)],
    [precisión de etiquetado como MIR-ST500],
    [pocos datasets frase-nota con letra],
  ),
  (
    [C4a],
    [J. Mi; S. Kim; T. Toda],
    [Improved Architecture for High-resolution Piano Transcription to Efficiently Capture Acoustic Characteristics of Music Signals],
    [10.1109/apsipaasc63619.2025.10848780],
    [CRNN dilatada + decodificador Transformer],
    [MAESTRO v2/v3],
    [F1 onset 97.3% con menos parámetros],
    [precisión vs eficiencia en modelos pequeños],
  ),
  (
    [C4a],
    [Korade N.B.; Salunke M.B.; Bhosle A.A.; Sangve S.M.; Joshi D.M.; Asalkar G.G.; Kadu S.R.; Sarwade J.M.],
    [Intelligent Guitar Chord Recognition Using Spectrogram-Based Feature Extraction and AlexNet Architecture for Categorization],
    [10.14569/ijacsa.2025.0160475],
    [clasificación de acordes con AlexNet],
    [1440 wav propios (8 acordes)],
    [96% accuracy con espectrogramas],
    [poco estudiada la elección de features],
  ),
  (
    [C4a],
    [Bhattarai B.; Lee J.],
    [Korean Pansori Vocal Note Transcription Using Attention-Based Segmentation and Viterbi Decoding],
    [10.3390/app14020492],
    [atención + Viterbi para canto],
    [MedleyDB],
    [80% accuracy; comparable a pYin],
    [sin ground truth no occidental],
  ),
  (
    [C4a],
    [X. Wang; B. Tian; W. Yang; W. Xu; W. Cheng],
    [MusicYOLO: A Vision-Based Framework for Automatic Singing Transcription],
    [10.1109/taslp.2022.3221005],
    [detección YOLOX sobre CQT],
    [SSVD, MIR-ST500],
    [F1 onset 96%; mejor generalización],
    [falta evaluación de lectura a primera vista],
  ),
  (
    [C4a],
    [A. Fernandez],
    [Onsets and Velocities: Affordable Real-Time Piano Transcription Using Convolutional Neural Networks],
    [10.23919/eusipco58844.2023.10290067],
    [CNN ligera en tiempo real],
    [MAESTRO v3],
    [F1 onset 96.8% en tiempo real],
    [latencia aún ~4 s en demo],
  ),
  (
    [C4a],
    [Kim T.; Kim M.-J.; Ahn C.W.],
    [PF2N: Periodicity–Frequency Fusion Network for Multi-Instrument Music Transcription],
    [10.3390/math13111708],
    [fusión frecuencia-periodicidad (PF2N)],
    [Slakh2100, MusicNet, MAESTRO],
    [+3.3% onset F1 vs YMT3],
    [limitado por armónicos solapados],
  ),
  (
    [C4a],
    [D. Li; Y. Zang; Q. Kong],
    [Piano Transcription by Hierarchical Language Modeling with Pretrained Roll-based Encoders],
    [10.1109/icassp49660.2025.10890508],
    [pianoroll preentrenado + LM jerárquico],
    [MAESTRO (~200 h)],
    [nuevo SOTA en AMT basado en LM],
    [no escala con tamaño del modelo],
  ),
  (
    [C4a],
    [Guo W.; Zhang Y.; Pan C.; Zhu Z.; Li R.; Chen Z.; Xu W.; Wu F.; Zhao Z.],
    [STARS: A Unified Framework for Singing Transcription, Alignment, and Refined Style Annotation],
    [10.18653/v1/2025.findings-acl.781],
    [anotación de canto unificada multi-nivel],
    [GTSinger + 30 h propias],
    [mejora alineación y transcripción],
    [pipelines fragmentados; faltan datos],
  ),
  (
    [C4a],
    [Y. Yamamoto],
    [Toward Leveraging Pre-Trained Self-Supervised Frontends for Automatic Singing Voice Understanding Tasks: Three Case Studies],
    [10.1109/apsipaasc58517.2023.10317286],
    [frontends SSL preentrenados],
    [Artist20, MIR-ST500, VocalSet],
    [SSL iguala o supera supervisados],
    [escasez de datos etiquetados],
  ),
  (
    [C4a],
    [C. Biesinger; H. Awano; M. Hashimoto],
    [Window Function-Less DFT with Reduced Noise and Latency for Real-Time Music Analysis],
    [10.23919/eusipco63237.2025.11226525],
    [DFT sin ventana, tiempo real],
    [audio en vivo (sin dataset)],
    [sin lóbulos laterales; mitad de latencia],
    [FFT convencional: latencia y ruido],
  ),
  (
    [C4a],
    [S. Chang; E. Benetos; H. Kirchhoff; S. Dixon],
    [YourMT3+: Multi-Instrument Music Transcription with Enhanced Transformer Architectures and Cross-Dataset STEM Augmentation],
    [10.1109/mlsp58920.2024.10734819],
    [Transformer multi-instrumento con MoE],
    [Slakh, MusicNet y 8 más],
    [supera a MT3; canto ~64% F1],
    [brecha sintético vs pop real],
  ),
  (
    [C4b],
    [J. Jung; D. Kim; S. Lee; S. Cho; H. Soh; I. Bukey; C. Donahue; D. Jeong],
    [U-MusT: A Unified Framework for Cross-Modal Translation of Score Images, Symbolic Music, and Performance Audio],
    [10.1109/taslpro.2025.3648794],
    [traducción cross-modal partitura-MIDI-audio],
    [YTSV, MAESTRO, Slakh y otros],
    [OMR SOTA; primer audio desde partitura],
    [faltan datasets imagen-interpretación a gran escala],
  ),
  (
    [C4a],
    [Bittner, R., Bosch, J. J., Rubinstein, D., Meseguer-Brocal, G., & Ewert, S. (2022)],
    [A Lightweight Instrument-Agnostic Model for Polyphonic Note Transcription and Multipitch Estimation (Basic Pitch)],
    [10.1109/icassp43922.2022.9746549],
    [AMT ligero independiente del instrumento (modelo integrado en la tesis)],
    [Datasets de notas musicales polifónicas],
    [Competitivo con menor complejidad],
    [Generalizar a varios instrumentos es difícil],
  ),
)

#apatable(
  columns: (1.2cm, 4.2cm, 4.1cm, 4.6cm, 3.5cm, 3cm, 3cm, 3.1cm),
  inset: (x: 3pt, y: 4pt),
  header: (
    [*Cluster*],
    [*Autores*],
    [*Título*],
    [*DOI*],
    [*Técnicas*],
    [*Dataset/Población*],
    [*Resultados*],
    [*Gap*],
  ),
  rows: anexo-filas,
)

#set page(flipped: false, margin: (x: 2.54cm, y: 2.54cm))
#set text(size: 12pt)
#set par(first-line-indent: 1.27cm, leading: 1em, spacing: 1em)

#pagebreak(weak: true)

== Anexo B. Consentimiento informado para la sesión experimental

El presente documento establece las condiciones de participación en la sesión experimental de evaluación del videojuego de entrenamiento auditivo desarrollado como proyecto de tesis en la Universidad Nacional Mayor de San Marcos.

*Finalidad de la sesión.* La sesión evalúa la efectividad del videojuego en el desarrollo de habilidades auditivas, mediante actividades de dictado y repentinización melódica. Los datos recopilados se utilizarán exclusivamente con fines de investigación y de redacción de la tesis.

*Datos recopilados.* Durante la sesión se registran las respuestas musicales, las puntuaciones de desempeño y las grabaciones de voz realizadas en las tareas de repentinización.

*Uso de las grabaciones.* Las grabaciones se reproducen dentro de la plataforma para los participantes de la misma partida, funcionalidad que el docente puede desactivar. También pueden reproducirse como evidencia en la documentación o la defensa de la tesis. No se publicarán en medios abiertos ni se utilizarán con fines comerciales.

*Voluntariedad.* La participación es voluntaria. Puede retirarse en cualquier momento sin consecuencias y solicitar la eliminación de sus grabaciones y respuestas, que se suprimirán de la plataforma.

*Conservación y acceso.* Los datos se conservan durante el desarrollo del estudio y se eliminan una vez completado el análisis. El acceso a los datos queda limitado al investigador responsable y al asesor de tesis.

*Confidencialidad.* Los resultados se publicarán de forma agregada, sin identificar a los participantes.

#v(1em)

#table(
  columns: (1fr, 1fr),
  align: left,
  inset: 8pt,
  stroke: 0.5pt,
  [*Participante*], [*Investigador responsable*],
  [Nombre: #h(1fr)], [Nombre: Jesus Stevan Diaz Ingol],
  [Firma: #h(1fr)], [Firma: #h(1fr)],
  [Fecha: #h(1fr)], [Fecha: #h(1fr)],
)
