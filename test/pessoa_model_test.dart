// test/models/pessoa_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:exemplo/models/pessoa.dart';

void main() {
  test('Pessoa: toMap e fromMap', () {
    final p = Pessoa(id: 1, nome: 'Teste', idade: 20);
    final map = p.toMap();
    final p2 = Pessoa.fromMap(map);
    expect(p2.id, 1);
    expect(p2.nome, 'Teste');
    expect(p2.idade, 20);
  });

  test('Pessoa: copyWith', () {
    final p = Pessoa(id: 1, nome: 'A', idade: 10);
    final p2 = p.copyWith(nome: 'B', idade: 20);
    expect(p2.id, 1);
    expect(p2.nome, 'B');
    expect(p2.idade, 20);
  });

  test('Pessoa: toString', () {
    final p = Pessoa(id: 1, nome: 'X', idade: 30);
    final s = p.toString();
    expect(s, 'Pessoa(id: 1, nome: X, idade: 30)');
  });
}
