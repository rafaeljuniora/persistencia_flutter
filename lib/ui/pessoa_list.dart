import 'package:flutter/material.dart';
import '../models/pessoa.dart';
import '../domain/stores/pessoa_store.dart';
import '../di/injection.dart';

class PessoaList extends StatefulWidget {
  final void Function(Pessoa) onEdit;

  const PessoaList({super.key, required this.onEdit});

  @override
  State<PessoaList> createState() => _PessoaListState();
}

class _PessoaListState extends State<PessoaList> {
  final store = getIt<PessoaStore>();

  @override
  void initState() {
    super.initState();
    store.carregar();
  }

  @override
  void reassemble() {
    super.reassemble();
    store.carregar();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final pessoas = store.lista;
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
                await store.remover(p.id!);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pessoa removida.')),
                );
              },
              child: ListTile(
                tileColor: Colors.grey.withOpacity(0.06),
                title: Text('${p.nome} (${p.idade})'),
                subtitle: Text('ID: ${p.id ?? '-'}'),
                onTap: () => widget.onEdit(p),
                trailing: IconButton(
                  tooltip: 'Editar',
                  icon: const Icon(Icons.edit),
                  onPressed: () => widget.onEdit(p),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
