import 'package:flutter/foundation.dart';
import '../../models/pessoa.dart';
import '../repositories/pessoa_repository.dart';

class PessoaStore extends ChangeNotifier {
  final PessoaRepository repository;
  PessoaStore(this.repository);

  List<Pessoa> _lista = [];
  List<Pessoa> get lista => _lista;

  Future<void> carregar() async {
    _lista = await repository.listar();
    notifyListeners();
  }

  Future<void> salvar(Pessoa p) async {
    await repository.salvar(p);
    await carregar();
  }

  Future<void> remover(int id) async {
    await repository.remover(id);
    await carregar();
  }
}
