import 'package:flutter/material.dart';
import 'package:exemplo/ui/pessoa_form.dart';
import 'fake_database_helper.dart';

class PessoaFormWrapper extends StatelessWidget {
  final FakeDatabaseHelper fakeDb;

  const PessoaFormWrapper({super.key, required this.fakeDb});

  @override
  Widget build(BuildContext context) {
    return PessoaForm(
      databaseHelper: fakeDb, 
    );
  }
}
