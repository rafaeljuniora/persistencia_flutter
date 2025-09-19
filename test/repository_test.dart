import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as p;

import 'package:exemplo/data/dao/pessoa_dao.dart';
import 'package:exemplo/data/repositories/pessoa_repository_impl.dart';
import 'package:exemplo/domain/stores/pessoa_store.dart';
import 'package:exemplo/models/pessoa.dart';

Future<Database> createTestDb() async {
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
    return databaseFactory.openDatabase(
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

  test('Repository: salvar e buscar pessoa', () async {
    final p1 = Pessoa(nome: 'Alice', idade: 30);
    await repository.salvar(p1);

    final lista = await repository.listar();
    expect(lista, isNotEmpty);
    expect(lista.first.nome, 'Alice');

    final fetched = await repository.buscar(lista.first.id!);
    expect(fetched, isNotNull);
    expect(fetched!.nome, 'Alice');
  });

  test('Repository: atualizar pessoa', () async {
    final p2 = Pessoa(nome: 'Bob', idade: 25);
    await repository.salvar(p2);

    final saved = (await repository.listar()).firstWhere(
      (p) => p.nome == 'Bob',
    );
    final updated = saved.copyWith(nome: 'Bob Updated', idade: 26);
    await repository.salvar(updated);

    final fetched = await repository.buscar(saved.id!);
    expect(fetched!.nome, 'Bob Updated');
    expect(fetched.idade, 26);
  });

  test('Repository: remover pessoa', () async {
    final p3 = Pessoa(nome: 'Carlos', idade: 40);
    await repository.salvar(p3);

    final saved = (await repository.listar()).firstWhere(
      (p) => p.nome == 'Carlos',
    );
    await repository.remover(saved.id!);

    final fetched = await repository.buscar(saved.id!);
    expect(fetched, isNull);
  });

  test('Store: carregar lista de pessoas', () async {
    await repository.salvar(Pessoa(nome: 'Diana', idade: 22));
    await store.carregar();

    expect(store.lista, isNotEmpty);
    expect(store.lista.any((p) => p.nome == 'Diana'), isTrue);
  });

  test('Store: salvar e atualizar pessoa via store', () async {
    final p = Pessoa(nome: 'Eva', idade: 28);
    await store.salvar(p);

    final saved = store.lista.firstWhere((p) => p.nome == 'Eva');
    expect(saved.id, isNotNull);

    final updated = saved.copyWith(nome: 'Eva Updated', idade: 29);
    await store.salvar(updated);

    final fetched = store.lista.firstWhere((p) => p.id == saved.id);
    expect(fetched.nome, 'Eva Updated');
    expect(fetched.idade, 29);
  });

  test('Store: remover pessoa via store', () async {
    final p = Pessoa(nome: 'Fernando', idade: 35);
    await store.salvar(p);

    final saved = store.lista.firstWhere((p) => p.nome == 'Fernando');
    await store.remover(saved.id!);

    expect(store.lista.any((p) => p.nome == 'Fernando'), isFalse);
  });
}
