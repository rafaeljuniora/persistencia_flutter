import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:exemplo/ui/pessoa_form.dart';
import 'fakes/fake_database_helper.dart';
import 'package:exemplo/models/pessoa.dart';

void main() {
  late FakeDatabaseHelper fakeDb;

  setUp(() {
    fakeDb = FakeDatabaseHelper();
  });

  testWidgets('Adicionar nova pessoa', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: PessoaForm(databaseHelper: fakeDb)),
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'João');
    await tester.enterText(find.byType(TextFormField).at(1), '25');

    await tester.tap(find.text('Adicionar'));
    await tester.pumpAndSettle();

    final pessoas = await fakeDb.getAll();
    expect(pessoas.length, 1);
    expect(pessoas.first.nome, 'João');
    expect(pessoas.first.idade, 25);
  });

  testWidgets('Validação do formulário', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: PessoaForm(databaseHelper: fakeDb)),
      ),
    );

    await tester.tap(find.text('Adicionar'));
    await tester.pump();

    expect(find.text('Informe o nome'), findsOneWidget);
    expect(find.text('Informe a idade'), findsOneWidget);
  });

  testWidgets('Editar pessoa existente', (tester) async {
    final p = Pessoa(nome: 'Maria', idade: 30);
    await fakeDb.insert(p);

    final pessoas = await fakeDb.getAll();
    final pessoaId = pessoas.first.id!;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PessoaForm(databaseHelper: fakeDb, editingId: pessoaId),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Modifica o nome
    await tester.enterText(find.byType(TextFormField).at(0), 'Maria Alterada');
    await tester.tap(find.text('Salvar alterações'));
    await tester.pumpAndSettle();

    final updated = await fakeDb.getById(pessoaId);
    expect(updated!.nome, 'Maria Alterada');
    expect(updated.idade, 30); // idade não alterada
  });
}
