import 'package:flutter/foundation.dart';
import '../models/item.dart';
import '../repositories/item_repository.dart';

class ItemProvider extends ChangeNotifier {
  final ItemRepository _repository = ItemRepository();

  List<Item> _items = [];
  bool _isLoading = false;

  List<Item> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;

  List<String> get categories {
    final set = <String>{};
    for (final item in _items) {
      if (item.category != null && item.category!.trim().isNotEmpty) {
        set.add(item.category!);
      }
    }
    final list = set.toList()..sort();
    return list;
  }

  Future<void> loadItems() async {
    _isLoading = true;
    notifyListeners();
    _items = await _repository.getAllItems();
    _isLoading = false;
    notifyListeners();
  }

  Item? findById(String id) {
    try {
      return _items.firstWhere((i) => i.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addItem(Item item) async {
    await _repository.insertItem(item);
    await loadItems();
  }

  Future<void> updateItem(Item item) async {
    await _repository.updateItem(item);
    await loadItems();
  }

  Future<void> deleteItem(String id) async {
    await _repository.deleteItem(id);
    await loadItems();
  }
}
