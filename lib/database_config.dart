import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqltest/word.dart';

class DatabaseService {
  static final DatabaseService _database = DatabaseService._internal();

  late Future<Database> database;

  factory DatabaseService() => _database;

  DatabaseService._internal() {
    databaseConfig();
  }

  Future<bool> databaseConfig() async {
    try {
      database = openDatabase(
        join(await getDatabasesPath(), 'word_database.db'),
        onCreate: (db, version) {
          return db.execute(
            'CREATE TABLE words(id INTEGER PRIMARY KEY, name TEXT, meaning TEXT)',
          );
        },
        version: 1,
      );

      return true;
    } catch (err) {
      print(err.toString());

      return false;
    }
  }

  Future<bool> insertWord(Word word) async {
    final Database db = await database;
    try {
      db.insert(
        'words',
        word.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return true;
    } catch (err) {
      return false;
    }
  }

  Future<List<Word>> selectWords() async {
    final Database db = await database;

    final List<Map<String, dynamic>> data = await db.query('words');

    return List.generate(data.length, (i) {
      return Word(
        id: data[i]['id'],
        name: data[i]['name'],
        meaning: data[i]['meaning'],
      );
    });
  }

  Future<Word> selectWord(int id) async {
    final Database db = await database;

    final List<Map<String, dynamic>> data =
        await db.query('words', where: "id = ?", whereArgs: [id]);

    return Word(
        id: data[0]['id'], name: data[0]['name'], meaning: data[0]['meaning']);
  }

  Future<bool> updateWord(Word word) async {
    final Database db = await database;

    try {
      db.update(
        'words',
        word.toMap(),
        where: "id = ?",
        whereArgs: [word.id],
      );

      return true;
    } catch (err) {
      return false;
    }
  }

  Future<bool> deleteWord(int id) async {
    final Database db = await database;

    try {
      db.delete(
        'words',
        where: "id = ?",
        whereArgs: [id],
      );

      return true;
    } catch (err) {
      return false;
    }
  }
}
