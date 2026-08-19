import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/item.dart';
import '../providers/item_provider.dart';
import '../widgets/empty_state.dart';
import 'item_form_screen.dart';

class ItemsTab extends StatefulWidget {
  const ItemsTab({super.key});

  @override
  State<ItemsTab> createState() => _ItemsTabState();
}

class _ItemsTabState extends State<ItemsTab> {
  String _query = '';
  String? _categoryFilter;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ItemProvider>();
    var items = provider.items;

    if (_query.isNotEmpty) {
      items = items
          .where((i) => i.name.toLowerCase().contains(_query.toLowerCase()))
          .toList();
    }
    if (_categoryFilter != null) {
      items = items.where((i) => i.category == _categoryFilter).toList();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Itens')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar item...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          if (provider.categories.isNotEmpty)
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: const Text('Todos'),
                      selected: _categoryFilter == null,
                      onSelected: (_) => setState(() => _categoryFilter = null),
                    ),
                  ),
                  ...provider.categories.map((c) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(c),
                          selected: _categoryFilter == c,
                          onSelected: (_) => setState(() => _categoryFilter = c),
                        ),
                      )),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Expanded(
            child: items.isEmpty
                ? const EmptyState(
                    icon: Icons.inventory_2_outlined,
                    title: 'Nenhum item encontrado',
                    message:
                        'Toque no botão + para cadastrar o primeiro item da sua despensa.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) => _ItemTile(item: items[index]),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ItemFormScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  final Item item;
  const _ItemTile({required this.item});

  String _formatNum(double v) => v % 1 == 0 ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    String freqText = 'Sem histórico de compras';
    if (item.averageIntervalDays != null) {
      freqText = 'A cada ${item.averageIntervalDays!.round()} dias';
    }

    return Card(
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: CircleAvatar(
          backgroundColor:
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
          child: Text(item.icon, style: const TextStyle(fontSize: 18)),
        ),
        title:
            Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          [
            if (item.category != null) item.category!,
            freqText,
          ].join(' · '),
          style: const TextStyle(fontSize: 12.5),
        ),
        trailing: Text(
          '${_formatNum(item.defaultQuantity)}${item.unit != null ? ' ${item.unit}' : ''}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ItemFormScreen(item: item)),
        ),
      ),
    );
  }
}
