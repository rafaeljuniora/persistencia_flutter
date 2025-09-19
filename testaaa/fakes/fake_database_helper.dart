import '../../lib/models/pessoa.dart';

class FakeDatabaseHelper {
  final List<Pessoa> lista = [];

  Future<void> insert(Pessoa p) async {
    final id = lista.isEmpty
        ? 1
        : (lista.map((e) => e.id ?? 0).reduce((a, b) => a > b ? a : b) + 1);
    lista.add(Pessoa(id: id, nome: p.nome, idade: p.idade));
  }

  Future<void> update(Pessoa p) async {
    final index = lista.indexWhere((e) => e.id == p.id);
    if (index >= 0) lista[index] = p;
  }

  Future<void> remove(int id) async {
    lista.removeWhere((p) => p.id == id);
  }

  Future<Pessoa?> getById(int id) async {
    try {
      return lista.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
}
