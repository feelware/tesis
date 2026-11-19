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

En entornos formales de educación musical, alcanzar un buen desempeño en los cursos de habilidades auditivas requiere de mucha práctica, pues la dificultad de estos aumenta rápidamente (Royston y Wilson, 2024). Estos cursos representan un obstáculo desalentador para muchos estudiantes de música, contribuyendo en ciertos casos a la deserción académica (Barlow, 2016). Las evaluaciones de aptitud auditiva consisten en escuchar una grabación proporcionada por el docente y transcribirla en papel. Calificar estas evaluaciones suele tomar varios días a los docentes, lo que impide al alumno obtener retroalimentación instantánea (Pesek et al., 2020b). Kleppinger (2017) señala que estas evaluaciones no se alinean consistentemente con lo que se espera que los estudiantes aprendan. Su naturaleza "contrarreloj" genera ansiedad incluso en estudiantes de alto rendimiento, lo que más adelante se transforma en perspectivas pesimistas sobre la utilidad de estos cursos. Chenette (2021) argumenta que el material de estudio para entrenamiento auditivo, al estar fuertemente enlazado a la currícula tradicional de teoría musical, hereda un enfoque eurocentrista, ignorando la música popular y las tradiciones musicales internacionales. Donn et al. (2024) argumentan que muchos de los métodos de entrenamiento auditivo aplicados en escuelas secundarias británicas fueron diseñados para un contexto musical mucho menos diverso que el contemporáneo.

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

Para la recolección de datos se empleará la técnica de evaluación mediante pruebas de desempeño, aplicadas a los participantes antes y después de la intervención educativa. Estas evaluaciones serán similares en naturaleza a aquellas propuestas por docentes de cursos formales de entrenamiento auditivo, incluyendo actividades de dictado y repentización musical.

== 3.8. Técnicas de análisis de datos

Los datos recopilados serán procesados mediante técnicas de análisis estadístico descriptivo e inferencial. Inicialmente se emplearán medidas descriptivas, tales como promedios, frecuencias y desviaciones estándar, con el fin de caracterizar el desempeño de los participantes y resumir los resultados obtenidos durante las evaluaciones. Posteriormente, se compararán los resultados obtenidos por el grupo experimental y el grupo de control en las evaluaciones realizadas antes y después de la intervención, con el propósito de determinar el grado de cumplimiento de los objetivos definidos para la solución propuesta. Para ello se utilizarán pruebas estadísticas apropiadas según la naturaleza y distribución de los datos recolectados

// ============ Capítulo IV ============
// Estilo: el capítulo sigue el registro del capítulo de desarrollo de Freire
// (2025): exposición en presente y pasado, tablas y figuras propias, sin
// citas externas adicionales. Las secciones marcadas con PLACEHOLDER describen
// el diseño de la versión completa y deberán reescribirse cuando exista
// implementación y evidencia empírica. Ver docs/context.md, sección 21.

#import "@preview/fletcher:0.5.5" as fletcher: diagram, node, edge

#let caja-c4(x, y, body, fill: rgb("#eef2ff")) = node((x, y), body, shape: fletcher.shapes.rect, fill: fill)
#let pastilla-c4(x, y, body, fill: rgb("#eef2ff")) = node((x, y), body, shape: fletcher.shapes.pill, fill: fill)
#let diam-c4(x, y, body, fill: rgb("#fff7ed")) = node((x, y), body, shape: fletcher.shapes.diamond, fill: fill)

= Capítulo IV: Desarrollo de la propuesta

El presente capítulo documenta el diseño y la construcción del artefacto propuesto, correspondiente a la tercera actividad del Design Science Research Methodology (DSRM): diseño y desarrollo (Peffers et al., 2008). La exposición se organiza en once secciones que recorren el enfoque de desarrollo, la arquitectura, el modelo de dominio musical, el generador procedural, el evaluador de similitud, la transcripción automática, las mecánicas de juego, la persistencia, la interfaz, las pruebas técnicas y la síntesis del capítulo.

El capítulo distingue entre el prototipo funcional, que implementa el núcleo individual del videojuego, y la especificación de la versión multijugador completa. Esta distinción responde a la naturaleza iterativa del DSRM: el núcleo musical y de interacción se construyó y verificó primero, y sobre esa base se definió la mecánica multijugador. En las figuras de arquitectura y de flujo, los componentes de la versión completa se representan con trazo discontinuo o con relleno diferenciado; en el texto, se emplea el verbo *implementar* únicamente para los componentes construidos y verificados, y el verbo *definir* o *especificar* para los que forman parte del diseño de la versión completa.

== 4.1. Enfoque de desarrollo y alcance del artefacto

=== 4.1.1. Posición dentro del DSRM

El DSRM organiza la investigación en seis actividades: identificación del problema y motivación, definición de objetivos para la solución, diseño y desarrollo, demostración, evaluación y comunicación (Peffers et al., 2008). El presente capítulo se ubica en la tercera actividad. Las actividades de demostración y evaluación se abordan en el capítulo III, en la medida en que definen el protocolo experimental, y en el capítulo V, donde se reportan los resultados.

La construcción del artefacto no siguió una secuencia lineal. Durante la implementación surgieron hallazgos que obligaron a revisar decisiones de diseño: el backend `webgl` de TensorFlow.js dejó de avanzar dentro de un Web Worker, lo que obligó a forzar el backend `cpu`; el ruido tonal por debajo del registro cantado produjo notas espurias, lo que llevó a acotar el rango de frecuencia del modelo; y la diferencia entre los ataques introducidos sobre una rejilla y los ataques producidos por el transcriptor obligó a separar las tolerancias de dictado y de canto. Estos retornos a la actividad de diseño son consistentes con el DSRM, que se concibe como un modelo nominal y no como una secuencia rígida.

// Extracto clave de Peffers et al. (2008), manuscrito, p. 1117:
// «we are suggesting that the DSRM should not be used as a rigid orthodoxy
// to criticize work that does not follow it explicitly».

=== 4.1.2. Estrategia de construcción

La construcción se organizó en incrementos verticales. Cada incremento incorporó una capacidad completa —dominio, persistencia, interfaz y pruebas— y mantuvo la aplicación ejecutable. El orden fue el siguiente: primero el dominio musical, después la persistencia, luego la interfaz de dictado, a continuación la transcripción y la interfaz de repentización, y finalmente la integración y el resumen de la partida. Esta secuencia redujo el riesgo de mezclar errores musicales con errores de red, de persistencia o de interfaz.

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
    ([Transcripción con Basic Pitch], [Servicio externo de transcripción], [Inferencia local en el navegador; no se transfiere audio ni se requiere GPU del servidor.]),
    ([Piano roll], [Pentagrama], [Permite aislar altura y ataque; reduce la influencia de la lectoescritura en la medición de habilidades auditivas.]),
    ([Payload CMS], [Backend propio], [Autenticación, colecciones, administración y API disponibles sin desarrollar un backend desde cero.]),
    ([Modelo monofónico], [Modelo polifónico], [Los ejercicios son melódicos; el emparejamiento uno a uno es suficiente y verificable.]),
    ([Inferencia en cliente], [Inferencia en servidor], [Menor transferencia de datos personales y menor carga para la aplicación Next.js.]),
  ),
)]

=== 4.1.3. Alcance y trazabilidad

