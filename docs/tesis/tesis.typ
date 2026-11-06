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

En entornos formales de educación musical, alcanzar un buen desempeño en los cursos de habilidades auditivas requiere de mucha práctica, pues la dificultad de estos aumenta raṕidamente (Royston y Wilson, 2024). Estos cursos representan un obstáculo desalentador para muchos estudiantes de música, contribuyendo en ciertos casos a la deserción académica (Barlow, 2016). Las evaluaciones de aptitud auditiva consisten en escuchar una grabación proporcionada por el docente y transcribirla en papel. Calificar estas evaluaciones suele tomar varios días a los docentes, lo que impide al alumno obtener retroalimentación instantánea (Pesek et al., 2020b). Kleppinger (2017) señala que estas evaluaciones no se alinean consistentemente con lo que se espera que los estudiantes aprendan. Su naturaleza "contrarreloj" genera ansiedad incluso en estudiantes de alto rendimiento, lo que más adelante se transforma en perspectivas pesimistas sobre la utilidad de estos cursos. Chenette (2016) argumenta que el material de estudio para entrenamiento auditivo, al estar fuertemente enlazado a la currícula tradicional de teoría musical, hereda un enfoque eurocentrista, ignorando la música popular y las tradiciones musicales internacionales. Donn et al. (2024) argumentan que muchos de los métodos de entrenamiento auditivo aplicados en escuelas secundarias británicas fueron diseñados para un contexto musical mucho menos diverso que el contemporáneo.

== 1.2. Formulación del problema

=== 1.2.1. Problema general

¿De qué manera un videojuego en línea basado en técnicas de generación y análisis de similitud melódica facilita el desarrollo de habilidades auditivas en estudiantes de música?

=== 1.2.2. Problemas específicos

#listasin[
  - ¿Cómo integrar un modelo generador de estructuras melódicas simbólicas existente para la generación automática de ejercicios de dictado y repentización melódica?
  - ¿Cómo integrar un modelo de análisis de similitud de estructuras melódicas simbólicas existente para evaluar la precisión de interpretaciones y transcripciones musicales?
  - ¿Cómo integrar un modelo de transcripción musical automática (audio a MIDI) existente para la evaluación de ejercicios de repentización melódica?
  - ¿Cómo desarrollar un videojuego en línea que integre los modelos descritos para implementar mecánicas de dictado y repentización melódica?
  - ¿Cómo evaluar la efectividad pedagógica del videojuego implementado mediante un estudio experimental con estudiantes de música?
]

== 1.3. Justificación

=== 1.3.2. Justificación teórica

Según Vallejo (2019), muchas de las aplicaciones y plataformas de entrenamiento auditivo existentes no exploran mecánicas más allá de la simple identificación “al oído” de notas e intervalos musicales, sugiriendo una falta de innovación en el diseño de estas. El mismo autor señala que el componente gamificador de estas aplicaciones suele ser superficial y poco útil para facilitar el proceso de aprendizaje. Este fenómeno no es exclusivo al contexto musical, Almeida et al. (2022) demuestran que las plataformas gamificadas que centran su atención en elementos gamificadores superficiales, tales como puntos e insignias, provocan que los usuarios pierdan motivación intrínseca por el tema que se desea enseñar. En este sentido, la presente investigación propone mecánicas de juego poco exploradas en la literatura existente. Así mismo, se pretende aumentar la discusión sobre el uso de técnicas de aprendizaje automático para la retroalimentación automatizada en contextos de educación musical.

=== 1.3.2. Justificación práctica

Las plataformas existentes de educación musical basadas en juegos no suelen estar orientadas a contextos educativos formales, lo que hace difícil a los docentes integrarlas en la currícula (Pesek et al., 2020a). La mayor parte de estas aplicaciones se limitan al aprendizaje de instrumentos musicales, siendo muy pocas las que se centran en el desarrollo de habilidades auditivas y el aprendizaje de teoría musical. Más aún, muchas de estas aplicaciones no son gratuitas, lo que dificulta aún más su adopción en el aula (Pesek et al., 2020b). La presente investigación aborda esta brecha de mercado proponiendo una plataforma de entrenamiento auditivo basada en juegos, cuyas mecánicas de juego están diseñadas para ser de utilidad tanto a alumnos como a docentes de conservatorios. Richards (2023) señala el potencial de estas plataformas para proveer una sensación de comunidad, competencia y trabajo en equipo a estudiantes en el contexto de la educación en línea. En este sentido, la base de usuarios objetivo de la plataforma propuesta incluye también a estudiantes autodidactas. Los estudiantes en etapas escolares tempranas también se podrían beneficiar, siendo que se encuentran en un periodo crítico para el desarrollo de habilidades auditivas (Respati et al., 2021).

== 1.4. Objetivos

=== 1.4.1. Objetivo general

Desarrollar un videojuego en línea basado en técnicas de generación y análisis de similitud melódica para el desarrollo de habilidades auditivas en estudiantes de música.

=== 1.4.2. Objetivos específicos

#listasin[
  - Integrar un modelo generador de estructuras melódicas simbólicas existente para la generación automática de ejercicios de dictado y repentización melódica.
  - Integrar un modelo de análisis de similitud de estructuras melódicas simbólicas existente para evaluar el desempeño de un jugador en ejercicios de dictado y repentización melódica.
  - Integrar un modelo de transcripción musical automática (audio a MIDI) existente para la evaluación de ejercicios de repentización melódica.
  - Desarrollar un videojuego en línea que integre los modelos descritos para implementar mecánicas de dictado y repentización melódica.
  - Evaluar la efectividad pedagógica del videojuego implementado mediante un estudio experimental con estudiantes de música.
]

= Capítulo II: Marco teórico

== 2.1. Antecedentes del problema

Pesek et al. (2020a), en su artículo "Troubadour: A Gamified e-Learning Platform for Ear Training" abordaron los desafíos asociados al entrenamiento auditivo, concretamente al dictado musical, proponiendo una plataforma de código abierto cuyo enfoque central es la identificación de intervalos musicales. La interfaz principal de la aplicación consiste de un teclado virtual con el que el estudiante interactúa. El estudiante escucha una secuencia melódica proporcionada por la plataforma y es su deber introducir aquellas notas que identificó mediante el teclado virtual. La generación de estos ejercicios es automática y su dificultad se ajusta de forma adaptativa. Para aumentar el engagement en los estudiantes, la plataforma incluye elementos gamificadores como insignias, tablas de clasificación y un modo multijugador. Para evaluar la efectividad de esta propuesta, se realizó un estudio A/B con estudiantes de primer y segundo año del Conservatorio de Música y Ballet de Ljubljana. Los estudiantes de primer año que utilizaron la plataforma obtuvieron una puntuación media del 69.8% en sus exámenes finales de dictado, lo que supuso una mejora del 9.2% respecto al grupo de control (60.6%), el cual no utilizó la plataforma.

Chen y Li (2025) realizaron el estudio “A Quasi-Experimental Study on the Application of MuseScore Software to Improve Sight-Singing and Ear-Training Abilities in Music Education at Chuzhou University” para explorar la efectividad del software de notación musical MuseScore como herramienta de aprendizaje en cursos de dictado y repentización musical en la Universidad de Chuzhou. El objetivo fue comparar la precisión rítmica y tonal de aquellos estudiantes que usaron la aplicación con la de aquellos que recurrieron a métodos tradicionales. Se realizó una intervención de ocho semanas a 60 estudiantes de primer año: 30 en grupo experimental y 30 en control. Ambos tuvieron acceso a los mismos materiales y contenido de estudio. Al trabajar con el grupo control, los docentes hicieron uso de ciertas funcionalidades de MuseScore durante clase, tales como el metrónomo al practicar precisión de ritmo y el tempo ajustable para facilitar la repentización (sight-reading). Tras finalizar las ocho semanas, ambos grupos rindieron un examen final. Las calificaciones de este exámen fueron analizadas mediante una prueba t-test. La diferencia más notoria se encontró en el dictado melódico, donde el grupo experimental logró una puntuación promedio de 34.4 frente a 32.3 del grupo control, reflejando una diferencia significativa (p < 0.01) y un tamaño de efecto alto (Cohen’s d = -0.78).

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

=== 2.4.1. Planificación

