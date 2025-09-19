import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'fakes/fake_database_helper.dart';
import '../testaaa/fakes/pessoa_form_wrapper.dart';
import 'package:exemplo/models/pessoa.dart';

void main() {
  late FakeDatabaseHelper fakeDb;

  setUp(() {
    fakeDb = FakeDatabaseHelper();
  });

  testWidgets('Adicionar nova pessoa', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: PessoaFormWrapper(fakeDb: fakeDb)),
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'João');
    await tester.enterText(find.byType(TextFormField).at(1), '25');

    await tester.tap(find.text('Adicionar'));
    await tester.pumpAndSettle();

    expect(fakeDb.lista.length, 1);
    expect(fakeDb.lista.first.nome, 'João');
    expect(fakeDb.lista.first.idade, 25);
  });

  testWidgets('Validação do formulário', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: PessoaFormWrapper(fakeDb: fakeDb)),
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

    final pessoaId = fakeDb.lista.first.id!;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PessoaFormWrapper(fakeDb: fakeDb, editingId: pessoaId),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Maria Alterada');
    await tester.tap(find.text('Salvar alterações'));
    await tester.pumpAndSettle();

    final updated = await fakeDb.getById(pessoaId);
    expect(updated!.nome, 'Maria Alterada');
    expect(updated.idade, 30);
  });
}