El prototipo funcional implementa el flujo individual completo: configuración de la partida, generación de melodías, dictado, repentización con transcripción, evaluación por ronda, persistencia de la sesión y resumen. La versión completa añade salas multijugador, intercambio de producciones entre jugadores, galería final, aulas y vista docente. La Tabla 4 relaciona los objetivos específicos con las secciones del capítulo.

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
  caja-c4(3.0, 2.6, [Transcripción #linebreak() Basic Pitch], fill: rgb("#f0fdf4")),
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

La Tabla 5 resume las tecnologías empleadas y su función. Las versiones se consignan porque afectan la reproducibilidad de los resultados: una actualización mayor de TensorFlow.js o de Basic Pitch puede modificar la salida de la transcripción, y una actualización de Tonal puede alterar la construcción de escalas.

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
    ([Basic Pitch], [1.0.1], [Transcripción de audio a notas], [Implementación oficial en TypeScript ejecutable en navegador.]),
    ([TensorFlow.js], [3.21.0], [Ejecución del modelo en el navegador], [Dependencia compartida con Basic Pitch.]),
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
    ([`app/(frontend)`], [Interfaz de partida, componentes de ejercicio, evaluación y resumen.]),
    ([`app/(payload)`], [Panel administrativo y rutas de Payload.]),
    ([`src/lib/music`], [Dominio musical: tipos canónicos, validación, generador y evaluador.]),
    ([`src/lib/transcription`], [Captura, normalización, protocolo y Web Worker de Basic Pitch.]),
    ([`src/lib/audio`], [Grabación con `MediaRecorder` y reproducción con Web Audio.]),
    ([`src/lib/persistence.ts`], [Guardado de melodías y sesiones en Payload.]),
    ([`src/collections`], [Definición de las colecciones `Users`, `Melodies` y `GameSessions`.]),
    ([`scripts`], [Pruebas de humo y barrido de parámetros de transcripción.]),
  ),
)]

=== 4.2.4. Comunicación y despliegue

En el prototipo, la aplicación Next.js sirve la interfaz y las rutas de API; Payload expone la API de las colecciones y el panel administrativo; PostgreSQL almacena los datos estructurados. El audio no sale del navegador: se captura con `MediaRecorder`, se decodifica con Web Audio y se procesa en un Web Worker. El modelo de Basic Pitch se sirve como archivo estático desde `/models/basic-pitch/model.json`.

// PLACEHOLDER (parcial): la comunicación en tiempo real no forma parte del
// prototipo individual. El párrafo siguiente especifica el diseño de la
// versión completa y deberá reescribirse cuando se implemente y se pruebe.

La versión multijugador requiere un mecanismo de tiempo real para anunciar el inicio y el cierre de las rondas, notificar la recepción de respuestas y mantener sincronizado el estado de la partida. El diseño prioriza un servicio administrado de publicación y suscripción, con canales por sala y presencia, frente a un servidor WebSocket propio. La primera alternativa evita operar conexiones persistentes y delega la reconexión al proveedor; la segunda ofrece mayor control, pero exige mantener un proceso adicional y coordinarlo con Next.js y Payload. El canal de tiempo real transporta únicamente identificadores, estados y avisos de sincronización; las melodías, las respuestas y el audio se transfieren por la API o por almacenamiento de objetos.

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
    ([Seguridad], [Validación en servidor y control de acceso por rol (diseño)], [Evitar que el cliente altere resultados o consulte datos ajenos.]),
    ([Privacidad], [Procesamiento local del audio y retención definida (diseño)], [Protección de las grabaciones de voz.]),
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

La Tabla 9 define los tres niveles de dificultad. La Tabla 10 completa la configuración global del generador. Los valores de registro se expresan como números MIDI y corresponden a una ventana centrada en C4 (MIDI 60); el ambitus indica la extensión total de la ventana.

#block(breakable: false)[
#leyenda([Tabla], 9, [Parámetros de generación melódica por nivel de dificultad])
#apatable(
  columns: (4.4cm, 3.3cm, 3.8cm, 4.4cm),
  header: ([*Parámetro*], [*Dificultad baja*], [*Dificultad media*], [*Dificultad alta*]),
  rows: (
    ([Longitud (notas)], [8], [15], [24]),
    ([Intervalo máximo consecutivo], [2 semitonos], [5 semitonos], [7 semitonos]),
    ([Ambitus], [12 semitonos (1 octava)], [24 semitonos (2 octavas)], [36 semitonos (3 octavas)]),
    ([Registro MIDI], [54–66], [48–72], [42–78]),
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

El generador se cubrió con 26 pruebas unitarias. Cada propiedad estructural se verificó sobre 25 semillas por nivel de dificultad, lo que permitió detectar casos límite en la modulación, en el ritmo y en el ambitus. La Tabla 11 resume las propiedades verificadas.

#block(breakable: false)[
#leyenda([Tabla], 11, [Propiedades verificadas del generador])
#apatable(
  columns: (4.3cm, 7.4cm, 4.2cm),
  header: ([*Propiedad*], [*Criterio*], [*Cobertura*]),
  rows: (
    ([Longitud], [8, 15 o 24 notas según el nivel], [25 semillas por nivel]),
    ([Intervalo máximo], [≤ 2, 5 o 7 semitonos], [25 semillas por nivel]),
    ([Ambitus], [≤ 12, 24 o 36 semitonos], [25 semillas por nivel]),
    ([Pertenencia a la escala], [Cada segmento usa su escala activa], [25 semillas por nivel]),
    ([Valores rítmicos], [Solo duraciones permitidas], [25 semillas por nivel]),
    ([Figura requerida], [Al menos una figura del nivel], [25 semillas por nivel]),
    ([Superposición], [Sin notas superpuestas], [25 semillas por nivel]),
    ([Modulación], [Regla de modulación del nivel], [25 semillas por nivel]),
    ([Reproducibilidad], [Misma tupla de parámetros, misma melodía], [2 casos]),
    ([Sensibilidad], [Semillas distintas, melodías distintas], [2 casos]),
  ),
)]

=== 4.4.5. Discusión de decisiones

El enfoque procedural ofrece tres ventajas frente a un modelo generativo. Primero, permite imponer restricciones pedagógicas verificables, como el intervalo máximo o la longitud. Segundo, produce melodías reproducibles y auditables. Tercero, no requiere entrenamiento ni infraestructura de inferencia. La desventaja es que la corrección estructural no garantiza calidad musical: una melodía puede cumplir todas las restricciones y resultar poco idiomática. Por esta razón, la validación automática se complementa con la revisión de docentes, que se aborda en el diseño experimental.

Una limitación del diseño actual es la relación entre el registro y la tesitura vocal. La dificultad alta abarca tres octavas (F#2–F#6), lo que excede la extensión cómoda de muchas voces. Para atenuar este efecto, la evaluación de repentización en dificultad baja admite equivalencia de octava; en dificultades media y alta se exige correspondencia estricta. La selección de melodías para repentización debe considerar esta restricción, y la posibilidad de transponer la referencia a la tesitura cómoda del jugador queda como una línea de mejora del generador.

== 4.5. Evaluación de similitud melódica

=== 4.5.1. Definición del problema

La evaluación compara dos secuencias monofónicas: la melodía de referencia y la respuesta del jugador. La respuesta puede tener notas omitidas, notas añadidas, alturas incorrectas o ataques desplazados. Por este motivo, la comparación no puede reducirse a contrastar posiciones de dos listas: es necesario establecer primero una correspondencia entre eventos y luego calcular las métricas sobre esa correspondencia.

La evaluación se limita a dos dimensiones: precisión de alturas y precisión rítmica. No se evalúa el timbre, la expresividad, la calidad vocal ni la duración de las notas. La duración se conserva para la visualización y la reproducción, pero no forma parte de la puntuación. Esta delimitación concentra la medición en los objetivos del videojuego y evita introducir juicios subjetivos.

=== 4.5.2. Métricas

Para cada dimensión se calculan precisión, exhaustividad y medida $F_1$. La precisión mide la proporción de notas de la respuesta que encontraron correspondencia; la exhaustividad, la proporción de notas de referencia que fueron encontradas. La medida $F_1$ combina ambas y penaliza tanto las notas de más como las notas omitidas.

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

El evaluador se cubrió con 20 pruebas unitarias. La Tabla 13 resume los casos límite y el comportamiento esperado. Además de los casos de la tabla, se verificó que el resultado no dependa del orden de las notas y que los empates se resuelvan de forma uno a uno.

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

La medida $F_1$ se adoptó porque penaliza simétricamente las omisiones y las notas de más, a diferencia de una precisión simple. El promedio aritmético de las dos dimensiones es transparente para el jugador y fácil de explicar, aunque no distingue si un error de altura es más grave que un error rítmico. La separación de dimensiones permite que el jugador identifique el tipo de error, y el panel de evaluación muestra ambas puntuaciones además de la global. La decisión de no puntuar la duración de las notas reduce la complejidad del dictado, pero limita la evaluación del ritmo a la ubicación de los ataques.

== 4.6. Transcripción automática de audio a MIDI

=== 4.6.1. Selección del modelo

La evaluación de la repentización requiere transformar la interpretación vocal en una secuencia de notas. Se seleccionó Spotify Basic Pitch en su implementación oficial para TypeScript, publicada como `@spotify/basic-pitch`. La selección se basó en cuatro criterios: disponibilidad de una implementación mantenida en npm, ejecución en el navegador mediante TensorFlow.js, capacidad de procesar audio monofónico y posibilidad de operar sin enviar el audio a un servicio externo. La implementación se apoya en un modelo preentrenado y no requiere entrenamiento propio.

=== 4.6.2. Pipeline de procesamiento

La Figura 8 muestra el pipeline. El jugador graba su interpretación con `MediaRecorder`; el audio se decodifica con Web Audio, se remuestrea a 22 050 Hz mono y se recorta el silencio inicial. La señal resultante se transfiere a un Web Worker, donde Basic Pitch infiere las notas. La salida se normaliza y se convierte en una secuencia de `EvaluatedNote`, que se compara con la melodía de referencia mediante el evaluador descrito en la sección 4.5.

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
  caja-c4(4.0, 1.4, [Web Worker #linebreak() backend CPU]),
  caja-c4(2.0, 1.4, [Basic Pitch]),
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
    ([`onsetThresh`], [0.5], [Umbral de detección de ataques.]),
    ([`frameThresh`], [0.3], [Umbral de activación por fotograma.]),
    ([`minNoteLen`], [12 fotogramas], [Descarta transitorios de consonante; equivale a unos 0.14 s.]),
    ([`minFreq`–`maxFreq`], [75–1500 Hz], [Acota el rango de inferencia y elimina ruido tonal grave.]),
    ([`melodiaTrick`], [`true`], [Favorece la melodía dominante.]),
    ([`energyTolerance`], [11], [Tolerancia de energía del modelo.]),
    ([Frecuencia de muestreo], [22 050 Hz], [Requisito de entrada del modelo.]),
    ([Fusión de segmentos], [< 80 ms], [Une notas contiguas de igual altura.]),
  ),
)]

