/// Pure Dart Category Entity (Domain Layer)
class Category {
  final String id;
  final String name;
  final String? iconName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;

  const Category({
    required this.id,
    required this.name,
    this.iconName,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
  });

  Category copyWith({
    String? id,
    String? name,
    String? iconName,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Category && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
