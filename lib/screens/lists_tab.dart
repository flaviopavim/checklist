import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/shopping_list.dart';
import '../providers/shopping_provider.dart';
import '../widgets/empty_state.dart';
import 'list_detail_screen.dart';

class ListsTab extends StatelessWidget {
  const ListsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final shopping = context.watch<ShoppingProvider>();
    final lists = shopping.allLists;

    return Scaffold(
      appBar: AppBar(title: const Text('Listas de compras')),
      body: lists.isEmpty
          ? const EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'Nenhuma lista ainda',
              message:
                  'Adicione itens pelas sugestões ou crie uma lista manualmente.',
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              itemCount: lists.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) => _ListTile(list: lists[index]),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createList(context),
        icon: const Icon(Icons.add),
        label: const Text('Nova lista'),
      ),
    );
  }

  void _createList(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nova lista de compras'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(hintText: 'Nome da lista'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              context.read<ShoppingProvider>().createNewList(ctrl.text);
              Navigator.pop(ctx);
            },
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }
}

class _ListTile extends StatelessWidget {
  final ShoppingList list;
  const _ListTile({required this.list});

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd/MM/yyyy');
    return Card(
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: list.isActive
              ? Colors.orange.withOpacity(0.15)
              : Colors.green.withOpacity(0.15),
          child: Icon(
            list.isActive ? Icons.shopping_cart : Icons.check,
            color: list.isActive ? Colors.orange[800] : Colors.green[800],
          ),
        ),
        title:
            Text(list.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          list.isActive
              ? 'Em andamento · criada em ${dateFmt.format(list.createdAt)}'
              : 'Concluída em ${dateFmt.format(list.completedAt ?? list.createdAt)}',
          style: const TextStyle(fontSize: 12.5),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ListDetailScreen(listId: list.id)),
        ),
      ),
    );
  }
}
