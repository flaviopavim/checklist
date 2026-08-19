import 'item.dart';

class ShoppingListItem {
  final String id;
  final String shoppingListId;
  final String itemId;
  final double quantity;
  final bool isChecked;
  final DateTime addedAt;

  /// Preenchido em memória via join com a tabela de itens.
  final Item? item;

  ShoppingListItem({
    required this.id,
    required this.shoppingListId,
    required this.itemId,
    this.quantity = 1,
    this.isChecked = false,
    required this.addedAt,
    this.item,
  });

  ShoppingListItem copyWith({
    double? quantity,
    bool? isChecked,
    Item? item,
  }) {
    return ShoppingListItem(
      id: id,
      shoppingListId: shoppingListId,
      itemId: itemId,
      quantity: quantity ?? this.quantity,
      isChecked: isChecked ?? this.isChecked,
      addedAt: addedAt,
      item: item ?? this.item,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'shoppingListId': shoppingListId,
      'itemId': itemId,
      'quantity': quantity,
      'isChecked': isChecked ? 1 : 0,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  factory ShoppingListItem.fromMap(Map<String, dynamic> map, {Item? item}) {
    return ShoppingListItem(
      id: map['id'] as String,
      shoppingListId: map['shoppingListId'] as String,
      itemId: map['itemId'] as String,
      quantity: (map['quantity'] as num).toDouble(),
      isChecked: (map['isChecked'] as int) == 1,
      addedAt: DateTime.parse(map['addedAt'] as String),
      item: item,
    );
  }
}