=== 4.6.4. Integración en el navegador

La inferencia se ejecuta en un Web Worker para no bloquear la interfaz. Durante el desarrollo se comprobó que, dentro del Worker, el backend `webgl` de TensorFlow.js deja de avanzar en la ejecución del modelo; por esta razón se fuerza el backend `cpu` antes de inferir. También se fijó TensorFlow.js en la versión 3.21.0 como dependencia directa para compartir una única instancia con Basic Pitch. El modelo se sirve localmente, de modo que la transcripción no depende de una conexión externa ni expone el audio del jugador a un tercero.

El cliente mantiene un watchdog de 30 s: si la transcripción deja de reportar progreso, la solicitud se cancela y se informa al jugador. Esta decisión evita que la interfaz quede bloqueada esperando un mensaje que no llegará.

=== 4.6.5. Manejo de errores

El flujo distingue entre errores de captura, de decodificación, de transcripción y de resultado vacío. Si el permiso del micrófono se deniega, se informa al jugador y se le permite reintentar. Si la grabación no puede decodificarse, se descarta y se solicita una nueva toma. Si la transcripción no detecta notas, se informa que no se detectaron eventos y se permite repetir la grabación. Si la transcripción falla o se estanca, se cancela y se muestra el error. En ninguno de estos casos se asigna automáticamente una puntuación de cero: la respuesta no puntuada se excluye del promedio y se muestra como ausente en el resumen.

=== 4.6.6. Validación técnica

La integración se verificó con una señal sinusoidal de 2 s que contiene un La4; el modelo detecta correctamente la nota. También se ejecutó un banco de 25 casos sintéticos con vibrato, ruido y transitorios de respiración. Los resultados se reportan en la sección 4.10.3. La validación con voz cantada real se especifica en la sección 4.10.5.

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

// PLACEHOLDER: sección de diseño de la versión completa. Reescribir con
// evidencia de implementación y pruebas cuando exista el flujo multijugador.

La versión completa organiza la partida en salas creadas manualmente. El creador configura la dificultad, la actividad inicial y el número de rondas; la sala genera un código de acceso y los participantes se incorporan antes de iniciar. Durante la partida, cada respuesta se asigna a otro participante en la ronda siguiente. En una ronda de dictado, el jugador escucha una melodía interpretada por otro participante y la transcribe; en una ronda de repentización, recibe una transcripción realizada por otro participante y la interpreta. El intercambio preserva la trazabilidad: cada respuesta se vincula con su autor, su ronda de origen, su material de referencia y su destinatario. La asignación evita devolver una respuesta a su autor en la misma cadena, salvo que la sala lo permita explícitamente.

=== 4.7.4. Puntuación y cierre

La puntuación de cada respuesta es el promedio de las medidas $F_1$ de alturas y ritmo. La puntuación final del jugador es el promedio aritmético de las puntuaciones de sus respuestas puntuadas:

$ S_"jugador" = (sum_(i = 1)^n S_i) / n $

donde $n$ es el número de respuestas puntuadas y $S_i$ es la puntuación global de la respuesta $i$. Las respuestas no puntuadas por fallos técnicos se excluyen del promedio y se muestran como ausentes; no se incorporan como ceros. La clasificación se limita a la partida y no se extiende a un ranking global.

=== 4.7.5. Reglas de recuperación y abandono

// PLACEHOLDER: sección de diseño de la versión completa. Reescribir con
// evidencia de pruebas de reconexión y abandono.

La versión completa define reglas para los casos en que un participante se desconecta, abandona la sala o no envía su respuesta dentro del tiempo de la ronda. Si un jugador se desconecta, la sala conserva su lugar y su respuesta previa; si se reconecta antes del cierre de la ronda, puede continuar. Si no envía una respuesta, la ronda se cierra con las respuestas disponibles y el jugador recibe una ausencia, no una puntuación de cero. Si el anfitrión abandona, la sala elige un nuevo anfitrión o se cierra de forma controlada. El plan de pruebas de la versión completa incluye la verificación de estas reglas mediante pruebas de sincronización y de reconexión antes de la sesión con estudiantes.

== 4.8. Persistencia y modelo de datos

=== 4.8.1. Modelo conceptual

// PLACEHOLDER: el modelo conceptual corresponde a la versión completa. La
// implementación actual se describe en 4.8.2.

La versión completa organiza los datos en entidades relacionadas. La Figura 10 muestra la cadena principal de una partida: una sala contiene partidas, una partida contiene rondas, una ronda se asocia con una melodía y con las respuestas de los jugadores, y cada respuesta puede tener una transcripción, un resultado de evaluación y un archivo de audio. Las entidades de usuario, aula y pertenencia se mantienen separadas de la cadena de juego para permitir que un docente consulte los resultados de sus estudiantes sin mezclar los datos de las partidas.

