import 'package:flutter/material.dart';
import '../models/pessoa.dart';
import '../data/database_helper.dart';
import 'pessoa_form.dart';
import 'pessoa_list.dart';

class PessoasPage extends StatefulWidget {
  const PessoasPage({super.key});

  @override
  State<PessoasPage> createState() => _PessoasPageState();
}

class _PessoasPageState extends State<PessoasPage> {
  int? _editingId;
  late Future<List<Pessoa>> _futurePessoas;
  int _reloadTick = 0;

  @override
  void initState() {
    super.initState();
    _futurePessoas = DatabaseHelper.instance.getAll();
  }

  Future<void> _refresh() async {
    setState(() {
      _futurePessoas = DatabaseHelper.instance.getAll();
      _reloadTick++;
    });
  }

  void _editarPessoa(Pessoa p) {
    setState(() => _editingId = p.id);
  }

  void _finalizarEdicao() {
    setState(() => _editingId = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pessoas (SQLite)'),
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
          Expanded(
            child: PessoaList(
              key: ValueKey(_reloadTick),
              futurePessoas: _futurePessoas,
              onEdit: _editarPessoa,
              onDelete: (id) async {
                await DatabaseHelper.instance.delete(id);
                _refresh();
              },
            ),
          ),
        ],
      ),
    );
  }
}
