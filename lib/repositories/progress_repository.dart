import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_progress.dart';
import 'dart:developer' as developer;

class ProgressRepository {
  static Database? _db;

  Future<Database> get db async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    try {
      final path = join(await getDatabasesPath(), 'net_intelligence_progress.db');
      developer.log('[ProgressRepository] Opening DB at \$path');
      return openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await _createTables(db);
          developer.log('[ProgressRepository] DB created');
        },
      );
    } catch (e) {
      developer.log('[ProgressRepository] DB init error: \$e');
      rethrow;
    }
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS question_results (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        question_id TEXT NOT NULL,
        scenario_id TEXT NOT NULL,
        chosen_choice_id TEXT NOT NULL,
        is_correct INTEGER NOT NULL,
        score INTEGER NOT NULL,
        answered_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> saveResult(QuestionResult result, String scenarioId) async {
    try {
      final database = await db;
      await database.insert('question_results', {
        'question_id': result.questionId,
        'scenario_id': scenarioId,
        'chosen_choice_id': result.chosenChoiceId,
        'is_correct': result.isCorrect ? 1 : 0,
        'score': result.score,
        'answered_at': result.answeredAt.toIso8601String(),
      });
      developer.log('[ProgressRepository] Saved: \${result.questionId}');
    } catch (e) {
      developer.log('[ProgressRepository] Save error: \$e');
    }
  }

  Future<List<QuestionResult>> getResultsForScenario(String scenarioId) async {
    try {
      final database = await db;
      final rows = await database.query(
        'question_results',
        where: 'scenario_id = ?',
        whereArgs: [scenarioId],
        orderBy: 'answered_at DESC',
      );
      return rows.map((r) => QuestionResult(
        questionId: r['question_id'] as String,
        chosenChoiceId: r['chosen_choice_id'] as String,
        isCorrect: (r['is_correct'] as int) == 1,
        score: r['score'] as int,
        answeredAt: DateTime.parse(r['answered_at'] as String),
      )).toList();
    } catch (e) {
      developer.log('[ProgressRepository] getResults error: \$e');
      return [];
    }
  }

  Future<Map<String, double>> getAccuracyByCategory(
    Map<String, String> questionToCategoryMap,
  ) async {
    try {
      final database = await db;
      final rows = await database.query('question_results');
      final categoryResults = <String, List<bool>>{};

      for (final row in rows) {
        final qId = row['question_id'] as String;
        final category = questionToCategoryMap[qId];
        if (category == null) continue;
        categoryResults.putIfAbsent(category, () => []);
        categoryResults[category]!.add((row['is_correct'] as int) == 1);
      }

      return categoryResults.map((k, v) =>
          MapEntry(k, v.isEmpty ? 0.0 : v.where((x) => x).length / v.length));
    } catch (e) {
      developer.log('[ProgressRepository] getAccuracy error: \$e');
      return {};
    }
  }

  Future<int> getTotalScore() async {
    try {
      final database = await db;
      final result = await database.rawQuery(
          'SELECT SUM(score) as total FROM question_results');
      return (result.first['total'] as int?) ?? 0;
    } catch (e) {
      developer.log('[ProgressRepository] getTotalScore error: \$e');
      return 0;
    }
  }
}
