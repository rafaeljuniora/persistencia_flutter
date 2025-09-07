import 'package:flutter/material.dart';
import '../models/pessoa.dart';
import '../data/database_helper.dart';

class PessoaList extends StatelessWidget {
  final Future<List<Pessoa>> futurePessoas;
  final void Function(Pessoa) onEdit;
  final Future<void> Function(int) onDelete;

  const PessoaList({
    super.key,
    required this.futurePessoas,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Pessoa>>(
      future: futurePessoas,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(child: Text('Erro: ${snapshot.error}'));
        }

        final pessoas = snapshot.data ?? const <Pessoa>[];
        if (pessoas.isEmpty) {
          return const Center(child: Text('Nenhuma pessoa cadastrada.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: pessoas.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final p = pessoas[index];
            return Dismissible(
              key: ValueKey(p.id ?? '${p.nome}-${p.idade}-$index'),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                color: Colors.red,
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              confirmDismiss: (_) async {
                return await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Remover registro'),
                        content: Text('Deseja remover ${p.nome}?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Remover'),
                          ),
                        ],
                      ),
                    ) ??
                    false;
              },
              onDismissed: (_) async {
                await onDelete(p.id!);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pessoa removida.')),
                );
              },
              child: ListTile(
                tileColor: Colors.grey.withOpacity(0.06),
                title: Text('${p.nome} (${p.idade})'),
                subtitle: Text('ID: ${p.id ?? '-'}'),
                onTap: () => onEdit(p),
                trailing: IconButton(
                  tooltip: 'Editar',
                  icon: const Icon(Icons.edit),
                  onPressed: () => onEdit(p),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
