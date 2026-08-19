import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/item.dart';
import '../providers/item_provider.dart';
import '../providers/shopping_provider.dart';

const _iconOptions = [
  '🛒', '🍎', '🥦', '🥩', '🍞', '🥛', '🧀', '🥚', '🍚', '🍝',
  '🧴', '🧻', '🧼', '🪥', '🧹', '🍫', '☕', '🧃', '🐾', '🍺',
];

class ItemFormScreen extends StatefulWidget {
  final Item? item;
  const ItemFormScreen({super.key, this.item});

  @override
  State<ItemFormScreen> createState() => _ItemFormScreenState();
}

class _ItemFormScreenState extends State<ItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  late TextEditingController _nameCtrl;
  late TextEditingController _categoryCtrl;
  late TextEditingController _unitCtrl;
  late TextEditingController _quantityCtrl;
  late TextEditingController _intervalCtrl;
  late String _icon;

  bool get _isEditing => widget.item != null;

  String _formatNum(double v) =>
      v % 1 == 0 ? v.toStringAsFixed(0) : v.toString();

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _nameCtrl = TextEditingController(text: item?.name ?? '');
    _categoryCtrl = TextEditingController(text: item?.category ?? '');
    _unitCtrl = TextEditingController(text: item?.unit ?? '');
    _quantityCtrl =
        TextEditingController(text: _formatNum(item?.defaultQuantity ?? 1));
    _intervalCtrl = TextEditingController(
        text: item?.averageIntervalDays?.round().toString() ?? '');
    _icon = item?.icon ?? '🛒';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _categoryCtrl.dispose();
    _unitCtrl.dispose();
    _quantityCtrl.dispose();
    _intervalCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final itemProvider = context.read<ItemProvider>();
    final quantity =
        double.tryParse(_quantityCtrl.text.replaceAll(',', '.')) ?? 1;
    final interval = _intervalCtrl.text.trim().isEmpty
        ? null
        : double.tryParse(_intervalCtrl.text.replaceAll(',', '.'));

    if (_isEditing) {
      final updated = widget.item!.copyWith(
        name: _nameCtrl.text.trim(),
        category:
            _categoryCtrl.text.trim().isEmpty ? null : _categoryCtrl.text.trim(),
        clearCategory: _categoryCtrl.text.trim().isEmpty,
        unit: _unitCtrl.text.trim().isEmpty ? null : _unitCtrl.text.trim(),
        clearUnit: _unitCtrl.text.trim().isEmpty,
        defaultQuantity: quantity,
        averageIntervalDays: interval,
        clearAverageIntervalDays: interval == null,
        icon: _icon,
      );
      await itemProvider.updateItem(updated);
      if (mounted) Navigator.pop(context);
    } else {
      final newItem = Item(
        id: _uuid.v4(),
        name: _nameCtrl.text.trim(),
        category:
            _categoryCtrl.text.trim().isEmpty ? null : _categoryCtrl.text.trim(),
        unit: _unitCtrl.text.trim().isEmpty ? null : _unitCtrl.text.trim(),
        defaultQuantity: quantity,
        createdAt: DateTime.now(),
        averageIntervalDays: interval,
        icon: _icon,
      );
      await itemProvider.addItem(newItem);
      if (mounted) Navigator.pop(context, newItem);
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover item'),
        content: Text(
            'Tem certeza que deseja remover "${widget.item!.name}"? Isso também removerá o histórico de compras associado.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remover', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await context.read<ItemProvider>().deleteItem(widget.item!.id);
      await context.read<ShoppingProvider>().loadAll();
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar item' : 'Novo item'),
        actions: [
          if (_isEditing)
            IconButton(
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline, color: Colors.red),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            Text('Ícone', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _iconOptions.map((icon) {
                final selected = icon == _icon;
                return GestureDetector(
                  onTap: () => setState(() => _icon = icon),
                  child: Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
                          : Colors.black.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(12),
                      border: selected
                          ? Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 1.6)
                          : null,
                    ),
                    child: Text(icon, style: const TextStyle(fontSize: 20)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Nome do item *'),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Informe um nome' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _categoryCtrl,
              decoration: const InputDecoration(
                labelText: 'Categoria (opcional)',
                hintText: 'Ex: Hortifruti, Limpeza, Higiene...',
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _quantityCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Quantidade padrão'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Obrigatório';
                      final n = double.tryParse(v.replaceAll(',', '.'));
                      if (n == null || n <= 0) return 'Valor inválido';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _unitCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Unidade',
                      hintText: 'kg, un, L...',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _intervalCtrl,
              decoration: const InputDecoration(
                labelText: 'Comprar a cada quantos dias? (opcional)',
                hintText: 'Ex: 14 para a cada 2 semanas',
              ),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                final n = int.tryParse(v.trim());
                if (n == null || n <= 0) return 'Valor inválido';
                return null;
              },
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4),
              child: Text(
                'Define a estimativa inicial de frequência de compra. Depois que você comprar o item algumas vezes, o app ajusta isso automaticamente com base no seu histórico real.',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: _save,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(_isEditing ? 'Salvar alterações' : 'Cadastrar item'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
