import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqltest/word.dart';

class DatabaseService {
  // 싱글톤 패턴을 사용하여 DatabaseService 클래스의 단일 인스턴스 생성
  static final DatabaseService _database = DatabaseService._internal();

  // 데이터베이스 인스턴스를 비동기적으로 관리할 Future 타입의 변수
  late Future<Database> database;

  // 외부에서 DatabaseService를 호출할 때 싱글톤 인스턴스를 반환하는 팩토리 생성자
  factory DatabaseService() => _database;

  // 내부 생성자: 싱글톤 패턴 구현을 위한 생성자
  DatabaseService._internal() {
    databaseConfig(); // 데이터베이스 설정을 초기화
  }

  // 데이터베이스 설정 및 테이블 생성 함수
  Future<bool> databaseConfig() async {
    try {
      // 데이터베이스 경로를 지정하고, 'word_database.db'라는 데이터베이스 생성
      database = openDatabase(
        join(await getDatabasesPath(), 'word_database.db'),
        // 데이터베이스가 처음 생성될 때 호출되어 테이블을 만드는 부분
        onCreate: (db, version) {
          return db.execute(
            'CREATE TABLE words(id INTEGER PRIMARY KEY, name TEXT, meaning TEXT)',
          );
        },
        version: 1, // 데이터베이스 버전 설정
      );

      return true; // 성공적으로 설정되면 true 반환
    } catch (err) {
      print(err.toString()); // 오류가 발생하면 오류 메시지 출력

      return false; // 오류 발생 시 false 반환
    }
  }

  // 데이터베이스에 Word 객체를 삽입하는 함수
  Future<bool> insertWord(Word word) async {
    // 데이터베이스 인스턴스를 가져옴
    final Database db = await database;
    try {
      // 'words' 테이블에 Word 객체를 삽입하고, 충돌 발생 시 기존 데이터 대체
      db.insert(
        'words',
        word.toMap(), // Word 객체를 Map 형태로 변환하여 삽입
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return true; // 성공적으로 삽입되면 true 반환
    } catch (err) {
      return false; // 오류 발생 시 false 반환
    }
  }

  // 데이터베이스에서 모든 단어를 조회하는 함수
  Future<List<Word>> selectWords() async {
    // 데이터베이스 인스턴스를 가져옴
    final Database db = await database;

    // 'words' 테이블의 모든 데이터를 조회
    final List<Map<String, dynamic>> data = await db.query('words');

    // 조회된 데이터를 Word 객체 리스트로 변환하여 반환
    return List.generate(data.length, (i) {
      return Word(
        id: data[i]['id'],
        name: data[i]['name'],
        meaning: data[i]['meaning'],
      );
    });
  }

  // 주어진 id에 해당하는 단어를 조회하는 함수
  Future<Word> selectWord(int id) async {
    // 데이터베이스 인스턴스를 가져옴
    final Database db = await database;

    // 'words' 테이블에서 특정 id에 해당하는 단어 조회
    final List<Map<String, dynamic>> data =
        await db.query('words', where: "id = ?", whereArgs: [id]);

    // 조회된 데이터를 기반으로 Word 객체 생성 및 반환
    return Word(
        id: data[0]['id'], name: data[0]['name'], meaning: data[0]['meaning']);
  }

  // 데이터베이스에서 Word 객체를 업데이트하는 함수
  Future<bool> updateWord(Word word) async {
    // 데이터베이스 인스턴스를 가져옴
    final Database db = await database;

    try {
      // 'words' 테이블에서 주어진 id에 해당하는 데이터를 업데이트
      db.update(
        'words',
        word.toMap(), // 업데이트할 Word 객체를 Map 형태로 변환
        where: "id = ?", // 업데이트할 조건 (id)
        whereArgs: [word.id], // 조건에 해당하는 값 (word.id)
      );

      return true; // 성공적으로 업데이트되면 true 반환
    } catch (err) {
      return false; // 오류 발생 시 false 반환
    }
  }

  // 데이터베이스에서 특정 id에 해당하는 단어를 삭제하는 함수
  Future<bool> deleteWord(int id) async {
    // 데이터베이스 인스턴스를 가져옴
    final Database db = await database;

    try {
      // 'words' 테이블에서 주어진 id에 해당하는 데이터를 삭제
      db.delete(
        'words',
        where: "id = ?", // 삭제할 조건 (id)
        whereArgs: [id], // 조건에 해당하는 값 (id)
      );

      return true; // 성공적으로 삭제되면 true 반환
    } catch (err) {
      return false; // 오류 발생 시 false 반환
    }
  }
}
