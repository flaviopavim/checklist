class ShoppingList {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime? completedAt;
  final bool isActive;

  ShoppingList({
    required this.id,
    required this.name,
    required this.createdAt,
    this.completedAt,
    this.isActive = true,
  });

  ShoppingList copyWith({
    String? name,
    DateTime? completedAt,
    bool? isActive,
  }) {
    return ShoppingList(
      id: id,
      name: name ?? this.name,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'isActive': isActive ? 1 : 0,
    };
  }

  factory ShoppingList.fromMap(Map<String, dynamic> map) {
    return ShoppingList(
      id: map['id'] as String,
      name: map['name'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'] as String)
          : null,
      isActive: (map['isActive'] as int) == 1,
    );
  }
}
