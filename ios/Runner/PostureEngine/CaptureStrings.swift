import Foundation

/// On-screen text of the native capture screen (PoseDetectionViewController and
/// the live PoseOverlayView) in the app's languages. Flutter passes the selected
/// language in the `startDetection` arguments; anything missing or unsupported
/// falls back to English.
///
/// Keep in sync with android/app/src/main/kotlin/com/sabbir/postura/CaptureStrings.kt.
///
/// Text baked into the saved photos ("Eye level", angle labels, the "Monitor"
/// box label) is deliberately NOT here: those photos are reviewed by ergonomists
/// and admins who may use another language, so they stay English.
///
/// Templates use named placeholders like `{value}`, filled by `get`, so each
/// language can order the words its own way.
enum CaptureStrings {

    static let defaultLanguage = "en"
    private static let supported: Set<String> = ["en", "de", "es", "nl"]

    /// "de", "de-DE", "de_DE", "DE" → "de"; nil / unsupported → "en".
    static func normalize(_ language: String?) -> String {
        guard let raw = language?.trimmingCharacters(in: .whitespaces).lowercased(),
              !raw.isEmpty else { return defaultLanguage }
        let code = String(raw.split(whereSeparator: { $0 == "-" || $0 == "_" }).first ?? "")
        return supported.contains(code) ? code : defaultLanguage
    }

    enum Key {
        // Condition chips
        case chipLight, chipPerson, chipMonitor
        case chipRotationIdle, chipRotationOk, chipRotationBad
        case chipTiltIdle, chipTiltOk, chipTiltBad
        case chipDistanceIdle, chipDistanceOk, chipDistanceTooClose, chipDistanceTooFar
        case chipSideIdle, chipSideOk, chipSideAdjust
        case chipFrontShowBody, chipFrontMove, chipFrontStraighten, chipFrontHoldStill, chipFrontOk, chipFrontHoldLower
        // Status messages
        case lightTooDark, lightTooBright, loading, holdStill, poseInitFailed
        case processingPhotos, checkingPhotos, processFailed
        case cameraPermissionRequired, cameraUnavailable
        // Side-shot capture banner
        case shotsAllDone, shotDone, shotCapturing, shotGetReady
        // Front-shot capture banner
        case sidePhotosDone, frontMove, frontShowBody, frontStraighten, frontHoldPhoneStill, frontCapturing, frontHoldLower
        // Live height guide (overlay only, never baked into photos)
        case guideLowerPhone, guideRaisePhone, guideHeightOk
        // Accessibility
        case switchCamera
        // Front-photo guide shown between the side photos and the front photo
        case frontGuideTitle, frontGuideWorker, frontGuideA1, frontGuideA2, frontGuideA3, frontGuideA4, frontGuidePhotographer, frontGuideB1, frontGuideB2, frontGuideB3, frontGuideB4, frontGuideContinue
    }

