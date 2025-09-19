import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:path/path.dart' as p;
import 'dart:io' show Platform;

class DatabaseFactoryProvider {
  static Future<Database> create(String dbName) async {
    Future<void> onCreate(Database db, int version) async {
      await db.execute('''
        CREATE TABLE pessoas(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nome TEXT NOT NULL,
          idade INTEGER NOT NULL
        )
      ''');
    }

    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
      return databaseFactory.openDatabase(
        dbName,
        options: OpenDatabaseOptions(version: 1, onCreate: onCreate),
      );
    } else {
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
      final dbDir = await getDatabasesPath();
      final path = p.join(dbDir, dbName);
      return openDatabase(path, version: 1, onCreate: onCreate);
    }
  }
}