La búsqueda del estado del arte realizada en el presente estudio consistió en múltiples trabajos de búsqueda de literatura ejecutados en paralelo. Esto con el propósito de identificar soluciones existentes al problema central de investigación, así como técnicas computacionales con el potencial de ser aplicadas a la construcción del sistema propuesto por este estudio. Dicha propuesta consiste en un videojuego en línea dirigido a estudiantes de música. La partida inicia con cada jugador realizando dictado melódico sobre piezas musicales generadas por el sistema. En la siguiente ronda, cada jugador recibirá la transcripción realizada por algún otro jugador en la ronda anterior y realizará repentización sobre ésta, interpretando la partitura en vivo. Este ciclo de dictado y repentización se repite por tantas rondas como deseen los jugadores. Al final de la partida, cada jugador recibirá estadísticas sobre su desempeño: qué tan similares fueron sus transcripciones e interpretaciones musicales a las piezas que recibieron. Estas estadísticas se acumularán a modo de un historial que permitirá al estudiante visualizar su progreso a lo largo de varias partidas.

Así, el videojuego propuesto involucra una serie de técnicas que hacen posible la mecánica de juego y evaluación descrita: generación automática de material musical, análisis de similitud melódica y transcripción musical automática. Búsquedas preliminares revelaron que muy pocos estudios han abordado estas tres técnicas en contextos de educación musical basada en juegos. Restringir la revisión de literatura a estos estudios omitiría información técnica valiosa para el desarrollo del sistema. Por esta razón, la revisión del estado del arte se dividió en cuatro búsquedas (o clusters) independientes una de la otra. El primer cluster (C1) se enfoca en estudios que proponen plataformas gamificadas y otras propuestas digitales para solucionar problemas en educación musical, específicamente en entrenamiento auditivo. Esto con el fin de identificar qué mecánicas de juego y otras estrategias pedagógicas se suelen proponer ante el problema central de la presente investigación. Puesto que ningún trabajo previo implementa las mismas mecánicas de juego propuestas por el presente estudio, se requieren búsquedas adicionales que permitan estudiar el estado del arte de las tres técnicas mencionadas anteriormente. En este sentido, el segundo cluster (C2) se enfocó en trabajos que utilizan generación automática de estructuras melódicas, con el fin de identificar modelos o herramientas existentes, de preferencia con implementaciones o pesos preentrenados públicamente disponibles, que puedan integrarse en la plataforma para la generación de ejercicios de dictado musical. El tercer cluster (C3) se enfocó en estudios que emplean modelos capaces de comparar estructuras musicales simbólicas, con el objetivo de identificar un modelo existente que pueda integrarse para evaluar la precisión de las transcripciones e interpretaciones musicales de los jugadores. Finalmente, el cuarto cluster (C4) se centró en modelos de transcripción musical automática, es decir, modelos que convierten grabaciones musicales en representaciones simbólicas como MIDI, un paso realizado por la propia plataforma para permitir evaluar la similitud musical entre audio y MIDI.

Para cada cluster se formuló una cadena de búsqueda independiente del resto. La cadena del primer cluster está conformada por dos grupos de términos de búsqueda: el primero representando conceptos asociados al entrenamiento auditivo y educación musical; y el segundo grupo, a la gamificación y juegos serios. Ambos grupos están unidos por un operador AND, asegurando que los estudios obtenidos aborden ambos frentes. Cada una de las otras tres cadenas de búsqueda contienen un solo grupo para los conceptos asociados a la técnica correspondiente. La Tabla 1 muestra las cadenas de búsqueda para cada cluster. Los repositorios full-text Springer Nature Link e IEEE Xplore, así como los índices de abstracts y citas Scopus y OpenAlex, fueron elegidos como fuentes de literatura debido a su amplia cobertura de áreas académicas, incluyendo aquellas relevantes a esta investigación, y por sus capacidades para búsqueda booleana. Ciertos repositorios fueron excluidos por sus limitaciones en búsqueda booleana, tal como MDPI, el cual no es capaz de procesar cadenas de búsqueda de gran tamaño, o como ScienceDirect, el cual impone restricciones en el tamaño de la cadena (no más de 500 caracteres) y el número de operadores booleanos (no más de 8).

#block(breakable: false)[
#leyenda([Tabla], 1, [Cadenas de búsqueda por cluster])
#apatable(
  columns: (5cm, 10.9cm),
  header: ([*Tipo de criterio*], [*Descripción*]),
  rows: (
    (
      [Gamificación en educación musical],
      [("ear training" OR "aural training" OR "music dictation" OR "melodic dictation" OR "sight reading" OR "music education") AND ("gamification" OR "gamified" OR "serious game" OR "educational game" OR "game-based learning" OR "multiplayer game" OR "online platform")],
    ),
    (
      [Generación automática de melodías],
      ["melody generation" OR "melodic generation" OR "music generation" OR "symbolic music generation" OR "automatic exercise generation" OR "procedural music generation" OR "algorithmic composition" OR "computational music generation"],
    ),
    (
      [Análisis de similitud melódica],
      ["melodic similarity" OR "music similarity" OR "symbolic music similarity" OR "melody comparison" OR "symbolic sequence similarity" OR "music sequence alignment" OR "music pattern matching"],
    ),
    (
      [Transcripción musical automática],
      ["automatic music transcription" OR "audio to MIDI" OR "music transcription" OR "symbolic music transcription" OR "pitch detection" OR "note onset detection" OR "singing transcription" OR "polyphonic transcription"],
    ),
  ),
)]

#block(breakable: false)[
#leyenda([Tabla], 2, [Criterios de inclusión y exclusión])
#apatable(
  columns: (4cm, 11.9cm),
  header: ([*Tipo de criterio*], [*Descripción*]),
  rows: (
    (
      [Exclusión],
      [
        Estudios previos al 2021#linebreak()
        Estudios de acceso cerrado#linebreak()
        Estudios en idiomas distintos al inglés y español
      ],
    ),
    (
      [Inclusión],
      [
        Artículos científicos o papers de conferencia#linebreak()
        Estudios que abordan problemas en educación musical mediante gamificación y aprendizaje basado en juegos#linebreak()
        Estudios que aplican técnicas de generación automática de melodías, análisis de similitud melódica o transcripción musical automática para resolver un problema de investigación y que, además, reporten públicamente modelos pre-entrenados.
      ],
    ),
  ),
)]

ACM Digital Library fue excluido por sus limitaciones en la descarga de resultados de búsqueda. Web of Science fue excluido por no permitir acceso a través de la Universidad Nacional Mayor de San Marcos. Por otro lado, se definieron una serie de criterios de exclusión e inclusión con los cuales seleccionar los estudios más relevantes entre aquellos obtenidos en la búsqueda. Estos criterios son descritos en la Tabla 2.

=== 2.4.2. Desarrollo

La Figura 1 muestra el proceso seguido para la búsqueda y selección del estado del arte. Se utilizaron las cuatro cadenas de búsqueda en los cuatro repositorios elegidos. Luego, se configuraron los filtros de dichos repositorios de tal manera que se apliquen los criterios de exclusión. Tras esto, se descargaron los resultados de búsqueda en formato CSV. Para cada cluster, se concatenaron los resultados de cada repositorio y se eliminaron duplicados, resultando en 1488 estudios. Se analizó el título de cada uno y se descartaron aquellos que no cumplen con los criterios de inclusión, resultando en 832 estudios candidatos. Finalmente, se analizó el abstract de cada candidato y se seleccionaron los 10 estudios más relevantes por cada cluster, resultando en 40 estudios listados en el Anexo A. Por cada estudio se mencionan las técnicas implementadas en la propuesta de solución, así como el dataset utilizado para el entrenamiento de los modelos pertinentes, o la población de interés en el caso de aquellos estudios que no utilizaron modelos de inteligencia artificial. También se menciona de forma muy concisa los resultados obtenidos y el research gap.

#block(breakable: false)[
  #leyenda([Figura], 1, [Proceso de búsqueda y selección de estado del arte])
  #align(center)[#image("fig1.png", width: 100%)]
]

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

Una vez la propuesta ha sido desarrollada, la cuarta etapa requiere demostrar su actividad para resolver el problema identificado. Durante esta etapa se busca demostrar que el sistema propuesto puede ser usado en el contexto para el que fue diseñado. La demostración consistirá en la implementación del videojuego desarrollado y la realización de sesiones de juego con estudiantes de música. Durante estas sesiones, los participantes interactuarán con el sistema realizando ejercicios de dictado melódico y lectura a primera vista, mientras que la plataforma generará ejercicios, registrará las respuestas y evaluará el rendimiento de forma automática. El objetivo de esta actividad no es medir la eficacia, sino demostrar la viabilidad de la solución propuesta y verificar que el artefacto implementado puede respaldar con éxito el flujo de trabajo previsto durante la fase de diseño.

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

