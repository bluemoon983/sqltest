import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart'; // join 함수를 사용하기 위해 추가

class DatabaseService {
  static final DatabaseService _database = DatabaseService._internal();
  late Future<Database> database;

  factory DatabaseService() => _database;

  DatabaseService._internal() {
    databaseConfig();
  }

  Future<bool> databaseConfig() async {
    try {
      // 경로를 올바르게 조합하기 위해 join 사용
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
}
