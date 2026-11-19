# Guion breve — Capítulo IV: Desarrollo de la propuesta

## Ficha de la presentación

- **Duración objetivo:** 12–15 minutos.
- **Mensaje central:** el capítulo documenta un artefacto construido, con un núcleo musical verificable: generador procedural, evaluador de similitud, transcripción en el navegador y flujo de partida.
- **Idea de cierre:** no se presenta solo un diseño; cada componente tiene implementación, pruebas y evidencia de funcionamiento.
- **Regla de exposición:** una idea por figura. No leer las tablas completas: señalar la fila o columna que sostiene la idea.

## Estructura y tiempos

| Bloque | Tiempo | Apoyo |
| --- | --- | --- |
| Apertura y alcance | 1.5 min | Figura 3 |
| Arquitectura y separación de capas | 1.5 min | Figura 4 |
| Modelo de dominio musical | 1.5 min | Figura 5 |
| Generador procedural | 2 min | Figura 6; Tablas 9 y 11 |
| Evaluador de similitud | 2 min | Figura 7; Tablas 12 y 13 |
| Transcripción automática | 2 min | Figura 8; Tablas 14 y 18 |
| Flujo de partida | 1.5 min | Figura 9 |
| Interfaz y cierre | 1.5 min | Figura 11 |
| Síntesis | 1 min | Tablas 16 y 17 |

## Guion

### 1. Apertura y alcance (1.5 min)

**Decir:**

> “El capítulo IV documenta el diseño y la construcción del artefacto. Lo organizo en tres bloques: primero el alcance y la arquitectura; después el núcleo musical, que es la parte más técnica; y al final el flujo de partida, la interfaz y la verificación.”

> “La Figura 3 ordena el alcance. A la izquierda están los actores; al centro, las actividades de juego; a la derecha, los tres servicios internos que sostienen todo: generar la melodía, evaluar la similitud y transcribir el audio.”

**Señalar en la Figura 3:**

- Los actores: estudiante, docente, administrador.
- La tríada técnica: *Generar melodía*, *Evaluar similitud*, *Transcribir audio*.
- Las líneas discontinuas: relaciones de inclusión entre casos de uso.

**Cerrar el bloque:**

> “La lectura de la figura es directa: las actividades de juego se apoyan en un núcleo pequeño y reutilizable. Ese núcleo es el que se describe en las secciones siguientes.”

### 2. Arquitectura y separación de capas (1.5 min)

**Decir:**

> “La Figura 4 muestra la arquitectura en tres capas. La interfaz web está construida con Next.js e incluye el piano roll, la reproducción, la grabación y el Worker de transcripción. El dominio musical está implementado en TypeScript con Tonal. La persistencia se apoya en la API de Payload y en PostgreSQL.”

**Señalar:**

- La dirección de las dependencias: la interfaz depende del dominio y de la API; el dominio no depende de la interfaz ni de la base de datos.
- El Worker como frontera entre la interfaz y la transcripción.

**Cerrar el bloque:**

> “Esta separación tiene una consecuencia práctica: el generador y el evaluador se prueban sin navegador y sin base de datos. La lógica musical no queda atrapada en la interfaz.”

### 3. Modelo de dominio musical (1.5 min)

**Decir:**

> “La Figura 5 muestra el modelo que conecta todos los componentes. Una melodía contiene eventos de nota y modulaciones. Cada evento guarda altura MIDI, inicio y duración en pulsos. Para evaluar, esos eventos se convierten a una representación con tiempos en segundos y se comparan contra la referencia.”

**Señalar:**

- `Melody` → `NoteEvent`; `Melody` → `Modulation`.
- `NoteEvent` → `EvaluatedNote` → `EvaluationResult`.

**Cerrar el bloque:**

> “Hay una decisión importante: los tiempos se guardan en pulsos, no en segundos. Eso evita errores de redondeo y permite representar corcheas, tresillos y valores con puntillo con exactitud. La conversión a segundos se hace solo cuando se reproduce o se compara con audio.”

### 4. Generador procedural (2 min)

**Decir:**