Para la recolección de datos se empleará la técnica de evaluación mediante pruebas de desempeño, aplicadas a los participantes antes y después de la intervención educativa. Estas evaluaciones serán similares en naturaleza a aquellas propuestas por docentes de cursos formales de entrenamiento auditivo, incluyendo actividades de dictado y repentización musical.

== 3.8. Técnicas de análisis de datos

Los datos recopilados serán procesados mediante técnicas de análisis estadístico descriptivo e inferencial. Inicialmente se emplearán medidas descriptivas, tales como promedios, frecuencias y desviaciones estándar, con el fin de caracterizar el desempeño de los participantes y resumir los resultados obtenidos durante las evaluaciones. Posteriormente, se compararán los resultados obtenidos por el grupo experimental y el grupo de control en las evaluaciones realizadas antes y después de la intervención, con el propósito de determinar el grado de cumplimiento de los objetivos definidos para la solución propuesta. Para ello se utilizarán pruebas estadísticas apropiadas según la naturaleza y distribución de los datos recolectados

= Capítulo IV: Desarrollo

== 4.1. Diseño del generador de estructuras melódicas

El generador de estructuras melódicas será responsable de crear los ejercicios utilizados en las rondas de dictado y repentización. Se optó por un enfoque algorítmico, en lugar de entrenar un nuevo modelo de generación musical, debido a que los ejercicios requieren restricciones explícitas sobre el intervalo entre notas, la tonalidad, el rango melódico, la complejidad rítmica y la longitud de la secuencia.

Esta decisión sigue un principio similar al aplicado en Troubadour, donde las secuencias melódicas se generan mediante un algoritmo que considera la longitud de la secuencia y la distribución de los intervalos para producir ejercicios con distintos niveles de dificultad (Pesek et al., 2020). Para la implementación se utilizará Tonal, una biblioteca de JavaScript que proporciona operaciones sobre notas, intervalos, escalas y tonalidades. Sin embargo, Tonal no genera por sí sola melodías completas; se implementará un algoritmo propio que utilizará sus funciones para aplicar las restricciones musicales definidas.

Se definieron tres niveles de dificultad, cuyos parámetros se muestran en la Tabla 4.1.

#block(breakable: false)[
#leyenda([Tabla], 3, [Parámetros de generación melódica por nivel de dificultad])
#apatable(
  columns: (5.5cm, 3.4cm, 3.5cm, 3.5cm),
  header: (
    [*Parámetro*],
    [*Dificultad baja*],
    [*Dificultad media*],
    [*Dificultad alta*],
  ),
  rows: (
    ([Intervalo máximo entre notas consecutivas], [2 semitonos], [5 semitonos], [7 semitonos]),
    ([Congruencia tonal], [Una sola escala], [Posible modulación], [Modulación]),
    ([Ambitus o rango total], [1 octava], [2 octavas], [3 octavas]),
    ([Complejidad rítmica], [Negras y blancas en compás simple], [Inclusión de corcheas], [Síncopas y tresillos]),
    ([Longitud], [8 notas], [15 notas], [24 notas]),
  ),
)]

El algoritmo seleccionará una tonalidad y construirá una secuencia de notas que respete los límites correspondientes al nivel elegido. En dificultad baja, todas las notas pertenecerán a una sola escala y los intervalos consecutivos no superarán los dos semitonos. En dificultad media se permitirá ampliar los saltos hasta cinco semitonos y se contemplará la posibilidad de cambiar de centro tonal. En dificultad alta, los saltos podrán alcanzar siete semitonos y se incorporarán modulaciones.

La selección de cada nota estará condicionada por las notas válidas que puedan seguir a la nota anterior. De esta forma, la generación no dependerá únicamente de una selección aleatoria independiente, sino de un conjunto de restricciones que limitará las secuencias posibles. También se establecerán reglas para evitar que las melodías resultantes sean excesivamente repetitivas o carezcan de una dirección musical reconocible. Estas reglas se ajustarán durante las pruebas del generador.

Para representar las melodías se utilizará una estructura simbólica que almacene, como mínimo, la altura MIDI de cada nota, su posición temporal y su duración. Esta representación permitirá generar una partitura, reproducir la secuencia como audio, compararla con las respuestas de los jugadores y almacenarla en la base de datos.

La generación se ejecutará antes de iniciar la partida, a partir del nivel de dificultad seleccionado por quien cree la sala. Por tanto, la dificultad permanecerá fija durante toda la partida; no se incrementará automáticamente entre rondas. Cada jugador recibirá una melodía inicial diferente, generada con los parámetros comunes de la partida.

== 4.2. Diseño del análisis de similitud melódica

El análisis de similitud melódica permitirá evaluar las transcripciones de los ejercicios de dictado y las interpretaciones de los ejercicios de repentización. En ambos casos, la respuesta del jugador se comparará con la melodía de referencia correspondiente.

Se decidió que la evaluación se centrará en dos dimensiones: precisión de alturas y precisión rítmica. No se evaluará el timbre de la voz ni se intentará determinar si la interpretación es expresiva. Esta delimitación permitirá concentrar el análisis en los elementos musicales directamente relacionados con los objetivos del videojuego.

No se ha identificado, entre las bibliotecas consideradas, una alternativa para JavaScript que reproduzca de forma directa todas las métricas de mir_eval requeridas por este proyecto. Por ello, se implementará un comparador propio en JavaScript, inspirado en los criterios de correspondencia entre notas y tiempos empleados en herramientas de evaluación musical como mir_eval. El uso de una implementación propia permitirá controlar los parámetros de comparación y presentar resultados interpretables para cada ejercicio.

El comparador trabajará con dos puntuaciones:

#listasin[
  - *Precisión de alturas:* medirá la proporción de notas que coinciden en altura con las notas de referencia. Para ello, se establecerá una correspondencia entre las notas de ambas secuencias y se considerará correcta una nota cuando su número MIDI coincida con el de la nota de referencia.
  - *Precisión rítmica:* medirá la correspondencia entre los inicios de las notas de la respuesta y los de la melodía de referencia. Para determinar si dos inicios corresponden a la misma nota, se empleará una tolerancia temporal definida durante la implementación y las pruebas del comparador.
]

La comparación tendrá que contemplar respuestas con notas omitidas, añadidas o desplazadas en el tiempo. Por este motivo, no se compararán únicamente posiciones de listas de forma directa: se establecerá primero una correspondencia entre los eventos musicales de ambas secuencias, de modo que una nota incorrecta no desplace necesariamente todas las comparaciones posteriores.

La puntuación global de cada respuesta será el promedio de las dos dimensiones:

$ S_"global" = (S_"alturas" + S_"ritmo") / 2 $

Las tres puntuaciones se expresarán en una escala de 0 a 100. Se optó por asignar el mismo peso a alturas y ritmo porque ambas dimensiones constituyen objetivos explícitos de los ejercicios. Esta decisión podrá revisarse si las pruebas técnicas revelan que alguna de las métricas no ofrece resultados suficientemente estables.

El sistema presentará la puntuación global junto con las puntuaciones parciales. Así, un jugador podrá distinguir si sus errores se concentran en la identificación de las notas o en su ubicación rítmica. El mismo procedimiento se aplicará a las respuestas de dictado y a las interpretaciones transcritas desde audio.

== 4.3. Integración de un modelo de transcripción musical automática

La evaluación de repentización requiere transformar la interpretación vocal del jugador en una secuencia de notas que pueda compararse con la partitura original. Para realizar esta tarea se integrará un modelo de transcripción de audio a MIDI existente, evitando desarrollar y entrenar un modelo propio.

La alternativa seleccionada inicialmente será Spotify Basic Pitch, mediante su implementación para JavaScript y TensorFlow.js, publicada como \@spotify/basic-pitch. Esta biblioteca permite procesar audio y generar una transcripción simbólica; su repositorio documenta su disponibilidad en Python y en una implementación complementaria para JavaScript.

El flujo de procesamiento previsto será el siguiente:

#listasin[
  + El jugador accederá a la partitura asignada y grabará su interpretación utilizando el micrófono.
  + El navegador solicitará los permisos necesarios para acceder al micrófono y capturará la interpretación.
  + El audio se enviará al componente de transcripción, que producirá eventos musicales a partir de la señal recibida.
  + El sistema normalizará la salida a una representación común de notas, posiciones temporales y duraciones.
  + La secuencia obtenida se comparará con la melodía de referencia mediante el componente descrito en la sección 4.2.
  + Se almacenarán la interpretación, su transcripción y las puntuaciones resultantes para mostrarlas en el resumen de la partida.
]

