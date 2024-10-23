// import 'package:flutter/s'

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class FolderRepository {
  static final FolderRepository _instance = FolderRepository._internal();

  static Database? _database;

  FolderRepository._internal();

  String _databaseName = 'folder';

  factory FolderRepository() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _init();
    return _database!;
  }

  Future<Database> _init() async {
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, 'folders.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database database, int version) async {
    await database.execute('''
      CREATE TABLE $_database ( -- document 테이블
        id INTEGER AUTOINCREMENT, -- 폴더 id
        name TEXT, -- 폴더 이름
        parent_id INTEGER DEFAULT 0, -- 상위 folder id (최상위는 0)
        created_at TEXT, -- 문서 생성 시간
        updated_at TEXT, -- 문서 수정 시간
        PRIMARY KEY (name, parent_id), -- 폴더 이름, parent_id로 복합키 설정
        FOREIGN KEY(parent_id) REFERENCES $_databaseName(id) -- 외래키(parent_id) 설정
      )
    ''');
  }

  // 폴더 id로 조회
  Future<Map<String, dynamic>> findById(int id) async {
    final db = await database;

    List<Map<String, dynamic>> foundDocuments =
        await db.query(_databaseName, where: 'id = ?', whereArgs: [id]);

    return foundDocuments.first;
  }

  // 폴더 id(parent_id)로 하위 폴더 목록 조회
  Future<List<Map<String, dynamic>>> findDownFoldersById(int id) async {
    final db = await database;

    List<Map<String, dynamic>> foundFolders =
    await db.query(_databaseName, where: 'parent_id = ?', whereArgs: [id]);

    return foundFolders;
  }

  // 새 폴더 생성
  // 생성에 성공하면 id, 실패하면 0 반환
  Future<int> insert() async {
    final db = await database;
    Map<String, dynamic> document = {};
    document['name'] = '제목 없음';
    document['is_bookmark'] = 0;
    document['created_at'] = _getCurrentTimestamp();
    document['updated_at'] = _getCurrentTimestamp();
    return await db.insert(_databaseName, document);
  }

  // 문서 이름 수정
  // 성공 시 1, 실패 시 0 반환
  Future<int> updateName(int id, String name) async {
    final db = await database;

    // id로 문서 조회
    List<Map<String, dynamic>> result =
        await db.query(_databaseName, where: 'id = ?', whereArgs: [id]);

    if (result.isNotEmpty) {
      Map<String, dynamic> foundDocument = result.first;
      foundDocument['name'] = name; // name 수정
      foundDocument['updated_at'] = _getCurrentTimestamp();

      // 저장
      await db.update(_databaseName, foundDocument,
          where: 'id = ?', whereArgs: [id]);
    } else {
      print('ID $id FILE NOT FOUND');
      return 0;
    }

    return 1;
  }

  String _getCurrentTimestamp() {
    return DateTime.now().toIso8601String();
  }
}
