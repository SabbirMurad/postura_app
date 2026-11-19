package com.sabbir.postura

/**
 * On-screen text of the native capture screen (PoseDetectionActivity, the live
 * PoseOverlayView and the layout's chips) in the app's languages. Flutter passes
 * the selected language in the launch intent; anything missing or unsupported
 * falls back to English.
 *
 * Keep in sync with ios/Runner/PostureEngine/CaptureStrings.swift.
 *
 * Text baked into the saved photos ("Eye level", angle labels, the "Monitor"
 * box label) is deliberately NOT here: those photos are reviewed by ergonomists
 * and admins who may use another language, so they stay English.
 *
 * Templates use named placeholders like `{value}`, filled by [get], so each
 * language can order the words its own way.
 */
object CaptureStrings {

    const val DEFAULT_LANGUAGE = "en"
    private val SUPPORTED = setOf("en", "de", "es", "nl")

    /** "de", "de-DE", "de_DE", "DE" → "de"; null / unsupported → "en". */
    fun normalize(language: String?): String {
        val code = language?.trim()?.lowercase()?.substringBefore('-')?.substringBefore('_')
        return if (code != null && code in SUPPORTED) code else DEFAULT_LANGUAGE
    }

    enum class Key {
        // Condition chips
        CHIP_LIGHT, CHIP_PERSON, CHIP_MONITOR,
        CHIP_ROTATION_IDLE, CHIP_ROTATION_OK, CHIP_ROTATION_BAD,
        CHIP_TILT_IDLE, CHIP_TILT_OK, CHIP_TILT_BAD,
        CHIP_DISTANCE_IDLE, CHIP_DISTANCE_OK, CHIP_DISTANCE_TOO_CLOSE, CHIP_DISTANCE_TOO_FAR,
        CHIP_SIDE_IDLE, CHIP_SIDE_OK, CHIP_SIDE_ADJUST,
        CHIP_FRONT_SHOW_BODY, CHIP_FRONT_MOVE, CHIP_FRONT_STRAIGHTEN, CHIP_FRONT_HOLD_STILL, CHIP_FRONT_OK, CHIP_FRONT_HOLD_LOWER,
        // Status messages
        LIGHT_TOO_DARK, LIGHT_TOO_BRIGHT, LOADING, HOLD_STILL, POSE_INIT_FAILED,
        PROCESSING_PHOTOS, CHECKING_PHOTOS, PROCESS_FAILED,
        CAMERA_PERMISSION_REQUIRED, CAMERA_UNAVAILABLE,
        // Side-shot capture banner
        SHOTS_ALL_DONE, SHOT_DONE, SHOT_CAPTURING, SHOT_GET_READY,
        // Front-shot capture banner
        SIDE_PHOTOS_DONE, FRONT_MOVE, FRONT_SHOW_BODY, FRONT_STRAIGHTEN, FRONT_HOLD_PHONE_STILL, FRONT_CAPTURING, FRONT_HOLD_LOWER,
        // Live height guide (overlay only, never baked into photos)
        GUIDE_LOWER_PHONE, GUIDE_RAISE_PHONE, GUIDE_HEIGHT_OK,
        // Accessibility
        SWITCH_CAMERA,
        // Front-photo guide shown between the side photos and the front photo
        FRONT_GUIDE_TITLE, FRONT_GUIDE_WORKER, FRONT_GUIDE_A1, FRONT_GUIDE_A2, FRONT_GUIDE_A3, FRONT_GUIDE_A4, FRONT_GUIDE_PHOTOGRAPHER, FRONT_GUIDE_B1, FRONT_GUIDE_B2, FRONT_GUIDE_B3, FRONT_GUIDE_B4, FRONT_GUIDE_CONTINUE,
    }

    private class T(val en: String, val de: String, val es: String, val nl: String)

