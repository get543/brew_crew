// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:brew_crew/models/order.dart';
import 'package:brew_crew/providers/cart_provider.dart';

void main() {
  test('cart calculates an order total', () {
    final cart = CartProvider();
    cart.add(
      const OrderItem(
        menuItemId: 'latte',
        itemName: 'Latte',
        quantity: 2,
        unitPrice: 4.5,
        sugars: 1,
        milk: 'Whole milk',
      ),
    );

    expect(cart.items, hasLength(1));
    expect(cart.total, 9);
  });
}
