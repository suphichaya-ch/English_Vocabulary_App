import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/word_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('vocab.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE words (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        word TEXT NOT NULL,
        translation TEXT NOT NULL,
        type TEXT,
        difficulty TEXT,
        isMemorized INTEGER,
        sentence TEXT
      )
    ''');
  }

  // --- CRUD Operations ---

  Future<int> insert(Word word) async {
    final db = await instance.database;
    return await db.insert('words', word.toMap());
  }

  Future<List<Word>> getAllWords() async {
    final db = await instance.database;
    final result = await db.query('words');
    return result.map((json) => Word.fromMap(json)).toList();
  }

  // ฟังก์ชันแก้ไข (ต้องชื่อ update และรับ parameter เป็น Word)
  Future<int> update(Word word) async {
    final db = await instance.database;
    return await db.update(
      'words',
      word.toMap(),
      where: 'id = ?',
      whereArgs: [word.id],
    );
  }

  // ฟังก์ชันลบ (ต้องชื่อ delete และรับ parameter เป็น int)
  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete('words', where: 'id = ?', whereArgs: [id]);
  }
}
