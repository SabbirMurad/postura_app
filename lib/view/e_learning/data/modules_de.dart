import 'package:posture_detector_app/models/quiz/quiz_module.dart';

QuizModule m1De() => QuizModule(
  id: 1,
  title: "Grundlagen der Ergonomie und Risiken",
  objectives: [
    "Verstehen, was Ergonomie ist und warum sie bei der Bildschirmarbeit wichtig ist.",
    "Die wichtigsten muskuloskelettalen Risikofaktoren im Buero erkennen.",
    "Verstehen, wie Arbeitsplatznormen eine gute Einrichtung unterstuetzen.",
  ],
  content:
      "Ergonomie ist die Wissenschaft, die Arbeit an den Menschen anzupassen, "
      "anstatt den Menschen zu zwingen, sich an schlechte Bedingungen "
      "anzupassen. In einer Bueroumgebung kann eine schlechte "
      "Arbeitsplatzgestaltung zu Beschwerden und langfristigen Verletzungen "
      "fuehren, die als Muskel-Skelett-Erkrankungen (MSE) bekannt sind.\n\n"
      "Die wichtigsten Risikofaktoren bei der Bildschirmarbeit sind "
      "Zwangshaltungen, statische Belastungen und repetitive Bewegungen. "
      "Internationale Normen wie ISO 9241-5 geben Hinweise zur "
      "Arbeitsplatzgestaltung und Koerperhaltung. Instrumente wie "
      "Beschwerderfrageboegen und Haltungschecklisten helfen Unternehmen, "
      "Probleme zu erkennen und Verbesserungen nachzuverfolgen.",
  quizzes: [
    QuizItemModel(
      question: "Was ist das Hauptziel der Ergonomie?",
      options: [
        "Menschen um jeden Preis schneller arbeiten lassen",
        "Arbeit und Werkzeuge an die menschlichen Grenzen und den Komfort anpassen",
        "Arbeitnehmer durch Automatisierung ersetzen",
        "Sich ausschliesslich auf Produktivitaet konzentrieren",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Was ist ein typischer Risikofaktor bei der Bildschirmarbeit?",
      options: [
        "Kurze E-Mails",
        "Lange Zeitraeume mit gebeugtem Nacken beim Blick auf den Bildschirm",
        "Wasser trinken",
        "Einen Stuhl mit Rueckenstuetze verwenden",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Womit befassen sich Arbeitsplatznormen (wie ISO 9241-5) hauptsaechlich?",
      options: [
        "Brandschutz",
        "Arbeitsplatzgestaltung und Koerperhaltung bei Bildschirmarbeit",
        "Gehaltsabrechnungssysteme",
        "Ausschliesslich Luftqualitaet",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Warum verwenden Unternehmen Beschwerderfrageboegen?",
      options: [
        "Zur Dekoration",
        "Um Probleme zu erfassen und Veraenderungen im Zeitverlauf zu verfolgen",
        "Um die Internetnutzung zu ueberwachen",
        "Um die medizinische Versorgung zu ersetzen",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Welche Aussage ueber MSE bei Bueroangestellten ist am zutreffendsten?",
      options: [
        "Sie betreffen selten Nacken oder Schultern",
        "Nur schweres Heben kann sie verursachen",
        "Schlechte Arbeitsplatzeinrichtung und langes statisches Sitzen koennen zu Nacken- und Armproblemen beitragen",
        "Sie koennen durch Arbeitsplatzaenderungen nicht beeinflusst werden",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "Welche Aussage beschreibt eine Muskel-Skelett-Erkrankung (MSE) bei Bueroarbeit am besten?",
      options: [
        "Eine Erkrankung, die nur die Fuesse betrifft",
        "Eine Erkrankung, die nur in der Schwerindustrie auftritt",
        "Eine Beschwerde oder Verletzung, die Muskeln, Sehnen oder Gelenke betrifft und oft mit der Arbeitshaltung zusammenhaengt",
        "Eine Erkrankung, die nur durch Sport verursacht wird",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "Welche Kombination von Risikofaktoren ist typisch fuer Bildschirmarbeit?",
      options: [
        "Starker Laerm und Kontakt mit Chemikalien",
        "Zwangshaltungen, statische Belastungen und repetitive Bewegungen",
        "Hohe Temperaturen und schlechte Beleuchtung",
        "Nur kurze E-Mails und leichtes Tippen",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Warum ist es wichtig, die Arbeit an den Menschen anzupassen?",
      options: [
        "Es garantiert, dass niemand jemals Schmerzen haben wird",
        "Es erlaubt den Menschen, laenger ohne Pausen zu arbeiten",
        "Es reduziert die Belastung und hilft, MSE langfristig vorzubeugen",
        "Es konzentriert sich nur auf die Erhoehung der Tippgeschwindigkeit",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "Welche Rolle spielen Arbeitsplatznormen wie ISO 9241-5 in Unternehmen?",
      options: [
        "Sie legen fest, wie viele E-Mails Mitarbeiter senden sollen",
        "Sie bestimmen das genaue Gehalt fuer Bueroangestellte",
        "Sie geben Hinweise zur Arbeitsplatzgestaltung und zu Haltungsanforderungen",
        "Sie gelten nur fuer Fabrikmaschinen",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "Wie koennen Beschwerderfrageboegen und Haltungschecklisten Ergonomieprogramme unterstuetzen?",
      options: [
        "Durch Ueberwachung der Internetnutzung und Bildschirmzeit",
        "Durch Erkennung von Problemen und Ueberwachung von Veraenderungen nach Massnahmen",
        "Durch Ersetzung aller aerztlichen Konsultationen",
        "Durch ausschliessliche Messung von Produktivitaet und Leistung",
      ],
      answer: 1,
    ),
  ],
);

QuizModule m2De() => QuizModule(
  id: 2,
  title: "Sitzhaltung und Ausrichtung",
  objectives: [
    "Die wichtigsten Elemente einer neutralen Sitzhaltung erlernen.",
    "Haeufige Sitzfehler erkennen und einfache Korrekturen vornehmen.",
    "Grundlegende Nacken- und obere Rueckenaktivierungsuebungen durchfuehren.",
  ],
  content:
      "Eine neutrale Sitzhaltung reduziert die Belastung von Muskeln und "
      "Gelenken. Die Fuesse sollten flach auf dem Boden oder einer "
      "Fussstuetze stehen, die Knie auf Huefthoehe oder leicht darunter "
      "sein und der untere Ruecken gestuetzt werden.\n\n"
      "Ein haeufiger Fehler ist die vorgestreckte Kopfhaltung, die die "
      "Nackenbelastung erhoeht. Einfache Uebungen wie Kinneinziehen und "
      "Schulterblattzusammenfuehren helfen, die richtige Ausrichtung "
      "wiederherzustellen.",
  quizzes: [
    QuizItemModel(
      question: "Wo sollten sich Ihre Fuesse in einer neutralen Sitzhaltung befinden?",
      options: [
        "Frei ueber dem Boden haengend",
        "Flach auf dem Boden oder auf einer stabilen Fussstuetze",
        "Fest unter dem Stuhl verschraenkt",
        "Auf den Stuhlrollen",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Die vorgestreckte Kopfhaltung erhoeht vor allem die Belastung in welchem Bereich?",
      options: ["Zehen", "Nacken und oberer Ruecken", "Knoechel", "Hueften"],
      answer: 1,
    ),
    QuizItemModel(
      question: "Was ist eine wichtige Funktion der Rueckenlehne?",
      options: [
        "Die Schultern nach vorne druecken",
        "Die natuerliche Kruemmung im unteren Ruecken stuetzen",
        "Sie weit nach vorne gelehnt halten",
        "Jede Bewegung blockieren",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Welche Muskeln werden beim Kinneinziehen hauptsaechlich angesprochen?",
      options: [
        "Tiefe Nackenstabilisatoren",
        "Wadenmuskeln",
        "Handmuskeln",
        "Bauchmuskeln",
      ],
      answer: 0,
    ),
    QuizItemModel(
      question: "Was koennen Sie verwenden, wenn Ihre Fuesse den Boden nicht erreichen?",
      options: [
        "Schuhe mit hoeheren Absaetzen",
        "Eine stabile Fussstuetze",
        "Keine Aenderung notwendig",
        "Die Fuesse auf die Stuhlrollen stellen",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Welche Beschreibung passt am besten zu einer \"neutralen Sitzhaltung\"?",
      options: [
        "Fuesse baumeln, Knie viel hoeher als die Hueften",
        "Fuesse flach oder auf einer Fussstuetze, Knie etwa auf Huefthoehe oder leicht darunter, Ruecken gestuetzt",
        "Auf der Stuhlkante sitzen ohne Rueckenkontakt",
        "Beine fest unter dem Stuhl verschraenkt",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Was ist eine praktische Methode, um die vorgestreckte Kopfhaltung am Schreibtisch zu reduzieren?",
      options: [
        "Den Bildschirm weiter weg stellen und nach vorne sacken",
        "Den Ruecken staendig von der Rueckenlehne fernhalten",
        "Die Rueckenlehne nutzen, den Stuhl naeher an den Schreibtisch ziehen und den Bildschirm in angenehme Sichtweite bringen",
        "Beim Tippen auf den Schoss schauen",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "Welches Anzeichen deutet darauf hin, dass Ihr Stuhl den unteren Ruecken nicht richtig stuetzt?",
      options: [
        "Sie fuehlen sich im unteren Ruecken stabil und gestuetzt",
        "Sie koennen die natuerliche Kruemmung im unteren Ruecken muehelos beibehalten",
        "Sie spueren regelmaessig, dass sich Ihr unterer Ruecken rundet und muede oder schmerzend wird",
        "Ihre Fuesse beruehren den Boden",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "Was ist der Hauptzweck des Schulterblattzusammenfuehrens in Modul 2?",
      options: [
        "Die Wadenmuskeln staerken",
        "Die Schulterspannung und Steifheit erhoehen",
        "Gerundete Schultern korrigieren und die obere Rueckenmuskulatur aktivieren",
        "Finger und Handgelenke dehnen",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "Wann koennte eine Fussstuetze besonders hilfreich sein?",
      options: [
        "Wenn Ihre Fuesse bereits bequem auf dem Boden ruhen",
        "Wenn Sie auf Ihren Fuessen sitzen moechten",
        "Wenn Ihr Stuhl nicht tief genug eingestellt werden kann und Ihre Fuesse den Boden nicht erreichen",
        "Wenn Sie sich weit nach vorne lehnen moechten",
      ],
      answer: 2,
    ),
  ],
);

QuizModule m3De() => QuizModule(
  id: 3,
  title: "Bildschirm, Tastatur und Maus",
  objectives: [
    "Bildschirme positionieren, um Augen- und Nackenbelastung zu reduzieren.",
    "Tastatur und Maus einstellen, um Schulter- und Handgelenkbelastung zu verringern.",
    "Einfache Regeln fuer einen oder zwei Bildschirme anwenden.",
  ],
  content:
      "Die korrekte Positionierung der Geraete ist entscheidend fuer den "
      "Komfort. Die Oberkante des Monitors sollte auf Augenhoehe oder "
      "leicht darunter sein und etwa eine Armlaenge entfernt stehen.\n\n"
      "Tastatur und Maus sollten koerpernah auf Ellbogenhoehe platziert "
      "werden, damit die Schultern entspannt bleiben und die Handgelenke "
      "gerade sind.",
  quizzes: [
    QuizItemModel(
      question: "Wo sollte sich die Oberkante des Hauptbildschirms fuer die meisten Benutzer befinden?",
      options: [
        "Deutlich ueber Augenhoehe",
        "Auf oder leicht unter Augenhoehe",
        "Auf Kniehoehe",
        "Auf dem Boden",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Was ist ein typischer Betrachtungsabstand zur Reduzierung der Belastung?",
      options: [
        "Etwa 10 cm",
        "Etwa eine Armlaenge entfernt",
        "Etwa 3 Meter entfernt",
        "Die Nase beruehrend",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Wie sollten die Handgelenke beim Tippen oder bei der Mausbenutzung positioniert sein?",
      options: [
        "Stark nach oben gebeugt",
        "Gerade und in einer Linie mit den Unterarmen gehalten",
        "Nur auf der Schreibtischkante ruhend",
        "Stark nach aussen gedreht",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Wenn Sie hauptsaechlich einen Bildschirm verwenden, wo sollte er platziert werden?",
      options: [
        "Weit zur Seite",
        "Direkt vor Ihnen",
        "Hinter Ihnen",
        "Auf dem Boden",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Was ist ein Anzeichen dafuer, dass die Maus zu weit entfernt sein koennte?",
      options: [
        "Sie koennen den Arm bequem an der Seite ablegen",
        "Sie muessen greifen und die Schulter anheben, um sie zu benutzen",
        "Sie koennen den Cursor nicht sehen",
        "Sie tippen schneller",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Was kann passieren, wenn der Monitor laengere Zeit zu tief platziert ist?",
      options: [
        "Nur Augenbelastung, niemals Nackenprobleme",
        "Der Benutzer kann eine vorgestreckte Kopfhaltung und Nackenbeschwerden entwickeln",
        "Der Benutzer wird immer perfekt gerade sitzen",
        "Es beeinflusst nur die Tippgeschwindigkeit",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Wenn Ihre Maus zu weit vom Koerper entfernt platziert ist, welche Auswirkung ist wahrscheinlich?",
      options: [
        "Ihre Schulter und Ihr Arm koennen sich mehr entspannen",
        "Sie muessen Ihren Arm nie bewegen",
        "Sie muessen moeglicherweise greifen und die Schulter anheben, was die Spannung erhoeht",
        "Es aendert nur die Bildschirmhelligkeit",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "Wo ist die ideale Position fuer die Tastatur relativ zu Ihren Ellbogen?",
      options: [
        "Deutlich hoeher als Ellbogenhoehe",
        "Deutlich niedriger als Ellbogenhoehe",
        "Etwa auf Ellbogenhoehe, damit die Unterarme ungefaehr horizontal bleiben koennen",
        "Direkt auf dem Schoss mit gebeugten Handgelenken",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "Wie ist die beste Platzierung bei gleichmaessiger Nutzung von zwei Bildschirmen?",
      options: [
        "Einer direkt davor, einer dahinter",
        "Beide Bildschirme mittig vor Ihnen, in einer leichten Kurve, die Sie durch Augen- oder Stuhlbewegung ueberblicken koennen",
        "Einer sehr hoch, einer sehr tief",
        "Einer auf dem Boden, einer an der Wand",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Warum ist es wichtig, die Handgelenke beim Tippen oder bei der Mausbenutzung gerade zu halten?",
      options: [
        "Es sieht nur auf Fotos besser aus",
        "Es reduziert die Belastung von Handgelenksehnen und -nerven",
        "Es macht die Tastatur ueberfluessig",
        "Es verhindert alle Arten von Augenbelastung",
      ],
      answer: 1,
    ),
  ],
);

QuizModule m4De() => QuizModule(
  id: 4,
  title: "Licht, Laerm und Raumklima",
  objectives: [
    "Beleuchtung anpassen, um Blendung und Augenmuedigkeit zu reduzieren.",
    "Grundlegende Komfortbereiche fuer Temperatur und Luft verstehen.",
    "Mikropausen zur Bewaeltigung von Muedigkeit nutzen.",
  ],
  content:
      "Beleuchtung, Temperatur und Belueftung beeinflussen alle den "
      "Komfort. Bildschirme sollten senkrecht zu Fenstern positioniert "
      "werden, um Blendung zu reduzieren.\n\n"
      "Mikropausen von 20-60 Sekunden alle 20-30 Minuten reduzieren "
      "Beschwerden, ohne die Produktivitaet zu verringern.",
  quizzes: [
    QuizItemModel(
      question: "Wie koennen Sie Bildschirmblendung durch ein Fenster reduzieren?",
      options: [
        "Den Bildschirm direkt vor das Fenster stellen",
        "Den Bildschirm senkrecht zum Fenster positionieren",
        "Alle Lichter ausschalten",
        "Die Anwendung schliessen",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Warum sind extreme Temperaturen am Arbeitsplatz problematisch?",
      options: [
        "Sie verbessern die Aufmerksamkeit",
        "Sie erhoehen Unbehagen und Muedigkeit",
        "Sie betreffen nur Computer",
        "Sie verhindern MSE",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Was ist eine Mikropause?",
      options: [
        "Dreissig Minuten Computerspiele",
        "Eine kurze Pause, um sich zu bewegen oder vom Bildschirm wegzuschauen",
        "Ein ganzer freier Tag",
        "Ein Mittagsmeeting",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Gute Buerobeleuchtung sollte sein:",
      options: [
        "Sehr hell und direkt in die Augen scheinend",
        "Gleichmaessig, blendfrei und zum Lesen ausreichend",
        "Voellig dunkel",
        "Flackernd",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Welche ist eine einfache Mikropausenaktivitaet?",
      options: [
        "Voellig stillstehen",
        "Aufstehen, Schultern kreisen und kurz die Handgelenke dehnen",
        "Die Luft anhalten",
        "Schneller tippen",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Was ist eine haeufige Folge starker Blendung auf Ihrem Bildschirm?",
      options: [
        "Verbesserte Konzentration und Komfort",
        "Reduzierte Augenbelastung und Kopfschmerzen",
        "Erhoehte Augenbelastung, moegliche Kopfschmerzen und Schwierigkeiten beim Lesen",
        "Keine Auswirkungen auf die Benutzer",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "Wie koennen Sie den Kontrast zwischen einem hellen Fenster und einem dunkleren Bildschirm reduzieren?",
      options: [
        "Den Bildschirm direkt vor das Fenster stellen",
        "Alle Lichter ausschalten und zum Fenster schauen",
        "Den Bildschirm senkrecht zum Fenster positionieren und Jalousien oder Vorhaenge anpassen",
        "Nur die Bildschirmhelligkeit auf Maximum erhoehen",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "Warum werden regelmaessige Mikropausen waehrend der Bildschirmarbeit empfohlen?",
      options: [
        "Sie reduzieren die Produktivitaet erheblich",
        "Sie helfen, Beschwerden und Muedigkeit zu reduzieren, ohne die Gesamtproduktivitaet zu beeintraechtigen",
        "Sie sind nur fuer Sportler notwendig",
        "Sie aendern nur die Bildschirmaufloesung",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Welche Aussage ueber Temperatur und Konzentration ist am zutreffendsten?",
      options: [
        "Extrem heisse oder kalte Umgebungen haben keinen Einfluss auf die Konzentration",
        "Sehr kalte Umgebungen verbessern immer die Konzentration",
        "Angenehme Temperaturbereiche unterstuetzen die Konzentration, waehrend Extreme die Muedigkeit erhoehen koennen",
        "Nur der Laermpegel ist fuer die Konzentration relevant",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "Was ist ein Beispiel fuer eine einfache Mikropause waehrend der Bildschirmarbeit?",
      options: [
        "4 Stunden ohne Bewegung arbeiten",
        "Fuer 20-30 Sekunden aufstehen, die Schultern kreisen und auf einen entfernten Gegenstand schauen",
        "Beim Tippen die Luft anhalten",
        "Nur die Augen schliessen, ohne sich zu bewegen",
      ],
      answer: 1,
    ),
  ],
);

QuizModule m5De() => QuizModule(
  id: 5,
  title: "Lasthandhabung und Heben",
  objectives: [
    "Sichere Hebeprinzipien auf Buerotaetigkeiten anwenden.",
    "Wissen, wann man um Hilfe bitten oder Hilfsmittel verwenden sollte.",
    "Verstehen, wie die Position der Last die Rueckenbelastung beeinflusst.",
  ],
  content:
      "Auch im Buero kann das Heben Risiken bergen. Halten Sie Lasten "
      "koerpernah, beugen Sie Hueften und Knie und vermeiden Sie "
      "Verdrehungen beim Tragen von Gewichten.\n\n"
      "Verwenden Sie Transportwagen oder bitten Sie bei schweren oder "
      "sperrigen Gegenstaenden um Hilfe.",
  quizzes: [
    QuizItemModel(
      question: "Wo sollte sich die Last beim Heben befinden?",
      options: [
        "Weit vom Koerper entfernt",
        "So nah wie moeglich am Koerper",
        "Ueber dem Kopf",
        "Auf einem ausgestreckten Arm",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Welche Bewegung sollte beim Heben vermieden werden?",
      options: [
        "Sich mit den Fuessen drehen",
        "Den Ruecken verdrehen, waehrend man eine Last haelt",
        "Atmen",
        "Beide Haende benutzen",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Wie koennen Sie die Rueckenbelastung beim Heben verringern?",
      options: [
        "Nur in der Taille beugen",
        "Hueften und Knie beugen und den Ruecken moeglichst gerade halten",
        "Die Luft anhalten",
        "Schnell mit ruckartiger Bewegung heben",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Wann ist es besser, Hilfe oder ein Hilfsmittel zu holen?",
      options: [
        "Bei schweren oder sperrigen Gegenstaenden",
        "Fuer einen Kugelschreiber",
        "Fuer ein Blatt Papier",
        "Niemals",
      ],
      answer: 0,
    ),
    QuizItemModel(
      question: "Welche Aussage ueber das Heben bei Buerotaetigkeiten ist richtig?",
      options: [
        "Es gibt nie ein Heberisiko",
        "Gelegentliches unguenstiges Heben kann dennoch zu Rueckenproblemen beitragen",
        "Nur Fabrikarbeit ist relevant",
        "Nur das Sitzen ist wichtig",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Warum ist es so wichtig, eine Last beim Heben koerpernah zu halten?",
      options: [
        "Es macht die Last schwerer",
        "Es reduziert die Belastung von Ruecken und Wirbelsaeule",
        "Es hat keine Auswirkung auf den Koerper",
        "Es hilft nur beim Gleichgewicht, nicht bei der Belastung",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Was ist die sicherste Art, sich beim Tragen eines schweren Gegenstands zu drehen?",
      options: [
        "Den Ruecken verdrehen, waehrend die Fuesse stillstehen",
        "Sich nach vorne beugen und nur die Schultern drehen",
        "Die Fuesse bewegen, um den gesamten Koerper zusammen mit der Last zu drehen",
        "Sich beim Drehen so weit wie moeglich zuruecklehnen",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "Welche Bewegungsstrategie ist beim Heben vom Boden besser?",
      options: [
        "Hauptsaechlich in der Taille beugen mit gerundetem Ruecken",
        "Hueften und Knie beugen und den Ruecken moeglichst gerade halten",
        "Die Beine gerade halten und nur mit den Armen ziehen",
        "Springen und die Last in der Luft fangen",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Wann ist es im Buero am sinnvollsten, einen Transportwagen zu benutzen oder um Hilfe zu bitten?",
      options: [
        "Nur wenn man Lust hat, die Arbeit zu teilen",
        "Bei schweren, sperrigen oder unhandlichen Gegenstaenden, die schwer zu halten sind",
        "Niemals, da Buerolasten immer sicher sind",
        "Nur fuer sehr kleine Gegenstaende",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Welche Situation erhoeht das Risiko einer Rueckenbelastung beim Heben im Buero?",
      options: [
        "Einen sehr leichten Ordner mit guter Haltung heben",
        "Gelegentlich eine schwere Kiste mit schlechter Technik heben",
        "Einen Kugelschreiber in der Tasche tragen",
        "Eine leichte Tastatur mit beiden Haenden halten",
      ],
      answer: 1,
    ),
  ],
);

QuizModule m6De() => QuizModule(
  id: 6,
  title: "Hybrides Arbeiten und Homeoffice",
  objectives: [
    "Ergonomische Prinzipien zu Hause oder bei hybrider Arbeit anwenden.",
    "Langes Sitzen bei der Arbeit im Homeoffice reduzieren.",
    "Einfache Regeln fuer Laptops und Telefone anwenden.",
  ],
  content:
      "Die Arbeit im Homeoffice erfordert die gleichen ergonomischen "
      "Prinzipien wie die Bueroarbeit. Laptops sollten erhoeht und mit "
      "externen Eingabegeraeten verwendet werden.\n\n"
      "Stehen waehrend Telefonaten und Vermeidung von laengerer "
      "Nackenbeugung beim Telefonieren reduziert die Belastung.",
  quizzes: [
    QuizItemModel(
      question: "Was ist das Ziel bezueglich Ergonomie zu Hause?",
      options: [
        "Ergonomie ignorieren",
        "Die gleichen grundlegenden Einrichtungsprinzipien wie im Buero anwenden",
        "Nur vom Bett aus arbeiten",
        "Im Dunkeln arbeiten",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Eine einfache Methode, langes Sitzen zu reduzieren, ist:",
      options: [
        "Niemals bei Anrufen aufstehen",
        "Bei einigen Anrufen aufstehen oder umhergehen",
        "Den Stuhl feststellen",
        "Pausen vermeiden",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Welche Option ist fuer die Laptopnutzung besser?",
      options: [
        "Ihn stundenlang auf dem Schoss halten",
        "Ihn erhoehen und eine externe Tastatur und Maus verwenden",
        "Ihn im Liegen auf der Seite verwenden",
        "Ihn ueber dem Kopf halten",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Warum sind haeufige Haltungswechsel bei der Arbeit im Homeoffice hilfreich?",
      options: [
        "Sie erhoehen die Beschwerden",
        "Sie reduzieren Steifheit und unterstuetzen die Durchblutung",
        "Sie unterbrechen nur die Konzentration",
        "Sie beschaedigen den Stuhl",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Welches Verhalten erhoeht die Nackenbelastung bei der Telefonnutzung?",
      options: [
        "Das Telefon auf Augenhoehe bringen",
        "Laengere Zeit mit gebeugtem Nacken auf das Telefon schauen",
        "Kurze Pausen einlegen",
        "Ein Headset verwenden",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Warum wird laengeres Arbeiten vom Sofa oder Bett aus normalerweise nicht empfohlen?",
      options: [
        "Es verbessert immer die Haltung",
        "Es ist zu ruhig",
        "Es fuehrt oft zu einer schlechten Ruecken- und Nackenhaltung ohne ausreichende Unterstuetzung",
        "Es verhindert die Nutzung eines Laptops",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "Welche Kombination ist fuer laengere Laptopnutzung zu Hause am besten?",
      options: [
        "Laptop auf dem Schoss, keine Stuetze, keine externen Geraete",
        "Laptop auf einem niedrigen Tisch mit Bildschirm sehr weit entfernt",
        "Laptop auf Augenhoehe erhoeht plus externe Tastatur und Maus",
        "Laptop auf Bodenhoehe, darueber stehend",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "Was ist eine praktische Methode, um langes Sitzen bei der Arbeit im Homeoffice zu reduzieren?",
      options: [
        "Alle Pausen vermeiden, um schneller fertig zu werden",
        "Bei einigen Anrufen und Online-Meetings aufstehen oder umhergehen",
        "Nur vom Bett aus arbeiten",
        "Den Stuhl feststellen und sich nie bewegen",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Welches Verhalten erhoeht das Risiko eines \"Handynackens\"?",
      options: [
        "Das Telefon naeher auf Augenhoehe bringen",
        "Ein Headset verwenden, um die Haende frei zu haben",
        "Laengere Zeit mit gebeugtem Nacken auf das Telefon schauen",
        "Kurze Pausen vom Telefon einlegen",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "Warum gelten die gleichen ergonomischen Prinzipien zu Hause und im Buero?",
      options: [
        "Weil Ihr Koerper und Ihre Gelenke an beiden Orten gleich sind",
        "Weil Buerostuehle zu Hause verboten sind",
        "Weil Laptops nur zu Hause funktionieren",
        "Weil die Haltung nur im Buero wichtig ist",
      ],
      answer: 0,
    ),
  ],
);

QuizModule m7De() => QuizModule(
  id: 7,
  title: "Taegliche Praeventionsroutine",
  objectives: [
    "Einfache Uebungen und Mikropausen erlernen.",
    "Grundlegende Dosierung verstehen (wie lange und wie oft).",
    "Uebungen mit Nacken-, Schulter- und Lendenwirbelsaeulenbeschwerden verknuepfen.",
  ],
  content:
      "Taegliche sanfte Bewegung beugt Steifheit vor. Nackendehnungen, "
      "Streckuebungen fuer den oberen Ruecken und Handgelenkdehnungen "
      "sollten regelmaessig durchgefuehrt werden.\n\n"
      "Halten Sie Dehnungen 10-30 Sekunden, wiederholen Sie 2-3 Mal und "
      "hoeren Sie auf, wenn scharfe Schmerzen auftreten.",
  quizzes: [
    QuizItemModel(
      question: "Warum koennen gezielte Uebungen Bueroangestellten helfen?",
      options: [
        "Sie bauen nur Muskelmasse auf",
        "Sie koennen bei regelmaessiger Durchfuehrung Nacken- und Schulterschmerzen reduzieren",
        "Sie machen die Anpassung des Arbeitsplatzes ueberfluessig",
        "Sie ersetzen den Schlaf",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Eine typische Haltezeit fuer eine sanfte Dehnung betraegt:",
      options: [
        "Etwa 1 Sekunde",
        "Etwa 10 bis 30 Sekunden",
        "Etwa 5 Minuten",
        "Etwa 30 Minuten",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Welche davon ist eine einfache Schulteraktivierungsuebung?",
      options: [
        "Die Schultern den ganzen Tag hochziehen",
        "Die Schulterblaetter sanft fuer mehrere Wiederholungen zusammenfuehren",
        "Schwere Taschen tragen",
        "Unter schwerer Last die Schultern hochziehen",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Wann sollte ein Benutzer eine Uebung abbrechen?",
      options: [
        "Wenn der Schmerz stark zunimmt",
        "Wenn es sich besser anfuehlt",
        "Niemals",
        "Erst nach 3 Stunden",
      ],
      answer: 0,
    ),
    QuizItemModel(
      question: "Eine realistische Haeufigkeit fuer Mikropausen waehrend der Bildschirmarbeit ist:",
      options: [
        "Einmal im Monat",
        "Einige Sekunden alle 20 bis 30 Minuten",
        "Einmal im Jahr",
        "Nur im Urlaub",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Was ist das Hauptziel der taeglichen Praeventionsroutine in Modul 7?",
      options: [
        "Alle medizinischen Behandlungen ersetzen",
        "Steifheit sanft reduzieren und Nacken-, Schulter- und Lendenwirbelsuaeulenbeschwerden vorbeugen",
        "Fuer Leistungssport trainieren",
        "Die Anpassung des Arbeitsplatzes vermeiden",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Wie sollten sich Dehnungsuebungen im Allgemeinen anfuehlen?",
      options: [
        "Sehr schmerzhaft, damit man weiss, dass sie wirken",
        "Sanft, mit einem leichten Dehnungsgefuehl, aber ohne scharfe Schmerzen",
        "Voellig muehelos ohne jegliches Empfinden",
        "So intensiv, dass man die Luft anhalten muss",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Wie oft koennen kurze Uebungs- oder Dehnungspausen realistisch in die Bildschirmarbeit integriert werden?",
      options: [
        "Nur einmal im Monat",
        "Nur im Urlaub",
        "Einige Sekunden oder Minuten alle 20-30 Minuten",
        "Nur einmal im Jahr",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "Was sollten Sie tun, wenn der Schmerz waehrend einer Uebung stark zunimmt?",
      options: [
        "Weitermachen und ignorieren",
        "Nur ein wenig langsamer werden",
        "Die Uebung sofort abbrechen und in eine bequeme Position zurueckkehren",
        "Die Intensitaet erhoehen",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "Warum ist es hilfreich, Uebungen mit bestimmten Beschwerden zu verknuepfen (z. B. Nacken- oder Schulterverspannungen)?",
      options: [
        "Es ermoeglicht Ihnen, Uebungen auszuwaehlen, die Ihre eigenen Problembereiche gezielt ansprechen",
        "Es macht Dehnung ueberfluessig",
        "Es erhoeht nur die Komplexitaet ohne Nutzen",
        "Es ersetzt die Anpassung des Arbeitsplatzes vollstaendig",
      ],
      answer: 0,
    ),
  ],
);

QuizModule m8De() => QuizModule(
  id: 8,
  title: "Schmerz verstehen und bei der Arbeit aktiv bleiben",
  objectives: [
    "Verstehen, dass Schmerz nicht immer Gewebeschaden bedeutet.",
    "Angst-Vermeidungs-Denken erkennen und verstehen, warum es das Risiko laengerfristiger Probleme erhoeht.",
    "Prinzipien der gestuften Aktivitaet waehrend der normalen Buerotaetigkeit anwenden.",
    "Wissen, wann zusaetzliche professionelle Unterstuetzung noch sinnvoll ist.",
  ],
  content:
      "Muskuloskelettale Beschwerden am Schreibtisch sind sehr haeufig. "
      "Viele Menschen nehmen an, dass bei Schmerzen das Gewebe geschaedigt "
      "sein muss und Ruhe die einzig sichere Option ist. Die moderne "
      "Schmerzforschung zeigt jedoch ein vollstaendigeres Bild: Schmerz ist "
      "ein Schutzsignal des Nervensystems, das nicht nur vom Zustand des "
      "Gewebes, sondern auch von Stress, Schlaf, frueheren Erfahrungen, "
      "Ueberzeugungen ueber Schmerz und der Menge an Bewegung beeinflusst "
      "wird. Schmerz kann auch ohne ernsthafte Schaedigung auftreten, und "
      "die Schmerzintensitaet entspricht nicht immer dem Ausmass der "
      "Gewebeverletzung. Der Glaube \"Schmerz bedeutet immer Schaden\" "
      "fuehrt oft dazu, dass Menschen die Aktivitaet mehr als noetig "
      "einschraenken, was mit der Zeit zu Steifheit, Verlust des "
      "Vertrauens in Bewegung und einer laengeren Genesung fuehren "
      "kann.\n\n"
      "Angst-Vermeidung ist die Tendenz, Bewegung oder normale "
      "Aktivitaeten zu vermeiden, weil man befuerchtet, dass die "
      "Aktivitaet den Schmerz verstaerkt oder Schaden verursacht. Es ist "
      "eine normale kurzfristige Schutzreaktion, wird aber zum Problem, "
      "wenn sie ueber die akute Phase hinaus anhaelt. Typische "
      "Angst-Vermeidungs-Gedanken sind: \"Ich sollte nichts tun, was "
      "irgendwelche Beschwerden verursacht\", \"wenn ich weiterarbeite, "
      "verschlimmere ich die Verletzung\" und \"ich muss warten, bis der "
      "Schmerz vollstaendig weg ist, bevor ich zu normalen Taetigkeiten "
      "zurueckkehre\". Untersuchungen mit Screening-Instrumenten wie dem "
      "Oerebro-Fragebogen zur muskuloskelettalen Schmerzeinschaetzung "
      "zeigen, dass hohe Angst-Vermeidung und geringe Genesungserwartungen "
      "zu den staerksten Praediktoren dafuer gehoeren, dass kurzfristiger "
      "Schmerz langfristig wird - die Hochrisikogruppe hat deutlich mehr "
      "Krankheitstage und ein wesentlich hoeheres Risiko einer "
      "langfristigen Arbeitsunfaehigkeit als die Niedrigrisikogruppe.\n\n"
      "Statt vollstaendiger Ruhe oder dem Warten auf Schmerzfreiheit ist "
      "gestufte Aktivitaet fuer die meisten schreibtischbedingten "
      "muskuloskelettalen Probleme die wirksamere Strategie: Beginnen Sie "
      "mit einem handhabbaren Mass an Bewegung und Arbeit und steigern Sie "
      "dieses ueber Tage und Wochen schrittweise. Leichte Beschwerden "
      "waehrend der Aktivitaet sind oft normal und bedeuten nicht, dass "
      "ein Schaden entsteht. Teilen Sie die Arbeit in kuerzere Abschnitte "
      "mit haeufigen kurzen Bewegungspausen auf und steigern Sie die Dauer "
      "dann langsam. Konzentrieren Sie sich darauf, die normale Funktion "
      "wiederherzustellen, statt jede Empfindung von Unbehagen zu "
      "beseitigen, und kombinieren Sie dies mit einem gut eingestellten "
      "Arbeitsplatz. Gestufte Aktivitaet hilft, das Nervensystem neu zu "
      "trainieren, das Vertrauen in Bewegung wiederherzustellen und das "
      "Risiko zu verringern, dass das Problem chronisch wird.\n\n"
      "Sie koennen diese Grundsaetze sofort anwenden: Nutzen Sie weiterhin "
      "einen gut eingestellten Arbeitsplatz mit Stuhl, Bildschirm, "
      "Tastatur und Maus in neutraler Position; machen Sie alle 20-30 "
      "Minuten kurze Bewegungspausen, statt sehr lange zu sitzen; "
      "reduzieren Sie bei Beschwerden die Intensitaet oder Dauer der "
      "Taetigkeit, statt ganz aufzuhoeren; kehren Sie schrittweise zu "
      "Ihrem normalen Arbeitspensum zurueck, sobald sich Ihre Toleranz "
      "verbessert; und nutzen Sie die in Ihrem Postura-Programm "
      "empfohlenen einfachen Uebungen als Teil dieses gestuften "
      "Vorgehens.\n\n"
      "Selbstmanagement und gestufte Aktivitaet sind wirkungsvoll, aber "
      "nicht immer ausreichend. Suchen Sie zusaetzliche Unterstuetzung bei "
      "einem Ergonomen, Physiotherapeuten oder der Arbeitsmedizin, wenn "
      "der Schmerz stark ist oder sich schnell verschlimmert, wenn er Sie "
      "trotz gestufter Aktivitaet und Arbeitsplatzverbesserungen an der "
      "normalen Arbeit hindert, wenn Sie neue Symptome wie deutliche "
      "Taubheit, Schwaeche oder in Arme oder Beine ausstrahlende Schmerzen "
      "bemerken, oder wenn Sie bereits seit mehreren Wochen mit wenig "
      "Besserung kaempfen. Es hat sich gezeigt, dass fruehe professionelle "
      "Unterstuetzung fuer Personen mit erhoehtem Risiko fuer "
      "langfristige Probleme im Vergleich zur ueblichen Versorgung "
      "weniger verlorene Arbeitstage zur Folge hat.\n\n"
      "Ein gut eingestellter Arbeitsplatz reduziert die koerperliche "
      "Belastung. Das Verstaendnis von Schmerz und aktiv zu bleiben "
      "verringert das Risiko, dass kurzfristige Beschwerden zu einem "
      "langfristigen Problem werden. Zusammen bilden sie einen "
      "umfassenderen Ansatz zur Vorbeugung muskuloskelettaler "
      "Erkrankungen und unnoetiger Krankheitstage.",
  quizzes: [
    QuizItemModel(
      question: "Was ist die zutreffendste Aussage ueber muskuloskelettale Schmerzen am Schreibtisch?",
      options: [
        "Wenn es wehtut, schaedigen Sie immer das Gewebe",
        "Schmerz ist ein komplexes Signal und bedeutet nicht immer eine Gewebeschaedigung",
        "Schmerz bedeutet immer, dass Sie jede Aktivitaet stoppen sollten",
        "Schmerz entsteht nur durch schlechte Haltung",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Was ist \"Angst-Vermeidung\"?",
      options: [
        "Nur bei schwerem Heben vorsichtig zu sein",
        "Bewegung oder Aktivitaet zu vermeiden, weil man befuerchtet, dass sich der Schmerz verschlimmert oder ein Schaden entsteht",
        "Regelmaessige Dehnpausen einzulegen",
        "Einen ergonomischen Stuhl zu benutzen",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Laut Forschung neigen Menschen mit hoher Angst-Vermeidung und geringen Genesungserwartungen dazu:",
      options: [
        "Genauso viele Krankheitstage zu haben wie andere",
        "Deutlich mehr Krankheitstage und ein hoeheres Risiko fuer langfristige Probleme zu haben",
        "Schneller zu genesen",
        "Keinen Unterschied im Ergebnis zu zeigen",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Was ist der bessere Ansatz bei anhaltenden schreibtischbedingten Beschwerden?",
      options: [
        "Vollstaendige Ruhe, bis der Schmerz bei 0/10 liegt",
        "Nur Uebungen machen, die keinerlei Beschwerden verursachen",
        "Aktivitaet und Bewegung schrittweise steigern, auch wenn leichte Beschwerden auftreten",
        "Jegliche Computerarbeit vermeiden",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "Welcher Gedanke ist hilfreicher fuer die Genesung?",
      options: [
        "\"Ich sollte nichts tun, was irgendwelche Schmerzen verursacht\"",
        "\"Manche Beschwerden waehrend der Aktivitaet sind normal und bedeuten nicht, dass ich mir schade\"",
        "\"Schmerz bedeutet, dass ich mehr Bildgebung und Ruhe brauche\"",
        "\"Ich muss warten, bis ich zu 100% schmerzfrei bin, bevor ich zu normalen Taetigkeiten zurueckkehre\"",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Was ist eine praktische Moeglichkeit, gestufte Aktivitaet bei der Buerotaetigkeit anzuwenden?",
      options: [
        "Ohne jegliche Pausen durch den Schmerz hindurcharbeiten",
        "Die Nutzung von Maus oder Tastatur vollstaendig einstellen",
        "Mit kuerzeren Arbeitsphasen und haeufigen kurzen Bewegungspausen beginnen und dann schrittweise steigern",
        "Nur arbeiten, wenn der Schmerz vollstaendig weg ist",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "Wann ist es weiterhin wichtig, zusaetzliche Hilfe zu suchen (Ergonom, Physiotherapeut oder Arbeitsmedizin)?",
      options: [
        "Nur wenn der Schmerz 9 oder 10 von 10 betraegt",
        "Wenn der Schmerz stark ist, sich verschlimmert oder Sie trotz gestufter Aktivitaet und Arbeitsplatzverbesserungen an normaler Arbeit hindert",
        "Nie - Sie sollten immer allein zurechtkommen",
        "Erst nach 6 Monaten",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Die Kombination aus gut eingestelltem Arbeitsplatz, Schmerzverstaendnis und Aktivbleiben ist wichtig, weil:",
      options: [
        "Sie nur bei der Haltung hilft",
        "Sie sowohl die koerperliche Belastung als auch das Risiko, dass Schmerz langfristig wird, angeht",
        "Sie jegliche professionelle Unterstuetzung ueberfluessig macht",
        "Sie nur fuer Sportler nuetzlich ist",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Welche Aussage beschreibt gestufte Aktivitaet am besten?",
      options: [
        "Zuerst die schwierigste Aktivitaet ausfuehren",
        "Alle Aktivitaeten vermeiden, die irgendeine Empfindung verursachen",
        "Mit einem handhabbaren Aktivitaetsniveau beginnen und es im Laufe der Zeit schrittweise steigern",
        "Nur dehnen, wenn der Schmerz null ist",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "Warum kann das Verstaendnis von Schmerz helfen, langfristige Krankheitstage zu reduzieren?",
      options: [
        "Es hat keinen Einfluss auf Krankheitstage",
        "Es hilft nur Spitzensportlern",
        "Es reduziert unhilfreiches Vermeidungsverhalten und unterstuetzt eine fruehere, sicherere Rueckkehr zur normalen Aktivitaet",
        "Es ersetzt die Notwendigkeit jeglicher Arbeitsplatzverbesserungen",
      ],
      answer: 2,
    ),
  ],
);
