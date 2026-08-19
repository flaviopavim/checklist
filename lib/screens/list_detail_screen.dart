import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/item.dart';
import '../models/shopping_list.dart';
import '../models/shopping_list_item.dart';
import '../providers/item_provider.dart';
import '../providers/shopping_provider.dart';
import '../widgets/empty_state.dart';

class ListDetailScreen extends StatefulWidget {
  final String listId;
  const ListDetailScreen({super.key, required this.listId});

  @override
  State<ListDetailScreen> createState() => _ListDetailScreenState();
}

class _ListDetailScreenState extends State<ListDetailScreen> {
  List<ShoppingListItem> _items = [];
  ShoppingList? _list;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final shopping = context.read<ShoppingProvider>();
    ShoppingList? list;
    try {
      list = shopping.allLists.firstWhere((l) => l.id == widget.listId);
    } catch (_) {
      list = null;
    }
    final items = await shopping.getItemsForList(widget.listId);
    if (!mounted) return;
    setState(() {
      _list = list;
      _items = items;
      _loading = false;
    });
  }

  Future<void> _refreshAfterAction() async {
    await context.read<ShoppingProvider>().loadAll();
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ShoppingProvider>();

    if (_loading || _list == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final list = _list!;
    final pending = _items.where((e) => !e.isChecked).length;
    final checked = _items.where((e) => e.isChecked).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(list.name, overflow: TextOverflow.ellipsis),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenu(value, list),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'rename', child: Text('Renomear lista')),
              const PopupMenuItem(value: 'delete', child: Text('Excluir lista')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: Row(
              children: [
                _StatChip(label: 'restantes', value: '$pending'),
                const SizedBox(width: 10),
                _StatChip(label: 'comprados', value: '$checked'),
                const Spacer(),
                if (!list.isActive)
                  Chip(
                    label: const Text('Concluída'),
                    backgroundColor: Colors.green.withOpacity(0.12),
                    labelStyle: const TextStyle(color: Colors.green),
                  ),
              ],
            ),
          ),
          Expanded(
            child: _items.isEmpty
                ? const EmptyState(
                    icon: Icons.shopping_basket_outlined,
                    title: 'Lista vazia',
                    message: 'Toque em "Adicionar item" para começar.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final sli = _items[index];
                      return _CartItemTile(
                        sli: sli,
                        editable: list.isActive,
                        onToggle: () async {
                          await context
                              .read<ShoppingProvider>()
                              .toggleCartItemChecked(sli);
                          await _refreshAfterAction();
                        },
                        onQuantityChanged: (q) async {
                          await context
                              .read<ShoppingProvider>()
                              .updateCartItemQuantity(sli, q);
                          await _refreshAfterAction();
                        },
                        onRemove: () async {
                          await context
                              .read<ShoppingProvider>()
                              .removeItemFromCart(sli.id);
                          await _refreshAfterAction();
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: list.isActive
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _addItem(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Adicionar item'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed:
                            _items.isEmpty ? null : () => _finalize(context, list),
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Finalizar compra'),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  void _handleMenu(String value, ShoppingList list) async {
    if (value == 'rename') {
      final ctrl = TextEditingController(text: list.name);
      final newName = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Renomear lista'),
          content: TextField(controller: ctrl, autofocus: true),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, ctrl.text),
                child: const Text('Salvar')),
          ],
        ),
      );
      if (newName != null && newName.trim().isNotEmpty) {
        await context.read<ShoppingProvider>().renameList(list, newName);
        await _refreshAfterAction();
      }
    } else if (value == 'delete') {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Excluir lista'),
          content: const Text(
              'Tem certeza que deseja excluir esta lista de compras? Essa ação não pode ser desfeita.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar')),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child:
                  const Text('Excluir', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
      if (confirm == true) {
        await context.read<ShoppingProvider>().deleteList(list.id);
        if (mounted) Navigator.pop(context);
      }
    }
  }

  Future<void> _finalize(BuildContext context, ShoppingList list) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Finalizar compra'),
        content: const Text(
            'Isso vai registrar a data de compra de cada item e atualizar as próximas sugestões. Deseja continuar?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Finalizar')),
        ],
      ),
    );
    if (confirm != true) return;

    await context.read<ShoppingProvider>().finalizePurchase(list.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Compra finalizada! 🎉')),
      );
      Navigator.pop(context);
    }
  }

  void _addItem(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddItemSheet(
        excludeIds: _items.map((e) => e.itemId).toSet(),
        onPicked: (item) async {
          await context.read<ShoppingProvider>().addItemToCart(item);
          await _refreshAfterAction();
        },
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text('$value $label',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5)),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final ShoppingListItem sli;
  final bool editable;
  final VoidCallback onToggle;
  final ValueChanged<double> onQuantityChanged;
  final VoidCallback onRemove;

  const _CartItemTile({
    required this.sli,
    required this.editable,
    required this.onToggle,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  String _formatNum(double v) => v % 1 == 0 ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    final item = sli.item;
    if (item == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          children: [
            Checkbox(
              value: sli.isChecked,
              onChanged: editable ? (_) => onToggle() : null,
            ),
            Text(item.icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      decoration:
                          sli.isChecked ? TextDecoration.lineThrough : null,
                      color: sli.isChecked ? Colors.grey : null,
                    ),
                  ),
                  if (item.category != null)
                    Text(item.category!,
                        style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            if (editable) ...[
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, size: 20),
                onPressed: () => onQuantityChanged(sli.quantity - 1),
              ),
              SizedBox(
                width: 34,
                child: Text(
                  _formatNum(sli.quantity),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 20),
                onPressed: () => onQuantityChanged(sli.quantity + 1),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                onPressed: onRemove,
              ),
            ] else
              Text(_formatNum(sli.quantity),
                  style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _AddItemSheet extends StatefulWidget {
  final Set<String> excludeIds;
  final ValueChanged<Item> onPicked;
  const _AddItemSheet({required this.excludeIds, required this.onPicked});

  @override
  State<_AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends State<_AddItemSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final allItems = context.watch<ItemProvider>().items;
    final available = allItems
        .where((i) => !widget.excludeIds.contains(i.id))
        .where((i) => i.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Adicionar item à lista',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Buscar...',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: available.isEmpty
                    ? const EmptyState(
                        icon: Icons.search_off,
                        title: 'Nada encontrado',
                        message:
                            'Todos os itens já estão na lista ou nenhum item cadastrado.',
                      )
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: available.length,
                        itemBuilder: (context, index) {
                          final item = available[index];
                          return ListTile(
                            leading:
                                Text(item.icon, style: const TextStyle(fontSize: 20)),
                            title: Text(item.name),
                            subtitle:
                                item.category != null ? Text(item.category!) : null,
                            trailing:
                                const Icon(Icons.add_circle, color: Colors.green),
                            onTap: () {
                              widget.onPicked(item);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
