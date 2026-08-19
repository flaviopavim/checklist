class Item {
  final String id;
  final String name;
  final String? category;
  final String? unit;
  final double defaultQuantity;
  final DateTime createdAt;
  final DateTime? lastPurchasedAt;
  final double? averageIntervalDays;
  final int purchaseCount;
  final String icon;

  Item({
    required this.id,
    required this.name,
    this.category,
    this.unit,
    this.defaultQuantity = 1,
    required this.createdAt,
    this.lastPurchasedAt,
    this.averageIntervalDays,
    this.purchaseCount = 0,
    this.icon = '🛒',
  });

  Item copyWith({
    String? name,
    String? category,
    String? unit,
    double? defaultQuantity,
    DateTime? lastPurchasedAt,
    double? averageIntervalDays,
    int? purchaseCount,
    String? icon,
    bool clearCategory = false,
    bool clearUnit = false,
    bool clearAverageIntervalDays = false,
  }) {
    return Item(
      id: id,
      name: name ?? this.name,
      category: clearCategory ? null : (category ?? this.category),
      unit: clearUnit ? null : (unit ?? this.unit),
      defaultQuantity: defaultQuantity ?? this.defaultQuantity,
      createdAt: createdAt,
      lastPurchasedAt: lastPurchasedAt ?? this.lastPurchasedAt,
      averageIntervalDays: clearAverageIntervalDays
          ? null
          : (averageIntervalDays ?? this.averageIntervalDays),
      purchaseCount: purchaseCount ?? this.purchaseCount,
      icon: icon ?? this.icon,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'unit': unit,
      'defaultQuantity': defaultQuantity,
      'createdAt': createdAt.toIso8601String(),
      'lastPurchasedAt': lastPurchasedAt?.toIso8601String(),
      'averageIntervalDays': averageIntervalDays,
      'purchaseCount': purchaseCount,
      'icon': icon,
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'] as String,
      name: map['name'] as String,
      category: map['category'] as String?,
      unit: map['unit'] as String?,
      defaultQuantity: (map['defaultQuantity'] as num).toDouble(),
      createdAt: DateTime.parse(map['createdAt'] as String),
      lastPurchasedAt: map['lastPurchasedAt'] != null
          ? DateTime.parse(map['lastPurchasedAt'] as String)
          : null,
      averageIntervalDays: map['averageIntervalDays'] != null
          ? (map['averageIntervalDays'] as num).toDouble()
          : null,
      purchaseCount: map['purchaseCount'] as int? ?? 0,
      icon: map['icon'] as String? ?? '🛒',
    );
  }

  /// Data prevista para a próxima compra, com base no intervalo médio de uso.
  /// Se o item ainda não foi comprado mas tem um intervalo estimado
  /// (definido manualmente ao cadastrar), usa a data de criação como base.
  DateTime? get nextDueDate {
    if (averageIntervalDays == null) return null;
    final base = lastPurchasedAt ?? createdAt;
    return base.add(Duration(days: averageIntervalDays!.round()));
  }

  /// Dias até a próxima compra prevista (negativo = já está atrasado).
  int? get daysUntilDue {
    final due = nextDueDate;
    if (due == null) return null;
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final dueOnly = DateTime(due.year, due.month, due.day);
    return dueOnly.difference(todayOnly).inDays;
  }
}