#block(breakable: false)[
#leyenda([Figura], 10, [Cadena de datos de una partida])
#align(center)[
#set text(size: 7.5pt)
#diagram(
  node-stroke: 0.7pt, edge-stroke: 0.7pt, node-corner-radius: 3pt, mark-scale: 70%,
  spacing: (1.1cm, 0.8cm),
  caja-c4(0, 0, [GameRoom #linebreak() id · code · hostId]),
  caja-c4(0, 1.1, [Game #linebreak() id · roomId · status]),
  caja-c4(0, 2.2, [Round #linebreak() id · gameId #linebreak() number · type]),
  caja-c4(2.6, 2.2, [Melody #linebreak() id · seed #linebreak() difficulty]),
  caja-c4(0, 3.5, [Submission #linebreak() id · roundId #linebreak() playerId · type]),
  caja-c4(2.6, 3.5, [Transcription #linebreak() id · submissionId #linebreak() modelVersion]),
  caja-c4(5.0, 3.5, [EvaluationResult #linebreak() submissionId #linebreak() pitch · rhythm · overall]),
  caja-c4(-2.2, 3.5, [AudioAsset #linebreak() id · submissionId #linebreak() uri]),
  edge((0,0), (0,1.1), "->"),
  edge((0,1.1), (0,2.2), "->"),
  edge((0,2.2), (2.6,2.2), "->", label: [referencia]),
  edge((0,2.2), (0,3.5), "->"),
  edge((0,3.5), (2.6,3.5), "->"),
  edge((0,3.5), (5.0,3.5), "->", bend: -20deg),
  edge((0,3.5), (-2.2,3.5), "->"),
  edge((2.6,2.2), (5.0,3.5), "->", stroke: (dash: "dashed"), label: [referencia]),
)
]
]

=== 4.8.2. Implementación en Payload

El prototipo implementa tres colecciones: `Users`, `Melodies` y `GameSessions`. La Tabla 15 describe sus campos. La sesión de juego embebe las rondas en un arreglo, en lugar de modelarlas como una colección independiente, para simplificar la escritura y la lectura durante el prototipo. Esta decisión reduce el número de consultas, pero limita las consultas agregadas y la normalización; la versión completa separa las rondas, las respuestas y los resultados.

#block(breakable: false)[
#leyenda([Tabla], 15, [Colecciones implementadas en Payload])
#apatable(
  columns: (4.0cm, 5.8cm, 6.1cm),
  header: ([*Colección*], [*Campos*], [*Propósito*]),
  rows: (
    ([`Users`], [`email`, `name`], [Autenticación y perfil mínimo.]),
    ([`Melodies`], [`symbolicData`, `seed`, `difficulty`, `tempoBpm`, `generatorVersion`, `key`, `scale`], [Melodías generadas y sus metadatos.]),
    ([`GameSessions`], [`sessionSeed`, `difficulty`, `firstActivity`, `tempoBpm`, `averageScore`, `rounds[]`], [Sesión, configuración y promedio.]),
    ([GameSessions #linebreak() (rondas)], [`roundNumber`, `activity`, `melody`, `response`, `pitchScore`, `rhythmScore`, `overallScore`], [Resultado de cada ronda.]),
  ),
)]

=== 4.8.3. Trazabilidad de la partida

La sesión se identifica con `sessionSeed`; cada ronda se identifica con `roundNumber`; cada melodía se relaciona con la colección `Melodies`; y cada respuesta se almacena en el campo `response` de la ronda. Las puntuaciones de alturas, ritmo y global se almacenan en la misma ronda. Esta estructura permite reconstruir la partida completa a partir de una sesión y sus rondas, y permite verificar que la melodía evaluada corresponde a la melodía generada.

=== 4.8.4. Archivos de audio y retención

// PLACEHOLDER: sección de diseño de la versión completa. Reescribir con
// evidencia de almacenamiento, consentimiento y retención implementados.

La versión completa conserva las grabaciones originales y las transcripciones. El audio se almacena en un servicio de objetos y la base de datos guarda la referencia y los metadatos; no se almacenan blobs grandes en las filas de PostgreSQL. La retención se define antes de la sesión con estudiantes e incluye el consentimiento informado, el plazo de conservación, el procedimiento de eliminación y las condiciones de acceso. El audio se trata como dato personal y no se expone públicamente por defecto.

=== 4.8.5. Control de acceso

// PLACEHOLDER: sección de diseño de la versión completa. Reescribir con la
// implementación de access control de Payload y las pruebas de autorización.

La versión completa define tres roles: participante, docente y administrador. El participante consulta sus propios datos y las partidas en las que participa; el docente consulta los estudiantes y los resultados de las aulas que administra; el administrador gestiona usuarios y configuración. Las reglas se definen mediante el control de acceso de Payload y se validan en el servidor, no solo mediante la ocultación de elementos en la interfaz. En el prototipo, las colecciones emplean acceso abierto para facilitar la verificación funcional; esta configuración no se traslada a la versión completa.

== 4.9. Interfaz y retroalimentación

=== 4.9.1. Principios de diseño

La interfaz se diseñó para computadoras de escritorio, porque las tareas requieren escuchar melodías, leer una representación musical, introducir notas y grabar la voz. La adaptación a dispositivos móviles se considera una línea de trabajo posterior y requiere probar la grabación y la edición musical en esos entornos.

La representación musical elegida es el piano roll, tanto para el dictado como para la lectura en repentización. Esta decisión aísla la altura y el ataque, que son las dos dimensiones evaluadas, y reduce la influencia de la lectoescritura en la medición. En repentización, el piano roll sustituye al pentagrama tradicional; esta simplificación favorece la comparabilidad entre jugadores con distinto nivel de lectura, pero reduce la validez ecológica respecto de la repentización sobre partitura. La tensión se reconoce como una limitación del diseño y se retoma en la sección 4.10.7.

=== 4.9.2. Flujo de pantallas

La Figura 11 muestra el flujo de pantallas. Las pantallas sólidas corresponden al prototipo funcional: configuración, dictado, repentización, evaluación y resumen. Las pantallas discontinuas corresponden a la versión completa: acceso, sala de espera, galería final y vista docente.

#block(breakable: false)[
#leyenda([Figura], 11, [Flujo de pantallas del videojuego])
#align(center)[
#set text(size: 8pt)
#diagram(
  node-stroke: 0.7pt, edge-stroke: 0.7pt, node-corner-radius: 3pt, mark-scale: 70%,
  spacing: (0.9cm, 0.8cm),
  caja-c4(-1.6, 0, [Acceso], fill: rgb("#fafafa")),
  caja-c4(-1.6, 1.6, [Sala de espera], fill: rgb("#fafafa")),
  caja-c4(0, 0.8, [Configuración]),
  caja-c4(1.5, 0, [Dictado]),
  caja-c4(1.5, 1.6, [Repentización]),
  caja-c4(3.0, 0.8, [Evaluación]),
  caja-c4(4.5, 0.8, [Resumen]),
  caja-c4(6.0, 0, [Galería final], fill: rgb("#fafafa")),
  caja-c4(6.0, 1.6, [Vista docente], fill: rgb("#fafafa")),
  edge((-1.6,0), (0,0.8), "->", stroke: (dash: "dashed")),
  edge((-1.6,1.6), (0,0.8), "->", stroke: (dash: "dashed")),
  edge((0,0.8), (1.5,0), "->"),
  edge((0,0.8), (1.5,1.6), "->"),
  edge((1.5,0), (3.0,0.8), "->"),
  edge((1.5,1.6), (3.0,0.8), "->"),
  edge((3.0,0.8), (4.5,0.8), "->"),
  edge((4.5,0.8), (6.0,0), "->", stroke: (dash: "dashed")),
  edge((4.5,0.8), (6.0,1.6), "->", stroke: (dash: "dashed")),
)
]
]

=== 4.9.3. Pantalla de configuración

La pantalla de configuración presenta cuatro controles: dificultad, actividad inicial, número de rondas y tempo. La dificultad se muestra con su número de notas y su intervalo máximo, de modo que el jugador comprenda el efecto de la selección. El número de rondas se ajusta entre 2 y 8 y el tempo entre 60 y 120 BPM. Al iniciar, se genera una semilla de sesión y se construyen todas las rondas.

=== 4.9.4. Pantalla de dictado

La pantalla de dictado reproduce la melodía y muestra un piano roll editable. El jugador coloca una nota por ataque; si coloca otra nota en el mismo ataque, la anterior se reemplaza, de modo que la respuesta es monofónica. La duración de cada nota se fija en un pulso y no es editable: la evaluación rítmica se basa en la ubicación de los ataques, no en la duración. Esta decisión simplifica la entrada y evita penalizar la notación de duraciones, que no forma parte del objetivo del ejercicio.

La rejilla de entrada depende de la dificultad: un pulso en dificultad baja, medio pulso en dificultad media y un sexto de pulso en dificultad alta. El jugador puede reproducir la melodía, detener la reproducción y borrar la respuesta antes de enviarla. Al enviar, el sistema compara la respuesta con la referencia y muestra el panel de evaluación.

=== 4.9.5. Pantalla de repentización

La pantalla de repentización muestra la melodía en un piano roll y habilita la grabación. Durante la grabación se muestra un indicador y se informa del límite de 30 s. Al detenerla, el jugador puede escuchar la grabación, repetirla o enviarla. Al enviar, se muestra el progreso de la transcripción y, si el proceso falla, se informa del error y se permite reintentar. La interfaz no bloquea la edición ni la navegación durante la inferencia, porque esta ocurre en un Worker.

=== 4.9.6. Evaluación y resumen

El panel de evaluación muestra tres puntuaciones: alturas, ritmo y global. Debajo, presenta dos piano rolls: la respuesta del jugador y la melodía de referencia. Las notas se colorean en verde cuando encontraron correspondencia, en rojo cuando fueron omitidas y en ámbar cuando son adicionales. El coloreado se basa en la dimensión de alturas; la puntuación rítmica se informa por separado. El resumen final muestra una tabla con las puntuaciones de cada ronda y el promedio de precisión general.

El uso exclusivo del color para señalar aciertos y errores es una limitación de accesibilidad. La versión completa incorpora formas o etiquetas adicionales para que la información no dependa de la percepción del color. Asimismo, el coloreado por altura puede mostrar en verde una nota con ataque incorrecto; la versión completa distingue ambos tipos de coincidencia.

=== 4.9.7. Vistas de la versión completa

// PLACEHOLDER: sección de diseño de la versión completa. Reescribir con
// capturas y pruebas de usabilidad de la galería, el acceso y la vista docente.

La versión completa incorpora el acceso y la sala de espera, la galería final y la vista docente. La galería muestra el recorrido de cada melodía a través de las rondas, permite reproducir las grabaciones y compara la referencia con cada respuesta. La vista docente permite organizar aulas y consultar los resultados de los estudiantes. Estas vistas reutilizan el panel de evaluación y la representación en piano roll, de modo que la experiencia de revisión sea consistente con la de juego.

== 4.10. Integración, pruebas y validación técnica

=== 4.10.1. Estrategia de pruebas

Las pruebas se organizaron en cinco niveles: unitarias, de humo, de barrido de parámetros, de compilación y de navegador. La Tabla 16 resume el alcance de cada nivel. Las pruebas unitarias cubren el dominio musical; las de humo y barrido cubren la transcripción; la compilación verifica la integración de Next.js, Payload y TypeScript; y la prueba de navegador verifica el flujo completo de una partida individual.

#block(breakable: false)[
#leyenda([Tabla], 16, [Estrategia de pruebas])
#apatable(
  columns: (3.6cm, 5.8cm, 6.5cm),
  header: ([*Nivel*], [*Alcance*], [*Herramienta y evidencia*]),
  rows: (
    ([Unitarias], [Generador, evaluador y parámetros de transcripción], [Vitest; 50 pruebas.]),
    ([Humo], [Transcripción de una sinusoide de 2 s], [`smoke:basic-pitch`; detecta La4.]),
    ([Barrido], [25 casos sintéticos con ruido y vibrato], [`tune:transcription`; ajuste de parámetros.]),
    ([Compilación], [Build de producción de Next.js], [`next build`; sin errores.]),
    ([Navegador], [Dictado, grabación, transcripción y resumen], [Prueba manual en Chrome.]),
  ),
)]

=== 4.10.2. Pruebas unitarias

La Tabla 17 resume las 50 pruebas unitarias. El generador concentra 26 pruebas porque cada propiedad estructural se verifica sobre 25 semillas por nivel; el evaluador concentra 20, incluyendo los casos límite de la Tabla 13; y los parámetros de transcripción concentran 4, que verifican el rango de frecuencias y la longitud mínima de nota.

#block(breakable: false)[
#leyenda([Tabla], 17, [Resultados de las pruebas unitarias])
#apatable(
  columns: (4.8cm, 2.8cm, 8.3cm),
  header: ([*Módulo*], [*Pruebas*], [*Cobertura*]),
  rows: (
    ([Generador], [26], [Propiedades estructurales, modulación y reproducibilidad.]),
    ([Evaluador], [20], [Emparejamiento, tolerancias y casos límite.]),
    ([Parámetros de transcripción], [4], [Rango de frecuencias y longitud mínima.]),
    ([Total], [50], [—]),
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

=== 4.10.4. Integración del flujo individual

La compilación de producción se ejecutó sin errores. En el navegador se verificó el flujo completo: configuración, dictado con piano roll, evaluación con colores, repentización con grabación, transcripción en Worker y resumen con promedio. Se verificó que la transcripción puede ejecutarse dos veces en una misma partida sin bloquear la interfaz. El cliente incorpora un watchdog que cancela una solicitud estancada. La sesión se guarda en Payload al finalizar la partida; si el guardado falla, la interfaz informa del error y conserva los resultados en memoria hasta que el jugador inicia una nueva partida.

=== 4.10.5. Validación con voz cantada

// PLACEHOLDER: protocolo de validación pendiente de ejecución. Reescribir con
// las grabaciones, métricas y resultados reales.

El protocolo de validación con voz cantada real comprende un conjunto de grabaciones de melodías conocidas, interpretadas por participantes de distintas tesituras y niveles de experiencia. El conjunto incluye grabaciones con y sin ruido moderado, diferentes micrófonos y distintos navegadores. Para cada grabación se compara la transcripción automática con la referencia y se calculan la precisión de altura y la precisión de ataques. Esta validación técnica no sustituye la evaluación pedagógica del capítulo V.

=== 4.10.6. Pruebas de la versión multijugador

// PLACEHOLDER: pruebas pendientes de la versión completa. Reescribir con
// resultados de sincronización, reconexión y latencia.

El plan de pruebas de la versión completa comprende pruebas de sincronización, reconexión y latencia. Las pruebas verifican que todos los participantes observan la misma transición de ronda, que una respuesta se asigna a un único destinatario, que una desconexión no bloquea la partida y que una respuesta tardía no se incorpora a una ronda cerrada. También se mide la latencia de los eventos de sala y se comprueba que el canal de tiempo real no transporta audio ni melodías completas.

=== 4.10.7. Limitaciones y amenazas a la validez

La validación de la transcripción se realizó con audio sintético; la voz cantada introduce vibrato, portamentos, consonantes y respiración que pueden alterar la detección. La evaluación de usabilidad se limitó a pruebas manuales en un navegador de escritorio; no se realizó un estudio con usuarios. La evaluación pedagógica corresponde al capítulo V y no se deduce de las pruebas técnicas. El prototipo implementa el flujo individual; la mecánica multijugador, la galería y la vista docente forman parte de la especificación de la versión completa. El piano roll simplifica la lectura respecto del pentagrama y puede reducir la validez ecológica de la repentización. El feedback por color y el registro de la dificultad alta son limitaciones reconocidas del diseño actual.

== 4.11. Síntesis del capítulo

El prototipo funcional integra un generador procedural determinista, un evaluador de similitud con emparejamiento bipartito, una transcripción de audio en el navegador, una interfaz de dictado y repentización y persistencia en Payload y PostgreSQL. La versión completa añade salas, intercambio, galería, aulas y vista docente. Las pruebas unitarias y el banco sintético evidencian el funcionamiento de los componentes implementados; la efectividad pedagógica se evalúa en el capítulo V.

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

Las 600 melodías se generaron sin fallos. En los tres niveles, el 100 % de las melodías cumplió la pertenencia a la escala activa y la regla de no repetición triple. La figura rítmica requerida se cumplió en el 100 % de las melodías de dificultad media y alta; en dificultad baja no se exige. El tiempo medio de generación fue de 0.25 ms en baja, 0.59 ms en media y 1.09 ms en alta; el percentil 95 no superó 1.40 ms. La Tabla 20 resume estos resultados.

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
    ([Baja], [200], [0], [100], [100], [—], [0.25], [0.42]),
    ([Media], [200], [0], [100], [100], [100], [0.59], [0.98]),
    ([Alta], [200], [0], [100], [100], [100], [1.09], [1.40]),
    ([Total], [600], [0], [—], [—], [—], [—], [—]),
  ),
)]

La reproducibilidad se verificó con la misma tupla de parámetros: dos ejecuciones producen la misma melodía. La sensibilidad a la semilla se verificó con semillas distintas, que producen secuencias distintas. La combinación de ambas propiedades es la base de la auditabilidad del generador: una melodía puede reconstruirse a partir de su semilla, su dificultad, su tempo y su compás.

=== 5.1.3. Perfil de intervalos y ambitus

La Tabla 21 y la Figura 12 muestran la distribución de intervalos. En los tres niveles predominan los intervalos de 0 a 2 semitonos. En baja, el 100 % de los intervalos es menor o igual a 2 semitonos; en media, el 82.3 %; en alta, el 80.0 %. Los intervalos de 0 semitonos, es decir, las notas repetidas, representan el 40.9 %, 36.6 % y 35.3 %, respectivamente. Los saltos de 3 a 7 semitonos aparecen solo en media (17.7 %) y alta (20.0 %); en baja no hay saltos.

#block(breakable: false)[
#leyenda([Tabla], 21, [Distribución de intervalos por nivel de dificultad])
#apatable(
  columns: (3cm, 4.3cm, 4.3cm, 4.3cm),
  header: ([*Intervalo (semitonos)*], [*Baja (%)*], [*Media (%)*], [*Alta (%)*]),
  rows: (
    ([0], [40.9], [36.6], [35.3]),
    ([1], [27.3], [21.6], [21.7]),
    ([2], [31.8], [24.2], [22.9]),
    ([3], [0.0], [8.3], [8.7]),
    ([4], [0.0], [4.5], [3.4]),
    ([5], [0.0], [4.9], [4.9]),
    ([6], [0.0], [0.0], [0.7]),
    ([7], [0.0], [0.0], [2.3]),
  ),
)]

#block(breakable: false)[
#leyenda([Figura], 12, [Distribución de intervalos por nivel de dificultad])
#align(center)[
#set text(size: 9pt)
#canvas({
  draw.set-style(legend: (fill: white), barchart: (bar-width: .75, cluster-gap: 0))
  chart.barchart(
    (
      ([0], 40.9, 36.6, 35.3),
      ([1], 27.3, 21.6, 21.7),
      ([2], 31.8, 24.2, 22.9),
      ([3], 0, 8.3, 8.7),
      ([4], 0, 4.5, 3.4),
      ([5], 0, 4.9, 4.9),
      ([6], 0, 0, 0.7),
      ([7], 0, 0, 2.3),
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

El ambitus medio fue de 3.49, 8.70 y 13.53 semitonos, muy por debajo del máximo permitido (12, 24 y 36). El uso del ambitus fue del 29.1 %, 36.2 % y 37.6 %. La duración media fue de 9.82, 14.91 y 23.57 pulsos, equivalentes a 6.5, 9.9 y 15.7 s a 90 BPM. La modulación apareció en el 48 % de las melodías de dificultad media y en el 100 % de las de dificultad alta; en baja no se aplica. La Tabla 22 resume estos valores.

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
    ([Baja], [3.49], [12], [29.1], [9.82], [6.5], [0]),
    ([Media], [8.70], [24], [36.2], [14.91], [9.9], [48]),
    ([Alta], [13.53], [36], [37.6], [23.57], [15.7], [100]),
  ),
)]

Las tonalidades y los modos se distribuyeron de forma equilibrada: las siete tonalidades aparecieron entre 20 y 40 veces por nivel, y la proporción entre mayor y menor se mantuvo cerca de 50/50. Esto indica que la selección de tonalidad no está sesgada por el generador.

=== 5.1.4. Variedad melódica y rítmica

La Tabla 23 y la Figura 13 muestran la variedad melódica. El número medio de alturas distintas por melodía fue de 3.1 en baja (de 8 notas), 5.6 en media (de 15) y 8.3 en alta (de 24). El 100 % de las melodías contiene al menos un par de notas repetidas; la longitud máxima de una racha de notas iguales fue 2, como exige la regla. Los cambios de dirección del contorno fueron 1.8, 4.4 y 7.4 en promedio. La variedad rítmica, medida como número de duraciones distintas por melodía, fue de 1.9, 2.9 y 4.9. Las secuencias únicas fueron 92.5 %, 100 % y 100 %.

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
    ([Baja], [3.1 / 8], [40.9], [0.0], [1.8], [1.9], [92.5]),
    ([Media], [5.6 / 15], [36.6], [17.7], [4.4], [2.9], [100]),
    ([Alta], [8.3 / 24], [35.3], [20.0], [7.4], [4.9], [100]),
  ),
)]