La grabación original se conservará para que el jugador pueda escuchar nuevamente su interpretación durante la revisión posterior. El sistema también almacenará la transcripción simbólica, ya que esta permitirá visualizar las notas detectadas y analizar los errores sin tener que ejecutar de nuevo el modelo.

La integración deberá contemplar fallos de transcripción, grabaciones vacías y problemas de acceso al micrófono. En esos casos, el sistema informará al jugador de que la respuesta no pudo procesarse correctamente, en lugar de asignarle automáticamente una puntuación de cero. Las reglas concretas para repetir una grabación o resolver una transcripción fallida se establecerán durante el desarrollo.

== 4.4. Arquitectura del sistema

El videojuego se desarrollará como una aplicación web utilizando Next.js para la interfaz y la lógica de la aplicación, Payload CMS para la gestión de usuarios y contenidos, y PostgreSQL como sistema gestor de base de datos. PostgreSQL se ejecutará mediante Docker Compose durante el desarrollo, lo que permitirá mantener una configuración reproducible del entorno.

La arquitectura se organizará en cuatro componentes principales:

#listasin[
  + *Interfaz del videojuego:* mostrará las salas disponibles mediante códigos de acceso, las instrucciones de cada ronda, las herramientas para responder los ejercicios, las puntuaciones y el resumen final.
  + *Lógica de juego:* gestionará la creación de partidas, el orden de las rondas, la asignación de melodías, la recepción de respuestas y el cálculo de puntuaciones.
  + *Componentes musicales:* incluirán el generador de melodías, el comparador de respuestas y el modelo de transcripción de audio a MIDI.
  + *Persistencia de datos:* almacenará las cuentas de usuario, las salas, las partidas, las melodías generadas, las respuestas, las grabaciones y las puntuaciones.
]

La comunicación entre los jugadores requerirá un mecanismo de tiempo real para anunciar el inicio de las rondas, notificar la recepción de respuestas y mantener sincronizado el estado de la partida. Para simplificar la implementación se priorizará un servicio administrado de comunicación en tiempo real, como Ably, en lugar de desarrollar desde cero un servidor WebSocket. Esta decisión evitará que la gestión de conexiones persistentes se convierta en una responsabilidad adicional del servidor de Next.js. La solución definitiva se confirmará durante la implementación, atendiendo a su integración con la aplicación y a sus condiciones de uso.

Payload CMS se utilizará para administrar las colecciones de datos y las cuentas de usuario, mientras que la lógica de juego controlará qué información puede consultar cada participante. En particular, las respuestas de otros jugadores no se mostrarán antes de que termine la ronda correspondiente, pues hacerlo alteraría la dinámica de intercambio prevista.

El cliente web se comunicará con la aplicación y el servicio de tiempo real; la aplicación consultará y actualizará los datos mediante Payload CMS y PostgreSQL; y los componentes musicales procesarán las melodías y respuestas. El servicio de tiempo real notificará los cambios relevantes a los clientes conectados, mientras que la base de datos conservará el historial de la partida.

== 4.5. Diseño de las mecánicas de juego

La mecánica central consistirá en intercambiar transcripciones e interpretaciones musicales entre los participantes. El diseño toma como referencia la dinámica de juegos como Gartic Phone, en los que una creación pasa de un jugador a otro y se transforma a lo largo de varias rondas. En esta propuesta, el contenido que se transmite será una melodía representada mediante notas musicales.

Se decidió que cada partida tendrá una sala creada manualmente por un usuario. La sala dispondrá de un código que permitirá a otros jugadores incorporarse antes de iniciar la sesión. El creador configurará el nivel de dificultad y elegirá cuál será la primera actividad: dictado o repentización. No se implementará emparejamiento automático ni un chat integrado; se asumirá que los participantes podrán comunicarse mediante servicios externos, como Discord.

La partida estará compuesta por rondas alternadas de dictado y repentización. El flujo será el siguiente:

#listasin[
  + *Preparación de la partida.* El creador establecerá la dificultad y seleccionará la actividad inicial. Cuando la sala esté lista, el sistema generará una melodía inicial diferente para cada jugador. Todas las melodías se generarán con los mismos parámetros de dificultad, aunque sus notas y ritmos podrán ser distintos.
  + *Ronda de dictado.* Cada jugador escuchará la melodía asignada y deberá transcribirla utilizando la interfaz musical del videojuego. Al terminar, el sistema comparará la respuesta con la melodía original y calculará las puntuaciones de alturas y ritmo. La transcripción producida por el jugador quedará almacenada como parte del historial de la partida.
  + *Ronda de repentización.* El sistema asignará a cada jugador una transcripción realizada por otro participante en la ronda de dictado anterior. El jugador deberá leer la melodía recibida e interpretarla mediante el micrófono. El sistema transcribirá el audio a una secuencia simbólica y la comparará con la melodía que debía interpretarse. La interpretación y la transcripción resultante se guardarán para la revisión posterior.
  + *Intercambio de respuestas.* En cada nueva ronda, las respuestas de la actividad anterior servirán como material de trabajo para otros participantes. De este modo, la secuencia musical que se originó en el sistema podrá experimentar modificaciones a medida que los jugadores la transcriban e interpreten. El intercambio será el principal elemento de gamificación, ya que permitirá observar cómo evoluciona una melodía y qué errores aparecen durante el proceso.
  + *Finalización y clasificación.* La partida terminará cuando se complete el número de rondas establecido para la sesión. El sistema calculará la puntuación final de cada jugador y mostrará una clasificación correspondiente exclusivamente a esa partida. El ganador será quien obtenga el mayor promedio de precisión general considerando todas sus rondas de dictado y repentización.
]

Para el cálculo del resultado final se utilizará el promedio aritmético de las puntuaciones globales de las respuestas válidas del jugador:

$ S_"final" = (sum_(i = 1)^n S_i) / n $

donde $n$ representa el número de respuestas puntuadas del jugador y $S_i$ corresponde a la puntuación global obtenida en cada respuesta. Esta fórmula dará el mismo peso a cada ronda puntuada. Las respuestas que no puedan procesarse por fallos técnicos deberán tratarse mediante una regla explícita de recuperación, en lugar de incorporarse como ceros sin distinguir entre un error musical y un fallo del sistema.

La dificultad no aumentará automáticamente durante la partida. Se mantendrá el nivel elegido al crear la sala, puesto que la complejidad de la sesión dependerá de las melodías iniciales generadas con esos parámetros. La clasificación tampoco se extenderá a un ranking global: se mostrará únicamente la posición relativa de los participantes de cada partida.

La hipótesis de diseño es que el intercambio de melodías y la visualización de sus transformaciones generarán un nivel de participación significativo. Esta expectativa se fundamenta en la dinámica de juegos de intercambio creativo como Gartic Phone, pero no se considerará un resultado demostrado hasta que se recojan y analicen datos de uso del prototipo.

== 4.6. Gestión de usuarios, partidas y resultados

La persistencia de los datos será necesaria tanto para el funcionamiento del videojuego como para su posterior evaluación. Se utilizará PostgreSQL para almacenar la información estructurada, administrada mediante Payload CMS y las operaciones de la aplicación.

El modelo de datos incluirá las siguientes entidades principales:

#block(breakable: false)[
#leyenda([Tabla], 4, [Entidades a incluir en el modelo de datos])
#apatable(
  columns: (3.5cm, 12.4cm),
  header: ([*Entidad*], [*Información que almacenará*]),
  rows: (
    ([Usuarios], [Identificador, nombre y datos necesarios para la autenticación.]),
    ([Salas], [Código de acceso, creador, configuración y estado de la sala.]),
    ([Partidas], [Sala de origen, participantes, nivel de dificultad, actividad inicial, estado y fechas relevantes.]),
    ([Rondas], [Número de ronda, tipo de actividad, estado y asignaciones de participantes.]),
    ([Melodías], [Notas, alturas MIDI, posiciones temporales, duraciones, parámetros de generación y relación con la partida.]),
    ([Respuestas], [Participante, melodía de referencia, contenido entregado y fecha de envío.]),
    ([Transcripciones], [Notas detectadas a partir de una grabación y relación con la respuesta correspondiente.]),
    ([Grabaciones], [Referencia al archivo de audio de la interpretación vocal.]),
    ([Resultados], [Puntuación de alturas, puntuación rítmica, puntuación global y datos necesarios para reconstruir la clasificación.]),
  ),
)]

