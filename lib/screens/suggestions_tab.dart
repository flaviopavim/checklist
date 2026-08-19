import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/item.dart';
import '../providers/item_provider.dart';
import '../providers/shopping_provider.dart';
import '../widgets/suggestion_card.dart';
import '../widgets/empty_state.dart';
import 'cart_screen.dart';
import 'item_form_screen.dart';

class SuggestionsTab extends StatelessWidget {
  const SuggestionsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final shopping = context.watch<ShoppingProvider>();
    final suggestions = shopping.suggestions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sugestões'),
        actions: [
          IconButton(
            tooltip: 'Carrinho',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CartScreen()),
            ),
            icon: Badge(
              label: Text('${shopping.cartCount}'),
              isLabelVisible: shopping.cartCount > 0,
              child: const Icon(Icons.shopping_cart_outlined),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: shopping.loadAll,
        child: suggestions.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 80),
                  EmptyState(
                    icon: Icons.check_circle_outline,
                    title: 'Tudo em dia!',
                    message:
                        'Nenhum item parece estar precisando de reposição agora.\nAs sugestões aparecem aqui com base no seu histórico de compras.',
                  ),
                ],
              )
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                itemCount: suggestions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final entry = suggestions[index];
                  return SuggestionCard(
                    entry: entry,
                    onAdd: () =>
                        context.read<ShoppingProvider>().addItemToCart(entry.item),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openQuickAdd(context),
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('Adicionar ao carrinho'),
      ),
    );
  }

  void _openQuickAdd(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _QuickAddSheet(),
    );
  }
}

class _QuickAddSheet extends StatefulWidget {
  const _QuickAddSheet();

  @override
  State<_QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends State<_QuickAddSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final items = context.watch<ItemProvider>().items;
    final filtered = items
        .where((i) => i.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
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
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Adicionar ao carrinho',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Buscar item...',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: items.isEmpty
                    ? const EmptyState(
                        icon: Icons.inventory_2_outlined,
                        title: 'Nenhum item cadastrado',
                        message: 'Cadastre itens na aba Itens para começar.',
                      )
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.1),
                              child: Text(item.icon,
                                  style: const TextStyle(fontSize: 18)),
                            ),
                            title: Text(item.name),
                            subtitle:
                                item.category != null ? Text(item.category!) : null,
                            trailing: IconButton(
                              icon: const Icon(Icons.add_circle,
                                  color: Colors.green),
                              onPressed: () {
                                context
                                    .read<ShoppingProvider>()
                                    .addItemToCart(item);
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          '${item.name} adicionado ao carrinho')),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  final created = await Navigator.of(context).push<Item>(
                    MaterialPageRoute(builder: (_) => const ItemFormScreen()),
                  );
                  if (created != null && context.mounted) {
                    context.read<ShoppingProvider>().addItemToCart(created);
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Cadastrar novo item'),
              ),
            ],
          ),
        );
      },
    );
  }
}