    private val table: Map<Key, T> = mapOf(
        Key.CHIP_LIGHT to T("● Light", "● Licht", "● Luz", "● Licht"),
        Key.CHIP_PERSON to T("● Person", "● Person", "● Persona", "● Persoon"),
        Key.CHIP_MONITOR to T("● Monitor", "● Monitor", "● Monitor", "● Monitor"),

        Key.CHIP_ROTATION_IDLE to T("● Rotation  --", "● Drehung  --", "● Rotación  --", "● Rotatie  --"),
        Key.CHIP_ROTATION_OK to T("● Rotation  OK", "● Drehung  OK", "● Rotación  OK", "● Rotatie  OK"),
        Key.CHIP_ROTATION_BAD to T(
            "● Rotation  {value}°  ·  Level the phone",
            "● Drehung  {value}°  ·  Handy gerade halten",
            "● Rotación  {value}°  ·  Nivela el teléfono",
            "● Rotatie  {value}°  ·  Houd de telefoon recht"),

        Key.CHIP_TILT_IDLE to T("● Tilt  --°", "● Neigung  --°", "● Inclinación  --°", "● Kanteling  --°"),
        Key.CHIP_TILT_OK to T("● Tilt  {value}°", "● Neigung  {value}°", "● Inclinación  {value}°", "● Kanteling  {value}°"),
        Key.CHIP_TILT_BAD to T(
            "● Tilt  {value}°  ·  Hold phone upright",
            "● Neigung  {value}°  ·  Handy aufrecht halten",
            "● Inclinación  {value}°  ·  Mantén el teléfono vertical",
            "● Kanteling  {value}°  ·  Houd de telefoon rechtop"),

        Key.CHIP_DISTANCE_IDLE to T("● Distance  --", "● Abstand  --", "● Distancia  --", "● Afstand  --"),
        Key.CHIP_DISTANCE_OK to T(
            "● Distance  {value}m", "● Abstand  {value}m", "● Distancia  {value}m", "● Afstand  {value}m"),
        Key.CHIP_DISTANCE_TOO_CLOSE to T(
            "● Distance  {value}m  ·  Move back",
            "● Abstand  {value}m  ·  Geh weiter zurück",
            "● Distancia  {value}m  ·  Aléjate",
            "● Afstand  {value}m  ·  Ga verder naar achteren"),
        Key.CHIP_DISTANCE_TOO_FAR to T(
            "● Distance  {value}m  ·  Move closer",
            "● Abstand  {value}m  ·  Geh näher heran",
            "● Distancia  {value}m  ·  Acércate",
            "● Afstand  {value}m  ·  Kom dichterbij"),

        Key.CHIP_SIDE_IDLE to T("● Side  --", "● Seite  --", "● Lateral  --", "● Zijkant  --"),
        Key.CHIP_SIDE_OK to T("● Side  OK", "● Seite  OK", "● Lateral  OK", "● Zijkant  OK"),
        Key.CHIP_SIDE_ADJUST to T(
            "● Side  Adjust angle", "● Seite  Winkel anpassen", "● Lateral  Ajusta el ángulo", "● Zijkant  Pas de hoek aan"),

        Key.CHIP_FRONT_SHOW_BODY to T(
            "● Front  Face/shoulders/hands",
            "● Vorne  Gesicht/Schultern/Hände",
            "● Frontal  Cara/hombros/manos",
            "● Voorkant  Gezicht/schouders/handen"),
        Key.CHIP_FRONT_MOVE to T(
            "● Front  Move to the front",
            "● Vorne  Geh nach vorne",
            "● Frontal  Ponte delante",
            "● Voorkant  Ga naar de voorkant"),
        Key.CHIP_FRONT_STRAIGHTEN to T(
            "● Front  Straighten phone",
            "● Vorne  Handy gerade halten",
            "● Frontal  Endereza el teléfono",
            "● Voorkant  Houd de telefoon recht"),
        Key.CHIP_FRONT_HOLD_STILL to T(
            "● Front  Hold still", "● Vorne  Stillhalten", "● Frontal  No te muevas", "● Voorkant  Stilhouden"),
        Key.CHIP_FRONT_OK to T("● Front  OK", "● Vorne  OK", "● Frontal  OK", "● Voorkant  OK"),

        Key.LIGHT_TOO_DARK to T(
            "Room is too dark — turn on more lights",
            "Der Raum ist zu dunkel – schalte mehr Licht ein",
            "La sala está demasiado oscura: enciende más luces",
            "De ruimte is te donker — doe meer lampen aan"),
        Key.LIGHT_TOO_BRIGHT to T(
            "Too bright — reduce glare or step back",
            "Zu hell – verringere die Blendung oder geh einen Schritt zurück",
            "Demasiada luz: reduce los reflejos o da un paso atrás",
            "Te fel — verminder de schittering of doe een stap achteruit"),
        Key.LOADING to T("Loading…", "Wird geladen…", "Cargando…", "Laden…"),
        Key.HOLD_STILL to T("Hold still…", "Stillhalten…", "No te muevas…", "Stilhouden…"),
        Key.POSE_INIT_FAILED to T(
            "Pose detection couldn't start on this device",
            "Die Haltungserkennung konnte auf diesem Gerät nicht gestartet werden",
            "No se pudo iniciar la detección de postura en este dispositivo",
            "De houdingsherkenning kon niet starten op dit apparaat"),
        Key.PROCESSING_PHOTOS to T(
            "Processing photos…", "Fotos werden verarbeitet…", "Procesando fotos…", "Foto's verwerken…"),
        Key.CHECKING_PHOTOS to T(
            "Checking photos…", "Fotos werden geprüft…", "Comprobando fotos…", "Foto's controleren…"),
        Key.PROCESS_FAILED to T(
            "Couldn't process the photos. Please try again.",
            "Die Fotos konnten nicht verarbeitet werden. Bitte versuche es erneut.",
            "No se pudieron procesar las fotos. Inténtalo de nuevo.",
            "De foto's konden niet worden verwerkt. Probeer het opnieuw."),
        Key.CAMERA_PERMISSION_REQUIRED to T(
            "Camera permission required",
            "Kamerazugriff erforderlich",
            "Se necesita permiso para usar la cámara",
            "Cameratoestemming vereist"),
        Key.CAMERA_UNAVAILABLE to T(
            "Camera unavailable", "Kamera nicht verfügbar", "Cámara no disponible", "Camera niet beschikbaar"),

        Key.SHOTS_ALL_DONE to T(
            "✓ All {total} photos captured",
            "✓ Alle {total} Fotos aufgenommen",
            "✓ Se han tomado las {total} fotos",
            "✓ Alle {total} foto's gemaakt"),
        Key.SHOT_DONE to T(
            "✓ Photo {done} of {total} captured — hold your position",
            "✓ Foto {done} von {total} aufgenommen – bleib in Position",
            "✓ Foto {done} de {total} tomada: mantén la posición",
            "✓ Foto {done} van {total} gemaakt — blijf op je plek"),
        Key.SHOT_CAPTURING to T(
            "Hold steady — capturing photo {number} of {total}…",
            "Ruhig halten – Foto {number} von {total} wird aufgenommen…",
            "Mantén el teléfono quieto: tomando la foto {number} de {total}…",
            "Stil houden — foto {number} van {total} wordt gemaakt…"),
        Key.SHOT_GET_READY to T(
            "Get into position for photo {number} of {total}",
            "Geh in Position für Foto {number} von {total}",
            "Colócate en posición para la foto {number} de {total}",
            "Ga in positie voor foto {number} van {total}"),

        Key.SIDE_PHOTOS_DONE to T(
            "Side photos done — move to the FRONT of the person, behind the monitor",
            "Seitenfotos fertig – geh VOR die Person, hinter den Monitor",
            "Fotos laterales listas: ponte DELANTE de la persona, detrás del monitor",
            "Zijfoto's klaar — ga VOOR de persoon staan, achter de monitor"),
        Key.FRONT_MOVE to T(
            "Move to the FRONT of the person, behind the monitor",
            "Geh VOR die Person, hinter den Monitor",
            "Ponte DELANTE de la persona, detrás del monitor",
            "Ga VOOR de persoon staan, achter de monitor"),
        Key.FRONT_SHOW_BODY to T(
            "Show the person's face, shoulders and hands",
            "Gesicht, Schultern und Hände der Person müssen zu sehen sein",
            "Encuadra la cara, los hombros y las manos de la persona",
            "Breng het gezicht, de schouders en de handen van de persoon in beeld"),
        Key.FRONT_HOLD_LOWER to T(
            "Hold the phone lower, level with the person's shoulders",
            "Halte das Handy tiefer, auf Schulterhöhe der Person",
            "Baja el teléfono a la altura de los hombros de la persona",
            "Houd de telefoon lager, op schouderhoogte van de persoon"),
        Key.CHIP_FRONT_HOLD_LOWER to T(
            "● Front  Hold phone lower",
            "● Vorne  Handy tiefer halten",
            "● Frontal  Baja el teléfono",
            "● Voorkant  Telefoon lager houden"),
        Key.FRONT_STRAIGHTEN to T(
            "Straighten the phone — it's rotated",
            "Halte das Handy gerade – es ist verdreht",
            "Endereza el teléfono: está girado",
            "Houd de telefoon recht — hij is gedraaid"),
        Key.FRONT_HOLD_PHONE_STILL to T(
            "Hold the phone still", "Halte das Handy still", "Mantén el teléfono quieto", "Houd de telefoon stil"),
        Key.FRONT_CAPTURING to T(
            "Hold steady — capturing front photo…",
            "Ruhig halten – Foto von vorne wird aufgenommen…",
            "Mantén el teléfono quieto: tomando la foto frontal…",
            "Stil houden — foto van voren wordt gemaakt…"),

        Key.GUIDE_LOWER_PHONE to T("▼  Lower phone", "▼  Handy senken", "▼  Baja el teléfono", "▼  Telefoon lager"),
        Key.GUIDE_RAISE_PHONE to T("▲  Raise phone", "▲  Handy anheben", "▲  Sube el teléfono", "▲  Telefoon hoger"),
        Key.GUIDE_HEIGHT_OK to T("✓  Height OK", "✓  Höhe OK", "✓  Altura OK", "✓  Hoogte OK"),

        Key.SWITCH_CAMERA to T("Switch camera", "Kamera wechseln", "Cambiar de cámara", "Camera wisselen"),

        Key.FRONT_GUIDE_TITLE to T("Front Photo Guide", "Anleitung Frontfoto", "Guía de la foto frontal", "Gids voor de frontfoto"),
        Key.FRONT_GUIDE_WORKER to T("A (Worker)", "A (Mitarbeiter)", "A (Trabajador)", "A (Medewerker)"),
        Key.FRONT_GUIDE_A1 to T("Stay seated exactly as you normally work", "Bleib so sitzen, wie du normalerweise arbeitest", "Sigue sentado tal como trabajas normalmente", "Blijf zitten zoals je normaal werkt"),
        Key.FRONT_GUIDE_A2 to T("Face the screen with your hands on the keyboard", "Schau zum Bildschirm, die Hände auf der Tastatur", "Mira la pantalla con las manos sobre el teclado", "Kijk naar het scherm met je handen op het toetsenbord"),
        Key.FRONT_GUIDE_A3 to T("Keep your shoulders relaxed", "Halte die Schultern locker", "Mantén los hombros relajados", "Houd je schouders ontspannen"),
        Key.FRONT_GUIDE_A4 to T("Look at the screen naturally", "Schau ganz natürlich auf den Bildschirm", "Mira la pantalla con naturalidad", "Kijk op een natuurlijke manier naar het scherm"),
        Key.FRONT_GUIDE_PHOTOGRAPHER to T("B (Photographer)", "B (Fotograf)", "B (Fotógrafo)", "B (Fotograaf)"),
        Key.FRONT_GUIDE_B1 to T("Stand behind the monitor, facing the worker", "Stell dich hinter den Monitor, mit Blick zur Person", "Colócate detrás del monitor, frente al trabajador", "Ga achter de monitor staan, met je gezicht naar de medewerker"),
        Key.FRONT_GUIDE_B2 to T("Hold the phone upright, level with the worker's shoulders", "Halte das Handy aufrecht, auf Schulterhöhe der Person", "Sujeta el teléfono en vertical, a la altura de los hombros del trabajador", "Houd de telefoon rechtop, op schouderhoogte van de medewerker"),
        Key.FRONT_GUIDE_B3 to T("Make sure the head, shoulders and both hands are visible", "Achte darauf, dass Kopf, Schultern und beide Hände zu sehen sind", "Asegúrate de que se vean la cabeza, los hombros y ambas manos", "Zorg dat het hoofd, de schouders en beide handen zichtbaar zijn"),
        Key.FRONT_GUIDE_B4 to T("Hold the phone still until the photo is taken", "Halte das Handy still, bis das Foto aufgenommen ist", "Mantén el teléfono quieto hasta que se tome la foto", "Houd de telefoon stil tot de foto is gemaakt"),
        Key.FRONT_GUIDE_CONTINUE to T("Continue", "Weiter", "Continuar", "Doorgaan"),
    )

    /**
     * Text for [key] in [language] (already normalized or not), with each
     * `{name}` placeholder replaced by its value from [args].
     */
    fun get(key: Key, language: String, vararg args: Pair<String, Any>): String {
        val t = table[key] ?: return key.name
        var text = when (normalize(language)) {
            "de" -> t.de
            "es" -> t.es
            "nl" -> t.nl
            else -> t.en
        }
        for ((name, value) in args) text = text.replace("{$name}", value.toString())
        return text
    }
}