> “La Figura 6 es el corazón del capítulo. El generador parte de una semilla y de la dificultad, construye un generador pseudoaleatorio determinista, elige tonalidad y escala, planifica las modulaciones, divide la melodía en segmentos, genera las alturas y el ritmo, construye las notas y valida el resultado.”

**Señalar:**

- El flujo vertical: semilla → hash → tonalidad → modulación → segmentos → alturas → ritmo → notas → validación.
- La salida “Melodía” solo después de la validación.
- La Tabla 9, solo la columna de dificultad que se quiera destacar: longitud, intervalo máximo, ambitus y duraciones.
- La Tabla 11, la fila de reproducibilidad: misma semilla y mismos parámetros producen la misma melodía.

**Explicar el algoritmo en tres frases:**

> “No es aleatorio: es procedural. Cada nota se elige de un conjunto restringido por la escala, el registro y el intervalo máximo. Además, el algoritmo evita tres notas iguales consecutivas y tres intervalos iguales consecutivos. Si la validación falla, reintenta con otra secuencia, hasta un máximo de 50 intentos.”

**Cerrar el bloque:**

> “El resultado es un generador reproducible y auditable: con la semilla y los parámetros se puede reconstruir exactamente la melodía. Las pruebas verifican 25 semillas por cada nivel de dificultad.”

### 5. Evaluador de similitud (2 min)

**Decir:**

> “La Figura 7 explica cómo se evalúa una respuesta. No se comparan listas posición a posición. Se construye una matriz de compatibilidad entre las notas de referencia y las notas estimadas, y se calcula un emparejamiento uno a uno. Ese emparejamiento se hace dos veces: una para alturas y otra para ataques.”

**Señalar:**

- Las dos entradas: notas de referencia y notas estimadas.
- La matriz de compatibilidad.
- Las dos ramas: matching de alturas y matching de ritmo.
- La convergencia en la puntuación global.

**Explicar las métricas:**

> “Cada dimensión produce precisión, exhaustividad y F1. La puntuación de la dimensión es el F1. La global es el promedio de las dos. Así se penalizan tanto las notas omitidas como las notas de más.”

**Apoyarse en las tablas:**

- Tabla 12: tolerancias. Dictado: 50 ms; repentización: 150 ms; equivalencia de octava solo en dificultad baja.
- Tabla 13: casos límite. Señalar un caso: nota omitida, nota adicional, altura incorrecta, ataque fuera de tolerancia.

**Cerrar el bloque:**

> “El evaluador está cubierto con 20 pruebas. La separación de dimensiones permite decirle al jugador si el error está en la altura o en el ataque, no solo cuánto se acercó.”

### 6. Transcripción automática (2 min)

**Decir:**

> “La Figura 8 muestra el pipeline de repentización. El jugador graba con el micrófono; el audio se decodifica, se remuestrea a 22 050 Hz mono y se recorta el silencio inicial. Después entra a un Web Worker, donde Basic Pitch infiere las notas. La salida se normaliza y se convierte en la misma estructura que usa el evaluador.”

**Señalar:**

- El recorrido de izquierda a derecha y el descenso al Worker.
- La normalización antes de llegar al evaluador.
- La Tabla 14, solo los parámetros clave: rango 75–1500 Hz, longitud mínima de nota y fusión de segmentos.
- La Tabla 18: el efecto del rango de frecuencia en el banco sintético.

**Explicar la decisión técnica:**

> “La inferencia ocurre en el navegador. El audio no se envía a un servicio externo y no se necesita GPU del servidor. El modelo se sirve localmente.”

**Cerrar el bloque:**

> “La integración se verificó con una señal sinusoidal y con 25 casos sintéticos. El hallazgo principal fue que el ruido tonal grave genera notas espurias; acotar el rango a 75–1500 Hz elevó la precisión de 0.30 a 0.98 en ese banco.”

### 7. Flujo de partida (1.5 min)

**Decir:**

> “La Figura 9 baja del componente al juego. La partida se configura con dificultad, actividad inicial, número de rondas y tempo. Cada ronda recibe una melodía nueva; las rondas alternan dictado y repentización. Al terminar cada ronda, el sistema evalúa y muestra las puntuaciones. Al final, el resumen presenta el promedio de precisión general.”

