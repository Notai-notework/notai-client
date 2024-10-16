import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DocumentRepository {
  static final DocumentRepository _instance = DocumentRepository._internal();

  static Database? _database;

  DocumentRepository._internal();

  factory DocumentRepository() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _init();
    return _database!;
  }

  Future<Database> _init() async {
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, 'documents.db');

    return await openDatabase(
      readOnly: false,
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<List<Map<String, dynamic>>> getDocuments() async {
    final db = await database;
    // await insert();
    print(
        'Fetching documents from database...=================================');
    final result = await db.query('document');
    // await db.delete('document');
    print('Documents fetched: $result');
    return result.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future _onCreate(Database database, int version) async {
    await database.execute('''
      CREATE TABLE document ( -- document 테이블
        id INTEGER PRIMARY KEY AUTOINCREMENT, -- id PK,
        folder_id INTEGER, -- 폴더 id
        name TEXT, -- 문서 이름
        is_bookmark INTEGER, -- 문서 즐겨찾기 여부(1 or 0)
        created_at TEXT, -- 문서 생성 시간
        updated_at TEXT, -- 문서 수정 시간
        FOREIGN KEY(folder_id) REFERENCES folder(id)
      );
    ''');
  }

  // 문서 id로 조회
  Future<Map<String, dynamic>> findById(int id) async {
    final db = await database;

    List<Map<String, dynamic>> foundDocuments =
        await db.query('document', where: 'id = ?', whereArgs: [id]);

    return foundDocuments.first;
  }

  // 문서 이름(name)으로 조회
  Future<Map<String, dynamic>> findByName(String name) async {
    final db = await database;

    List<Map<String, dynamic>> foundDocuments =
        await db.query('document', where: 'name = ?', whereArgs: [name]);

    return foundDocuments.first;
  }

  // 새 문서 생성
  Future<int> insert(String fileName) async {
    final db = await database;
    Map<String, dynamic> document = {};
    document['name'] = fileName;
    document['is_bookmark'] = 0;
    document['created_at'] = _getCurrentTimestamp();
    document['updated_at'] = _getCurrentTimestamp();
    return await db.insert('document', document);
  }

  // 문서 이름 수정
  // 성공 시 1, 실패 시 0 반환
  Future<int> updateName(int id, String name) async {
    final db = await database;

    // id로 문서 조회
    List<Map<String, dynamic>> result =
        await db.query('document', where: 'id = ?', whereArgs: [id]);

    if (result.isNotEmpty) {
      // 저장
      await db.update('document', {'name': name},
          where: 'id = ?', whereArgs: [id]);
    } else {
      print('ID $id FILE NOT FOUND');
      return 0;
    }

    return 1;
  }

  Future<void> remove(int id) async {
    final db = await database;
    await db.delete('document', where: 'id = ?', whereArgs: [id]);
  }

  // 현재 시간
  String _getCurrentTimestamp() {
    return DateTime.now().toIso8601String();
  }
}
