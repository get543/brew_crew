import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItem {
  final String menuItemId;
  final String itemName;
  final int quantity;
  final double unitPrice;
  final int sugars;
  final String milk;

  const OrderItem({
    required this.menuItemId,
    required this.itemName,
    required this.quantity,
    required this.unitPrice,
    required this.sugars,
    required this.milk,
  });

  OrderItem copyWith({
    int? quantity,
    int? sugars,
    String? milk,
  }) {
    return OrderItem(
      menuItemId: menuItemId,
      itemName: itemName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice,
      sugars: sugars ?? this.sugars,
      milk: milk ?? this.milk,
    );
  }

  Map<String, dynamic> toMap() => {
    'menuItemId': menuItemId,
    'itemName': itemName,
    'quantity': quantity,
    'unitPrice': unitPrice,
    'sugars': sugars,
    'milk': milk,
  };

  factory OrderItem.fromMap(Map<String, dynamic> data) => OrderItem(
    menuItemId: data['menuItemId'] as String? ?? '',
    itemName: data['itemName'] as String? ?? 'Coffee',
    quantity: (data['quantity'] as num?)?.toInt() ?? 1,
    unitPrice: (data['unitPrice'] as num?)?.toDouble() ?? 0,
    sugars: (data['sugars'] as num?)?.toInt() ?? 0,
    milk: data['milk'] as String? ?? 'Whole milk',
  );
}

class CoffeeOrder {
  final String id;
  final String orderNumber;
  final String orderName;
  final String userId;
  final String customerName;
  final DateTime timestamp;
  final String status;
  final double totalPrice;
  final List<OrderItem> items;

  const CoffeeOrder({
    required this.id,
    required this.orderNumber,
    required this.orderName,
    required this.userId,
    required this.customerName,
    required this.timestamp,
    required this.status,
    required this.totalPrice,
    required this.items,
  });

  factory CoffeeOrder.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? <String, dynamic>{};
    final timestamp = data['timestamp'];
    return CoffeeOrder(
      id: snapshot.id,
      orderNumber: data['orderNumber'] as String? ?? snapshot.id.substring(0, 6).toUpperCase(),
      orderName: data['orderName'] as String? ?? _orderNameFromItems(data['items']),
      userId: data['userId'] as String? ?? '',
      customerName: data['customerName'] as String? ?? 'Customer',
      timestamp: timestamp is Timestamp ? timestamp.toDate() : DateTime.now(),
      status: data['status'] as String? ?? 'pending',
      totalPrice: (data['totalPrice'] as num?)?.toDouble() ?? 0,
      items: (data['items'] as List<dynamic>? ?? [])
          .map((item) => OrderItem.fromMap(Map<String, dynamic>.from(item as Map)))
          .toList(),
    );
  }

  static String _orderNameFromItems(dynamic rawItems) {
    final items = (rawItems as List<dynamic>? ?? [])
        .map((item) => OrderItem.fromMap(Map<String, dynamic>.from(item as Map)))
        .toList();
    if (items.isEmpty) return 'Coffee order';
    return items.map((item) => item.itemName).join(' + ');
  }
}
