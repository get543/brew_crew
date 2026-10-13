import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:brew_crew/models/order.dart';

class OrderService {
  final CollectionReference<Map<String, dynamic>> _orders = FirebaseFirestore.instance.collection('orders');

  Stream<List<CoffeeOrder>> customerOrders(String uid) {
    return _orders
        .where('userId', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(CoffeeOrder.fromSnapshot).toList());
  }

  Stream<List<CoffeeOrder>> get activeOrders {
    return _orders
        .where('status', whereIn: ['pending', 'brewing', 'ready'])
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) => snapshot.docs.map(CoffeeOrder.fromSnapshot).toList());
  }

  Future<String> placeOrder({
    required String userId,
    required String customerName,
    required List<OrderItem> items,
  }) async {
    final reference = _orders.doc();
    final orderNumber = reference.id.substring(0, 6).toUpperCase();
    final orderName = items.map((item) => item.itemName).join(' + ');
    await reference.set({
      'orderNumber': orderNumber,
      'orderName': orderName.isEmpty ? 'Coffee order' : orderName,
      'userId': userId,
      'customerName': customerName,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'pending',
      'totalPrice': items.fold<double>(
        0,
        (total, item) => total + item.unitPrice * item.quantity,
      ),
      'items': items.map((item) => item.toMap()).toList(),
    });
    return reference.id;
  }

  Future<void> updateStatus(String orderId, String status) {
    return _orders.doc(orderId).update({'status': status});
  }
}
