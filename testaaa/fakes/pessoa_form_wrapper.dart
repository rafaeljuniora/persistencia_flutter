import 'package:flutter/material.dart';
import '../../lib/models/pessoa.dart';
import '../../lib/ui/pessoa_form.dart';
import 'fake_database_helper.dart';

class PessoaFormWrapper extends StatefulWidget {
  final FakeDatabaseHelper fakeDb;
  final int? editingId;

  const PessoaFormWrapper({super.key, required this.fakeDb, this.editingId});

  @override
  State<PessoaFormWrapper> createState() => _PessoaFormWrapperState();
}

class _PessoaFormWrapperState extends State<PessoaFormWrapper> {
  late int? _editingId;

  @override
  void initState() {
    super.initState();
    _editingId = widget.editingId;
  }

  void _salvarPessoa(Pessoa p) async {
    if (p.id == null) {
      await widget.fakeDb.insert(p);
    } else {
      await widget.fakeDb.update(p);
    }
    setState(() {});
  }

  void _cancelarEdicao() {
    setState(() => _editingId = null);
  }

  @override
  Widget build(BuildContext context) {
    return PessoaForm(
      editingId: _editingId,
      onSaved: () {},
      onCancel: _cancelarEdicao,
    );
  }
}
