// test/data/dao/pessoa_dao_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'dart:io';

import 'package:exemplo/data/dao/pessoa_dao.dart';
import 'package:exemplo/models/pessoa.dart';

void main() {
  late Database db;
  late PessoaDao dao;

  setUpAll(() async {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
      db = await databaseFactory.openDatabase(
        'test_pessoas.db',
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, version) async {
            await db.execute('''
              CREATE TABLE pessoas(
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                nome TEXT NOT NULL,
                idade INTEGER NOT NULL
              )
            ''');
          },
        ),
      );
    } else {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      final dbDir = await getDatabasesPath();
      final path = p.join(dbDir, 'test_pessoas.db');
      db = await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE pessoas(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              nome TEXT NOT NULL,
              idade INTEGER NOT NULL
            )
          ''');
        },
      );
    }
    dao = PessoaDao(db);
  });

  tearDownAll(() async {
    await db.close();
  });

  test('inserir e buscar pessoa', () async {
    final p1 = Pessoa(nome: 'Alice', idade: 30);
    final id = await dao.insert(p1);
    expect(id, isNonZero);

    final fetched = await dao.getById(id);
    expect(fetched, isNotNull);
    expect(fetched!.nome, equals('Alice'));
    expect(fetched.idade, equals(30));
  });

  test('listar pessoas', () async {
    await dao.insert(Pessoa(nome: 'Bob', idade: 25));
    final lista = await dao.getAll();
    expect(lista.length, greaterThanOrEqualTo(1));
    expect(lista.map((p) => p.nome), contains('Bob'));
  });

  test('atualizar pessoa', () async {
    final p2 = Pessoa(nome: 'Carlos', idade: 40);
    final id = await dao.insert(p2);
    final updated = p2.copyWith(id: id, nome: 'Carlos Updated', idade: 41);
    final count = await dao.update(updated);
    expect(count, equals(1));

    final fetched = await dao.getById(id);
    expect(fetched!.nome, equals('Carlos Updated'));
    expect(fetched.idade, equals(41));
  });

  test('deletar pessoa', () async {
    final p3 = Pessoa(nome: 'Diana', idade: 22);
    final id = await dao.insert(p3);
    final deletedCount = await dao.delete(id);
    expect(deletedCount, equals(1));

    final fetched = await dao.getById(id);
    expect(fetched, isNull);
  });
}