Las entidades se relacionarán mediante identificadores, de modo que cada respuesta pueda asociarse con el jugador que la produjo, la ronda en que se creó y la melodía que debía reproducir o transcribir. Esta relación será especialmente importante para reconstruir el recorrido de una melodía durante el intercambio entre participantes.

Se decidió conservar tanto las respuestas simbólicas como las grabaciones de las interpretaciones. Las primeras permitirán analizar las notas y los errores; las segundas permitirán reproducir la ejecución original. Junto con las melodías de referencia y las puntuaciones, estos registros harán posible generar una galería final de la partida.

Las cuentas de usuario serán deliberadamente sencillas. El prototipo permitirá identificar a los participantes mediante su nombre y los datos básicos requeridos por el sistema, sin incorporar funciones extensas de personalización de perfiles. La gestión de usuarios se implementará mediante Payload CMS.

También se incorporarán salas de clase simples para que un docente pueda organizar la participación de sus estudiantes y consultar sus resultados. Estas funciones no sustituirán el modelo de salas abiertas mediante códigos: las salas de clase serán una herramienta adicional para el contexto educativo. Durante la evaluación experimental, el acceso a las partidas de estudio se limitará a los participantes autorizados, aunque el diseño general del producto contemple que otros usuarios puedan crear salas y jugar entre sí.

La retención de grabaciones y resultados se implementará teniendo en cuenta que los datos se utilizarán para revisar partidas y, cuando corresponda, para el estudio de investigación. Las condiciones de acceso, almacenamiento y uso de estos datos deberán quedar definidas antes de realizar las sesiones con estudiantes.

== 4.7. Diseño de la interfaz y retroalimentación al jugador

La interfaz se desarrollará como una aplicación web adaptable a distintos tamaños de pantalla. Se priorizará el uso desde computadoras, dado que las actividades requieren escuchar melodías, leer notación musical, introducir notas y grabar interpretaciones. La adaptación a dispositivos móviles se considerará en el diseño, aunque las funciones de grabación y edición musical deberán comprobarse específicamente en esos entornos.

La interfaz se organizará en las siguientes vistas:

=== Pantalla de inicio y acceso

Permitirá al usuario iniciar sesión, crear una sala o incorporarse a una existente mediante un código. La creación de una sala incluirá la selección del nivel de dificultad y de la actividad inicial.

=== Sala de espera

Mostrará los participantes conectados y la configuración de la partida. El creador podrá iniciar la sesión cuando estén preparados los jugadores. La sala también comunicará el estado de la partida para evitar que los participantes comiencen las actividades de forma desincronizada.

=== Pantalla de dictado

Reproducirá la melodía asignada y proporcionará herramientas para transcribirla. La respuesta se representará mediante una estructura musical editable que permita introducir alturas y duraciones. Se incluirán controles para reproducir el ejercicio y revisar la transcripción antes de enviarla.

=== Pantalla de repentización

Mostrará la partitura que el jugador debe interpretar y permitirá iniciar y finalizar la grabación. La interfaz comunicará cuándo se está grabando el audio y cuándo se está procesando la respuesta. Si la transcripción automática falla, se mostrará un mensaje que explique el problema y las opciones disponibles para continuar.

=== Pantalla de resultados

Presentará la puntuación global de la respuesta y las puntuaciones parciales de alturas y ritmo. Cuando sea posible, se señalarán las notas que coinciden y las que presentan diferencias respecto de la referencia. La intención es que la retroalimentación no se limite a indicar si una respuesta es correcta o incorrecta, sino que permita identificar el tipo de error cometido.

=== Galería final de la partida

Mostrará el recorrido de las melodías a través de las transcripciones e interpretaciones de los participantes. Cada secuencia podrá relacionarse con su melodía de origen, la respuesta producida y la evaluación obtenida. Se permitirá reproducir las grabaciones conservadas y revisar las puntuaciones de las distintas etapas. Esta vista cumplirá una doble función: ofrecer una conclusión entretenida a la sesión y permitir que los jugadores revisen sus errores después de jugar.

=== Vista docente

Permitirá organizar salas de clase y consultar los resultados de los estudiantes. La información incluirá las puntuaciones de las actividades realizadas y, cuando corresponda, los resultados parciales de alturas y ritmo. Esta funcionalidad estará orientada a la consulta del rendimiento registrado por la plataforma; no se asumirá que el docente podrá modificar libremente los parámetros internos de los modelos musicales.

En todas las vistas se priorizará que el usuario comprenda qué acción debe realizar, qué información está disponible y cuándo debe esperar a que el sistema termine de procesar una respuesta. Estas condiciones serán especialmente importantes en las rondas multijugador, donde una demora o una transición confusa puede interrumpir el flujo de la partida.

== 4.8. Integración de componentes y construcción del prototipo

El desarrollo integrará los componentes musicales y la lógica de juego en una única aplicación web. Debido a que todavía no se ha iniciado la implementación, las actividades descritas en esta sección constituyen el plan técnico de construcción del prototipo; no representan funcionalidades ya implementadas ni resultados de pruebas realizadas.

El desarrollo se organizará en las siguientes etapas.

#listasin[
  + *Preparación del entorno y persistencia.* Se configurará el proyecto Next.js, Payload CMS y PostgreSQL mediante Docker Compose. A continuación, se definirán las colecciones y relaciones necesarias para registrar usuarios, salas, partidas, rondas, melodías, respuestas, grabaciones y puntuaciones. En esta etapa se implementarán también las operaciones básicas de creación de salas y gestión de participantes.
  + *Implementación del generador melódico.* Se desarrollará el algoritmo de generación utilizando Tonal para las operaciones relacionadas con escalas, notas e intervalos. Se comprobará que las secuencias respeten los parámetros de los tres niveles de dificultad, incluyendo el número de notas, el rango melódico y las restricciones rítmicas. También se revisarán las secuencias generadas para detectar patrones repetitivos o resultados musicalmente poco coherentes. Si el algoritmo no produce resultados satisfactorios, se ajustarán sus reglas antes de integrarlo en las partidas.
  + *Implementación de la evaluación musical.* Se desarrollará el comparador de alturas y ritmo y se integrará la salida del modelo de transcripción de audio a MIDI. Se probarán las métricas con secuencias de referencia y respuestas que contengan errores controlados, como notas omitidas, alturas incorrectas y desplazamientos rítmicos. Estas pruebas permitirán comprobar si las puntuaciones reflejan de forma consistente las diferencias introducidas.

    En paralelo, se evaluará Basic Pitch con grabaciones de voz cantada. Se prestará atención a la detección de las alturas, los inicios de nota y los errores que puedan surgir al procesar una interpretación vocal. Si el modelo no ofrece resultados adecuados para este caso de uso, será necesario reconsiderar la solución de transcripción antes de utilizarla en el estudio experimental.
  + *Desarrollo del flujo multijugador.* Se implementará la creación de salas mediante códigos y la comunicación en tiempo real entre los participantes. La aplicación deberá coordinar el inicio y el cierre de cada ronda, comunicar qué jugadores han enviado sus respuestas y distribuir las transcripciones e interpretaciones según el flujo definido en la sección 4.5. Se comprobarán también los casos de desconexión y reingreso para evitar que un participante quede permanentemente bloqueado en una ronda.
  + *Implementación de las interfaces y la galería final.* Se construirán las vistas de dictado, repentización, resultados y resumen de partida. La galería se alimentará de los registros almacenados durante el juego, por lo que deberá conservarse la relación entre las melodías iniciales, las respuestas de los participantes y las transcripciones posteriores. También se desarrollará la vista docente para consultar los resultados de las salas de clase.
  + *Integración y pruebas funcionales.* Una vez disponibles los componentes, se ejecutarán partidas de prueba con varios usuarios. Se verificará que las melodías se asignen correctamente, que las respuestas se guarden, que las puntuaciones se calculen y que los resultados se muestren en la galería final. Además, se comprobará que los jugadores no puedan acceder anticipadamente a las respuestas que deben recibir en rondas posteriores.
]

Las pruebas técnicas deberán incluir casos como respuestas incompletas, grabaciones vacías, fallos de transcripción, pérdida temporal de conexión y participantes que abandonen una sala. El objetivo será detectar problemas que impidan completar una partida o que produzcan registros inconsistentes.

