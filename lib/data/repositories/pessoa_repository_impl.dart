// lib/data/repositories/pessoa_repository_impl.dart
import '../../models/pessoa.dart';
import '../../domain/repositories/pessoa_repository.dart';
import '../../data/dao/pessoa_dao.dart';

class PessoaRepositoryImpl implements PessoaRepository {
  final PessoaDao dao;
  PessoaRepositoryImpl(this.dao);

  @override
  Future<List<Pessoa>> listar() => dao.getAll();

  @override
  Future<Pessoa?> buscar(int id) => dao.getById(id);

  @override
  Future<void> salvar(Pessoa p) async {
    if (p.id == null) {
      await dao.insert(p);
    } else {
      await dao.update(p);
    }
  }

  @override
  Future<void> remover(int id) => dao.delete(id);
}
