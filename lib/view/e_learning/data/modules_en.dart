import 'package:posture_detector_app/models/quiz/quiz_module.dart';

QuizModule m1En() => QuizModule(
  id: 1,
  title: "Core Ergonomics and Risk",
  objectives: [
    "Understand what ergonomics is and why it matters for desk work.",
    "Recognize the main musculoskeletal risk factors in office settings.",
    "Understand how workstation standards guide good setups.",
  ],
  content:
      "Ergonomics is the science of designing work to fit the worker, rather "
      "than forcing the worker to adapt to poor setups. In an office "
      "environment, poor workstation design can contribute to discomfort "
      "and long-term injuries known as Musculoskeletal Disorders (MSDs).\n\n"
      "The main risk factors for desk work are awkward postures, static "
      "loading, and repetitive movements. International standards such as "
      "ISO 9241-5 provide guidance for workstation layout and posture. "
      "Tools like symptom questionnaires and posture checklists help "
      "organizations identify problems and track improvements.",
  quizzes: [
    QuizItemModel(
      question: "What is the main goal of ergonomics?",
      options: [
        "Make people work faster at any cost",
        "Adapt work and tools to human limits and comfort",
        "Replace workers with automation",
        "Focus only on productivity",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Which is a typical risk factor in desk work?",
      options: [
        "Short emails",
        "Long periods with a bent neck looking down at a screen",
        "Drinking water",
        "Using a chair with back support",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "What do workstation standards (like ISO 9241-5) mainly deal with?",
      options: [
        "Fire safety",
        "Workstation layout and posture for visual display work",
        "Payroll systems",
        "Air quality only",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Why do organizations use symptom questionnaires?",
      options: [
        "For decoration",
        "To map problems and track changes over time",
        "To monitor internet usage",
        "To replace medical care",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Which statement about MSDs in office workers is most accurate?",
      options: [
        "They rarely affect the neck or shoulders",
        "Only heavy lifting can cause them",
        "Poor workstation setup and long static sitting can contribute to neck and upper limb problems",
        "They cannot be influenced by workstation changes",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "Which statement best describes a Musculoskeletal Disorder (MSD) in office work?",
      options: [
        "A condition that only affects the feet",
        "A condition that only occurs in heavy industry",
        "A discomfort or injury affecting muscles, tendons, or joints, often linked to work posture",
        "A condition caused only by sports",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "Which combination of risk factors is most typical for desk work?",
      options: [
        "Loud noise and chemical exposure",
        "Awkward postures, static loading, and repetitive movements",
        "High temperatures and poor lighting",
        "Only short emails and light typing",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Why is \"designing work to fit the worker\" important?",
      options: [
        "It guarantees no one will ever feel pain",
        "It allows people to work longer without any breaks",
        "It reduces strain and helps prevent MSDs over time",
        "It focuses only on increasing typing speed",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "What is one role of workstation standards like ISO 9241-5 in organizations?",
      options: [
        "They define how many emails employees should send",
        "They set the exact salary for office workers",
        "They give guidance on workstation layout and postural requirements",
        "They only apply to factory machinery",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "How can symptom questionnaires and posture checklists support ergonomics programs?",
      options: [
        "By tracking internet usage and screen time",
        "By identifying problems and monitoring changes after interventions",
        "By replacing all medical consultations",
        "By measuring only productivity and output",
      ],
      answer: 1,
    ),
  ],
);

QuizModule m2En() => QuizModule(
  id: 2,
  title: "Seated Posture and Alignment",
  objectives: [
    "Learn the key elements of neutral sitting posture.",
    "Spot common sitting mistakes and simple fixes.",
    "Practice basic neck and upper-back activation exercises.",
  ],
  content:
      "Neutral sitting posture reduces strain on muscles and joints. "
      "Feet should rest flat on the floor or a footrest, knees level with "
      "or slightly lower than hips, and the lower back supported.\n\n"
      "A common mistake is forward head posture, which increases neck load. "
      "Simple exercises like chin tucks and shoulder blade squeezes help "
      "restore alignment.",
  quizzes: [
    QuizItemModel(
      question: "In a neutral sitting posture, where should your feet be?",
      options: [
        "Hanging freely above the floor",
        "Flat on the floor or on a stable footrest",
        "Crossed tightly under the chair",
        "On the chair wheels",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "A forward head posture mainly increases strain on which area?",
      options: ["Toes", "Neck and upper back", "Ankles", "Hips"],
      answer: 1,
    ),
    QuizItemModel(
      question: "What is a good role of the backrest?",
      options: [
        "Push the shoulders forward",
        "Support the natural curve in the lower back",
        "Keep you leaning far forward",
        "Block all movement",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Chin tucks mainly target which muscles?",
      options: [
        "Deep neck stabilizing muscles",
        "Calf muscles",
        "Hand muscles",
        "Abdominal muscles",
      ],
      answer: 0,
    ),
    QuizItemModel(
      question: "What can you use if your feet do not reach the floor?",
      options: [
        "Higher heel shoes",
        "A stable footrest",
        "No change needed",
        "Place feet on chair wheels",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Which description best matches a \"neutral sitting posture\"?",
      options: [
        "Feet dangling, knees much higher than hips",
        "Feet flat or on a footrest, knees about level with or slightly lower than hips, back supported",
        "Sitting on the edge of the chair with no back contact",
        "Legs tightly crossed under the chair",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "What is a practical way to reduce forward head posture at the desk?",
      options: [
        "Move the screen farther away and slouch forward",
        "Keep the back off the backrest at all times",
        "Use the backrest, pull the chair closer to the desk, and bring the screen within comfortable viewing distance",
        "Look down at your lap while typing",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "Which sign suggests your chair is not supporting your lower back correctly?",
      options: [
        "You feel stable and supported in your lower back",
        "You can keep the natural curve in your lower back without effort",
        "You regularly feel your lower back rounding and becoming tired or achy",
        "Your feet touch the floor",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "What is the main purpose of shoulder blade squeezes in Module 2?",
      options: [
        "To strengthen the calf muscles",
        "To increase shoulder tension and stiffness",
        "To correct rounded shoulders and activate upper-back muscles",
        "To stretch the fingers and wrists",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "When might a footrest be especially helpful?",
      options: [
        "When your feet already rest comfortably on the floor",
        "When you want to sit on your feet",
        "When your chair cannot be lowered enough and your feet do not reach the floor",
        "When you want to lean far forward",
      ],
      answer: 2,
    ),
  ],
);

QuizModule m3En() => QuizModule(
  id: 3,
  title: "Screens, Keyboard, and Mouse",
  objectives: [
    "Position screens to reduce eye and neck strain.",
    "Set keyboard and mouse to reduce shoulder and wrist load.",
    "Apply simple rules for one or two screens.",
  ],
  content:
      "Correct device placement is critical for comfort. The top of the "
      "monitor should be at or slightly below eye level and about an "
      "arm's length away.\n\n"
      "Keyboard and mouse should be close to the body at elbow height, "
      "allowing relaxed shoulders and straight wrists.",
  quizzes: [
    QuizItemModel(
      question: "Where should the top of the main screen be for most users?",
      options: [
        "Well above eye level",
        "At or slightly below eye level",
        "At knee level",
        "On the floor",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "What is a typical viewing distance to reduce strain?",
      options: [
        "About 10 cm",
        "About an arm's length away",
        "About 3 meters away",
        "Touching your nose",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "How should wrists be positioned when typing or using the mouse?",
      options: [
        "Bent sharply up",
        "Kept straight and in line with the forearms",
        "Resting only on the edge of the desk",
        "Rotated strongly outward",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "If you use one screen most of the time, where should it be placed?",
      options: [
        "Far to the side",
        "Directly in front of you",
        "Behind you",
        "On the floor",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "What is a sign that the mouse may be too far away?",
      options: [
        "You can rest the arm comfortably by your side",
        "You must reach and lift the shoulder to use it",
        "You cannot see the cursor",
        "You type faster",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "What can happen if the monitor is placed too low for a long time?",
      options: [
        "Only eye strain, never neck issues",
        "The user may develop forward head posture and neck discomfort",
        "The user will always sit perfectly straight",
        "It only affects typing speed",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "If your mouse is placed too far away from your body, what is the likely effect?",
      options: [
        "Your shoulder and arm can relax more",
        "You will never need to move your arm",
        "You may need to reach and lift your shoulder, increasing tension",
        "It only changes screen brightness",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "Where is an ideal position for the keyboard relative to your elbows?",
      options: [
        "Much higher than elbow height",
        "Much lower than elbow height",
        "About at elbow height so the forearms can stay roughly horizontal",
        "Directly on your lap with bent wrists",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "When using two screens equally, what is the best placement?",
      options: [
        "One directly in front, one behind you",
        "Both screens centered in front of you, forming a slight curve you can see by turning eyes or chair",
        "One very high, one very low",
        "One on the floor, one on the wall",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Why is it important to keep wrists straight while typing or using the mouse?",
      options: [
        "It only looks better in photos",
        "It reduces strain on wrist tendons and nerves",
        "It makes the keyboard unnecessary",
        "It prevents all types of eye strain",
      ],
      answer: 1,
    ),
  ],
);

QuizModule m4En() => QuizModule(
  id: 4,
  title: "Light, Noise, and Climate",
  objectives: [
    "Adjust lighting to reduce glare and eye fatigue.",
    "Understand basic comfort ranges for temperature and air.",
    "Use microbreaks to manage fatigue.",
  ],
  content:
      "Lighting, temperature, and ventilation all affect comfort. Screens "
      "should be positioned perpendicular to windows to reduce glare.\n\n"
      "Microbreaks of 20–60 seconds every 20–30 minutes reduce discomfort "
      "without reducing productivity.",
  quizzes: [
    QuizItemModel(
      question: "How can you reduce screen glare from a window?",
      options: [
        "Put the screen directly in front of the window",
        "Place the screen perpendicular to the window",
        "Turn all lights off",
        "Close the app",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Why are extreme temperatures problematic at work?",
      options: [
        "They improve attention",
        "They increase discomfort and fatigue",
        "They only affect computers",
        "They prevent MSDs",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "What is a microbreak?",
      options: [
        "Thirty minutes of gaming",
        "A short pause to move or look away from the screen",
        "A full day off",
        "A lunch meeting",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Good office lighting should be:",
      options: [
        "Very bright and directly in the eyes",
        "Even, non-glary and adequate for reading",
        "Completely dark",
        "Flickering",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Which is a simple microbreak activity?",
      options: [
        "Staying completely still",
        "Standing up, rolling shoulders and stretching wrists briefly",
        "Holding the breath",
        "Typing faster",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "What is a common consequence of strong glare on your screen?",
      options: [
        "Improved concentration and comfort",
        "Reduced eye strain and headaches",
        "Increased eye strain, possible headaches, and difficulty reading",
        "No impact on users",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "How can you reduce contrast between a bright window and a darker screen?",
      options: [
        "Put the screen directly in front of the window",
        "Turn off all lights and face the window",
        "Position the screen perpendicular to the window and adjust blinds or curtains",
        "Increase only screen brightness to maximum",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "Why are regular microbreaks recommended during screen work?",
      options: [
        "They significantly reduce productivity",
        "They help reduce discomfort and fatigue without harming overall productivity",
        "They are only needed for athletes",
        "They only change screen resolution",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Which statement about temperature and concentration is most accurate?",
      options: [
        "Extremely hot or cold environments have no effect on concentration",
        "Very cold environments always improve focus",
        "Comfortable temperature ranges support focus, while extremes can increase fatigue",
        "Only noise levels matter for concentration",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "What is an example of a simple microbreak during desk work?",
      options: [
        "Working without moving for 4 hours",
        "Standing up for 20–30 seconds, rolling shoulders, and looking at a distant object",
        "Holding your breath while typing",
        "Only closing your eyes without moving",
      ],
      answer: 1,
    ),
  ],
);

QuizModule m5En() => QuizModule(
  id: 5,
  title: "Handling Loads and Lifting",
  objectives: [
    "Apply safe lifting principles to office tasks.",
    "Know when to ask for help or use handling aids.",
    "Understand how load position affects back strain.",
  ],
  content:
      "Even in offices, lifting can pose risks. Keep loads close to the body, "
      "bend hips and knees, and avoid twisting while holding weight.\n\n"
      "Use trolleys or ask for help with heavy or awkward items.",
  quizzes: [
    QuizItemModel(
      question: "During a lift, where should the load be?",
      options: [
        "Far from the body",
        "As close to the body as possible",
        "Above the head",
        "On one stretched arm",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Which motion should be avoided while lifting?",
      options: [
        "Turning with the feet",
        "Twisting the back while holding a load",
        "Breathing",
        "Using both hands",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "How can you lower back strain when lifting?",
      options: [
        "Bend only at the waist",
        "Bend hips and knees while keeping the back as straight as possible",
        "Hold your breath",
        "Lift quickly with a jerking motion",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "When is it better to get help or a device?",
      options: [
        "For heavy or bulky items",
        "For a pen",
        "For a sheet of paper",
        "Never",
      ],
      answer: 0,
    ),
    QuizItemModel(
      question: "Which statement about lifting in office jobs is true?",
      options: [
        "There is never any lifting risk",
        "Occasional awkward lifting can still contribute to back issues",
        "Only factory work matters",
        "Only sitting matters",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Why is keeping a load close to your body when lifting so important?",
      options: [
        "It makes the load heavier",
        "It reduces the strain on your back and spine",
        "It has no effect on your body",
        "It only helps with balance but not with strain",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "What is the safest way to turn while carrying a heavy object?",
      options: [
        "Twist your back while the feet stay still",
        "Bend forward and rotate only your shoulders",
        "Move your feet to turn your whole body together with the load",
        "Lean as far back as possible while turning",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "When lifting from the floor, what is a better movement strategy?",
      options: [
        "Bend mainly at your waist with a rounded back",
        "Bend your hips and knees while keeping your back as straight as possible",
        "Keep your legs straight and pull only with your arms",
        "Jump and catch the load in mid-air",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "In an office, when is it most appropriate to use a trolley or ask for help?",
      options: [
        "Only when you feel like sharing the work",
        "For heavy, bulky, or awkward items that are difficult to hold",
        "Never, because office loads are always safe",
        "Only for very small items",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Which situation increases the risk of back strain in office lifting?",
      options: [
        "Lifting a very light folder with good posture",
        "Occasionally lifting a heavy box with poor technique",
        "Carrying a pen in your pocket",
        "Using both hands to hold a light keyboard",
      ],
      answer: 1,
    ),
  ],
);

QuizModule m6En() => QuizModule(
  id: 6,
  title: "Hybrid and Remote Work",
  objectives: [
    "Apply ergonomics principles at home or in hybrid work.",
    "Reduce long sitting periods in remote setups.",
    "Use simple rules for laptops and phones.",
  ],
  content:
      "Remote work requires the same ergonomic principles as office work. "
      "Laptops should be raised and used with external input devices.\n\n"
      "Standing during calls and avoiding prolonged phone neck flexion "
      "reduces strain.",
  quizzes: [
    QuizItemModel(
      question: "At home, what is the goal regarding ergonomics?",
      options: [
        "Ignore ergonomics",
        "Apply the same basic setup principles as in the office",
        "Work only from bed",
        "Work in the dark",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "A simple way to reduce prolonged sitting is to:",
      options: [
        "Never stand during calls",
        "Stand up or walk during some calls",
        "Lock the chair",
        "Avoid breaks",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "For laptop use, which option is better?",
      options: [
        "Keep it in your lap for hours",
        "Raise it and use an external keyboard and mouse",
        "Use it lying on your side",
        "Hold it above your head",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Why are frequent posture changes helpful in remote work?",
      options: [
        "They increase discomfort",
        "They reduce stiffness and support circulation",
        "They only break concentration",
        "They damage the chair",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Which behaviour increases neck strain with phones?",
      options: [
        "Bringing the phone to eye level",
        "Looking down at the phone with a bent neck for long periods",
        "Taking short breaks",
        "Using a headset",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Why is working long-term from a sofa or bed usually not recommended?",
      options: [
        "It always improves posture",
        "It is too quiet",
        "It often leads to poor back and neck posture without proper support",
        "It prevents you from using a laptop",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "Which combination is best for longer laptop use at home?",
      options: [
        "Laptop on lap, no support, no external devices",
        "Laptop on a low table with screen very far away",
        "Laptop raised to eye level plus external keyboard and mouse",
        "Laptop at floor level, standing above it",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "What is a practical way to reduce long sitting periods when working remotely?",
      options: [
        "Avoid all breaks to finish faster",
        "Stand up or walk during some calls and online meetings",
        "Work only from the bed",
        "Keep the chair locked and never move",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Which behavior increases the risk of \"text neck\"?",
      options: [
        "Bringing the phone closer to eye level",
        "Using a headset to keep hands free",
        "Looking down at the phone with a bent neck for long periods",
        "Taking short breaks from the phone",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "Why do the same ergonomics principles apply at home and in the office?",
      options: [
        "Because your body and joints are the same in both places",
        "Because office chairs are forbidden at home",
        "Because laptops only work at home",
        "Because posture only matters in the office",
      ],
      answer: 0,
    ),
  ],
);

QuizModule m7En() => QuizModule(
  id: 7,
  title: "Daily Preventive Routine",
  objectives: [
    "Learn simple exercises and microbreaks.",
    "Understand basic dosage (how long and how often).",
    "Link exercises to neck, shoulder, and lower-back symptoms.",
  ],
  content:
      "Daily gentle movement prevents stiffness. Neck stretches, upper back "
      "extensions, and wrist stretches should be done regularly.\n\n"
      "Hold stretches for 10–30 seconds, repeat 2–3 times, and stop if sharp "
      "pain occurs.",
  quizzes: [
    QuizItemModel(
      question: "Why can specific exercises help office workers?",
      options: [
        "They only build muscle size",
        "They can reduce neck and shoulder pain when done regularly",
        "They eliminate the need to adjust the workstation",
        "They replace sleep",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "A typical hold time for a gentle stretch is:",
      options: [
        "About 1 second",
        "About 10 to 30 seconds",
        "About 5 minutes",
        "About 30 minutes",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Which of these is a simple shoulder activation exercise?",
      options: [
        "Holding shoulders up all day",
        "Gently squeezing shoulder blades together for several repetitions",
        "Carrying heavy bags",
        "Shrugging under a heavy load",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "When should a user stop an exercise?",
      options: [
        "If pain sharply increases",
        "When feeling better",
        "Never",
        "Only after 3 hours",
      ],
      answer: 0,
    ),
    QuizItemModel(
      question: "A realistic frequency for microbreaks during screen work is:",
      options: [
        "Once per month",
        "A few seconds every 20 to 30 minutes",
        "Once per year",
        "Only during holidays",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "What is the main goal of the daily preventive routine in Module 7?",
      options: [
        "To replace all medical treatments",
        "To gently reduce stiffness and prevent neck, shoulder, and lower-back discomfort",
        "To train for competitive sports",
        "To avoid adjusting the workstation",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "How should stretching exercises generally feel?",
      options: [
        "Very painful so you know they are working",
        "Gentle, with a mild stretch but no sharp pain",
        "Completely effortless with no sensation at all",
        "So intense you must hold your breath",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "How often can short exercise or stretch breaks be realistically integrated into screen work?",
      options: [
        "Only once per month",
        "Only during holidays",
        "A few seconds or minutes every 20–30 minutes",
        "Only once per year",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "What should you do if pain sharply increases during an exercise?",
      options: [
        "Continue and ignore it",
        "Only slow down a little",
        "Stop the exercise immediately and return to a comfortable position",
        "Increase the intensity",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "Why is linking exercises to specific symptoms helpful (for example, neck or shoulder tension)?",
      options: [
        "It allows you to choose exercises that target your own problem areas",
        "It makes stretching unnecessary",
        "It only increases complexity with no benefit",
        "It replaces workstation adjustments completely",
      ],
      answer: 0,
    ),
  ],
);

QuizModule m8En() => QuizModule(
  id: 8,
  title: "Understanding Pain & Staying Active at Work",
  objectives: [
    "Understand that pain does not always equal tissue damage.",
    "Recognize fear-avoidance thinking and why it increases the risk of longer-term problems.",
    "Apply graded activity principles during normal desk work.",
    "Know when extra professional support is still useful.",
  ],
  content:
      "Musculoskeletal discomfort at a desk is very common. Many people "
      "assume that if something hurts, the tissue must be damaged and rest "
      "is the only safe option, but modern pain science shows a more "
      "complete picture: pain is a protective signal produced by the "
      "nervous system, shaped not only by the state of the tissues but also "
      "by stress, sleep, previous experiences, beliefs about pain, and how "
      "much you move. Pain can be present even when no serious damage is "
      "occurring, and its intensity does not always match the amount of "
      "tissue injury. Believing that \"hurt always equals harm\" often leads "
      "people to reduce activity more than necessary, which over time can "
      "cause stiffness, loss of confidence in movement, and a longer "
      "recovery.\n\n"
      "Fear-avoidance is the tendency to avoid movement or normal "
      "activities because you fear the activity will increase pain or "
      "cause damage. It is a normal short-term protective response, but "
      "becomes a problem when it continues past the acute phase. Typical "
      "fear-avoidance thoughts include \"I should not do anything that "
      "causes any discomfort,\" \"if I keep working I will make the injury "
      "worse,\" and \"I must wait until the pain is completely gone before I "
      "return to normal duties.\" Research using screening tools such as "
      "the Örebro Musculoskeletal Pain Screening Questionnaire shows that "
      "high fear-avoidance and low recovery expectations are among the "
      "strongest predictors that short-term pain becomes long-term, with "
      "the high-risk group having substantially more sick leave days and a "
      "much higher risk of long-term work disability than the low-risk "
      "group.\n\n"
      "Instead of complete rest or waiting for zero pain, graded activity "
      "is a more effective strategy for most desk-related musculoskeletal "
      "problems: start with a manageable level of movement and work, then "
      "gradually increase it over days and weeks. Some mild discomfort "
      "during activity is often normal and does not mean damage is "
      "occurring. Break work into shorter periods with frequent short "
      "movement breaks, then slowly increase the duration. Focus on "
      "returning to normal function rather than eliminating every "
      "sensation of discomfort, and combine this approach with a "
      "well-adjusted workstation. Graded activity helps retrain the "
      "nervous system, rebuild confidence in movement, and reduce the risk "
      "that the problem becomes chronic.\n\n"
      "You can apply these ideas immediately: keep using a good "
      "workstation setup with your chair, screen, keyboard and mouse in "
      "neutral positions; take short movement breaks every 20–30 minutes "
      "rather than sitting for very long periods; when discomfort is "
      "present, reduce the intensity or duration of the activity instead "
      "of stopping completely; gradually return to your normal work "
      "pattern as tolerance improves; and use the simple exercises "
      "recommended in your Postura programme as part of this graded "
      "approach.\n\n"
      "Self-management and graded activity are powerful, but not always "
      "enough. Seek extra support from an ergonomist, physiotherapist or "
      "occupational health when pain is severe or rapidly getting worse, "
      "when it stops you performing normal work duties despite gradual "
      "activity and workstation improvements, if you notice new symptoms "
      "such as significant numbness, weakness, or pain spreading into the "
      "arms or legs, or if you have already been struggling for several "
      "weeks with little improvement. Early professional support for "
      "people at elevated risk of long-term problems has been shown to "
      "reduce lost work days compared with usual care.\n\n"
      "Good workstation setup reduces physical load. Understanding pain "
      "and staying active reduces the risk that short-term discomfort "
      "becomes a long-term problem. Together they form a more complete "
      "approach to preventing musculoskeletal disorders and unnecessary "
      "sick leave.",
  quizzes: [
    QuizItemModel(
      question: "What is the most accurate statement about musculoskeletal pain at a desk?",
      options: [
        "If it hurts, you are always damaging the tissues",
        "Pain is a complex signal and does not always equal tissue damage",
        "Pain always means you should stop all activity",
        "Pain only comes from poor posture",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "What is \"fear-avoidance\"?",
      options: [
        "Being careful with heavy lifting only",
        "Avoiding movement or activity because you fear it will make the pain worse or cause damage",
        "Taking regular stretch breaks",
        "Using an ergonomic chair",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "According to research, people with high fear-avoidance and low recovery expectations tend to have:",
      options: [
        "The same number of sick days as others",
        "Significantly more sick leave days and higher risk of long-term problems",
        "Faster recovery",
        "No difference in outcome",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "What is the better approach when you have ongoing desk-related discomfort?",
      options: [
        "Complete rest until the pain is 0/10",
        "Only do exercises that cause zero discomfort",
        "Gradually increase activity and movement even if there is some mild discomfort",
        "Avoid all computer work",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "Which thought is more helpful for recovery?",
      options: [
        "\"I should not do anything that causes any pain\"",
        "\"Some discomfort during activity is normal and does not mean I am harming myself\"",
        "\"Pain means I need more imaging and rest\"",
        "\"I must wait until I am 100% pain-free before returning to normal duties\"",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "What is one practical way to apply graded activity at a desk job?",
      options: [
        "Work through pain without any breaks",
        "Completely stop using the mouse or keyboard",
        "Start with shorter periods of work + frequent short movement breaks, then gradually increase",
        "Only work when pain is completely gone",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "When is it still important to seek extra help (ergonomist, physiotherapist or occupational health)?",
      options: [
        "Only if pain is 9 or 10 out of 10",
        "If pain is severe, getting worse, or stopping you from normal work despite gradual activity and workstation improvements",
        "Never - you should always manage alone",
        "Only after 6 months",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "The combination of good workstation setup + understanding pain + staying active is important because:",
      options: [
        "It only helps with posture",
        "It addresses both the physical load and the risk that pain becomes long-term",
        "It replaces the need for any professional support",
        "It is only useful for athletes",
      ],
      answer: 1,
    ),
    QuizItemModel(
      question: "Which statement best describes graded activity?",
      options: [
        "Doing the most difficult activity first",
        "Avoiding all activities that cause any sensation",
        "Starting with a manageable level of activity and gradually increasing it over time",
        "Only stretching when pain is zero",
      ],
      answer: 2,
    ),
    QuizItemModel(
      question: "Why can understanding pain help reduce long-term sick days?",
      options: [
        "It has no effect on sick days",
        "It only helps elite athletes",
        "It reduces unhelpful avoidance behaviour and supports earlier, safer return to normal activity",
        "It replaces the need for any workstation improvements",
      ],
      answer: 2,
    ),
  ],
);
