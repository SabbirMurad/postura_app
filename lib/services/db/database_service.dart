// lib/services/database_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:posture_detector_app/models/quiz/module.dart';
import 'package:posture_detector_app/models/quiz/question_model.dart';
import 'package:posture_detector_app/models/quiz/quiz_attempt.dart';

class DatabaseService extends GetxService {
  static final DatabaseService instance = DatabaseService._init();
  Database? _database;

  DatabaseService._init();

  Future<DatabaseService> init() async {
    _database = await _initDatabase();
    return this;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'elearning_quiz.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        debugPrint('DB: Creating database tables...');
        await db.execute('''
          CREATE TABLE modules(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            module_id TEXT UNIQUE,
            title TEXT,
            description TEXT,
            score INTEGER DEFAULT 0,
            is_completed INTEGER DEFAULT 0,
            is_unlocked INTEGER DEFAULT 0,
            last_attempt TEXT,
            total_questions INTEGER DEFAULT 5,
            attempts INTEGER DEFAULT 0,
            created_at TEXT DEFAULT CURRENT_TIMESTAMP
          )
        ''');

        await db.execute('''
          CREATE TABLE questions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            module_id TEXT,
            question_text TEXT,
            options TEXT,
            correct_answer_index INTEGER,
            explanation TEXT,
            FOREIGN KEY (module_id) REFERENCES modules (module_id)
          )
        ''');

        await db.execute('''
          CREATE TABLE quiz_attempts(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            module_id TEXT,
            score INTEGER,
            total_questions INTEGER,
            passed INTEGER,
            timestamp TEXT,
            user_answers TEXT,
            FOREIGN KEY (module_id) REFERENCES modules (module_id)
          )
        ''');

        await _insertInitialData(db);
      },
      onOpen: (db) async {
        debugPrint('DB: Database opened. Checking data...');
        final count = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM modules'),
        );
        if (count == 0) {
          debugPrint('DB: Modules table empty. Inserting initial data...');
          await _insertInitialData(db);
        } else {
          debugPrint('DB: Found $count modules.');
        }
      },
    );
  }

  Future<void> _insertInitialData(Database db) async {
    // Define modules
    final modules = [
      {
        'module_id': 'module_1',
        'title': 'Core Ergonomics and Risk',
        'description': 'Learn the basics of ergonomics',
        'is_unlocked': 1,
        'total_questions': 5,
      },
      {
        'module_id': 'module_2',
        'title': 'Advanced Ergonomics',
        'description': 'Deep dive into ergonomic principles',
        'is_unlocked': 0,
        'total_questions': 5,
      },
      {
        'module_id': 'module_3',
        'title': 'Workplace Safety',
        'description': 'Understand safety standards and practices',
        'is_unlocked': 0,
        'total_questions': 5,
      },
      {
        'module_id': 'module_4',
        'title': 'Musculoskeletal Disorders',
        'description': 'Learn about MSDs and prevention',
        'is_unlocked': 0,
        'total_questions': 5,
      },
      {
        'module_id': 'module_5',
        'title': 'Ergonomic Tools and Equipment',
        'description': 'Tools to enhance comfort and productivity',
        'is_unlocked': 0,
        'total_questions': 5,
      },
      {
        'module_id': 'module_6',
        'title': 'Ergonomics in Remote Work',
        'description': 'Optimizing your home workstation',
        'is_unlocked': 0,
        'total_questions': 5,
      },
    ];

    // Insert modules
    for (var module in modules) {
      await db.insert('modules', module);
    }

    // Define comprehensive questions per module
    final allQuestions = {
      'module_1': [
        {
          'question_text': 'What is the main goal of ergonomics?',
          'options': json.encode([
            'Make people work faster at any cost',
            'Adapt work and tools to human limits and comfort',
            'Replace workers with automation',
            'Focus only on productivity',
          ]),
          'correct_answer_index': 1,
          'explanation':
              'Ergonomics aims to adapt work conditions to fit human capabilities and limitations, improving both comfort and productivity.',
        },
        {
          'question_text':
              'Which body part is most commonly affected by poor ergonomics?',
          'options': json.encode([
            'Feet',
            'Back and neck',
            'Hands only',
            'Head',
          ]),
          'correct_answer_index': 1,
          'explanation':
              'The back and neck are most vulnerable to poor ergonomic practices due to prolonged sitting and incorrect posture.',
        },
        {
          'question_text':
              'What is the recommended monitor height for optimal ergonomics?',
          'options': json.encode([
            'Above eye level',
            'At or slightly below eye level',
            'At chest level',
            'Any height is fine',
          ]),
          'correct_answer_index': 1,
          'explanation':
              'The monitor should be at or slightly below eye level to reduce neck strain and maintain proper posture.',
        },
        {
          'question_text':
              'How often should you take breaks when working at a computer?',
          'options': json.encode([
            'Every 30 minutes',
            'Every 2 hours',
            'Once per day',
            'Breaks are not necessary',
          ]),
          'correct_answer_index': 0,
          'explanation':
              'Taking short breaks every 20-30 minutes helps reduce eye strain, muscle fatigue, and improves concentration.',
        },
        {
          'question_text':
              'What is a common risk factor for developing work-related injuries?',
          'options': json.encode([
            'Proper lighting',
            'Repetitive motions',
            'Adjustable chair',
            'Regular exercise',
          ]),
          'correct_answer_index': 1,
          'explanation':
              'Repetitive motions without proper breaks or ergonomic setup significantly increase the risk of musculoskeletal disorders.',
        },
      ],
      'module_2': [
        {
          'question_text': 'Which factor is important in advanced ergonomics?',
          'options': json.encode([
            'Workspace design',
            'Employee feedback',
            'Equipment optimization',
            'All of the above',
          ]),
          'correct_answer_index': 3,
          'explanation':
              'Advanced ergonomics considers workspace design, employee input, and equipment optimization for comprehensive solutions.',
        },
        {
          'question_text': 'What is the ideal keyboard position?',
          'options': json.encode([
            'Above elbow level',
            'At or slightly below elbow level',
            'On your lap',
            'Position doesn\'t matter',
          ]),
          'correct_answer_index': 1,
          'explanation':
              'The keyboard should be positioned so your elbows are at a 90-degree angle or slightly more, reducing strain on arms and shoulders.',
        },
        {
          'question_text': 'What is the 20-20-20 rule for eye strain?',
          'options': json.encode([
            'Work for 20 hours straight',
            'Every 20 minutes, look at something 20 feet away for 20 seconds',
            'Blink 20 times every 20 minutes',
            'Take 20 minute breaks',
          ]),
          'correct_answer_index': 1,
          'explanation':
              'The 20-20-20 rule helps reduce digital eye strain by giving your eyes regular breaks from screen focus.',
        },
        {
          'question_text': 'Which lighting is best for computer work?',
          'options': json.encode([
            'Direct overhead lighting',
            'Indirect ambient lighting with task lighting',
            'Complete darkness',
            'Bright sunlight directly on screen',
          ]),
          'correct_answer_index': 1,
          'explanation':
              'Indirect lighting reduces glare while task lighting provides adequate illumination for specific work areas.',
        },
        {
          'question_text':
              'What is the recommended distance between eyes and monitor?',
          'options': json.encode([
            '10-15 inches',
            '20-26 inches (arm\'s length)',
            '30-40 inches',
            'Distance doesn\'t matter',
          ]),
          'correct_answer_index': 1,
          'explanation':
              'An arm\'s length (20-26 inches) is optimal to reduce eye strain while maintaining clear visibility.',
        },
      ],
      'module_3': [
        {
          'question_text': 'What is the main focus of workplace safety?',
          'options': json.encode([
            'Prevent injuries and accidents',
            'Increase productivity only',
            'Monitor employee hours',
            'Implement more meetings',
          ]),
          'correct_answer_index': 0,
          'explanation':
              'Workplace safety primarily aims to prevent injuries, accidents, and occupational hazards.',
        },
        {
          'question_text': 'What should you do if you notice a safety hazard?',
          'options': json.encode([
            'Ignore it',
            'Report it immediately to your supervisor',
            'Fix it yourself without training',
            'Wait for someone else to notice',
          ]),
          'correct_answer_index': 1,
          'explanation':
              'Reporting hazards immediately allows proper assessment and correction by qualified personnel.',
        },
        {
          'question_text': 'Which of these is a proper lifting technique?',
          'options': json.encode([
            'Bend at waist and lift with back',
            'Bend knees and lift with legs',
            'Twist while lifting',
            'Lift as quickly as possible',
          ]),
          'correct_answer_index': 1,
          'explanation':
              'Bending at the knees and using leg muscles protects your back from injury during lifting.',
        },
        {
          'question_text': 'What is the purpose of safety training?',
          'options': json.encode([
            'To waste time',
            'To educate workers on hazards and prevention',
            'To blame workers for accidents',
            'Only for new employees',
          ]),
          'correct_answer_index': 1,
          'explanation':
              'Safety training equips workers with knowledge to identify hazards and practice safe work procedures.',
        },
        {
          'question_text': 'How should workstations be organized for safety?',
          'options': json.encode([
            'Keep frequently used items within easy reach',
            'Store everything far away',
            'Clutter is acceptable',
            'Safety doesn\'t relate to organization',
          ]),
          'correct_answer_index': 0,
          'explanation':
              'Proper organization reduces unnecessary reaching, bending, and potential accidents from clutter.',
        },
      ],
      'module_4': [
        {
          'question_text':
              'Musculoskeletal disorders affect which parts of the body?',
          'options': json.encode([
            'Only bones',
            'Muscles, joints, tendons, and ligaments',
            'Only skin',
            'Only the brain',
          ]),
          'correct_answer_index': 1,
          'explanation':
              'MSDs affect the musculoskeletal system including muscles, joints, tendons, ligaments, and nerves.',
        },
        {
          'question_text': 'What is carpal tunnel syndrome?',
          'options': json.encode([
            'A foot condition',
            'Compression of median nerve in the wrist',
            'A back problem',
            'An eye disorder',
          ]),
          'correct_answer_index': 1,
          'explanation':
              'Carpal tunnel syndrome results from compression of the median nerve, often due to repetitive hand motions.',
        },
        {
          'question_text': 'Which activity increases MSD risk?',
          'options': json.encode([
            'Regular stretching',
            'Prolonged static postures',
            'Proper ergonomic setup',
            'Taking frequent breaks',
          ]),
          'correct_answer_index': 1,
          'explanation':
              'Maintaining the same posture for extended periods increases muscle fatigue and MSD risk.',
        },
        {
          'question_text': 'What is an early warning sign of MSDs?',
          'options': json.encode([
            'Persistent discomfort or pain',
            'Increased energy',
            'Better sleep',
            'Improved flexibility',
          ]),
          'correct_answer_index': 0,
          'explanation':
              'Persistent discomfort, especially after work, is an early indicator of developing MSDs.',
        },
        {
          'question_text': 'How can MSDs be prevented?',
          'options': json.encode([
            'Ignore early symptoms',
            'Proper ergonomics, breaks, and stretching',
            'Work longer hours',
            'Avoid all physical activity',
          ]),
          'correct_answer_index': 1,
          'explanation':
              'Prevention combines proper ergonomic setup, regular breaks, stretching, and early intervention.',
        },
      ],
      'module_5': [
        {
          'question_text': 'Which tool improves ergonomic posture?',
          'options': json.encode([
            'Adjustable chair',
            'Standing desk',
            'Keyboard tray',
            'All of the above',
          ]),
          'correct_answer_index': 3,
          'explanation':
              'These tools all contribute to better posture and reduced strain when properly used.',
        },
        {
          'question_text': 'What feature should an ergonomic chair have?',
          'options': json.encode([
            'Lumbar support',
            'Adjustable height',
            'Adjustable armrests',
            'All of the above',
          ]),
          'correct_answer_index': 3,
          'explanation':
              'A proper ergonomic chair offers multiple adjustments to fit individual body dimensions and support needs.',
        },
        {
          'question_text': 'What is the purpose of a footrest?',
          'options': json.encode([
            'Decoration',
            'Support feet when they don\'t reach the floor',
            'Extra storage',
            'No real purpose',
          ]),
          'correct_answer_index': 1,
          'explanation':
              'Footrests maintain proper posture when chair height doesn\'t allow feet to rest flat on the floor.',
        },
        {
          'question_text': 'What type of mouse reduces wrist strain?',
          'options': json.encode([
            'Traditional mouse only',
            'Vertical or ergonomic mouse',
            'Largest mouse available',
            'Mouse choice doesn\'t matter',
          ]),
          'correct_answer_index': 1,
          'explanation':
              'Vertical and ergonomic mice maintain a more natural hand position, reducing wrist rotation and strain.',
        },
        {
          'question_text': 'Why use a document holder?',
          'options': json.encode([
            'Reduces neck strain from looking down at papers',
            'Makes desk look professional',
            'No benefit',
            'Only for decoration',
          ]),
          'correct_answer_index': 0,
          'explanation':
              'Document holders position papers at eye level, preventing repetitive neck bending and strain.',
        },
      ],
      'module_6': [
        {
          'question_text': 'What is key for remote work ergonomics?',
          'options': json.encode([
            'Proper lighting',
            'Comfortable chair',
            'Screen at eye level',
            'All of the above',
          ]),
          'correct_answer_index': 3,
          'explanation':
              'Successful remote work ergonomics requires attention to multiple factors for comfort and productivity.',
        },
        {
          'question_text': 'What is a common challenge of working from home?',
          'options': json.encode([
            'Too much ergonomic equipment',
            'Lack of proper workspace and furniture',
            'Too many breaks',
            'Excessive supervision',
          ]),
          'correct_answer_index': 1,
          'explanation':
              'Many home setups lack dedicated workspace and appropriate furniture, leading to poor ergonomics.',
        },
        {
          'question_text': 'How should you set up a laptop for extended use?',
          'options': json.encode([
            'Use it directly on lap',
            'Use external keyboard and raise laptop screen',
            'On bed is fine',
            'Setup doesn\'t matter',
          ]),
          'correct_answer_index': 1,
          'explanation':
              'Elevating the laptop screen and using an external keyboard prevents hunching and neck strain.',
        },
        {
          'question_text': 'What is important for remote work-life balance?',
          'options': json.encode([
            'Work 24/7',
            'Never take breaks',
            'Set boundaries and maintain regular schedule',
            'Work in bed always',
          ]),
          'correct_answer_index': 2,
          'explanation':
              'Establishing boundaries and routines prevents burnout and maintains physical and mental health.',
        },
        {
          'question_text': 'Where should you NOT regularly work from?',
          'options': json.encode([
            'Dedicated workspace',
            'Ergonomic desk setup',
            'Bed or couch',
            'Properly adjusted table',
          ]),
          'correct_answer_index': 2,
          'explanation':
              'Working from bed or couch encourages poor posture and blurs work-life boundaries.',
        },
      ],
    };

    // Insert questions for each module
    for (var moduleId in allQuestions.keys) {
      for (var question in allQuestions[moduleId]!) {
        await db.insert('questions', {'module_id': moduleId, ...question});
      }
    }
  }

  // ========== MODULE OPERATIONS ==========
  Future<List<Module>> getAllModules() async {
    final db = database;
    final List<Map<String, dynamic>> maps = await db.query(
      'modules',
      orderBy: 'module_id ASC',
    );
    return List.generate(maps.length, (i) => Module.fromMap(maps[i]));
  }

  Future<Module?> getModule(String moduleId) async {
    final db = database;
    final List<Map<String, dynamic>> maps = await db.query(
      'modules',
      where: 'module_id = ?',
      whereArgs: [moduleId],
    );
    if (maps.isNotEmpty) {
      return Module.fromMap(maps.first);
    }
    return null;
  }

  Future<void> updateModuleProgress(Module module) async {
    final db = database;
    await db.update(
      'modules',
      module.toMap(),
      where: 'module_id = ?',
      whereArgs: [module.moduleId],
    );
  }

  Future<void> unlockModule(String moduleId) async {
    final db = database;
    await db.update(
      'modules',
      {'is_unlocked': 1},
      where: 'module_id = ?',
      whereArgs: [moduleId],
    );
  }

  // ========== QUESTION OPERATIONS ==========
  Future<List<QuestionModel>> getQuestionsForModule(String moduleId) async {
    final db = database;
    final List<Map<String, dynamic>> maps = await db.query(
      'questions',
      where: 'module_id = ?',
      whereArgs: [moduleId],
    );
    return List.generate(maps.length, (i) => QuestionModel.fromMap(maps[i]));
  }

  // ========== ATTEMPT OPERATIONS ==========
  Future<void> saveQuizAttempt(QuizAttempt attempt) async {
    final db = database;
    await db.insert('quiz_attempts', attempt.toMap());

    // Update module stats
    final module = await getModule(attempt.moduleId);
    if (module != null) {
      // Update score only if it's better than previous
      if (attempt.score > module.score) {
        module.score = attempt.score;
      }

      // FIXED: Don't overwrite completion status
      // Once completed, always remain completed
      module.isCompleted = module.isCompleted || attempt.passed;

      module.lastAttempt = attempt.timestamp;
      module.attempts = (module.attempts) + 1;

      await updateModuleProgress(module);

      // Unlock next module if passed (first time)
      if (attempt.passed) {
        await _unlockNextModule(attempt.moduleId);
      }
    }
  }

  Future<void> _unlockNextModule(String currentModuleId) async {
    final match = RegExp(r'module_(\d+)').firstMatch(currentModuleId);
    if (match != null) {
      final int currentNumber = int.parse(match.group(1)!);
      final nextModuleId = 'module_${currentNumber + 1}';

      // Check if next module exists before unlocking
      final nextModule = await getModule(nextModuleId);
      if (nextModule != null && !nextModule.isUnlocked) {
        await unlockModule(nextModuleId);
      }
    }
  }

  Future<List<QuizAttempt>> getQuizHistory(String moduleId) async {
    final db = database;
    final List<Map<String, dynamic>> maps = await db.query(
      'quiz_attempts',
      where: 'module_id = ?',
      whereArgs: [moduleId],
      orderBy: 'timestamp DESC',
    );
    return List.generate(maps.length, (i) => QuizAttempt.fromMap(maps[i]));
  }

  // ========== STATISTICS ==========
  Future<Map<String, dynamic>> getUserStatistics() async {
    final db = database;

    final completedModules = await db.rawQuery(
      'SELECT COUNT(*) as count FROM modules WHERE is_completed = 1',
    );

    final totalAttempts = await db.rawQuery(
      'SELECT COUNT(*) as count FROM quiz_attempts',
    );

    final avgScore = await db.rawQuery(
      'SELECT AVG(score) as avg FROM quiz_attempts',
    );

    final totalModules = await db.rawQuery(
      'SELECT COUNT(*) as count FROM modules',
    );

    return {
      'completedModules': completedModules.first['count'] ?? 0,
      'totalModules': totalModules.first['count'] ?? 0,
      'totalAttempts': totalAttempts.first['count'] ?? 0,
      'averageScore': (avgScore.first['avg'] ?? 0.0) as num,
    };
  }

  // ========== UTILITY ==========
  Database get database {
    if (_database == null) {
      throw Exception('Database not initialized. Call init() first.');
    }
    return _database!;
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  // Reset database (for testing purposes)
  Future<void> resetDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'elearning_quiz.db');

    await deleteDatabase(path);
    _database = await _initDatabase();
  }
}