La Figura 13 presenta una melodía de muestra por nivel. En baja se observan pares de notas repetidas y un contorno descendente con pocas alturas distintas; en media y alta aparecen más grados conjuntos, saltos y cambios de dirección, junto con la modulación marcada por la línea vertical.

#block(breakable: false)[
#leyenda([Figura], 13, [Melodías generadas por nivel de dificultad])
#align(center)[
#set text(size: 9pt)
#text(weight: "bold")[Baja — Mi bemol menor — 8 notas (MIDI 54–59)]
#v(0.15em)
#block(width: 15cm, height: 2.6cm, stroke: 0.5pt + rgb("#d4d4d8"), fill: rgb("#fafafa"), clip: true)[
  #place(dx: 0.00%, dy: 0.00%, rect(width: 10.00%, height: 16.67%, fill: rgb("#6366f1"), radius: 0.4pt))
  #place(dx: 10.00%, dy: 0.00%, rect(width: 10.00%, height: 16.67%, fill: rgb("#6366f1"), radius: 0.4pt))
  #place(dx: 20.00%, dy: 16.67%, rect(width: 20.00%, height: 16.67%, fill: rgb("#6366f1"), radius: 0.4pt))
  #place(dx: 40.00%, dy: 16.67%, rect(width: 10.00%, height: 16.67%, fill: rgb("#6366f1"), radius: 0.4pt))
  #place(dx: 50.00%, dy: 50.00%, rect(width: 10.00%, height: 16.67%, fill: rgb("#6366f1"), radius: 0.4pt))
  #place(dx: 60.00%, dy: 50.00%, rect(width: 10.00%, height: 16.67%, fill: rgb("#6366f1"), radius: 0.4pt))
  #place(dx: 70.00%, dy: 83.33%, rect(width: 20.00%, height: 16.67%, fill: rgb("#6366f1"), radius: 0.4pt))
  #place(dx: 90.00%, dy: 83.33%, rect(width: 10.00%, height: 16.67%, fill: rgb("#6366f1"), radius: 0.4pt))
]
#v(0.7em)
#text(weight: "bold")[Media — Si bemol mayor — 15 notas (MIDI 48–63)]
#v(0.15em)
#block(width: 15cm, height: 2.6cm, stroke: 0.5pt + rgb("#d4d4d8"), fill: rgb("#fafafa"), clip: true)[
  #place(dx: 48.39%, dy: 0%, rect(width: 0.6pt, height: 100%, fill: rgb("#a1a1aa")))
  #place(dx: 0.00%, dy: 18.75%, rect(width: 6.45%, height: 6.25%, fill: rgb("#22c55e"), radius: 0.4pt))
  #place(dx: 6.45%, dy: 6.25%, rect(width: 6.45%, height: 6.25%, fill: rgb("#22c55e"), radius: 0.4pt))
  #place(dx: 12.90%, dy: 6.25%, rect(width: 6.45%, height: 6.25%, fill: rgb("#22c55e"), radius: 0.4pt))
  #place(dx: 19.35%, dy: 0.00%, rect(width: 3.23%, height: 6.25%, fill: rgb("#22c55e"), radius: 0.4pt))
  #place(dx: 22.58%, dy: 0.00%, rect(width: 6.45%, height: 6.25%, fill: rgb("#22c55e"), radius: 0.4pt))
  #place(dx: 29.03%, dy: 6.25%, rect(width: 12.90%, height: 6.25%, fill: rgb("#22c55e"), radius: 0.4pt))
  #place(dx: 41.94%, dy: 31.25%, rect(width: 6.45%, height: 6.25%, fill: rgb("#22c55e"), radius: 0.4pt))
  #place(dx: 48.39%, dy: 37.50%, rect(width: 6.45%, height: 6.25%, fill: rgb("#22c55e"), radius: 0.4pt))
  #place(dx: 54.84%, dy: 62.50%, rect(width: 6.45%, height: 6.25%, fill: rgb("#22c55e"), radius: 0.4pt))
  #place(dx: 61.29%, dy: 62.50%, rect(width: 6.45%, height: 6.25%, fill: rgb("#22c55e"), radius: 0.4pt))
  #place(dx: 67.74%, dy: 75.00%, rect(width: 3.23%, height: 6.25%, fill: rgb("#22c55e"), radius: 0.4pt))
  #place(dx: 70.97%, dy: 93.75%, rect(width: 6.45%, height: 6.25%, fill: rgb("#22c55e"), radius: 0.4pt))
  #place(dx: 77.42%, dy: 93.75%, rect(width: 3.23%, height: 6.25%, fill: rgb("#22c55e"), radius: 0.4pt))
  #place(dx: 80.65%, dy: 81.25%, rect(width: 6.45%, height: 6.25%, fill: rgb("#22c55e"), radius: 0.4pt))
  #place(dx: 87.10%, dy: 81.25%, rect(width: 12.90%, height: 6.25%, fill: rgb("#22c55e"), radius: 0.4pt))
]
#v(0.7em)
#text(weight: "bold")[Alta — Si bemol menor — 24 notas (MIDI 49–61)]
#v(0.15em)
#block(width: 15cm, height: 2.6cm, stroke: 0.5pt + rgb("#d4d4d8"), fill: rgb("#fafafa"), clip: true)[
  #place(dx: 52.05%, dy: 0%, rect(width: 0.6pt, height: 100%, fill: rgb("#a1a1aa")))
  #place(dx: 0.00%, dy: 0.00%, rect(width: 2.05%, height: 7.69%, fill: rgb("#f59e0b"), radius: 0.4pt))
  #place(dx: 2.05%, dy: 0.00%, rect(width: 6.16%, height: 7.69%, fill: rgb("#f59e0b"), radius: 0.4pt))
  #place(dx: 8.22%, dy: 23.08%, rect(width: 2.74%, height: 7.69%, fill: rgb("#f59e0b"), radius: 0.4pt))
  #place(dx: 10.96%, dy: 0.00%, rect(width: 8.22%, height: 7.69%, fill: rgb("#f59e0b"), radius: 0.4pt))
  #place(dx: 19.18%, dy: 38.46%, rect(width: 2.74%, height: 7.69%, fill: rgb("#f59e0b"), radius: 0.4pt))
  #place(dx: 21.92%, dy: 38.46%, rect(width: 4.11%, height: 7.69%, fill: rgb("#f59e0b"), radius: 0.4pt))
  #place(dx: 26.03%, dy: 0.00%, rect(width: 4.11%, height: 7.69%, fill: rgb("#f59e0b"), radius: 0.4pt))
  #place(dx: 30.14%, dy: 7.69%, rect(width: 6.16%, height: 7.69%, fill: rgb("#f59e0b"), radius: 0.4pt))
  #place(dx: 36.30%, dy: 0.00%, rect(width: 4.11%, height: 7.69%, fill: rgb("#f59e0b"), radius: 0.4pt))
  #place(dx: 40.41%, dy: 7.69%, rect(width: 2.74%, height: 7.69%, fill: rgb("#f59e0b"), radius: 0.4pt))
  #place(dx: 43.15%, dy: 0.00%, rect(width: 2.74%, height: 7.69%, fill: rgb("#f59e0b"), radius: 0.4pt))
  #place(dx: 45.89%, dy: 23.08%, rect(width: 6.16%, height: 7.69%, fill: rgb("#f59e0b"), radius: 0.4pt))
  #place(dx: 52.05%, dy: 38.46%, rect(width: 2.74%, height: 7.69%, fill: rgb("#f59e0b"), radius: 0.4pt))
  #place(dx: 54.79%, dy: 38.46%, rect(width: 2.74%, height: 7.69%, fill: rgb("#f59e0b"), radius: 0.4pt))
  #place(dx: 57.53%, dy: 23.08%, rect(width: 2.05%, height: 7.69%, fill: rgb("#f59e0b"), radius: 0.4pt))
  #place(dx: 59.59%, dy: 23.08%, rect(width: 6.16%, height: 7.69%, fill: rgb("#f59e0b"), radius: 0.4pt))
  #place(dx: 65.75%, dy: 61.54%, rect(width: 4.11%, height: 7.69%, fill: rgb("#f59e0b"), radius: 0.4pt))
  #place(dx: 69.86%, dy: 92.31%, rect(width: 4.11%, height: 7.69%, fill: rgb("#f59e0b"), radius: 0.4pt))
  #place(dx: 73.97%, dy: 61.54%, rect(width: 2.74%, height: 7.69%, fill: rgb("#f59e0b"), radius: 0.4pt))
  #place(dx: 76.71%, dy: 53.85%, rect(width: 8.22%, height: 7.69%, fill: rgb("#f59e0b"), radius: 0.4pt))
  #place(dx: 84.93%, dy: 38.46%, rect(width: 6.16%, height: 7.69%, fill: rgb("#f59e0b"), radius: 0.4pt))
  #place(dx: 91.10%, dy: 38.46%, rect(width: 4.11%, height: 7.69%, fill: rgb("#f59e0b"), radius: 0.4pt))
  #place(dx: 95.21%, dy: 53.85%, rect(width: 2.05%, height: 7.69%, fill: rgb("#f59e0b"), radius: 0.4pt))
  #place(dx: 97.26%, dy: 61.54%, rect(width: 2.74%, height: 7.69%, fill: rgb("#f59e0b"), radius: 0.4pt))
]
#v(0.4em)
#text(size: 8pt)[La línea vertical gris marca la modulación. Cada barra representa una nota; el ancho indica su duración.]
]
]

