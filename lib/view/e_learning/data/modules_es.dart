import 'package:posture_detector_app/models/quiz/quiz_module.dart';

QuizModule m1Es() => QuizModule(
  id: 1,
  title: "Ergonomia Fundamental y Riesgos",
  objectives: [
    "Comprender que es la ergonomia y por que es importante para el trabajo de escritorio.",
    "Reconocer los principales factores de riesgo musculoesqueletico en entornos de oficina.",
    "Comprender como las normas de estaciones de trabajo orientan una buena configuracion.",
  ],
  content:
      "La ergonomia es la ciencia de disenar el trabajo para adaptarse al "
      "trabajador, en lugar de obligar al trabajador a adaptarse a "
      "configuraciones deficientes. En un entorno de oficina, un diseno "
      "deficiente de la estacion de trabajo puede contribuir a molestias "
      "y lesiones a largo plazo conocidas como Trastornos Musculoesqueleticos (TME).\n\n"
      "Los principales factores de riesgo en el trabajo de escritorio son las "
      "posturas forzadas, la carga estatica y los movimientos repetitivos. "
      "Las normas internacionales como la ISO 9241-5 proporcionan orientacion "
      "sobre la disposicion de la estacion de trabajo y la postura. "
      "Herramientas como los cuestionarios de sintomas y las listas de "
      "verificacion postural ayudan a las organizaciones a identificar "
      "problemas y realizar un seguimiento de las mejoras.",
  quizzes: [
    QuizItemModel(
      question: "Cual es el objetivo principal de la ergonomia?",
      options: [
        "Hacer que las personas trabajen mas rapido a cualquier precio",
        "Adaptar el trabajo y las herramientas a los limites y la comodidad humana",
        "Reemplazar a los trabajadores con automatizacion",
        "Centrarse unicamente en la productividad",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Cual es un factor de riesgo tipico en el trabajo de escritorio?",
      options: [
        "Correos electronicos cortos",
        "Periodos prolongados con el cuello inclinado mirando hacia abajo a una pantalla",
        "Beber agua",
        "Usar una silla con soporte lumbar",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "De que tratan principalmente las normas de estaciones de trabajo (como la ISO 9241-5)?",
      options: [
        "Seguridad contra incendios",
        "Disposicion de la estacion de trabajo y postura para trabajo con pantallas",
        "Sistemas de nomina",
        "Solo calidad del aire",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Por que las organizaciones utilizan cuestionarios de sintomas?",
      options: [
        "Por decoracion",
        "Para identificar problemas y realizar un seguimiento de los cambios a lo largo del tiempo",
        "Para supervisar el uso de internet",
        "Para reemplazar la atencion medica",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Cual afirmacion sobre los TME en trabajadores de oficina es mas precisa?",
      options: [
        "Rara vez afectan al cuello o los hombros",
        "Solo el levantamiento de cargas pesadas puede causarlos",
        "Una configuracion deficiente de la estacion de trabajo y estar sentado estaticamente durante mucho tiempo pueden contribuir a problemas de cuello y miembros superiores",
        "No pueden verse influenciados por cambios en la estacion de trabajo",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "Cual afirmacion describe mejor un Trastorno Musculoesqueletico (TME) en el trabajo de oficina?",
      options: [
        "Una condicion que solo afecta los pies",
        "Una condicion que solo ocurre en la industria pesada",
        "Una molestia o lesion que afecta musculos, tendones o articulaciones, a menudo relacionada con la postura de trabajo",
        "Una condicion causada unicamente por el deporte",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "Cual combinacion de factores de riesgo es mas tipica del trabajo de escritorio?",
      options: [
        "Ruido fuerte y exposicion a productos quimicos",
        "Posturas forzadas, carga estatica y movimientos repetitivos",
        "Altas temperaturas e iluminacion deficiente",
        "Solo correos cortos y tecleo ligero",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Por que es importante \"disenar el trabajo para adaptarse al trabajador\"?",
      options: [
        "Garantiza que nadie sentira dolor jamas",
        "Permite a las personas trabajar mas tiempo sin descansos",
        "Reduce la tension y ayuda a prevenir los TME con el tiempo",
        "Se centra unicamente en aumentar la velocidad de tecleo",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "Cual es una funcion de las normas de estaciones de trabajo como la ISO 9241-5 en las organizaciones?",
      options: [
        "Definen cuantos correos electronicos deben enviar los empleados",
        "Establecen el salario exacto de los trabajadores de oficina",
        "Proporcionan orientacion sobre la disposicion de la estacion de trabajo y los requisitos posturales",
        "Solo se aplican a maquinaria de fabrica",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "Como pueden los cuestionarios de sintomas y las listas de verificacion postural apoyar los programas de ergonomia?",
      options: [
        "Haciendo seguimiento del uso de internet y el tiempo de pantalla",
        "Identificando problemas y monitoreando cambios despues de las intervenciones",
        "Reemplazando todas las consultas medicas",
        "Midiendo unicamente la productividad y el rendimiento",
      ],
      answer: 1,
    ),
  ],
);

QuizModule m2Es() => QuizModule(
  id: 2,
  title: "Postura Sentada y Alineacion",
  objectives: [
    "Aprender los elementos clave de la postura sentada neutra.",
    "Detectar errores comunes al sentarse y soluciones sencillas.",
    "Practicar ejercicios basicos de activacion del cuello y la parte superior de la espalda.",
  ],
  content:
      "La postura sentada neutra reduce la tension en musculos y "
      "articulaciones. Los pies deben apoyarse planos en el suelo o en un "
      "reposapies, las rodillas a la altura de las caderas o ligeramente "
      "por debajo, y la zona lumbar debe estar apoyada.\n\n"
      "Un error comun es la postura de cabeza adelantada, que aumenta la "
      "carga sobre el cuello. Ejercicios sencillos como la retraccion "
      "cervical y la aproximacion de omoplatos ayudan a restaurar la "
      "alineacion.",
  quizzes: [
    QuizItemModel(
      question: "En una postura sentada neutra, donde deben estar los pies?",
      options: [
        "Colgando libremente sobre el suelo",
        "Planos sobre el suelo o sobre un reposapies estable",
        "Cruzados firmemente debajo de la silla",
        "Sobre las ruedas de la silla",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "La postura de cabeza adelantada aumenta principalmente la tension en que zona?",
      options: ["Dedos de los pies", "Cuello y parte superior de la espalda", "Tobillos", "Caderas"],
      answer: 1,
    ),
    QuizItemModel(
      question: "Cual es una buena funcion del respaldo?",
      options: [
        "Empujar los hombros hacia adelante",
        "Apoyar la curva natural de la zona lumbar",
        "Mantenerte inclinado muy hacia adelante",
        "Bloquear todo movimiento",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "La retraccion cervical trabaja principalmente que musculos?",
      options: [
        "Musculos estabilizadores profundos del cuello",
        "Musculos de la pantorrilla",
        "Musculos de la mano",
        "Musculos abdominales",
      ],
      answer: 0,
    ),
    QuizItemModel(
      question: "Que puedes usar si tus pies no llegan al suelo?",
      options: [
        "Zapatos de tacon alto",
        "Un reposapies estable",
        "No se necesita ningun cambio",
        "Colocar los pies sobre las ruedas de la silla",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Cual descripcion se ajusta mejor a una \"postura sentada neutra\"?",
      options: [
        "Pies colgando, rodillas mucho mas altas que las caderas",
        "Pies planos o sobre un reposapies, rodillas aproximadamente a la altura de las caderas o ligeramente por debajo, espalda apoyada",
        "Sentado en el borde de la silla sin contacto con el respaldo",
        "Piernas cruzadas firmemente debajo de la silla",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Cual es una forma practica de reducir la postura de cabeza adelantada en el escritorio?",
      options: [
        "Alejar la pantalla y encorvarse hacia adelante",
        "Mantener la espalda separada del respaldo en todo momento",
        "Usar el respaldo, acercar la silla al escritorio y colocar la pantalla a una distancia de vision comoda",
        "Mirar hacia abajo al regazo mientras se teclea",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "Cual senal sugiere que la silla no esta apoyando correctamente la zona lumbar?",
      options: [
        "Te sientes estable y apoyado en la zona lumbar",
        "Puedes mantener la curva natural de la zona lumbar sin esfuerzo",
        "Con frecuencia sientes que la zona lumbar se redondea y se cansa o duele",
        "Tus pies tocan el suelo",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "Cual es el proposito principal de la aproximacion de omoplatos en el Modulo 2?",
      options: [
        "Fortalecer los musculos de la pantorrilla",
        "Aumentar la tension y rigidez de los hombros",
        "Corregir los hombros redondeados y activar los musculos de la parte superior de la espalda",
        "Estirar los dedos y las munecas",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "Cuando puede ser especialmente util un reposapies?",
      options: [
        "Cuando los pies ya descansan comodamente en el suelo",
        "Cuando quieres sentarte sobre los pies",
        "Cuando la silla no se puede bajar lo suficiente y los pies no llegan al suelo",
        "Cuando quieres inclinarte mucho hacia adelante",
      ],
      answer: 2,
    ),
  ],
);

QuizModule m3Es() => QuizModule(
  id: 3,
  title: "Pantallas, Teclado y Raton",
  objectives: [
    "Posicionar las pantallas para reducir la fatiga ocular y cervical.",
    "Configurar el teclado y el raton para reducir la carga en hombros y munecas.",
    "Aplicar reglas sencillas para una o dos pantallas.",
  ],
  content:
      "La colocacion correcta de los dispositivos es fundamental para "
      "la comodidad. La parte superior del monitor debe estar a la altura "
      "de los ojos o ligeramente por debajo y a una distancia aproximada "
      "de un brazo extendido.\n\n"
      "El teclado y el raton deben estar cerca del cuerpo a la altura de "
      "los codos, permitiendo hombros relajados y munecas rectas.",
  quizzes: [
    QuizItemModel(
      question: "Donde debe estar la parte superior de la pantalla principal para la mayoria de los usuarios?",
      options: [
        "Muy por encima del nivel de los ojos",
        "A la altura de los ojos o ligeramente por debajo",
        "A la altura de las rodillas",
        "En el suelo",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Cual es una distancia de vision tipica para reducir la fatiga?",
      options: [
        "Aproximadamente 10 cm",
        "Aproximadamente la distancia de un brazo extendido",
        "Aproximadamente 3 metros",
        "Tocando la nariz",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Como deben colocarse las munecas al teclear o usar el raton?",
      options: [
        "Dobladas bruscamente hacia arriba",
        "Rectas y alineadas con los antebrazos",
        "Apoyadas solo en el borde del escritorio",
        "Giradas fuertemente hacia afuera",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Si usas una pantalla la mayor parte del tiempo, donde debe colocarse?",
      options: [
        "Muy hacia un lado",
        "Directamente frente a ti",
        "Detras de ti",
        "En el suelo",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Cual es una senal de que el raton puede estar demasiado lejos?",
      options: [
        "Puedes apoyar el brazo comodamente a tu lado",
        "Debes estirarte y levantar el hombro para usarlo",
        "No puedes ver el cursor",
        "Tecleas mas rapido",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Que puede ocurrir si el monitor esta colocado demasiado bajo durante mucho tiempo?",
      options: [
        "Solo fatiga ocular, nunca problemas de cuello",
        "El usuario puede desarrollar postura de cabeza adelantada y molestias cervicales",
        "El usuario siempre se sentara perfectamente erguido",
        "Solo afecta la velocidad de tecleo",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Si el raton esta colocado demasiado lejos del cuerpo, cual es el efecto probable?",
      options: [
        "Tu hombro y brazo pueden relajarse mas",
        "Nunca necesitaras mover el brazo",
        "Es posible que necesites estirarte y levantar el hombro, aumentando la tension",
        "Solo cambia el brillo de la pantalla",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "Cual es la posicion ideal del teclado en relacion con los codos?",
      options: [
        "Mucho mas alto que la altura de los codos",
        "Mucho mas bajo que la altura de los codos",
        "Aproximadamente a la altura de los codos para que los antebrazos se mantengan aproximadamente horizontales",
        "Directamente sobre el regazo con las munecas dobladas",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "Al usar dos pantallas por igual, cual es la mejor colocacion?",
      options: [
        "Una directamente enfrente, otra detras de ti",
        "Ambas pantallas centradas frente a ti, formando una ligera curva que puedes ver girando los ojos o la silla",
        "Una muy alta, otra muy baja",
        "Una en el suelo, otra en la pared",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Por que es importante mantener las munecas rectas al teclear o usar el raton?",
      options: [
        "Solo se ve mejor en las fotos",
        "Reduce la tension en los tendones y nervios de la muneca",
        "Hace innecesario el teclado",
        "Previene todos los tipos de fatiga ocular",
      ],
      answer: 1,
    ),
  ],
);

QuizModule m4Es() => QuizModule(
  id: 4,
  title: "Iluminacion, Ruido y Clima",
  objectives: [
    "Ajustar la iluminacion para reducir el deslumbramiento y la fatiga ocular.",
    "Comprender los rangos basicos de confort para la temperatura y el aire.",
    "Usar micropausas para gestionar la fatiga.",
  ],
  content:
      "La iluminacion, la temperatura y la ventilacion afectan la "
      "comodidad. Las pantallas deben colocarse perpendiculares a las "
      "ventanas para reducir el deslumbramiento.\n\n"
      "Las micropausas de 20 a 60 segundos cada 20 a 30 minutos reducen "
      "las molestias sin disminuir la productividad.",
  quizzes: [
    QuizItemModel(
      question: "Como puedes reducir el deslumbramiento de la pantalla causado por una ventana?",
      options: [
        "Colocar la pantalla directamente frente a la ventana",
        "Colocar la pantalla perpendicular a la ventana",
        "Apagar todas las luces",
        "Cerrar la aplicacion",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Por que las temperaturas extremas son problematicas en el trabajo?",
      options: [
        "Mejoran la atencion",
        "Aumentan las molestias y la fatiga",
        "Solo afectan a los ordenadores",
        "Previenen los TME",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Que es una micropausa?",
      options: [
        "Treinta minutos de videojuegos",
        "Una pausa breve para moverse o apartar la vista de la pantalla",
        "Un dia completo libre",
        "Una reunion durante el almuerzo",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "La buena iluminacion de oficina debe ser:",
      options: [
        "Muy brillante y directamente en los ojos",
        "Uniforme, sin deslumbramiento y adecuada para la lectura",
        "Completamente oscura",
        "Parpadeante",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Cual es una actividad sencilla de micropausa?",
      options: [
        "Permanecer completamente inmovil",
        "Levantarse, rotar los hombros y estirar brevemente las munecas",
        "Contener la respiracion",
        "Teclear mas rapido",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Cual es una consecuencia comun del deslumbramiento intenso en la pantalla?",
      options: [
        "Mejor concentracion y comodidad",
        "Reduccion de la fatiga ocular y los dolores de cabeza",
        "Aumento de la fatiga ocular, posibles dolores de cabeza y dificultad para leer",
        "Ningun impacto en los usuarios",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "Como puedes reducir el contraste entre una ventana brillante y una pantalla mas oscura?",
      options: [
        "Colocar la pantalla directamente frente a la ventana",
        "Apagar todas las luces y mirar hacia la ventana",
        "Colocar la pantalla perpendicular a la ventana y ajustar persianas o cortinas",
        "Aumentar solo el brillo de la pantalla al maximo",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "Por que se recomiendan micropausas regulares durante el trabajo con pantalla?",
      options: [
        "Reducen significativamente la productividad",
        "Ayudan a reducir las molestias y la fatiga sin perjudicar la productividad general",
        "Solo son necesarias para atletas",
        "Solo cambian la resolucion de la pantalla",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Cual afirmacion sobre la temperatura y la concentracion es mas precisa?",
      options: [
        "Los ambientes extremadamente calientes o frios no tienen efecto en la concentracion",
        "Los ambientes muy frios siempre mejoran la concentracion",
        "Los rangos de temperatura confortables favorecen la concentracion, mientras que los extremos pueden aumentar la fatiga",
        "Solo los niveles de ruido importan para la concentracion",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "Cual es un ejemplo de micropausa sencilla durante el trabajo de escritorio?",
      options: [
        "Trabajar sin moverse durante 4 horas",
        "Levantarse durante 20 a 30 segundos, rotar los hombros y mirar un objeto lejano",
        "Contener la respiracion mientras se teclea",
        "Solo cerrar los ojos sin moverse",
      ],
      answer: 1,
    ),
  ],
);

QuizModule m5Es() => QuizModule(
  id: 5,
  title: "Manejo de Cargas y Levantamiento",
  objectives: [
    "Aplicar principios de levantamiento seguro a las tareas de oficina.",
    "Saber cuando pedir ayuda o usar dispositivos de manipulacion.",
    "Comprender como la posicion de la carga afecta la tension en la espalda.",
  ],
  content:
      "Incluso en las oficinas, el levantamiento puede suponer riesgos. "
      "Mantener las cargas cerca del cuerpo, flexionar las caderas y las "
      "rodillas y evitar torcer el tronco mientras se sostiene peso.\n\n"
      "Usar carritos o pedir ayuda con objetos pesados o de forma irregular.",
  quizzes: [
    QuizItemModel(
      question: "Durante un levantamiento, donde debe estar la carga?",
      options: [
        "Lejos del cuerpo",
        "Lo mas cerca posible del cuerpo",
        "Por encima de la cabeza",
        "En un brazo extendido",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Que movimiento debe evitarse al levantar una carga?",
      options: [
        "Girar con los pies",
        "Torcer la espalda mientras se sostiene una carga",
        "Respirar",
        "Usar ambas manos",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Como puedes reducir la tension en la espalda al levantar?",
      options: [
        "Doblarse solo por la cintura",
        "Flexionar las caderas y las rodillas manteniendo la espalda lo mas recta posible",
        "Contener la respiracion",
        "Levantar rapidamente con un movimiento brusco",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Cuando es mejor pedir ayuda o usar un dispositivo?",
      options: [
        "Para objetos pesados o voluminosos",
        "Para un boligrafo",
        "Para una hoja de papel",
        "Nunca",
      ],
      answer: 0,
    ),
    QuizItemModel(
      question: "Cual afirmacion sobre el levantamiento en trabajos de oficina es verdadera?",
      options: [
        "Nunca hay riesgo de levantamiento",
        "El levantamiento inadecuado ocasional aun puede contribuir a problemas de espalda",
        "Solo importa el trabajo en fabrica",
        "Solo importa estar sentado",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Por que es tan importante mantener la carga cerca del cuerpo al levantar?",
      options: [
        "Hace que la carga sea mas pesada",
        "Reduce la tension en la espalda y la columna vertebral",
        "No tiene efecto sobre el cuerpo",
        "Solo ayuda con el equilibrio pero no con la tension",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Cual es la forma mas segura de girar mientras se transporta un objeto pesado?",
      options: [
        "Torcer la espalda mientras los pies permanecen inmoviles",
        "Inclinarse hacia adelante y girar solo los hombros",
        "Mover los pies para girar todo el cuerpo junto con la carga",
        "Inclinarse lo mas atras posible mientras se gira",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "Al levantar del suelo, cual es una mejor estrategia de movimiento?",
      options: [
        "Doblarse principalmente por la cintura con la espalda redondeada",
        "Flexionar las caderas y las rodillas manteniendo la espalda lo mas recta posible",
        "Mantener las piernas rectas y tirar solo con los brazos",
        "Saltar y atrapar la carga en el aire",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "En una oficina, cuando es mas apropiado usar un carrito o pedir ayuda?",
      options: [
        "Solo cuando tienes ganas de compartir el trabajo",
        "Para objetos pesados, voluminosos o de forma irregular que son dificiles de sostener",
        "Nunca, porque las cargas de oficina siempre son seguras",
        "Solo para objetos muy pequenos",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Cual situacion aumenta el riesgo de tension en la espalda al levantar en la oficina?",
      options: [
        "Levantar una carpeta muy ligera con buena postura",
        "Levantar ocasionalmente una caja pesada con mala tecnica",
        "Llevar un boligrafo en el bolsillo",
        "Usar ambas manos para sostener un teclado ligero",
      ],
      answer: 1,
    ),
  ],
);

QuizModule m6Es() => QuizModule(
  id: 6,
  title: "Trabajo Hibrido y Remoto",
  objectives: [
    "Aplicar los principios de ergonomia en casa o en el trabajo hibrido.",
    "Reducir los periodos prolongados sentado en configuraciones remotas.",
    "Usar reglas sencillas para portatiles y telefonos.",
  ],
  content:
      "El trabajo remoto requiere los mismos principios ergonomicos que "
      "el trabajo de oficina. Los portatiles deben elevarse y usarse con "
      "dispositivos de entrada externos.\n\n"
      "Ponerse de pie durante las llamadas y evitar la flexion cervical "
      "prolongada al usar el telefono reduce la tension.",
  quizzes: [
    QuizItemModel(
      question: "En casa, cual es el objetivo respecto a la ergonomia?",
      options: [
        "Ignorar la ergonomia",
        "Aplicar los mismos principios basicos de configuracion que en la oficina",
        "Trabajar solo desde la cama",
        "Trabajar en la oscuridad",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Una forma sencilla de reducir el tiempo sentado prolongado es:",
      options: [
        "Nunca ponerse de pie durante las llamadas",
        "Levantarse o caminar durante algunas llamadas",
        "Bloquear la silla",
        "Evitar los descansos",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Para el uso del portatil, cual opcion es mejor?",
      options: [
        "Mantenerlo en el regazo durante horas",
        "Elevarlo y usar un teclado y raton externos",
        "Usarlo acostado de lado",
        "Sostenerlo por encima de la cabeza",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Por que son utiles los cambios de postura frecuentes en el trabajo remoto?",
      options: [
        "Aumentan las molestias",
        "Reducen la rigidez y favorecen la circulacion",
        "Solo interrumpen la concentracion",
        "Danan la silla",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Cual comportamiento aumenta la tension cervical con los telefonos?",
      options: [
        "Llevar el telefono a la altura de los ojos",
        "Mirar hacia abajo al telefono con el cuello flexionado durante periodos prolongados",
        "Tomar descansos breves",
        "Usar auriculares",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Por que generalmente no se recomienda trabajar a largo plazo desde un sofa o la cama?",
      options: [
        "Siempre mejora la postura",
        "Es demasiado silencioso",
        "A menudo conduce a una mala postura de espalda y cuello sin el soporte adecuado",
        "Impide usar un portatil",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "Cual combinacion es la mejor para el uso prolongado del portatil en casa?",
      options: [
        "Portatil en el regazo, sin soporte, sin dispositivos externos",
        "Portatil sobre una mesa baja con la pantalla muy lejos",
        "Portatil elevado a la altura de los ojos mas teclado y raton externos",
        "Portatil a nivel del suelo, de pie sobre el",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "Cual es una forma practica de reducir los periodos prolongados sentado al trabajar en remoto?",
      options: [
        "Evitar todos los descansos para terminar mas rapido",
        "Levantarse o caminar durante algunas llamadas y reuniones en linea",
        "Trabajar solo desde la cama",
        "Mantener la silla bloqueada y no moverse nunca",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Cual comportamiento aumenta el riesgo de \"cuello de texto\"?",
      options: [
        "Acercar el telefono a la altura de los ojos",
        "Usar auriculares para mantener las manos libres",
        "Mirar hacia abajo al telefono con el cuello flexionado durante periodos prolongados",
        "Tomar descansos breves del telefono",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "Por que se aplican los mismos principios ergonomicos en casa y en la oficina?",
      options: [
        "Porque tu cuerpo y articulaciones son los mismos en ambos lugares",
        "Porque las sillas de oficina estan prohibidas en casa",
        "Porque los portatiles solo funcionan en casa",
        "Porque la postura solo importa en la oficina",
      ],
      answer: 0,
    ),
  ],
);

QuizModule m7Es() => QuizModule(
  id: 7,
  title: "Rutina Preventiva Diaria",
  objectives: [
    "Aprender ejercicios sencillos y micropausas.",
    "Comprender la dosificacion basica (cuanto tiempo y con que frecuencia).",
    "Vincular los ejercicios con los sintomas de cuello, hombros y zona lumbar.",
  ],
  content:
      "El movimiento suave diario previene la rigidez. Los estiramientos "
      "de cuello, las extensiones de la parte superior de la espalda y los "
      "estiramientos de muneca deben realizarse con regularidad.\n\n"
      "Mantener los estiramientos durante 10 a 30 segundos, repetir de 2 a "
      "3 veces y detenerse si aparece dolor agudo.",
  quizzes: [
    QuizItemModel(
      question: "Por que los ejercicios especificos pueden ayudar a los trabajadores de oficina?",
      options: [
        "Solo desarrollan masa muscular",
        "Pueden reducir el dolor de cuello y hombros cuando se realizan con regularidad",
        "Eliminan la necesidad de ajustar la estacion de trabajo",
        "Reemplazan el sueno",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Un tiempo de mantenimiento tipico para un estiramiento suave es:",
      options: [
        "Aproximadamente 1 segundo",
        "Aproximadamente de 10 a 30 segundos",
        "Aproximadamente 5 minutos",
        "Aproximadamente 30 minutos",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Cual de estos es un ejercicio sencillo de activacion de hombros?",
      options: [
        "Mantener los hombros elevados todo el dia",
        "Aproximar suavemente los omoplatos durante varias repeticiones",
        "Cargar bolsas pesadas",
        "Encoger los hombros bajo una carga pesada",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Cuando debe el usuario dejar de hacer un ejercicio?",
      options: [
        "Si el dolor aumenta bruscamente",
        "Cuando se siente mejor",
        "Nunca",
        "Solo despues de 3 horas",
      ],
      answer: 0,
    ),
    QuizItemModel(
      question: "Una frecuencia realista para las micropausas durante el trabajo con pantalla es:",
      options: [
        "Una vez al mes",
        "Unos segundos cada 20 a 30 minutos",
        "Una vez al ano",
        "Solo durante las vacaciones",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Cual es el objetivo principal de la rutina preventiva diaria del Modulo 7?",
      options: [
        "Reemplazar todos los tratamientos medicos",
        "Reducir suavemente la rigidez y prevenir las molestias de cuello, hombros y zona lumbar",
        "Entrenar para deportes de competicion",
        "Evitar ajustar la estacion de trabajo",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Como deben sentirse generalmente los ejercicios de estiramiento?",
      options: [
        "Muy dolorosos para saber que estan funcionando",
        "Suaves, con un estiramiento leve pero sin dolor agudo",
        "Completamente sin esfuerzo y sin ninguna sensacion",
        "Tan intensos que debes contener la respiracion",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Con que frecuencia se pueden integrar de forma realista las pausas cortas de ejercicio o estiramiento en el trabajo con pantalla?",
      options: [
        "Solo una vez al mes",
        "Solo durante las vacaciones",
        "Unos segundos o minutos cada 20 a 30 minutos",
        "Solo una vez al ano",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "Que debes hacer si el dolor aumenta bruscamente durante un ejercicio?",
      options: [
        "Continuar e ignorarlo",
        "Solo reducir un poco la velocidad",
        "Detener el ejercicio inmediatamente y volver a una posicion comoda",
        "Aumentar la intensidad",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "Por que es util vincular los ejercicios con sintomas especificos (por ejemplo, tension en cuello u hombros)?",
      options: [
        "Te permite elegir ejercicios que se enfoquen en tus propias areas problematicas",
        "Hace innecesario el estiramiento",
        "Solo aumenta la complejidad sin ningun beneficio",
        "Reemplaza completamente los ajustes de la estacion de trabajo",
      ],
      answer: 0,
    ),
  ],
);
