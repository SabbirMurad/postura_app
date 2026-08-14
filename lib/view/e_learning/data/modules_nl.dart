import 'package:posture_detector_app/models/quiz/quiz_module.dart';

QuizModule m1Nl() => QuizModule(
  id: 1,
  title: "Basisergonomie en Risico's",
  objectives: [
    "Begrijpen wat ergonomie is en waarom het belangrijk is voor bureauwerk.",
    "De belangrijkste risicofactoren voor het bewegingsapparaat in kantooromgevingen herkennen.",
    "Begrijpen hoe werkpleknormen bijdragen aan een goede inrichting.",
  ],
  content:
      "Ergonomie is de wetenschap van het aanpassen van werk aan de werknemer, "
      "in plaats van de werknemer te dwingen zich aan te passen aan een slechte "
      "inrichting. In een kantooromgeving kan een slechte werkplekinrichting "
      "bijdragen aan ongemak en langdurig letsel, bekend als "
      "aandoeningen aan het bewegingsapparaat (musculoskeletale aandoeningen, MSA's).\n\n"
      "De belangrijkste risicofactoren voor bureauwerk zijn ongunstige houdingen, "
      "statische belasting en repetitieve bewegingen. Internationale normen zoals "
      "ISO 9241-5 bieden richtlijnen voor de inrichting van werkplekken en "
      "lichaamshouding. Hulpmiddelen zoals klachtenvragenlijsten en "
      "houdingschecklists helpen organisaties problemen te identificeren en "
      "verbeteringen bij te houden.",
  quizzes: [
    QuizItemModel(
      question: "Wat is het belangrijkste doel van ergonomie?",
      options: [
        "Mensen sneller laten werken, ongeacht de kosten",
        "Werk en hulpmiddelen aanpassen aan menselijke grenzen en comfort",
        "Werknemers vervangen door automatisering",
        "Alleen focussen op productiviteit",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Wat is een typische risicofactor bij bureauwerk?",
      options: [
        "Korte e-mails",
        "Langdurig met een gebogen nek naar een scherm kijken",
        "Water drinken",
        "Een stoel met rugsteun gebruiken",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Waar gaan werkpleknormen (zoals ISO 9241-5) voornamelijk over?",
      options: [
        "Brandveiligheid",
        "Werkplekinrichting en houding voor beeldschermwerk",
        "Salarissystemen",
        "Uitsluitend luchtkwaliteit",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Waarom gebruiken organisaties klachtenvragenlijsten?",
      options: [
        "Voor de sier",
        "Om problemen in kaart te brengen en veranderingen in de tijd te volgen",
        "Om internetgebruik te monitoren",
        "Om medische zorg te vervangen",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Welke uitspraak over MSA's bij kantoormedewerkers is het meest accuraat?",
      options: [
        "Ze treffen zelden de nek of schouders",
        "Alleen zwaar tillen kan ze veroorzaken",
        "Een slechte werkplekinrichting en langdurig statisch zitten kunnen bijdragen aan nek- en bovenste ledematenklachten",
        "Ze kunnen niet beïnvloed worden door werkplekaanpassingen",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "Welke uitspraak beschrijft een aandoening aan het bewegingsapparaat (MSA) bij kantoorwerk het best?",
      options: [
        "Een aandoening die alleen de voeten treft",
        "Een aandoening die alleen voorkomt in de zware industrie",
        "Ongemak of letsel aan spieren, pezen of gewrichten, vaak gerelateerd aan werkhouding",
        "Een aandoening die alleen door sport wordt veroorzaakt",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "Welke combinatie van risicofactoren is het meest typisch voor bureauwerk?",
      options: [
        "Hard geluid en blootstelling aan chemicaliën",
        "Ongunstige houdingen, statische belasting en repetitieve bewegingen",
        "Hoge temperaturen en slechte verlichting",
        "Alleen korte e-mails en licht typen",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Waarom is \"werk aanpassen aan de werknemer\" belangrijk?",
      options: [
        "Het garandeert dat niemand ooit pijn zal voelen",
        "Het stelt mensen in staat langer te werken zonder pauzes",
        "Het vermindert belasting en helpt MSA's in de loop van de tijd te voorkomen",
        "Het richt zich uitsluitend op het verhogen van de typsnelheid",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "Wat is een rol van werkpleknormen zoals ISO 9241-5 in organisaties?",
      options: [
        "Ze bepalen hoeveel e-mails werknemers moeten versturen",
        "Ze stellen het exacte salaris van kantoormedewerkers vast",
        "Ze geven richtlijnen voor werkplekinrichting en houdingsvereisten",
        "Ze zijn alleen van toepassing op fabrieksmachines",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "Hoe kunnen klachtenvragenlijsten en houdingschecklists ergonomieprogramma's ondersteunen?",
      options: [
        "Door internetgebruik en schermtijd bij te houden",
        "Door problemen te identificeren en veranderingen na interventies te monitoren",
        "Door alle medische consulten te vervangen",
        "Door alleen productiviteit en output te meten",
      ],
      answer: 1,
    ),
  ],
);

QuizModule m2Nl() => QuizModule(
  id: 2,
  title: "Zithouding en Uitlijning",
  objectives: [
    "De belangrijkste elementen van een neutrale zithouding leren.",
    "Veelvoorkomende zitfouten en eenvoudige oplossingen herkennen.",
    "Basis nek- en bovenrugoefeningen oefenen.",
  ],
  content:
      "Een neutrale zithouding vermindert de belasting van spieren en "
      "gewrichten. Voeten moeten plat op de vloer of op een voetensteun rusten, "
      "knieën op gelijke hoogte met of iets lager dan de heupen, en de "
      "onderrug moet ondersteund worden.\n\n"
      "Een veelvoorkomende fout is een voorwaartse hoofdhouding, die de "
      "nekbelasting verhoogt. Eenvoudige oefeningen zoals kinintrektrekkingen "
      "en schouderbladknijpingen helpen de uitlijning te herstellen.",
  quizzes: [
    QuizItemModel(
      question: "Waar moeten je voeten zijn bij een neutrale zithouding?",
      options: [
        "Vrij boven de vloer hangend",
        "Plat op de vloer of op een stabiele voetensteun",
        "Strak gekruist onder de stoel",
        "Op de stoelwielen",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Een voorwaartse hoofdhouding verhoogt vooral de belasting op welk gebied?",
      options: ["Tenen", "Nek en bovenrug", "Enkels", "Heupen"],
      answer: 1,
    ),
    QuizItemModel(
      question: "Wat is een goede functie van de rugleuning?",
      options: [
        "De schouders naar voren duwen",
        "De natuurlijke kromming in de onderrug ondersteunen",
        "Je ver voorover laten leunen",
        "Alle beweging blokkeren",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Kinintrektrekkingen richten zich voornamelijk op welke spieren?",
      options: [
        "Diepe nekstabiliserende spieren",
        "Kuitspieren",
        "Handspieren",
        "Buikspieren",
      ],
      answer: 0,
    ),
    QuizItemModel(
      question: "Wat kun je gebruiken als je voeten de vloer niet bereiken?",
      options: [
        "Schoenen met hogere hakken",
        "Een stabiele voetensteun",
        "Geen verandering nodig",
        "Voeten op de stoelwielen plaatsen",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Welke beschrijving past het best bij een \"neutrale zithouding\"?",
      options: [
        "Voeten bungelend, knieën veel hoger dan de heupen",
        "Voeten plat of op een voetensteun, knieën ongeveer op gelijke hoogte met of iets lager dan de heupen, rug ondersteund",
        "Op de rand van de stoel zitten zonder rugcontact",
        "Benen strak gekruist onder de stoel",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Wat is een praktische manier om een voorwaartse hoofdhouding aan het bureau te verminderen?",
      options: [
        "Het scherm verder weg plaatsen en voorover hangen",
        "De rug altijd van de rugleuning af houden",
        "De rugleuning gebruiken, de stoel dichter bij het bureau trekken en het scherm op comfortabele kijkafstand brengen",
        "Naar je schoot kijken tijdens het typen",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "Welk teken wijst erop dat je stoel je onderrug niet goed ondersteunt?",
      options: [
        "Je voelt je stabiel en ondersteund in je onderrug",
        "Je kunt de natuurlijke kromming in je onderrug moeiteloos behouden",
        "Je merkt regelmatig dat je onderrug afrondt en moe of pijnlijk wordt",
        "Je voeten raken de vloer",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "Wat is het hoofddoel van schouderbladknijpingen in Module 2?",
      options: [
        "De kuitspieren versterken",
        "Schouderspanning en stijfheid verhogen",
        "Afgeronde schouders corrigeren en bovenrugspieren activeren",
        "De vingers en polsen stretchen",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "Wanneer kan een voetensteun bijzonder nuttig zijn?",
      options: [
        "Wanneer je voeten al comfortabel op de vloer rusten",
        "Wanneer je op je voeten wilt zitten",
        "Wanneer je stoel niet laag genoeg kan worden ingesteld en je voeten de vloer niet bereiken",
        "Wanneer je ver voorover wilt leunen",
      ],
      answer: 2,
    ),
  ],
);

QuizModule m3Nl() => QuizModule(
  id: 3,
  title: "Schermen, Toetsenbord en Muis",
  objectives: [
    "Schermen positioneren om oog- en nekbelasting te verminderen.",
    "Toetsenbord en muis instellen om schouder- en polsbelasting te verminderen.",
    "Eenvoudige regels toepassen voor één of twee schermen.",
  ],
  content:
      "De juiste plaatsing van apparaten is cruciaal voor comfort. De "
      "bovenkant van de monitor moet op of iets onder ooghoogte zijn en "
      "ongeveer op armlengte afstand.\n\n"
      "Toetsenbord en muis moeten dicht bij het lichaam op ellebooghoogte "
      "staan, zodat de schouders ontspannen blijven en de polsen recht zijn.",
  quizzes: [
    QuizItemModel(
      question: "Waar moet de bovenkant van het hoofdscherm zijn voor de meeste gebruikers?",
      options: [
        "Ruim boven ooghoogte",
        "Op of iets onder ooghoogte",
        "Op kniehoogte",
        "Op de vloer",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Wat is een gebruikelijke kijkafstand om belasting te verminderen?",
      options: [
        "Ongeveer 10 cm",
        "Ongeveer op armlengte afstand",
        "Ongeveer 3 meter weg",
        "Je neus aanrakend",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Hoe moeten de polsen gepositioneerd zijn bij het typen of muisgebruik?",
      options: [
        "Scherp omhoog gebogen",
        "Recht gehouden en in lijn met de onderarmen",
        "Alleen rustend op de rand van het bureau",
        "Sterk naar buiten gedraaid",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Als je het meeste van de tijd één scherm gebruikt, waar moet het dan geplaatst worden?",
      options: [
        "Ver opzij",
        "Recht voor je",
        "Achter je",
        "Op de vloer",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Wat is een teken dat de muis te ver weg staat?",
      options: [
        "Je kunt je arm comfortabel langs je zij laten rusten",
        "Je moet reiken en je schouder optillen om de muis te gebruiken",
        "Je kunt de cursor niet zien",
        "Je typt sneller",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Wat kan er gebeuren als de monitor langdurig te laag staat?",
      options: [
        "Alleen oogbelasting, nooit nekproblemen",
        "De gebruiker kan een voorwaartse hoofdhouding en nekklachten ontwikkelen",
        "De gebruiker zal altijd perfect rechtop zitten",
        "Het beïnvloedt alleen de typsnelheid",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Als je muis te ver van je lichaam staat, wat is dan het waarschijnlijke effect?",
      options: [
        "Je schouder en arm kunnen meer ontspannen",
        "Je hoeft je arm nooit te bewegen",
        "Je moet mogelijk reiken en je schouder optillen, wat de spanning verhoogt",
        "Het verandert alleen de schermhelderheid",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "Waar is een ideale positie voor het toetsenbord ten opzichte van je ellebogen?",
      options: [
        "Veel hoger dan ellebooghoogte",
        "Veel lager dan ellebooghoogte",
        "Ongeveer op ellebooghoogte zodat de onderarmen ongeveer horizontaal kunnen blijven",
        "Direct op je schoot met gebogen polsen",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "Wat is de beste plaatsing wanneer je twee schermen gelijkmatig gebruikt?",
      options: [
        "Eén direct voor je, één achter je",
        "Beide schermen gecentreerd voor je, in een lichte boog die je kunt overzien door je ogen of stoel te draaien",
        "Eén heel hoog, één heel laag",
        "Eén op de vloer, één aan de muur",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Waarom is het belangrijk om de polsen recht te houden bij het typen of muisgebruik?",
      options: [
        "Het ziet er alleen beter uit op foto's",
        "Het vermindert de belasting van polspezen en zenuwen",
        "Het maakt het toetsenbord overbodig",
        "Het voorkomt alle vormen van oogbelasting",
      ],
      answer: 1,
    ),
  ],
);

QuizModule m4Nl() => QuizModule(
  id: 4,
  title: "Licht, Geluid en Klimaat",
  objectives: [
    "Verlichting aanpassen om schittering en oogvermoeidheid te verminderen.",
    "Basiscomfortzones voor temperatuur en lucht begrijpen.",
    "Micropauzes gebruiken om vermoeidheid te beheersen.",
  ],
  content:
      "Verlichting, temperatuur en ventilatie beïnvloeden allemaal het "
      "comfort. Schermen moeten haaks op ramen worden geplaatst om "
      "schittering te verminderen.\n\n"
      "Micropauzes van 20–60 seconden elke 20–30 minuten verminderen "
      "ongemak zonder de productiviteit te verlagen.",
  quizzes: [
    QuizItemModel(
      question: "Hoe kun je schittering op het scherm door een raam verminderen?",
      options: [
        "Het scherm direct voor het raam plaatsen",
        "Het scherm haaks op het raam plaatsen",
        "Alle lichten uitdoen",
        "De applicatie sluiten",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Waarom zijn extreme temperaturen problematisch op het werk?",
      options: [
        "Ze verbeteren de aandacht",
        "Ze verhogen ongemak en vermoeidheid",
        "Ze beïnvloeden alleen computers",
        "Ze voorkomen MSA's",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Wat is een micropauze?",
      options: [
        "Dertig minuten gamen",
        "Een korte pauze om te bewegen of van het scherm weg te kijken",
        "Een volledige vrije dag",
        "Een lunchvergadering",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Goede kantoorverlichting moet zijn:",
      options: [
        "Zeer helder en direct in de ogen",
        "Gelijkmatig, schitteringsvrij en voldoende om te lezen",
        "Volledig donker",
        "Flikkerend",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Wat is een eenvoudige micropauze-activiteit?",
      options: [
        "Volledig stil blijven zitten",
        "Opstaan, schouders rollen en polsen kort stretchen",
        "De adem inhouden",
        "Sneller typen",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Wat is een veelvoorkomend gevolg van sterke schittering op je scherm?",
      options: [
        "Verbeterde concentratie en comfort",
        "Verminderde oogbelasting en hoofdpijn",
        "Verhoogde oogbelasting, mogelijke hoofdpijn en moeite met lezen",
        "Geen invloed op gebruikers",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "Hoe kun je het contrast tussen een helder raam en een donkerder scherm verminderen?",
      options: [
        "Het scherm direct voor het raam plaatsen",
        "Alle lichten uitdoen en naar het raam kijken",
        "Het scherm haaks op het raam plaatsen en jaloezieën of gordijnen aanpassen",
        "Alleen de schermhelderheid op maximaal zetten",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "Waarom worden regelmatige micropauzes aanbevolen tijdens beeldschermwerk?",
      options: [
        "Ze verlagen de productiviteit aanzienlijk",
        "Ze helpen ongemak en vermoeidheid te verminderen zonder de algehele productiviteit te schaden",
        "Ze zijn alleen nodig voor sporters",
        "Ze veranderen alleen de schermresolutie",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Welke uitspraak over temperatuur en concentratie is het meest accuraat?",
      options: [
        "Extreem warme of koude omgevingen hebben geen effect op concentratie",
        "Zeer koude omgevingen verbeteren altijd de focus",
        "Comfortabele temperatuurbereiken ondersteunen de focus, terwijl extremen de vermoeidheid kunnen verhogen",
        "Alleen geluidsniveaus zijn belangrijk voor concentratie",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "Wat is een voorbeeld van een eenvoudige micropauze tijdens bureauwerk?",
      options: [
        "4 uur werken zonder te bewegen",
        "20–30 seconden opstaan, schouders rollen en naar een ver object kijken",
        "Je adem inhouden tijdens het typen",
        "Alleen je ogen sluiten zonder te bewegen",
      ],
      answer: 1,
    ),
  ],
);

QuizModule m5Nl() => QuizModule(
  id: 5,
  title: "Omgaan met Lasten en Tillen",
  objectives: [
    "Veilige tilprincipes toepassen op kantoortaken.",
    "Weten wanneer je hulp moet vragen of hulpmiddelen moet gebruiken.",
    "Begrijpen hoe de positie van de last de rugbelasting beïnvloedt.",
  ],
  content:
      "Zelfs op kantoor kan tillen risico's met zich meebrengen. Houd lasten "
      "dicht bij het lichaam, buig heupen en knieën, en vermijd draaien "
      "terwijl je gewicht vasthoudt.\n\n"
      "Gebruik steekwagens of vraag hulp bij zware of onhandige voorwerpen.",
  quizzes: [
    QuizItemModel(
      question: "Waar moet de last zich bevinden tijdens het tillen?",
      options: [
        "Ver van het lichaam",
        "Zo dicht mogelijk bij het lichaam",
        "Boven het hoofd",
        "Op één uitgestrekte arm",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Welke beweging moet vermeden worden tijdens het tillen?",
      options: [
        "Draaien met de voeten",
        "De rug draaien terwijl je een last vasthoudt",
        "Ademen",
        "Beide handen gebruiken",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Hoe kun je de rugbelasting bij het tillen verminderen?",
      options: [
        "Alleen vanuit de taille buigen",
        "Heupen en knieën buigen terwijl je de rug zo recht mogelijk houdt",
        "Je adem inhouden",
        "Snel tillen met een schokkerige beweging",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Wanneer is het beter om hulp of een hulpmiddel te vragen?",
      options: [
        "Bij zware of omvangrijke voorwerpen",
        "Voor een pen",
        "Voor een vel papier",
        "Nooit",
      ],
      answer: 0,
    ),
    QuizItemModel(
      question: "Welke uitspraak over tillen bij kantoorwerk is juist?",
      options: [
        "Er is nooit een tilrisico",
        "Af en toe onhandig tillen kan nog steeds bijdragen aan rugklachten",
        "Alleen fabriekswerk is relevant",
        "Alleen zitten is van belang",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Waarom is het zo belangrijk om een last dicht bij je lichaam te houden tijdens het tillen?",
      options: [
        "Het maakt de last zwaarder",
        "Het vermindert de belasting op je rug en wervelkolom",
        "Het heeft geen effect op je lichaam",
        "Het helpt alleen bij de balans, maar niet bij de belasting",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Wat is de veiligste manier om te draaien terwijl je een zwaar voorwerp draagt?",
      options: [
        "Je rug draaien terwijl de voeten stil blijven staan",
        "Voorover buigen en alleen je schouders draaien",
        "Je voeten verplaatsen om je hele lichaam samen met de last te draaien",
        "Zo ver mogelijk achterover leunen tijdens het draaien",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "Wat is een betere bewegingsstrategie bij het tillen van de vloer?",
      options: [
        "Voornamelijk vanuit je taille buigen met een ronde rug",
        "Je heupen en knieën buigen terwijl je je rug zo recht mogelijk houdt",
        "Je benen recht houden en alleen met je armen trekken",
        "Springen en de last in de lucht opvangen",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Wanneer is het op kantoor het meest gepast om een steekwagen te gebruiken of hulp te vragen?",
      options: [
        "Alleen wanneer je zin hebt om het werk te delen",
        "Bij zware, omvangrijke of onhandige voorwerpen die moeilijk vast te houden zijn",
        "Nooit, want kantoorlasten zijn altijd veilig",
        "Alleen voor heel kleine voorwerpen",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Welke situatie verhoogt het risico op rugbelasting bij tillen op kantoor?",
      options: [
        "Een heel lichte map tillen met een goede houding",
        "Af en toe een zware doos tillen met een slechte techniek",
        "Een pen in je zak dragen",
        "Beide handen gebruiken om een licht toetsenbord vast te houden",
      ],
      answer: 1,
    ),
  ],
);

QuizModule m6Nl() => QuizModule(
  id: 6,
  title: "Hybride en Thuiswerken",
  objectives: [
    "Ergonomische principes toepassen bij thuiswerken of hybride werken.",
    "Langdurig zitten verminderen bij thuiswerkopstellingen.",
    "Eenvoudige regels gebruiken voor laptops en telefoons.",
  ],
  content:
      "Thuiswerken vereist dezelfde ergonomische principes als kantoorwerk. "
      "Laptops moeten verhoogd worden en gebruikt worden met externe "
      "invoerapparaten.\n\n"
      "Staan tijdens telefoongesprekken en het vermijden van langdurige "
      "nekbuiging bij telefoongebruik vermindert de belasting.",
  quizzes: [
    QuizItemModel(
      question: "Wat is thuis het doel met betrekking tot ergonomie?",
      options: [
        "Ergonomie negeren",
        "Dezelfde basisprincipes voor werkplekinrichting toepassen als op kantoor",
        "Alleen vanuit bed werken",
        "In het donker werken",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Een eenvoudige manier om langdurig zitten te verminderen is:",
      options: [
        "Nooit staan tijdens telefoongesprekken",
        "Opstaan of rondlopen tijdens sommige telefoongesprekken",
        "De stoel vastzetten",
        "Pauzes vermijden",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Welke optie is beter voor laptopgebruik?",
      options: [
        "De laptop urenlang op schoot houden",
        "De laptop verhogen en een extern toetsenbord en muis gebruiken",
        "De laptop gebruiken terwijl je op je zij ligt",
        "De laptop boven je hoofd houden",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Waarom zijn regelmatige houdingsveranderingen nuttig bij thuiswerken?",
      options: [
        "Ze verhogen ongemak",
        "Ze verminderen stijfheid en ondersteunen de bloedsomloop",
        "Ze verstoren alleen de concentratie",
        "Ze beschadigen de stoel",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Welk gedrag verhoogt de nekbelasting bij telefoons?",
      options: [
        "De telefoon op ooghoogte brengen",
        "Langdurig met een gebogen nek naar de telefoon kijken",
        "Korte pauzes nemen",
        "Een headset gebruiken",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Waarom wordt langdurig werken vanaf een bank of bed meestal niet aanbevolen?",
      options: [
        "Het verbetert altijd de houding",
        "Het is te stil",
        "Het leidt vaak tot een slechte rug- en nekhouding zonder goede ondersteuning",
        "Het voorkomt dat je een laptop kunt gebruiken",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "Welke combinatie is het best voor langdurig laptopgebruik thuis?",
      options: [
        "Laptop op schoot, geen ondersteuning, geen externe apparaten",
        "Laptop op een laag tafeltje met het scherm heel ver weg",
        "Laptop verhoogd tot ooghoogte plus extern toetsenbord en muis",
        "Laptop op vloerniveau, er staand boven",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "Wat is een praktische manier om langdurig zitten te verminderen bij thuiswerken?",
      options: [
        "Alle pauzes vermijden om sneller klaar te zijn",
        "Opstaan of rondlopen tijdens sommige telefoongesprekken en online vergaderingen",
        "Alleen vanuit bed werken",
        "De stoel vastzetten en nooit bewegen",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Welk gedrag verhoogt het risico op \"tekstnek\"?",
      options: [
        "De telefoon dichter bij ooghoogte brengen",
        "Een headset gebruiken om de handen vrij te houden",
        "Langdurig met een gebogen nek naar de telefoon kijken",
        "Korte pauzes nemen van de telefoon",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "Waarom gelden dezelfde ergonomische principes thuis als op kantoor?",
      options: [
        "Omdat je lichaam en gewrichten op beide plekken hetzelfde zijn",
        "Omdat kantoorstoelen thuis verboden zijn",
        "Omdat laptops alleen thuis werken",
        "Omdat houding alleen op kantoor belangrijk is",
      ],
      answer: 0,
    ),
  ],
);

QuizModule m7Nl() => QuizModule(
  id: 7,
  title: "Dagelijkse Preventieve Routine",
  objectives: [
    "Eenvoudige oefeningen en micropauzes leren.",
    "Basisdosering begrijpen (hoe lang en hoe vaak).",
    "Oefeningen koppelen aan nek-, schouder- en onderrugklachten.",
  ],
  content:
      "Dagelijkse lichte beweging voorkomt stijfheid. Nekstrekkingen, "
      "bovenrugextensies en polsstrekkingen moeten regelmatig worden "
      "uitgevoerd.\n\n"
      "Houd strekkingen 10–30 seconden aan, herhaal 2–3 keer, en stop "
      "als er scherpe pijn optreedt.",
  quizzes: [
    QuizItemModel(
      question: "Waarom kunnen specifieke oefeningen kantoormedewerkers helpen?",
      options: [
        "Ze bouwen alleen spiermassa op",
        "Ze kunnen nek- en schouderpijn verminderen wanneer ze regelmatig worden uitgevoerd",
        "Ze maken werkplekaanpassingen overbodig",
        "Ze vervangen slaap",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Een gebruikelijke houdtijd voor een lichte stretching is:",
      options: [
        "Ongeveer 1 seconde",
        "Ongeveer 10 tot 30 seconden",
        "Ongeveer 5 minuten",
        "Ongeveer 30 minuten",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Welke van deze is een eenvoudige schouderactivatieoefening?",
      options: [
        "De schouders de hele dag opgetrokken houden",
        "Voorzichtig de schouderbladen samenknijpen voor meerdere herhalingen",
        "Zware tassen dragen",
        "Optrekken onder een zware belasting",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Wanneer moet een gebruiker stoppen met een oefening?",
      options: [
        "Als de pijn scherp toeneemt",
        "Wanneer je je beter voelt",
        "Nooit",
        "Alleen na 3 uur",
      ],
      answer: 0,
    ),
    QuizItemModel(
      question: "Een realistische frequentie voor micropauzes tijdens beeldschermwerk is:",
      options: [
        "Eén keer per maand",
        "Een paar seconden elke 20 tot 30 minuten",
        "Eén keer per jaar",
        "Alleen tijdens vakanties",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Wat is het hoofddoel van de dagelijkse preventieve routine in Module 7?",
      options: [
        "Alle medische behandelingen vervangen",
        "Stijfheid voorzichtig verminderen en nek-, schouder- en onderrugklachten voorkomen",
        "Trainen voor wedstrijdsport",
        "Werkplekaanpassingen vermijden",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Hoe moeten stretchoefeningen over het algemeen aanvoelen?",
      options: [
        "Zeer pijnlijk zodat je weet dat ze werken",
        "Zacht, met een lichte rekking maar zonder scherpe pijn",
        "Volledig moeiteloos zonder enig gevoel",
        "Zo intens dat je je adem moet inhouden",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Hoe vaak kunnen korte oefen- of stretchpauzes realistisch in beeldschermwerk worden ingebouwd?",
      options: [
        "Alleen eenmaal per maand",
        "Alleen tijdens vakanties",
        "Een paar seconden of minuten elke 20–30 minuten",
        "Alleen eenmaal per jaar",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "Wat moet je doen als de pijn scherp toeneemt tijdens een oefening?",
      options: [
        "Doorgaan en het negeren",
        "Alleen een beetje vertragen",
        "De oefening onmiddellijk stoppen en terugkeren naar een comfortabele positie",
        "De intensiteit verhogen",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "Waarom is het nuttig om oefeningen te koppelen aan specifieke klachten (bijvoorbeeld nek- of schouderspanning)?",
      options: [
        "Het stelt je in staat oefeningen te kiezen die gericht zijn op je eigen probleemgebieden",
        "Het maakt stretchen overbodig",
        "Het voegt alleen complexiteit toe zonder voordeel",
        "Het vervangt werkplekaanpassingen volledig",
      ],
      answer: 0,
    ),
  ],
);