    private struct T {
        let en: String
        let de: String
        let es: String
        let nl: String
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    private static func entry(_ key: Key) -> T {
        switch key {
        case .chipLight: return T(en: "● Light", de: "● Licht", es: "● Luz", nl: "● Licht")
        case .chipPerson: return T(en: "● Person", de: "● Person", es: "● Persona", nl: "● Persoon")
        case .chipMonitor: return T(en: "● Monitor", de: "● Monitor", es: "● Monitor", nl: "● Monitor")

        case .chipRotationIdle:
            return T(en: "● Rotation  --", de: "● Drehung  --", es: "● Rotación  --", nl: "● Rotatie  --")
        case .chipRotationOk:
            return T(en: "● Rotation  OK", de: "● Drehung  OK", es: "● Rotación  OK", nl: "● Rotatie  OK")
        case .chipRotationBad:
            return T(en: "● Rotation  {value}°  ·  Level the phone",
                     de: "● Drehung  {value}°  ·  Handy gerade halten",
                     es: "● Rotación  {value}°  ·  Nivela el teléfono",
                     nl: "● Rotatie  {value}°  ·  Houd de telefoon recht")

        case .chipTiltIdle:
            return T(en: "● Tilt  --°", de: "● Neigung  --°", es: "● Inclinación  --°", nl: "● Kanteling  --°")
        case .chipTiltOk:
            return T(en: "● Tilt  {value}°", de: "● Neigung  {value}°",
                     es: "● Inclinación  {value}°", nl: "● Kanteling  {value}°")
        case .chipTiltBad:
            return T(en: "● Tilt  {value}°  ·  Hold phone upright",
                     de: "● Neigung  {value}°  ·  Handy aufrecht halten",
                     es: "● Inclinación  {value}°  ·  Mantén el teléfono vertical",
                     nl: "● Kanteling  {value}°  ·  Houd de telefoon rechtop")

        case .chipDistanceIdle:
            return T(en: "● Distance  --", de: "● Abstand  --", es: "● Distancia  --", nl: "● Afstand  --")
        case .chipDistanceOk:
            return T(en: "● Distance  {value}m", de: "● Abstand  {value}m",
                     es: "● Distancia  {value}m", nl: "● Afstand  {value}m")
        case .chipDistanceTooClose:
            return T(en: "● Distance  {value}m  ·  Move back",
                     de: "● Abstand  {value}m  ·  Geh weiter zurück",
                     es: "● Distancia  {value}m  ·  Aléjate",
                     nl: "● Afstand  {value}m  ·  Ga verder naar achteren")
        case .chipDistanceTooFar:
            return T(en: "● Distance  {value}m  ·  Move closer",
                     de: "● Abstand  {value}m  ·  Geh näher heran",
                     es: "● Distancia  {value}m  ·  Acércate",
                     nl: "● Afstand  {value}m  ·  Kom dichterbij")

        case .chipSideIdle:
            return T(en: "● Side  --", de: "● Seite  --", es: "● Lateral  --", nl: "● Zijkant  --")
        case .chipSideOk:
            return T(en: "● Side  OK", de: "● Seite  OK", es: "● Lateral  OK", nl: "● Zijkant  OK")
        case .chipSideAdjust:
            return T(en: "● Side  Adjust angle", de: "● Seite  Winkel anpassen",
                     es: "● Lateral  Ajusta el ángulo", nl: "● Zijkant  Pas de hoek aan")

        case .chipFrontShowBody:
            return T(en: "● Front  Face/shoulders/hands",
                     de: "● Vorne  Gesicht/Schultern/Hände",
                     es: "● Frontal  Cara/hombros/manos",
                     nl: "● Voorkant  Gezicht/schouders/handen")
        case .chipFrontMove:
            return T(en: "● Front  Move to the front", de: "● Vorne  Geh nach vorne",
                     es: "● Frontal  Ponte delante", nl: "● Voorkant  Ga naar de voorkant")
        case .chipFrontStraighten:
            return T(en: "● Front  Straighten phone", de: "● Vorne  Handy gerade halten",
                     es: "● Frontal  Endereza el teléfono", nl: "● Voorkant  Houd de telefoon recht")
        case .chipFrontHoldStill:
            return T(en: "● Front  Hold still", de: "● Vorne  Stillhalten",
                     es: "● Frontal  No te muevas", nl: "● Voorkant  Stilhouden")
        case .chipFrontOk:
            return T(en: "● Front  OK", de: "● Vorne  OK", es: "● Frontal  OK", nl: "● Voorkant  OK")

        case .lightTooDark:
            return T(en: "Room is too dark — turn on more lights",
                     de: "Der Raum ist zu dunkel – schalte mehr Licht ein",
                     es: "La sala está demasiado oscura: enciende más luces",
                     nl: "De ruimte is te donker — doe meer lampen aan")
        case .lightTooBright:
            return T(en: "Too bright — reduce glare or step back",
                     de: "Zu hell – verringere die Blendung oder geh einen Schritt zurück",
                     es: "Demasiada luz: reduce los reflejos o da un paso atrás",
                     nl: "Te fel — verminder de schittering of doe een stap achteruit")
        case .loading:
            return T(en: "Loading…", de: "Wird geladen…", es: "Cargando…", nl: "Laden…")
        case .holdStill:
            return T(en: "Hold still…", de: "Stillhalten…", es: "No te muevas…", nl: "Stilhouden…")
        case .poseInitFailed:
            return T(en: "Pose detection couldn't start on this device",
                     de: "Die Haltungserkennung konnte auf diesem Gerät nicht gestartet werden",
                     es: "No se pudo iniciar la detección de postura en este dispositivo",
                     nl: "De houdingsherkenning kon niet starten op dit apparaat")
        case .processingPhotos:
            return T(en: "Processing photos…", de: "Fotos werden verarbeitet…",
                     es: "Procesando fotos…", nl: "Foto's verwerken…")
        case .checkingPhotos:
            return T(en: "Checking photos…", de: "Fotos werden geprüft…",
                     es: "Comprobando fotos…", nl: "Foto's controleren…")
        case .processFailed:
            return T(en: "Couldn't process the photos. Please try again.",
                     de: "Die Fotos konnten nicht verarbeitet werden. Bitte versuche es erneut.",
                     es: "No se pudieron procesar las fotos. Inténtalo de nuevo.",
                     nl: "De foto's konden niet worden verwerkt. Probeer het opnieuw.")
        case .cameraPermissionRequired:
            return T(en: "Camera permission required", de: "Kamerazugriff erforderlich",
                     es: "Se necesita permiso para usar la cámara", nl: "Cameratoestemming vereist")
        case .cameraUnavailable:
            return T(en: "Camera unavailable", de: "Kamera nicht verfügbar",
                     es: "Cámara no disponible", nl: "Camera niet beschikbaar")

        case .shotsAllDone:
            return T(en: "✓ All {total} photos captured",
                     de: "✓ Alle {total} Fotos aufgenommen",
                     es: "✓ Se han tomado las {total} fotos",
                     nl: "✓ Alle {total} foto's gemaakt")
        case .shotDone:
            return T(en: "✓ Photo {done} of {total} captured — hold your position",
                     de: "✓ Foto {done} von {total} aufgenommen – bleib in Position",
                     es: "✓ Foto {done} de {total} tomada: mantén la posición",
                     nl: "✓ Foto {done} van {total} gemaakt — blijf op je plek")
        case .shotCapturing:
            return T(en: "Hold steady — capturing photo {number} of {total}…",
                     de: "Ruhig halten – Foto {number} von {total} wird aufgenommen…",
                     es: "Mantén el teléfono quieto: tomando la foto {number} de {total}…",
                     nl: "Stil houden — foto {number} van {total} wordt gemaakt…")
        case .shotGetReady:
            return T(en: "Get into position for photo {number} of {total}",
                     de: "Geh in Position für Foto {number} von {total}",
                     es: "Colócate en posición para la foto {number} de {total}",
                     nl: "Ga in positie voor foto {number} van {total}")

        case .sidePhotosDone:
            return T(en: "Side photos done — move to the FRONT of the person, behind the monitor",
                     de: "Seitenfotos fertig – geh VOR die Person, hinter den Monitor",
                     es: "Fotos laterales listas: ponte DELANTE de la persona, detrás del monitor",
                     nl: "Zijfoto's klaar — ga VOOR de persoon staan, achter de monitor")
        case .frontMove:
            return T(en: "Move to the FRONT of the person, behind the monitor",
                     de: "Geh VOR die Person, hinter den Monitor",
                     es: "Ponte DELANTE de la persona, detrás del monitor",
                     nl: "Ga VOOR de persoon staan, achter de monitor")
        case .frontShowBody:
            return T(en: "Show the person's face, shoulders and hands",
                     de: "Gesicht, Schultern und Hände der Person müssen zu sehen sein",
                     es: "Encuadra la cara, los hombros y las manos de la persona",
                     nl: "Breng het gezicht, de schouders en de handen van de persoon in beeld")
        case .frontStraighten:
            return T(en: "Straighten the phone — it's rotated",
                     de: "Halte das Handy gerade – es ist verdreht",
                     es: "Endereza el teléfono: está girado",
                     nl: "Houd de telefoon recht — hij is gedraaid")
        case .frontHoldPhoneStill:
            return T(en: "Hold the phone still", de: "Halte das Handy still",
                     es: "Mantén el teléfono quieto", nl: "Houd de telefoon stil")
        case .frontCapturing:
            return T(en: "Hold steady — capturing front photo…",
                     de: "Ruhig halten – Foto von vorne wird aufgenommen…",
                     es: "Mantén el teléfono quieto: tomando la foto frontal…",
                     nl: "Stil houden — foto van voren wordt gemaakt…")

        case .guideLowerPhone:
            return T(en: "▼  Lower phone", de: "▼  Handy senken",
                     es: "▼  Baja el teléfono", nl: "▼  Telefoon lager")
        case .guideRaisePhone:
            return T(en: "▲  Raise phone", de: "▲  Handy anheben",
                     es: "▲  Sube el teléfono", nl: "▲  Telefoon hoger")
        case .guideHeightOk:
            return T(en: "✓  Height OK", de: "✓  Höhe OK", es: "✓  Altura OK", nl: "✓  Hoogte OK")

        case .frontHoldLower:
            return T(en: "Hold the phone lower, level with the person's shoulders",
                     de: "Halte das Handy tiefer, auf Schulterhöhe der Person",
                     es: "Baja el teléfono a la altura de los hombros de la persona",
                     nl: "Houd de telefoon lager, op schouderhoogte van de persoon")
        case .chipFrontHoldLower:
            return T(en: "● Front  Hold phone lower", de: "● Vorne  Handy tiefer halten",
                     es: "● Frontal  Baja el teléfono", nl: "● Voorkant  Telefoon lager houden")
        case .switchCamera:
            return T(en: "Switch camera", de: "Kamera wechseln",
                     es: "Cambiar de cámara", nl: "Camera wisselen")
        case .frontGuideTitle:
            return T(en: "Front Photo Guide", de: "Anleitung Frontfoto",
                     es: "Guía de la foto frontal", nl: "Gids voor de frontfoto")
        case .frontGuideWorker:
            return T(en: "A (Worker)", de: "A (Mitarbeiter)",
                     es: "A (Trabajador)", nl: "A (Medewerker)")
        case .frontGuideA1:
            return T(en: "Stay seated exactly as you normally work", de: "Bleib so sitzen, wie du normalerweise arbeitest",
                     es: "Sigue sentado tal como trabajas normalmente", nl: "Blijf zitten zoals je normaal werkt")
        case .frontGuideA2:
            return T(en: "Face the screen with your hands on the keyboard", de: "Schau zum Bildschirm, die Hände auf der Tastatur",
                     es: "Mira la pantalla con las manos sobre el teclado", nl: "Kijk naar het scherm met je handen op het toetsenbord")
        case .frontGuideA3:
            return T(en: "Keep your shoulders relaxed", de: "Halte die Schultern locker",
                     es: "Mantén los hombros relajados", nl: "Houd je schouders ontspannen")
        case .frontGuideA4:
            return T(en: "Look at the screen naturally", de: "Schau ganz natürlich auf den Bildschirm",
                     es: "Mira la pantalla con naturalidad", nl: "Kijk op een natuurlijke manier naar het scherm")
        case .frontGuidePhotographer:
            return T(en: "B (Photographer)", de: "B (Fotograf)",
                     es: "B (Fotógrafo)", nl: "B (Fotograaf)")
        case .frontGuideB1:
            return T(en: "Stand behind the monitor, facing the worker", de: "Stell dich hinter den Monitor, mit Blick zur Person",
                     es: "Colócate detrás del monitor, frente al trabajador", nl: "Ga achter de monitor staan, met je gezicht naar de medewerker")
        case .frontGuideB2:
            return T(en: "Hold the phone upright, level with the worker's shoulders", de: "Halte das Handy aufrecht, auf Schulterhöhe der Person",
                     es: "Sujeta el teléfono en vertical, a la altura de los hombros del trabajador", nl: "Houd de telefoon rechtop, op schouderhoogte van de medewerker")
        case .frontGuideB3:
            return T(en: "Make sure the head, shoulders and both hands are visible", de: "Achte darauf, dass Kopf, Schultern und beide Hände zu sehen sind",
                     es: "Asegúrate de que se vean la cabeza, los hombros y ambas manos", nl: "Zorg dat het hoofd, de schouders en beide handen zichtbaar zijn")
        case .frontGuideB4:
            return T(en: "Hold the phone still until the photo is taken", de: "Halte das Handy still, bis das Foto aufgenommen ist",
                     es: "Mantén el teléfono quieto hasta que se tome la foto", nl: "Houd de telefoon stil tot de foto is gemaakt")
        case .frontGuideContinue:
            return T(en: "Continue", de: "Weiter",
                     es: "Continuar", nl: "Doorgaan")
        }
    }

    /// Text for `key` in `language` (normalized or not), with each `{name}`
    /// placeholder replaced by its value from `args`.
    static func get(_ key: Key, _ language: String, _ args: [String: CustomStringConvertible] = [:]) -> String {
        let t = entry(key)
        var text: String
        switch normalize(language) {
        case "de": text = t.de
        case "es": text = t.es
        case "nl": text = t.nl
        default: text = t.en
        }
        for (name, value) in args {
            text = text.replacingOccurrences(of: "{\(name)}", with: value.description)
        }
        return text
    }
}
