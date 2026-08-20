/// Pure Dart Store Entity (Domain Layer)
class Store {
  final String id;
  final String name;
  final String? address;
  final String? phone;
  final String? logoPath;
  final String currency;
  final String? pin;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;

  const Store({
    required this.id,
    required this.name,
    this.address,
    this.phone,
    this.logoPath,
    this.currency = 'IDR',
    this.pin,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
  });

  Store copyWith({
    String? id,
    String? name,
    String? address,
    String? phone,
    String? logoPath,
    String? currency,
    String? pin,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return Store(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      logoPath: logoPath ?? this.logoPath,
      currency: currency ?? this.currency,
      pin: pin ?? this.pin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Store && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
