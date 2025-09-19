// test/data/pessoa_store_extra_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'package:exemplo/data/dao/pessoa_dao.dart';
import 'package:exemplo/data/repositories/pessoa_repository_impl.dart';
import 'package:exemplo/domain/stores/pessoa_store.dart';
import 'package:exemplo/models/pessoa.dart';

Future<Database> createTestDb() async {
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
    return databaseFactory.openDatabase(
      'test_pessoas_extra.db',
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
    final path = p.join(dbDir, 'test_pessoas_extra.db');
    return openDatabase(
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
}

void main() {
  late Database db;
  late PessoaDao dao;
  late PessoaRepositoryImpl repository;
  late PessoaStore store;

  setUpAll(() async {
    db = await createTestDb();
    dao = PessoaDao(db);
    repository = PessoaRepositoryImpl(dao);
    store = PessoaStore(repository);
  });

  tearDownAll(() async {
    await db.close();
  });

  test('DAO: buscar ID inexistente retorna null', () async {
    final fetched = await dao.getById(9999);
    expect(fetched, isNull);
  });

  test('DAO: deletar ID inexistente retorna 0', () async {
    final deleted = await dao.delete(9999);
    expect(deleted, 0);
  });

  test('Repository: remover ID inexistente não lança', () async {
    await repository.remover(9999);
  });

  test('Store: listener é notificado ao carregar', () async {
    bool notified = false;
    store.addListener(() {
      notified = true;
    });

    await repository.salvar(Pessoa(nome: 'Test Listener', idade: 50));
    await store.carregar();
    expect(notified, isTrue);
  });

  test('DAO, Repository e Store consistência', () async {
    final p = Pessoa(nome: 'Consistência', idade: 45);
    final id = await dao.insert(p);

    final repoFetched = await repository.buscar(id);
    expect(repoFetched, isNotNull);
    expect(repoFetched!.nome, 'Consistência');

    await store.carregar();
    expect(store.lista.any((p) => p.id == id), isTrue);
  });
}
