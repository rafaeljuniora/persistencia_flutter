import 'package:flutter/material.dart';
import '../models/pessoa.dart';
import '../data/database_helper.dart';

class PessoaForm extends StatefulWidget {
  final int? editingId;
  final Future<void> Function()? onSaved;
  final VoidCallback? onCancel;

  const PessoaForm({super.key, this.editingId, this.onSaved, this.onCancel});

  @override
  State<PessoaForm> createState() => _PessoaFormState();
}

class _PessoaFormState extends State<PessoaForm> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _idadeCtrl = TextEditingController();
  bool _isSaving = false;
  int? _loadedId;

  @override
  void initState() {
    super.initState();
    _maybeLoadEditing();
  }

  @override
  void didUpdateWidget(covariant PessoaForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.editingId != widget.editingId) {
      _maybeLoadEditing();
    }
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _idadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _maybeLoadEditing() async {
    final id = widget.editingId;
    if (id == null) {
      _clearForm();
      return;
    }

    if (_loadedId != null && _loadedId == id) return;

    final p = await DatabaseHelper.instance.getById(id);
    if (!mounted) return;
    if (p == null) {
      _clearForm();
      return;
    }
    setState(() {
      _loadedId = p.id;
      _nomeCtrl.text = p.nome;
      _idadeCtrl.text = p.idade.toString();
    });
  }

  void _clearForm() {
    _loadedId = null;
    _formKey.currentState?.reset();
    _nomeCtrl.clear();
    _idadeCtrl.clear();
    setState(() {}); // atualiza botões
  }

  Future<void> _salvar() async {
    if (_isSaving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);
    try {
      final nome = _nomeCtrl.text.trim();
      final idade = int.parse(_idadeCtrl.text.trim());

      if (widget.editingId == null) {
        await DatabaseHelper.instance.insert(Pessoa(nome: nome, idade: idade));
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Pessoa adicionada!')));
      } else {
        await DatabaseHelper.instance.update(
          Pessoa(id: widget.editingId, nome: nome, idade: idade),
        );
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Pessoa atualizada!')));
      }

      _clearForm();
      await widget.onSaved?.call();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _cancelarEdicao() {
    _clearForm();
    widget.onCancel?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.editingId != null;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _nomeCtrl,
              decoration: const InputDecoration(
                labelText: 'Nome',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Informe o nome';
                if (v.trim().length < 2) return 'Nome muito curto';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _idadeCtrl,
              decoration: const InputDecoration(
                labelText: 'Idade',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Informe a idade';
                final n = int.tryParse(v.trim());
                if (n == null || n < 0 || n > 150) return 'Idade inválida';
                return null;
              },
              onFieldSubmitted: (_) {
                if (!_isSaving) _salvar();
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _salvar,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(isEditing ? Icons.save : Icons.add),
                    label: Text(isEditing ? 'Salvar alterações' : 'Adicionar'),
                  ),
                ),
                const SizedBox(width: 12),
                if (isEditing)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _cancelarEdicao,
                      icon: const Icon(Icons.close),
                      label: const Text('Cancelar edição'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