La integración se considerará satisfactoria cuando el prototipo pueda ejecutar el flujo completo de una sesión: crear una sala, incorporar participantes, generar melodías, realizar rondas alternadas de dictado y repentización, evaluar las respuestas, almacenar los resultados y mostrar la galería final. Esta comprobación corresponderá a la etapa de demostración de la metodología de investigación en ciencia del diseño descrita en el capítulo III; no será suficiente, por sí sola, para concluir que el videojuego mejora las habilidades auditivas de los estudiantes.

Finalmente, el prototipo se utilizará en sesiones controladas con participantes del estudio. La efectividad pedagógica se evaluará mediante el diseño experimental establecido en la metodología, comparando los resultados de las pruebas de desempeño correspondientes. De esta manera, se distinguirá entre la comprobación del funcionamiento técnico del artefacto y la evaluación de sus posibles efectos educativos.

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

  De Carvalho, C. V., & Coelho, A. (2022). Game-Based Learning, Gamification in Education and Serious Games. Computers, 11(3), 36. https://doi.org/10.3390/computers11030036

  Demian, A.-M. y Nedelcut, N. (2018). The Mental Processes Involved in the Musical Dictation. Music Cognition, 4, 86-97.

  Djaouti, D., Alvarez, J., & Jessel, J. (2011). Classifying serious games. En Advances in game-based learning book series (pp. 118-136). https://doi.org/10.4018/978-1-60960-495-0.ch006

  Donn, R., Stillie, B., & Moir, Z. (2024). The shifting sands of UK secondary music curricula: problematising relationships between aural training and music literacy. Music Education Research, 26(1), 58-70. https://doi.org/10.1080/14613808.2024.2309204

  Fernandez, A. D. (2025). Desarrollo de una aplicación web para el entrenamiento auditivo y enseñanza musical para miembros del Club de Música de la PUCE Ibarra \[Trabajo de titulación\]. Pontificia Universidad Católica del Ecuador.

  Giraldo, S., Waddell, G., Nou, I., Ortega, A., Mayor, O., Perez, A., Williamon, A., & Ramirez, R. (2019). Automatic Assessment of Tone Quality in Violin Music Performance. Frontiers In Psychology, 10, 334. https://doi.org/10.3389/fpsyg.2019.00334

  Huovinen, E., Ylitalo, A.-K., y Puurtinen, M. (2018). Early Attraction in Temporally Controlled Sight Reading of Music. Journal of Eye Movement Research, 11(2), 1-30. https://doi.org/10.16910/jemr.11.2.3

  Kleppinger, N. S. V. (2017b). Practical and Philosophical Reflections Regarding Aural Skills Assessment. Indiana Theory Review, 33(1-2), 153. https://doi.org/10.2979/inditheorevi.33.1-2.06

  Lingjie, A. (2025). Effectiveness Study of Applying Earmaster for Ear Training in Chinese University Students. International Journal Of Sociologies And Anthropologies Science Reviews, 5(2), 29-38. https://doi.org/10.60027/ijsasr.2025.5514

  Lu, L. (2025). AI-powered intelligent music education systems for real-time feedback and performance assessment. International Journal Of Information And Communication Technology, 1(1). https://doi.org/10.1504/ijict.2025.10071414

  McNeil, B. (2021). Aural Skills Pedagogy in the Wind Band: A Survey of Secondary and Collegiate Wind Band Conductors’ Perceptions and Strategies \[Disertación de PhD, Auburn University\]. https://etd.auburn.edu/handle/10415/7610

  Mingyu, G., Yunus, M. M., & Rafiq, K. R. M. (2024). Educational Games and Game-based Approaches in Higher Education: A Systematic Review (2014-2023). International Journal Of Academic Research In Progressive Education And Development, 13(1). https://doi.org/10.6007/ijarped/v13-i1/20555

  Nichols, B. E., & Springer, D. G. (2025). Piano history, aural skills, and working memory predict melodic dictation performance. Frontiers In Psychology, 16, 1579714. https://doi.org/10.3389/fpsyg.2025.1579714

  Ou, J., Nogueira, J., & Qin, C. (2025). Exploring the impact of AI-assisted practice applications on music learners’ performance, self-efficacy, and self-regulated learning. Frontiers In Psychology, 16, 1675762. https://doi.org/10.3389/fpsyg.2025.1675762

  Pesek, M., Suhadolnik, L., Šavli, P., & Marolt, M. (2020b). Motivating Students for Ear-Training with a Rhythmic Dictation Application. Applied Sciences, 10(19), 6781. https://doi.org/10.3390/app10196781

  Pesek, M., Vucko, Z., Savli, P., Kavcic, A., & Marolt, M. (2020a). Troubadour: A Gamified e-Learning Platform for Ear Training. IEEE Access, 8, 97090-97102. https://doi.org/10.1109/access.2020.2994389

  Qian, C., & Jiang, M. (2024). Exploring the Effects of Digital Game-Based Learning on Music Education. Studies In Social Science & Humanities, 3(5), 6-9. https://doi.org/10.56397/sssh.2024.05.02

  Respati, R., Apriyaningsih, E., & Muslihin, H. Y. (2021). The development of Aurilio games to facilitate the ear training of early childhood. Proceedings of the 3rd International Conference on Arts and Design Education (ICADE 2020).

  Richards, J. (2023). Discovering the Pedagogy and Secrets of Gamification and Game-Based Learning Applied to the Music Theory Classroom \[Disertación\]. Liberty University.

  Rogers, M. (2013). Aural dictation affects high achievement in sight singing, performance and composition skills. Australian Journal Of Music Education/Australian Journal Of Music Education (Online), 1, 34. http://files.eric.ed.gov/fulltext/EJ1061809.pdf

  Román-Celi, G. E. (2023). Aprendizaje Basado en Juegos (GBL) en el desarrollo del pensamiento crítico \[Games Based Learning (GBL) in the development of critical thinking\]. Cognopolis Revista de Educación y Pedagogía, 1(3), 1-14. https://doi.org/10.62574/5m9rgk11

  Royston, N., & Wilson, J. (2024). Do You Want to Major in Music?: A Guide to Majoring in Music or Music Education in American Colleges and Universities. https://doi.org/10.31274/isudp.2024.157

  Thompson, S. & Lehmann, A. C. (2004). Strategies for sight-reading and improvising music. En A. Williamon (Ed.), Musical excellence (pp.143-159). Oxford University Press. https://doi.org/10.1093/acprof:oso/9780198525356.003.0008

  Vallejo, D. (2019). Allegra: Gamification-based Tool to Practice Melodic Dictation \[Trabajo de fin de grado\]. Universidad de Castilla-La Mancha.

  Wang, X., & Haris, M. F. B. (2025). AI-Driven Violin Performance Evaluation: A Deep Learning Approach for Automated Assessment and Personalized Feedback in Music Education. En Proceedings of the 2025 International Conference on Generative Artificial Intelligence and Digital Media (pp. 126-132). https://doi.org/10.1145/3734921.3734941

  Wristen, B. (2005). Cognition and Motor Execution in Piano Sight-Reading: A Review of Literature. Update Applications Of Research In Music Education, 24(1), 44-56. https://doi.org/10.1177/87551233050240010106
]

= Anexos

== Anexo A. Estudios seleccionados del estado del arte

#set page(flipped: true, margin: (x: 1.5cm, y: 2cm))
#set text(size: 8pt)
#set par(first-line-indent: 0pt, leading: 0.75em, spacing: 0.75em)

