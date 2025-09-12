import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'fakes/fake_database_helper.dart';
import 'fakes/pessoa_form_wrapper.dart';

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

    print('Tela carregada');

    await tester.enterText(find.byType(TextFormField).at(0), 'João');
    await tester.enterText(find.byType(TextFormField).at(1), '25');
    print('Campos preenchidos');

    await tester.tap(find.text('Adicionar'));
    await tester.pumpAndSettle();
    print('Botão "Adicionar" clicado');

    final pessoas = await fakeDb.getAll();
    print('Pessoas no banco fake: ${pessoas.length}');
    if (pessoas.isNotEmpty) {
      print(
        'Primeira pessoa: nome=${pessoas.first.nome}, idade=${pessoas.first.idade}',
      );
    }

    expect(pessoas.length, 1);
    expect(pessoas.first.nome, 'João');
    expect(pessoas.first.idade, 25);
  });

  testWidgets('Validação do formulário', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: PessoaFormWrapper(fakeDb: fakeDb)),
      ),
    );

    print('Tela carregada para validação');

    await tester.tap(find.text('Adicionar'));
    await tester.pump();
    print('Botão "Adicionar" clicado sem preencher campos');

    expect(find.text('Informe o nome'), findsOneWidget);
    expect(find.text('Informe a idade'), findsOneWidget);
    print('Mensagens de validação encontradas');
  });
}
