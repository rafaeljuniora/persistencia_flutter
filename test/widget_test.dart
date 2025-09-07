import 'package:exemplo/ui/pessoas_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:exemplo/main.dart';

void main() {
  testWidgets('Renderiza tela principal PessoasApp', (
    WidgetTester tester,
  ) async {
    // Carrega o app
    await tester.pumpWidget(const PessoasPage());

    // Verifica se o título da AppBar aparece
    expect(find.text('Pessoas (SQLite)'), findsOneWidget);

    // Verifica se existe o botão de recarregar
    expect(find.byIcon(Icons.refresh), findsOneWidget);
  });
}