=== 5.1.5. Síntesis de resultados

En síntesis, el generador cumple las restricciones estructurales en el 100 % de los casos, es reproducible y computacionalmente barato. La contrapartida es una variedad melódica limitada: predominan los intervalos de 0 a 2 semitonos, el ambitus utilizado es menor que el permitido y todas las melodías contienen notas repetidas. Esta brecha entre cumplimiento y variedad es el eje de la discusión.

== 5.2. Discusión

=== 5.2.1. Sobre el cumplimiento de las restricciones

El cumplimiento del 100 % es consecuencia directa del diseño de generar y verificar. La función de validación rechaza cualquier melodía que viole las restricciones y el generador reintenta con otra secuencia pseudoaleatoria. La ausencia de fallos en 600 melodías indica que el espacio de soluciones es factible para los tres niveles y que el presupuesto de 50 intentos es suficiente. El tiempo medio de 0.25 a 1.09 ms confirma que el costo de reintentar es despreciable para melodías de 8 a 24 notas.

La reproducibilidad refuerza la utilidad del generador en un contexto educativo y de investigación. Una melodía puede reconstruirse a partir de su semilla, su dificultad, su tempo y su compás, lo que permite auditar una partida, repetir un experimento o generar el mismo ejercicio para distintos jugadores. La sensibilidad a la semilla evita que todas las partidas compartan el mismo material.

