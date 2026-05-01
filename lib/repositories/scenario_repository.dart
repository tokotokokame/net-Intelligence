import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/scenario.dart';
import '../data/seed_scenarios.dart';
import 'dart:developer' as developer;

class ScenarioRepository {
  static Database? _db;

  Future<Database> get db async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'net_intelligence.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE scenarios (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            category TEXT NOT NULL,
            difficulty TEXT NOT NULL,
            question_ids TEXT NOT NULL,
            prerequisite TEXT
          )
        ''');
        developer.log('[ScenarioRepository] DB created, seeding data...');
        await _seed(db);
      },
    );
  }

  Future<void> _seed(Database db) async {
    for (final s in kSeedScenarios) {
      await db.insert('scenarios', {
        'id': s.id,
        'title': s.title,
        'description': s.description,
        'category': s.category.name,
        'difficulty': s.difficulty.name,
        'question_ids': s.questionIds.join(','),
        'prerequisite': s.prerequisite,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    developer.log('[ScenarioRepository] Seeded ${kSeedScenarios.length} scenarios');
  }

  Future<List<Scenario>> getAll() async {
    final database = await db;
    final rows = await database.query('scenarios');
    return rows.map(_fromRow).toList();
  }

  Future<List<Scenario>> getByCategory(ScenarioCategory category) async {
    final database = await db;
    final rows = await database.query(
      'scenarios', where: 'category = ?', whereArgs: [category.name],
    );
    return rows.map(_fromRow).toList();
  }

  Scenario _fromRow(Map<String, dynamic> row) {
    return Scenario(
      id: row['id'] as String,
      title: row['title'] as String,
      description: row['description'] as String,
      category: ScenarioCategory.values.byName(row['category'] as String),
      difficulty: DifficultyLevel.values.byName(row['difficulty'] as String),
      questionIds: (row['question_ids'] as String).split(','),
      prerequisite: row['prerequisite'] as String?,
    );
  }
}
