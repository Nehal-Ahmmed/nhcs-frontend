class PharmacyItem {
  final String name;
  final String generic;
  final String category;
  final int stock;
  final int min;
  final String price;

  PharmacyItem({
    required this.name,
    required this.generic,
    required this.category,
    required this.stock,
    required this.min,
    required this.price,
  });

  PharmacyItem copyWith({
    String? name,
    String? generic,
    String? category,
    int? stock,
    int? min,
    String? price,
  }) {
    return PharmacyItem(
      name: name ?? this.name,
      generic: generic ?? this.generic,
      category: category ?? this.category,
      stock: stock ?? this.stock,
      min: min ?? this.min,
      price: price ?? this.price,
    );
  }
}
