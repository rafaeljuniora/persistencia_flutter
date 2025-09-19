// lib/data/dao/pessoa_dao.dart
import 'package:sqflite/sqflite.dart';
import '../../models/pessoa.dart';

class PessoaDao {
  final Database db;
  PessoaDao(this.db);

  Future<int> insert(Pessoa p) => db.insert('pessoas', p.toMap());
  Future<Pessoa?> getById(int id) async {
    final result = await db.query('pessoas', where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) return null;
    return Pessoa.fromMap(result.first);
  }

  Future<List<Pessoa>> getAll() async {
    final maps = await db.query('pessoas', orderBy: 'id DESC');
    return maps.map(Pessoa.fromMap).toList();
  }

  Future<int> update(Pessoa p) =>
      db.update('pessoas', p.toMap(), where: 'id = ?', whereArgs: [p.id]);

  Future<int> delete(int id) =>
      db.delete('pessoas', where: 'id = ?', whereArgs: [id]);
}
