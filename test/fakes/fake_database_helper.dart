import 'package:exemplo/models/pessoa.dart';

class FakeDatabaseHelper {
  final List<Pessoa> _pessoas = [];
  int _nextId = 1;

  Future<int> insert(Pessoa p) async {
    final nova = Pessoa(id: _nextId++, nome: p.nome, idade: p.idade);
    _pessoas.add(nova);
    return nova.id!;
  }

  Future<Pessoa?> getById(int id) async {
    try {
      return _pessoas.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<Pessoa>> getAll() async {
    return List.from(_pessoas.reversed);
  }

  Future<int> update(Pessoa p) async {
    final index = _pessoas.indexWhere((e) => e.id == p.id);
    if (index == -1) return 0;
    _pessoas[index] = p;
    return 1;
  }

  Future<int> delete(int id) async {
    final index = _pessoas.indexWhere((e) => e.id == id);
    if (index == -1) return 0;
    _pessoas.removeAt(index);
    return 1;
  }
}