=== 5.2.2. Sobre el perfil melódico y la repetitividad

El hallazgo principal es la brecha entre el cumplimiento de las restricciones y la variedad musical. Aunque todas las melodías son válidas, el 35–41 % de los intervalos son de 0 semitonos y el 100 % de las melodías contiene al menos un par de notas repetidas. En dificultad baja, el número medio de alturas distintas es de 3.1 sobre 8 notas y no hay saltos; el contorno cambia de dirección apenas 1.8 veces por melodía. El resultado son secuencias estáticas, con pares de notas repetidas y un ambitus real de solo 3.49 semitonos frente a los 12 permitidos.

La causa es la ponderación de la selección de alturas. El peso $1 / (1 + d^2)$ favorece la nota anterior ($d = 0$, peso 1) sobre el grado conjunto ($d = 1$, peso 0.5) y sobre el salto de dos semitonos ($d = 2$, peso 0.2). La regla de no repetición solo impide tres notas iguales consecutivas, de modo que los pares de notas repetidas son frecuentes. La ponderación produce un perfil muy cercano al grado conjunto, pero también una fuerte gravedad hacia la altura anterior.

La dificultad media y alta mejoran en variedad: más alturas distintas, más saltos, más cambios de dirección y el 100 % de secuencias únicas. Sin embargo, la proporción de intervalos repetidos se mantiene cerca del 35 %. El ambitus real sigue siendo bajo: 8.70 de 24 semitonos en media y 13.53 de 36 en alta. El parámetro de ambitus funciona como un máximo, no como un objetivo; el generador no busca ocupar el registro permitido.

