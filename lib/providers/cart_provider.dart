import 'package:flutter/foundation.dart';
import 'package:brew_crew/models/order.dart';

class CartProvider extends ChangeNotifier {
  final List<OrderItem> _items = [];

  List<OrderItem> get items => List.unmodifiable(_items);

  double get total => _items.fold(
    0,
    (sum, item) => sum + item.unitPrice * item.quantity,
  );

  void add(OrderItem item) {
    _items.add(item);
    notifyListeners();
  }

  void removeAt(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  void updateAt(int index, OrderItem item) {
    _items[index] = item;
    notifyListeners();
  }

  void changeQuantity(int index, int quantity) {
    if (quantity < 1) {
      removeAt(index);
      return;
    }
    updateAt(index, _items[index].copyWith(quantity: quantity));
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
