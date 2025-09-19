import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import '../models/pessoa.dart';

class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static const String _dbName = 'meu_banco.db';
  static const String _table = 'pessoas';

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    Future<void> onCreate(Database db, int version) async {
      await db.execute('''
        CREATE TABLE $_table(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nome TEXT NOT NULL,
          idade INTEGER NOT NULL
        )
      ''');
    }

    if (kIsWeb) {
      return await databaseFactory.openDatabase(
        _dbName,
        options: OpenDatabaseOptions(version: 1, onCreate: onCreate),
      );
    } else {
      final dbDir = await getDatabasesPath();
      final path = p.join(dbDir, _dbName);
      return await openDatabase(path, version: 1, onCreate: onCreate);
    }
  }

  Future<int> insert(Pessoa p) async {
    final db = await database;
    return db.insert(
      _table,
      p.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<Pessoa?> getById(int id) async {
    final db = await database;
    final result = await db.query(
      _table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return Pessoa.fromMap(result.first);
  }

  Future<List<Pessoa>> getAll() async {
    final db = await database;
    final maps = await db.query(_table, orderBy: 'id DESC');
    return maps.map((m) => Pessoa.fromMap(m)).toList();
  }

  Future<int> update(Pessoa p) async {
    if (p.id == null) return 0;
    final db = await database;
    return db.update(_table, p.toMap(), where: 'id = ?', whereArgs: [p.id]);
  }

  Future<int> delete(int id) async {
    final db = await database;
    return db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }
}
