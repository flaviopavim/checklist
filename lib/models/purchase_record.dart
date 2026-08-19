class PurchaseRecord {
  final String id;
  final String itemId;
  final DateTime purchaseDate;
  final double quantity;
  final String? shoppingListId;

  PurchaseRecord({
    required this.id,
    required this.itemId,
    required this.purchaseDate,
    required this.quantity,
    this.shoppingListId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itemId': itemId,
      'purchaseDate': purchaseDate.toIso8601String(),
      'quantity': quantity,
      'shoppingListId': shoppingListId,
    };
  }

  factory PurchaseRecord.fromMap(Map<String, dynamic> map) {
    return PurchaseRecord(
      id: map['id'] as String,
      itemId: map['itemId'] as String,
      purchaseDate: DateTime.parse(map['purchaseDate'] as String),
      quantity: (map['quantity'] as num).toDouble(),
      shoppingListId: map['shoppingListId'] as String?,
    );
  }
}
