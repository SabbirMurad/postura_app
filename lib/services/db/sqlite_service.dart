import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

class Sqlite {
  static Database? _db;
  static final Sqlite instance = Sqlite._constructor();

  Sqlite._constructor();

  Future<Database> get database async {
    if (_db != null) {
      return _db!;
    }

    _db = await _getDataBase();
    return _db!;
  }

  Future<void> init() async {
    try {
      final db = await database;
      await db.execute('''
      CREATE TABLE IF NOT EXISTS quiz_result (
        id INTEGER PRIMARY KEY,
        score INTEGER NOT NULL
      )
      ''');
    } catch (e) {
      debugPrint('SQLite init error: $e');
    }
  }

  Future<Database> _getDataBase() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = '$databaseDirPath/posture_care.db';
    final database = await openDatabase(databasePath, version: 1);

    return database;
  }

  Future<bool> insert({
    required String table,
    required Map<String, dynamic> data,
  }) async {
    try {
      final db = await database;
      final count = await db.insert(table, data);
      return count != 0;
    } catch (e) {
      debugPrint('SQLite insert error ($table): $e');
      return false;
    }
  }

  Future<bool> insertMany({
    required String table,
    required List<Map<String, dynamic>> dataList,
  }) async {
    try {
      final db = await database;
      await db.transaction((txn) async {
        for (final data in dataList) {
          await txn.insert(table, data);
        }
      });
      return true;
    } catch (e) {
      debugPrint('SQLite insertMany error ($table): $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> query({
    required String table,
    String? where,
    int? limit,
    int? offset,
    String? orderBy,
    List<dynamic>? whereArgs,
  }) async {
    try {
      final db = await database;
      return db.query(
        table,
        where: where,
        whereArgs: whereArgs,
        limit: limit ?? 100,
        offset: offset,
        orderBy: orderBy,
      );
    } catch (e) {
      debugPrint('SQLite query error ($table): $e');
      return [];
    }
  }

  Future<int> delete({
    required String table,
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    try {
      final db = await database;
      return await db.delete(table, where: where, whereArgs: whereArgs);
    } catch (e) {
      debugPrint('SQLite delete error ($table): $e');
      return 0;
    }
  }

  Future<bool> update({
    required String table,
    required Map<String, dynamic> data,
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    try {
      final db = await database;
      final count = await db.update(
        table,
        data,
        where: where,
        whereArgs: whereArgs,
      );
      return count != 0;
    } catch (e) {
      debugPrint('SQLite update error ($table): $e');
      return false;
    }
  }
}