Esta diferencia es relevante para el uso pedagógico. Una melodía estática puede ser adecuada para una primera aproximación al dictado, pero no ejercita la identificación de saltos ni la memoria de contornos amplios. Si la dificultad se define por el intervalo máximo y el ambitus permitido, el generador debería controlar también la distribución de intervalos y la ocupación del registro, no solo el límite superior. La comparación con Troubadour es ilustrativa: allí la dificultad aumenta la presencia de intervalos específicos y de movimientos en direcciones alternadas (Pesek et al., 2020a); en el generador propuesto, el límite aumenta, pero la ponderación sigue favoreciendo la repetición.

=== 5.2.3. Sobre la reproducibilidad y el uso pedagógico

La reproducibilidad y el bajo costo computacional hacen que el generador sea adecuado para la generación de ejercicios en tiempo real y para la investigación replicable. La semilla permite reconstruir una melodía y verificar que la evaluación corresponde al material generado. La distribución equilibrada de tonalidades y modos evita un sesgo sistemático hacia una tonalidad o un modo, y la tasa de modulación coincide con la configuración: 48 % en media frente al 50 % previsto y 100 % en alta.

No obstante, la reproducibilidad no garantiza la equidad entre jugadores. Dos semillas distintas pueden producir melodías con distinto ambitus real, distinta proporción de saltos y distinta variedad rítmica. En los datos, el ambitus real de la dificultad alta varía entre 3 y 26 semitonos, y el de la baja entre 1 y 6. Si dos jugadores reciben semillas distintas, la dificultad nominal es la misma, pero la dificultad efectiva puede diferir. Esta observación sugiere que la asignación de melodías debería estratificarse por el perfil real de la melodía, o que el generador debería aceptar solo melodías dentro de una banda de variedad.

=== 5.2.4. Limitaciones y mejoras

La evaluación es estructural y computacional. No se realizó una valoración perceptual con docentes ni una comparación con ejercicios compuestos por humanos; por tanto, los resultados no establecen que las melodías sean musicalmente idiomáticas o pedagógicamente adecuadas. La muestra de 200 semillas por nivel describe el comportamiento del generador, pero no agota el espacio de semillas posibles.

El generador tampoco modela silencios, ligaduras ni una gramática rítmica explícita. La variedad rítmica se limita a las duraciones permitidas y a los ataques que resultan de su suma; la dificultad alta incluye valores de 1.5 y 2/3, pero las síncopas no se generan como una estructura intencional.

A partir de los resultados se identifican cinco mejoras concretas:

#listasin[
  + *Penalizar la repetición.* Reducir el peso de `d = 0` o añadir una penalización explícita a la nota anterior, de modo que el grado conjunto y los saltos tengan mayor presencia.
  + *Controlar el perfil, no solo el máximo.* Definir una distribución objetivo de intervalos y un ambitus objetivo por nivel, y aceptar una melodía solo si su perfil cae dentro de una banda.
  + *Añadir restricciones de frase.* Incorporar un clímax, una cadencia o un contorno equilibrado para evitar melodías exclusivamente descendentes o estáticas.
  + *Medir la diversidad en la validación.* Incluir el número de alturas distintas, la proporción de intervalos repetidos y los cambios de dirección como criterios de aceptación.
  + *Validar con docentes y comparar con ejercicios humanos.* Complementar la verificación estructural con una valoración musical y pedagógica, y contrastar las melodías generadas con ejercicios compuestos por especialistas.
]

=== 5.2.5. Respuesta al primer objetivo específico

El primer objetivo específico se cumple en el plano del diseño y de la implementación verificada. El algoritmo existe, genera ejercicios para dictado y repentización, satisface las restricciones estructurales en el 100 % de los casos evaluados, es reproducible y su costo computacional es despreciable. La evidencia también muestra una limitación: la variedad melódica es baja, especialmente en dificultad baja, y el ambitus real está por debajo del permitido. Esta limitación no invalida el cumplimiento del objetivo, pero establece una línea de refinamiento del generador y una advertencia para su uso pedagógico: la dificultad nominal no equivale todavía a una dificultad musical efectiva.

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

  De Carvalho, C. V., & Coelho, A. (2022). Game-Based Learning, Gamification in Education and Serious Games. Computers, 11(3), 36. https://doi.org/10.3390/computers11030036

  Demian, A.-M. y Nedelcut, N. (2018). The Mental Processes Involved in the Musical Dictation. Music Cognition, 4, 86-97.

  Djaouti, D., Alvarez, J., & Jessel, J. (2011). Classifying serious games. En Advances in game-based learning book series (pp. 118-136). https://doi.org/10.4018/978-1-60960-495-0.ch006

  Donn, R., Stillie, B., & Moir, Z. (2024). The shifting sands of UK secondary music curricula: problematising relationships between aural training and music literacy. Music Education Research, 26(1), 58-70. https://doi.org/10.1080/14613808.2024.2309204

  Fernandez, A. D. (2025). Desarrollo de una aplicación web para el entrenamiento auditivo y enseñanza musical para miembros del Club de Música de la PUCE Ibarra \[Trabajo de titulación\]. Pontificia Universidad Católica del Ecuador.

  Giraldo, S., Waddell, G., Nou, I., Ortega, A., Mayor, O., Perez, A., Williamon, A., & Ramirez, R. (2019). Automatic Assessment of Tone Quality in Violin Music Performance. Frontiers In Psychology, 10, 334. https://doi.org/10.3389/fpsyg.2019.00334

  Huovinen, E., Ylitalo, A.-K., y Puurtinen, M. (2018). Early Attraction in Temporally Controlled Sight Reading of Music. Journal of Eye Movement Research, 11(2), 1-30. https://doi.org/10.16910/jemr.11.2.3

  Kleppinger, N. S. V. (2017). Practical and Philosophical Reflections Regarding Aural Skills Assessment. Indiana Theory Review, 33(1-2), 153. https://doi.org/10.2979/inditheorevi.33.1-2.06

  Lingjie, A. (2025). Effectiveness Study of Applying Earmaster for Ear Training in Chinese University Students. International Journal Of Sociologies And Anthropologies Science Reviews, 5(2), 29-38. https://doi.org/10.60027/ijsasr.2025.5514

  Lu, L. (2025). AI-powered intelligent music education systems for real-time feedback and performance assessment. International Journal Of Information And Communication Technology, 1(1). https://doi.org/10.1504/ijict.2025.10071414

  McNeil, B. (2021). Aural Skills Pedagogy in the Wind Band: A Survey of Secondary and Collegiate Wind Band Conductors’ Perceptions and Strategies \[Disertación de PhD, Auburn University\]. https://etd.auburn.edu/handle/10415/7610

  Mingyu, G., Yunus, M. M., & Rafiq, K. R. M. (2024). Educational Games and Game-based Approaches in Higher Education: A Systematic Review (2014-2023). International Journal Of Academic Research In Progressive Education And Development, 13(1). https://doi.org/10.6007/ijarped/v13-i1/20555

  Nichols, B. E., & Springer, D. G. (2025). Piano history, aural skills, and working memory predict melodic dictation performance. Frontiers In Psychology, 16, 1579714. https://doi.org/10.3389/fpsyg.2025.1579714

  Ou, J., Nogueira, J., & Qin, C. (2025). Exploring the impact of AI-assisted practice applications on music learners’ performance, self-efficacy, and self-regulated learning. Frontiers In Psychology, 16, 1675762. https://doi.org/10.3389/fpsyg.2025.1675762

  Peffers, K., Tuunanen, T., Rothenberger, M. A., & Chatterjee, S. (2008). A design science research methodology for information systems research. Journal of Management Information Systems, 24(3), 45-77. https://doi.org/10.2753/MIS0742-1222240302

  Pesek, M., Vucko, Z., Savli, P., Kavcic, A., & Marolt, M. (2020a). Troubadour: A Gamified e-Learning Platform for Ear Training. IEEE Access, 8, 97090-97102. https://doi.org/10.1109/access.2020.2994389

  Pesek, M., Suhadolnik, L., Šavli, P., & Marolt, M. (2020b). Motivating Students for Ear-Training with a Rhythmic Dictation Application. Applied Sciences, 10(19), 6781. https://doi.org/10.3390/app10196781

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
