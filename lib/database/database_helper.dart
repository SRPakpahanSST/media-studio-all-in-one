import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('media_studio.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Tabel riwayat konversi MP4 -> MP3
    await db.execute('''
      CREATE TABLE conversions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        source_path TEXT NOT NULL,
        output_path TEXT NOT NULL,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Tabel riwayat rekaman layar
    await db.execute('''
      CREATE TABLE recordings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        file_path TEXT NOT NULL,
        duration INTEGER NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Tabel project musik
    await db.execute('''
      CREATE TABLE music_projects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        data TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Tabel pengaturan aplikasi
    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  // ===== CRUD Conversions =====
  Future<int> insertConversion(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert('conversions', row);
  }

  Future<List<Map<String, dynamic>>> getConversions() async {
    final db = await database;
    return await db.query('conversions', orderBy: 'created_at DESC');
  }

  Future<int> deleteConversion(int id) async {
    final db = await database;
    return await db.delete('conversions', where: 'id = ?', whereArgs: [id]);
  }

  // ===== CRUD Recordings =====
  Future<int> insertRecording(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert('recordings', row);
  }

  Future<List<Map<String, dynamic>>> getRecordings() async {
    final db = await database;
    return await db.query('recordings', orderBy: 'created_at DESC');
  }

  // ===== CRUD Music Projects =====
  Future<int> insertMusicProject(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert('music_projects', row);
  }

  Future<List<Map<String, dynamic>>> getMusicProjects() async {
    final db = await database;
    return await db.query('music_projects', orderBy: 'updated_at DESC');
  }

  Future<int> updateMusicProject(int id, Map<String, dynamic> row) async {
    final db = await database;
    return await db.update('music_projects', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteMusicProject(int id) async {
    final db = await database;
    return await db.delete('music_projects', where: 'id = ?', whereArgs: [id]);
  }

  // ===== Settings =====
  Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getSetting(String key) async {
    final db = await database;
    final result = await db.query('settings', where: 'key = ?', whereArgs: [key]);
    if (result.isEmpty) return null;
    return result.first['value'] as String;
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}