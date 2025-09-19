import '../../models/pessoa.dart';

abstract class PessoaRepository {
  Future<List<Pessoa>> listar();
  Future<Pessoa?> buscar(int id);
  Future<void> salvar(Pessoa pessoa);
  Future<void> remover(int id);
}
