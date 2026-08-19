import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/item.dart';
import '../models/purchase_record.dart';
import '../models/shopping_list.dart';
import '../models/shopping_list_item.dart';
import '../repositories/item_repository.dart';
import '../repositories/purchase_repository.dart';
import '../repositories/shopping_list_repository.dart';

/// Representa um item sugerido para a próxima compra, junto com
/// quantos dias ele está atrasado em relação à frequência de uso estimada.
class SuggestionEntry {
  final Item item;
  final int daysOverdue; // 0 = venceu hoje, positivo = atrasado.
  SuggestionEntry({required this.item, required this.daysOverdue});
}

class ShoppingProvider extends ChangeNotifier {
  final ItemRepository _itemRepo = ItemRepository();
  final ShoppingListRepository _listRepo = ShoppingListRepository();
  final PurchaseRepository _purchaseRepo = PurchaseRepository();
  final _uuid = const Uuid();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  ShoppingList? _activeList;
  ShoppingList? get activeList => _activeList;

  List<ShoppingListItem> _activeListItems = [];
  List<ShoppingListItem> get activeListItems =>
      List.unmodifiable(_activeListItems);

  List<ShoppingList> _allLists = [];
  List<ShoppingList> get allLists => List.unmodifiable(_allLists);

  List<Item> _allItems = [];

  List<SuggestionEntry> _suggestions = [];
  List<SuggestionEntry> get suggestions => List.unmodifiable(_suggestions);

  int get cartCount => _activeListItems.length;

  Future<void> loadAll() async {
    _isLoading = true;
    notifyListeners();

    _allLists = await _listRepo.getAllLists();
    _activeList = await _listRepo.getActiveList();
    if (_activeList != null) {
      _activeListItems = await _listRepo.getListItems(_activeList!.id);
    } else {
      _activeListItems = [];
    }
    _allItems = await _itemRepo.getAllItems();
    _buildSuggestions();

    _isLoading = false;
    notifyListeners();
  }

  void _buildSuggestions() {
    final cartItemIds = _activeListItems.map((e) => e.itemId).toSet();
    final entries = <SuggestionEntry>[];

    for (final item in _allItems) {
      if (cartItemIds.contains(item.id)) continue;
      final daysUntil = item.daysUntilDue;
      if (daysUntil == null) continue; // sem histórico/estimativa ainda
      if (daysUntil <= 0) {
        entries.add(SuggestionEntry(item: item, daysOverdue: -daysUntil));
      }
    }

    // Ordem de uso: itens mais atrasados (mais "urgentes") aparecem primeiro.
    entries.sort((a, b) => b.daysOverdue.compareTo(a.daysOverdue));
    _suggestions = entries;
  }

  // ----------------- Carrinho / Lista ativa -----------------

  Future<ShoppingList> _ensureActiveList() async {
    if (_activeList != null) return _activeList!;
    final now = DateTime.now();
    final list = ShoppingList(
      id: _uuid.v4(),
      name: 'Lista de ${_formatDate(now)}',
      createdAt: now,
      isActive: true,
    );
    await _listRepo.insertList(list);
    _activeList = list;
    return list;
  }

  String _formatDate(DateTime d) {
    const months = [
      'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
      'jul', 'ago', 'set', 'out', 'nov', 'dez'
    ];
    return '${d.day.toString().padLeft(2, '0')} de ${months[d.month - 1]}';
  }

  Future<void> addItemToCart(Item item, {double? quantity}) async {
    final list = await _ensureActiveList();
    final exists = await _listRepo.listContainsItem(list.id, item.id);
    if (exists) return;
    final sli = ShoppingListItem(
      id: _uuid.v4(),
      shoppingListId: list.id,
      itemId: item.id,
      quantity: quantity ?? item.defaultQuantity,
      addedAt: DateTime.now(),
    );
    await _listRepo.insertListItem(sli);
    await loadAll();
  }

  Future<void> removeItemFromCart(String shoppingListItemId) async {
    await _listRepo.deleteListItem(shoppingListItemId);
    await loadAll();
  }

  Future<void> updateCartItemQuantity(
      ShoppingListItem sli, double newQuantity) async {
    if (newQuantity <= 0) {
      await removeItemFromCart(sli.id);
      return;
    }
    final updated = sli.copyWith(quantity: newQuantity);
    await _listRepo.updateListItem(updated);
    await loadAll();
  }

  Future<void> toggleCartItemChecked(ShoppingListItem sli) async {
    final updated = sli.copyWith(isChecked: !sli.isChecked);
    await _listRepo.updateListItem(updated);
    await loadAll();
  }

  /// Cria uma nova lista de compras manualmente.
  Future<ShoppingList> createNewList(String name) async {
    final now = DateTime.now();
    final list = ShoppingList(
      id: _uuid.v4(),
      name:
          name.trim().isEmpty ? 'Lista de ${_formatDate(now)}' : name.trim(),
      createdAt: now,
      isActive: true,
    );
    await _listRepo.insertList(list);
    await loadAll();
    return list;
  }

  Future<void> renameList(ShoppingList list, String newName) async {
    if (newName.trim().isEmpty) return;
    final updated = list.copyWith(name: newName.trim());
    await _listRepo.updateList(updated);
    await loadAll();
  }

  Future<void> deleteList(String listId) async {
    await _listRepo.deleteList(listId);
    await loadAll();
  }

  Future<List<ShoppingListItem>> getItemsForList(String listId) {
    return _listRepo.getListItems(listId);
  }

  /// Finaliza a compra: registra o histórico de compra de cada item da
  /// lista, recalcula o intervalo médio de uso de cada item (para ajustar
  /// as próximas sugestões) e marca a lista como concluída.
  Future<void> finalizePurchase(String listId,
      {bool onlyChecked = false}) async {
    final list = await _listRepo.getListById(listId);
    if (list == null) return;

    final items = await _listRepo.getListItems(listId);
    final toProcess =
        onlyChecked ? items.where((e) => e.isChecked).toList() : items;

    final now = DateTime.now();

    for (final sli in toProcess) {
      final item = sli.item;
      if (item == null) continue;

      await _purchaseRepo.insertRecord(PurchaseRecord(
        id: _uuid.v4(),
        itemId: item.id,
        purchaseDate: now,
        quantity: sli.quantity,
        shoppingListId: listId,
      ));

      double? newAverage;
      if (item.lastPurchasedAt == null) {
        // Primeira compra registrada: mantém a estimativa manual (se houver),
        // ainda não há um intervalo real medido entre duas compras.
        newAverage = item.averageIntervalDays;
      } else {
        final intervalDays =
            now.difference(item.lastPurchasedAt!).inHours / 24.0;
        if (item.averageIntervalDays == null) {
          newAverage = intervalDays;
        } else {
          // Média ponderada pelo número de intervalos já conhecidos.
          final n = (item.purchaseCount - 1).clamp(1, 999);
          newAverage =
              ((item.averageIntervalDays! * n) + intervalDays) / (n + 1);
        }
      }

      final updatedItem = item.copyWith(
        lastPurchasedAt: now,
        averageIntervalDays: newAverage,
        purchaseCount: item.purchaseCount + 1,
      );
      await _itemRepo.updateItem(updatedItem);
    }

    final updatedList = list.copyWith(isActive: false, completedAt: now);
    await _listRepo.updateList(updatedList);

    await loadAll();
  }
}
