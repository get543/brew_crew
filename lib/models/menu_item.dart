class MenuItemModel {
  final String id;
  final String itemName;
  final double basePrice;
  final String imageUrl;
  final List<int> availableSugars;
  final List<String> milkOptions;
  final bool isAvailable;

  const MenuItemModel({
    required this.id,
    required this.itemName,
    required this.basePrice,
    required this.imageUrl,
    required this.availableSugars,
    required this.milkOptions,
    required this.isAvailable,
  });

  factory MenuItemModel.fromMap(String id, Map<String, dynamic> data) {
    return MenuItemModel(
      id: id,
      itemName: data['itemName'] as String? ?? 'Coffee',
      basePrice: (data['basePrice'] as num?)?.toDouble() ?? 0,
      imageUrl: data['imageUrl'] as String? ?? '',
      availableSugars: (data['availableSugars'] as List<dynamic>? ?? [0, 1, 2, 3])
          .map((value) => (value as num).toInt())
          .toList(),
      milkOptions: (data['milkOptions'] as List<dynamic>? ?? ['Whole milk']).map((value) => value.toString()).toList(),
      isAvailable: data['isAvailable'] as bool? ?? true,
    );
  }
}