**Señalar:**

- Configuración → Ronda n → Dictado/Repentización → Evaluación.
- La decisión “¿Quedan rondas?” y la salida a Resumen.

**Cerrar el bloque:**

> “Cada ronda es una unidad completa: melodía, respuesta, evaluación y feedback. La partida no es una suma de pantallas; es un ciclo cerrado.”

### 8. Interfaz y cierre (1.5 min)

**Decir:**

> “La Figura 11 muestra el flujo de pantallas. El trazo continuo es el recorrido implementado: configuración, dictado, repentización, evaluación y resumen. El jugador siempre sabe en qué ronda está, qué debe hacer y qué puntuación obtuvo.”

**Señalar:**

- Las dos ramas de ejercicio: dictado y repentización.
- La convergencia en evaluación y resumen.
- El piano roll como representación común.

**Cerrar el bloque:**

> “La interfaz usa el piano roll tanto para escribir como para leer. Eso reduce la dependencia de la lectoescritura y concentra la tarea en altura y ataque, que son las dos dimensiones que evalúa el sistema.”

### 9. Síntesis (1 min)

**Decir:**

> “El capítulo no se queda en el diseño. El generador está implementado y verificado sobre 25 semillas por nivel. El evaluador tiene 20 pruebas y cubre los casos límite. La transcripción está integrada en el navegador y medida con un banco sintético. El flujo individual se verificó en el navegador. En total, 50 pruebas unitarias y una compilación de producción sin errores.”

**Señalar la Tabla 17:**

- Generador: 26 pruebas.
- Evaluador: 20 pruebas.
- Parámetros de transcripción: 4 pruebas.
- Total: 50.

**Frase final:**

> “La contribución del capítulo es un núcleo musical reproducible, evaluable y ejecutable en el navegador. Esa es la base sobre la que se sostiene la experiencia de juego.”

## Frases de transición

- De la arquitectura al dominio: “La arquitectura explica dónde vive cada cosa; el modelo de dominio explica qué se comparte entre todos los componentes.”
- Del dominio al generador: “Con el modelo definido, el primer componente que lo usa es el generador.”
- Del generador al evaluador: “Si el generador produce la referencia, el evaluador produce la comparación.”
- Del evaluador a la transcripción: “Para la repentización hay un paso adicional: convertir la voz en notas. Eso es lo que muestra la Figura 8.”
- De la transcripción al flujo: “Con el núcleo completo, la Figura 9 muestra cómo se encadenan las rondas.”

## Si preguntan

**¿Por qué no un modelo generativo?**
> “Porque los ejercicios requieren restricciones pedagógicas explícitas y reproducibilidad. Un algoritmo por reglas permite controlar intervalo, registro, tonalidad y ritmo, y auditar cada melodía con su semilla.”

**¿Cómo se evita que el evaluador sea arbitrario?**
> “Las tolerancias están fijadas y documentadas: 0.5 semitonos, 50 ms en dictado y 150 ms en canto. El emparejamiento es uno a uno y las dos dimensiones se calculan por separado. Los casos límite están cubiertos por pruebas.”

**¿Por qué Basic Pitch?**
> “Porque tiene una implementación oficial en TypeScript, se ejecuta en el navegador con TensorFlow.js y permite procesar el audio localmente, sin enviarlo a un servicio externo.”

**¿Cómo se sabe que las melodías son musicalmente adecuadas?**
> “La verificación estructural comprueba las restricciones de intervalo, ambitus, escala y ritmo. Esa verificación se complementa con la revisión musical de docentes en la etapa de evaluación.”

## Consejos de exposición

- Empezar cada figura con “Esta figura muestra…” y terminar con “Lo importante es…”.
- No leer ejes, etiquetas ni tablas completas: señalar solo el elemento que sostiene la idea.
- Mantener una idea por figura; si surge una pregunta técnica, responder en una frase y volver al hilo.
- Usar las tablas como respaldo, no como guion.
- Reservar el último minuto para la síntesis y la frase final.
