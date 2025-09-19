import 'package:flutter/material.dart';
import 'pessoa_form.dart';
import 'pessoa_list.dart';
import '../models/pessoa.dart';

class PessoasPage extends StatefulWidget {
  const PessoasPage({super.key});

  @override
  State<PessoasPage> createState() => _PessoasPageState();
}

class _PessoasPageState extends State<PessoasPage> {
  int? _editingId;

  void _editarPessoa(Pessoa p) {
    setState(() => _editingId = p.id);
  }

  void _finalizarEdicao() {
    setState(() => _editingId = null);
  }

  void _refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pessoas (Store + GetIt)'),
        actions: [
          IconButton(
            tooltip: 'Recarregar',
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          PessoaForm(
            editingId: _editingId,
            onSaved: _refresh,
            onCancel: _finalizarEdicao,
          ),
          const Divider(height: 1),
          Expanded(child: PessoaList(onEdit: _editarPessoa)),
        ],
      ),
    );
  }
}