#let anexo-filas = (
  (
    [C1],
    [Žnideršič, K., Podbreznik, M., Klun, Ž., Šavli, P., Marolt, M., & Pesek, M. (2024)],
    [Troubadour: Inverse Dictation Games for Ear Training],
    [10.5220/0012747200003693],
    [Aprendizaje gamificado; dictado inverso],
    [Usuarios de Troubadour; UEQ/Meega+],
    [Novedad positiva y eficiencia],
    [Los juegos de entrenamiento auditivo inverso son escasos],
  ),
  (
    [C1],
    [Baratè, A., Brugaletta, A., & Ludovico, L. A. (2023)],
    [A Mobile Serious Game to Foster Music Sight Reading with Different Clefs],
    [10.5220/0012059500003470],
    [Juego serio para dispositivos móviles; ejercicios de claves musicales],
    [Early test users],
    [Atractivo, pero con problemas de interacción],
    [La práctica de lectura a primera vista para múltiples claves es limitada],
  ),
  (
    [C1],
    [Pesek, M., Hirci, N., Žnideršič, K., & Marolt, M. (2024)],
    [Enhancing music rhythmic perception and performance with a VR game],
    [10.1007/s10055-024-01014-y],
    [Juego de realidad virtual para bateristas],
    [Usuarios de autoaprendizaje remoto],
    [Mejora en la percepción del ritmo y el rendimiento],
    [El entrenamiento rítmico en realidad virtual está infravalorado],
  ),
  (
    [C1],
    [Deja, J. A., Štor, S., Pucihar, I., Weerasinghe, M., Balbin, R. M., Pucihar, K. Č., & Kljun, M. (2025)],
    [ImproVisAR: designing augmented reality piano roll for teaching improvisation],
    [10.1007/s10055-025-01215-z],
    [Visualización de piano roll en realidad aumentada],
    [Learner studies],
    [Prometedor para el aprendizaje de la improvisación],
    [El apoyo a la improvisación pianística está poco explorado],
  ),
  (
    [C1],
    [Yu, J., Zhang, T., Wu, S., Wu, X., Wu, T., Chen, Y., & Zhang, K. (2024)],
    [ArchiTone: A LEGO-Inspired Gamified System for Visualized Music Education],
    [10.48550/arxiv.2410.15273],
    [Bloques gamificados inspirados en LEGO],
    [Estudio de usuario],
    [Más atractivo que los métodos tradicionales],
    [Los principiantes necesitan herramientas teóricas más accesibles],
  ),
  (
    [C1],
    [Brewer, A., & Ching, Y.-H. (2024)],
    [Designing and Developing a Gamified App for Enhancing Independent Practice in K-12 Music Education],
    [10.59668/1269.15625],
    [Aplicación móvil gamificada],
    [Estudiantes de música K-12],
    [Favorece la motivación y el autocontrol],
    [La práctica independiente carece de un apoyo estructurado],
  ),
  (
    [C1],
    [Rana, F. A., Tsang, Y. L., & Yip, T. W. (2024)],
    [Music Corner - A Feasibility Study for Creating a Gesture-Based Rhythm Game for Music Education Inspired by Solfege Hand Signs],
    [10.1145/3613905.3648112],
    [Juego rítmico basado en gestos; aprendizaje automático móvil],
    [Estudio de viabilidad],
    [Prototipo accesible y viable],
    [El entrenamiento rítmico asequible es limitado],
  ),
  (
    [C1],
    [Kim, S., & Cozzarin, J. (2023)],
    [A New Technical Ear Training Game and Its Effect on Critical Listening Skills],
    [10.3390/app13095357],
    [Juego de entrenamiento auditivo de cuatro módulos],
    [Practicantes de ingeniería de audio],
    [Mayor compromiso y mejores habilidades],
    [El entrenamiento auditivo técnico necesita formatos gamificados],
  ),
  (
    [C1],
    [Qian, C. H., & Jiang, M. (2024)],
    [Exploring the Effects of Digital Game-Based Learning on Music Education],
    [10.56397/sssh.2024.05.02],
    [Aprendizaje de piano basado en juegos],
    [30 estudiantes universitarios de piano],
    [El grupo experimental superó al de control],
    [La evidencia cuantitativa de DGBL es limitada],
  ),
  (
    [C1],
    [Li, M. (2025)],
    [The Impact of Game-Based Learning and Flipped Classroom on Solfeggio Performance, Engagement, and Satisfaction],
    [10.57239/pjlss-2025-23.1.00674],
    [GBL + aula invertida],
    [90 estudiantes de solfeo],
    [Mayor rendimiento y compromiso],
    [GBL+FC en solfeo está poco explorado],
  ),
  (
    [C2],
    [Zhao, W., Wang, Z., & Shen, D. (2026)],
    [Long-term symbolic music generation based on dilated convolutional adversarial networks and LM-VGAN],
    [10.1007/s44163-026-00982-1],
    [GAN con convoluciones dilatadas; LM-VGAN],
    [Secuencias musicales simbólicas],
    [Mejor continuidad y precisión de estilo],
    [La continuidad a largo plazo sigue siendo débil],
  ),
  (
    [C2],
    [Yalan, Y. (2026)],
    [Enhancing long-term structure in symbolic music generation via a cascaded Skeleton-to-texture framework],
    [10.1038/s41598-026-46750-0],
    [Esqueletos de MusicBERT; atención cruzada],
    [Secuencias simbólicas largas],
    [Menos errores estructurales; acordes más sólidos],
    [La retención de motivos se desmorona en intervalos largos],
  ),
  (
    [C2],
    [Zhou, L., Yin, L., Qian, Y., & Wang, M. (2025)],
    [MLAT: a multi-level attention transformer capturing multi-level information in compound word encoding for symbolic music generation],
    [10.1186/s13636-025-00407-4],
    [Codificación de palabras compuestas; atención multinivel],
    [Corpus de música simbólica],
    [Mejor calidad de tono, ritmo y acordes],
    [Las relaciones a nivel de token están poco modeladas],
  ),
  (
    [C2],
    [Zhao, C. (2026)],
    [T-WGAN: A Transformer-Wasserstein GAN Approach for Melody Generation with Structural and Rhythmic Fidelity],
    [10.31449/inf.v50i8.11624],
    [Transformer + WGAN-GP; REMI],
    [Lakh MIDI],
    [Mayor consistencia rítmica; menor FDM],
    [La diversidad y estabilidad melódicas necesitan trabajo],
  ),
  (
    [C2],
    [Chai, L., & Wang, D. (2025)],
    [CSL-L2M: Controllable Song-Level Lyric-to-Melody Generation Based on Conditional Transformer with Fine-Grained Lyric and Musical Controls],
    [10.1609/aaai.v39i22.34523],
    [Transformer condicional; controles FiLM],
    [Pares de letra y melodía],
    [Las melodías de las canciones completas se alinean con la letra],
    [La controlabilidad de letra a melodía es débil],
  ),
  (
    [C2],
    [Li, S., & Sung, Y. (2023)],
    [MelodyDiffusion: Chord-Conditioned Melody Generation Using a Transformer-Based Diffusion Model],
    [10.3390/math11081915],
    [Difusión de Transformer; condicionamiento de acordes],
    [Datos discretos de melodías simbólicas],
    [Maneja bien las dependencias largas],
    [La difusión para música discreta es poco común],
  ),
  (
    [C2],
    [Li, S., & Sung, Y. (2023)],
    [MRBERT: Pre-Training of Melody and Rhythm for Automatic Music Generation],
    [10.3390/math11040798],
    [Preentrenamiento para melodía/ritmo; BERT multitarea],
    [Corpus de preentrenamiento musical],
    [Apoya la generación y la finalización],
    [El preentrenamiento musical está infrautilizado],
  ),
  (
    [C2],
    [Zhu, J., Sakurai, K., Togo, R., OGAWA, T., & Haseyama, M. (2025)],
    [\[Paper\] TPSMG: Text-Controllable Polyphonic Symbolic Music Generation],
    [10.3169/mta.14.110],
    [U-Net de difusión condicionada por texto],
    [Indicaciones de texto + pares de música simbólica],
    [MIDI de alta calidad coincide con las indicaciones],
    [El control de texto para MIDI polifónico es escaso],
  ),
  (
    [C2],
    [Li, Y. (2025)],
    [ERLD-HC: Entropy-Regularized Latent Diffusion for Harmony-Constrained Symbolic Music Generation],
    [10.3390/e27090901],
    [VAE + difusión latente + CRF],
    [Música simbólica/MIDI],
    [Mejor calidad de la armonía],
    [El control de la armonía frente a la flexibilidad no está resuelto],
  ),
  (
    [C2],
    [Wang, C., & Deng, W. (2026)],
    [Multi-track symbolic music generation algorithm based on diffusion model and music structure constraints],
    [10.1504/ijict.2026.152436],
    [Modelo de difusión; restricciones de estructura],
    [Varios conjuntos de datos musicales],
    [Mayor similitud y puntuaciones de expertos],
    [Persisten los conflictos entre pistas y la fragmentación rítmica],
  ),
  (
    [C3],
    [Jin, X., Gui, J., Li, D., & Wang, Y. (2025)],
    [MIDI music plagiarism detection method based on feature similarity learning],
    [10.1186/s13636-025-00429-y],
    [Vectores de ritmo/nota; red siamesa],
    [Corpus musical MIDI],
    [96,3 % de precisión],
    [Se necesitan mejores características de similitud MIDI],
  ),
  (
    [C3],
    [Malandrino, D., Prisco, R. D., Ianulardo, M., & Zaccagnino, R. (2022)],
    [An adaptive meta-heuristic for music plagiarism detection based on text similarity and clustering],
    [10.1007/s10618-022-00835-2],
    [Similitud de texto + agrupamiento],
    [Casos de plagio/no plagio; 20 usuarios],
    [Superó a los métodos existentes],
    [Las métricas objetivas de plagio son escasas],
  ),
  (
    [C3],
    [Kim, S., Kim, Y., Lee, J., & Jang, D. (2026)],
    [Hybrid Music Similarity with Hypergraph and Siamese Network],
    [10.3390/bdcc10030096],
    [Metadatos de hipergrafo + pérdida siamesa],
    [Samples para producción musical],
    [Mejor modelado de similitud conjunta],
    [Los metadatos y la acústica suelen estar separados],
  ),
  (
    [C3],
    [Kharisma, R., & Denny, D. (2024)],
    [Music Similarity Ranking: Case Study Fairphonic],
    [10.33022/ijcs.v13i4.4298],
    [HPCP/croma/ritmo; perfil matricial],
    [Cientos de miles de pistas de catálogo],
    [MAP 0,989; búsqueda un 72 % más rápida],
    [Se necesita una similitud escalable en todo el catálogo],
  ),
  (
    [C3],
    [Chen, Y., & Li, N. (2023)],
    [Analysis of the Similarity Estimation Schemes for Music and Applications],
    [10.11648/j.ijecs.20230806.16],
    [Estudio de métricas de similitud],
    [Literatura sobre similitud musical],
    [Mapea métodos y aplicaciones],
    [Los esquemas de evaluación están fragmentados],
  ),
  (
    [C3],
    [Saner, A., & Chen, M. (2025)],
    [Music Similarity Detection Through Comparative Imagery Data],
    [10.3390/app15147706],
    [Conjunto de CNN sobre imágenes comparativas],
    [Plagio verificado + música generada por IA],
    [Funcionó en casos verificados y de IA],
    [Los datos etiquetados de plagio son escasos],
  ),
  (
    [C3],
    [Vahidi, C., Singh, S., Benetos, E., Phan, H. P., Stowell, D., Fazekas, G., & Lagrange, M. (2023)],
    [Perceptual Musical Similarity Metric Learning with Graph Neural Networks],
    [10.1109/waspaa58266.2023.10248151],
    [Aprendizaje de métricas con CNN de grafos],
    [Sonidos de técnicas de interpretación musical],
    [96,4 % de recuperación frente a 38,5 %],
    [La similitud perceptiva es difícil de modelar],
  ),
  (
    [C3],
    [Akama, T., Kitano, H., Takematsu, K., Miyajima, Y., & Polouliakh, N. (2023)],
    [Auxiliary self-supervision to metric learning for music similarity-based retrieval and auto-tagging],
    [10.1371/journal.pone.0294643],
    [Aprendizaje de métricas autosupervisado],
    [Datos de recuperación de audio musical],
    [Recuperación y etiquetado mejorados],
    [Necesita menos supervisión],
  ),
  (
    [C3],
    [J.S., S. (2022)],
    [Pairwise Similarity Normalization Based on a Hubness Score for Improving Cover Song Retrieval Accuracy],
    [10.1587/transinf.2021EDL8075],
    [Alineación de secuencias; normalización de centralidad],
    [Dos conjuntos de datos de versiones de canciones],
    [Precisión de recuperación mejorada],
    [El «hubness» perjudica la búsqueda de similitud],
  ),
  (
    [C3],
    [Carvalho, N., Diogo, D., & Bernardes, G. (2023)],
    [Computational Similarity of Portuguese Folk Melodies Using Hierarchical Reduction],
    [10.1145/3625135.3625152],
    [Reducción melódica jerárquica; SIAM],
    [Melodías folclóricas portuguesas],
    [84–90 % de varianza explicada],
    [La similitud simbólica robusta necesita jerarquía],
  ),
  (
    [C4],
    [Schwabe, M., Murgul, S., & Heizmann, M. (2022)],
    [Dual Task Monophonic Singing Transcription],
    [10.17743/jaes.2022.0040],
    [Transcripción de canto de doble tarea],
    [Datos de canto monofónico],
    [Transcripción a nivel de nota mejorada],
    [El AMT para canto está menos desarrollado que el de piano],
  ),
  (
    [C4],
    [Bhattarai, B., & Lee, J. (2024)],
    [Korean Pansori Vocal Note Transcription Using Attention-Based Segmentation and Viterbi Decoding],
    [10.3390/app14020492],
    [Segmentación de atención + Viterbi],
    [Voces de pansori coreano],
    [Transcripción eficaz de notas vocales],
    [La transcripción vocal tradicional está poco estudiada],
  ),
  (
    [C4],
    [X., W., B., T., W., Y., W., X., & W., C. (2023)],
    [MusicYOLO: A Vision-Based Framework for Automatic Singing Transcription],
    [10.1109/TASLP.2022.3221005],
    [AST estilo YOLO; inicio/fin/tono],
    [Corpus de audio de canto],
    [Proceso directo de transcripción de canto],
    [Se necesita un AST de extremo a extremo más rápido],
  ),
  (
    [C4],
    [Kim, T., Kim, M.-J., & Ahn, C. W. (2025)],
    [PF2N: Periodicity–Frequency Fusion Network for Multi-Instrument Music Transcription],
    [10.3390/math13111708],
    [Red de fusión de periodicidad-frecuencia],
    [Audio multi-instrumental],
    [Mejor transcripción de múltiples instrumentos],
    [Los armónicos superpuestos siguen siendo un reto para el AMT],
  ),
  (
    [C4],
    [Matsunaga, T., & Saito, H. (2026)],
    [Multitrack Music Transcription Based on Joint Learning of Onset and Frame Streams],
    [10.3390/signals7010012],
    [U-Net + Perceiver; aprendizaje conjunto de inicio/fotograma],
    [Datasets de música multipista],
    [Transcripción de múltiples instrumentos mejorada],
    [La escasez de conjuntos de datos limita la precisión],
  ),
  (
    [C4],
    [Li, Z., Zhou, Y., & Wu, H. (2025)],
    [A Hybrid Model for Automatic Music Transcription of Hulusi Based on Multi-Feature Fusion],
    [10.1145/3778534.3778540],
    [Fusión de características; ResNet + BiGRU],
    [Audio de hulusi],
    [Mejor calidad de tono y transcripción],
    [El AMT no occidental es escaso],
  ),
  (
    [C4],
    [T., K., D., L., M., J. K., & C., W. A. (2024)],
    [Polyphonic Piano Music Transcription System Exploiting Mutual Correlations of Different Musical Note States],
    [10.1109/ACCESS.2024.3425167],
    [Modelado de correlación de estado de nota],
    [Grabaciones de piano polifónicas],
    [Captura las dependencias del estado de las notas],
    [Las CNN pasan por alto las relaciones entre notas],
  ),
  (
    [C4],
    [Gu, X., Ou, L., Zeng, W., Zhang, J., Wong, N. H., & Wang, Y. (2024)],
    [Automatic Lyric Transcription and Automatic Music Transcription from Multimodal Singing],
    [10.1145/3651310],
    [Transcripción de canto multimodal],
    [Audio de canto con etiquetas de letra],
    [Transcribe conjuntamente letras y notas],
    [Las letras y las notas suelen estar separadas],
  ),
  (
    [C4],
    [Cao, R., Liang, Z., Yan, Z., & Liu, B. (2024)],
    [DAFE-MSGAT: Dual-Attention Feature Extraction and Multi-Scale Graph Attention Network for Polyphonic Piano Transcription],
    [10.3390/electronics13193939],
    [Atención dual + GAT multiescala + LSTM],
    [Audio polifónico de piano],
    [Modelado mejorado de tiempo-frecuencia y notas],
    [Las CNN pasan por alto la dependencia de las notas],
  ),
  (
    [C4],
    [Bittner, R., Bosch, J. J., Rubinstein, D., Meseguer-Brocal, G., & Ewert, S. (2022)],
    [A Lightweight Instrument-Agnostic Model for Polyphonic Note Transcription and Multipitch Estimation],
    [10.1109/icassp43922.2022.9746549],
    [AMT ligero independiente del instrumento],
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
