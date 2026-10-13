import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:brew_crew/models/menu_item.dart';

class MenuService {
  final CollectionReference<Map<String, dynamic>> _menu = FirebaseFirestore.instance.collection('menu');

  Stream<List<MenuItemModel>> get items {
    return _menu
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) => MenuItemModel.fromMap(doc.id, doc.data())).toList(),
        );
  }

  Stream<List<MenuItemModel>> get allItems {
    return _menu.snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => MenuItemModel.fromMap(doc.id, doc.data())).toList(),
    );
  }

  Future<void> seedExampleMenu() async {
    final batch = FirebaseFirestore.instance.batch();
    final examples = <String, Map<String, dynamic>>{
      'espresso': {
        'itemName': 'Espresso',
        'basePrice': 2.50,
        'imageUrl': '',
        'availableSugars': [0, 1, 2, 3],
        'milkOptions': ['No milk', 'Whole milk'],
        'isAvailable': true,
      },
      'latte': {
        'itemName': 'Latte',
        'basePrice': 4.50,
        'imageUrl': '',
        'availableSugars': [0, 1, 2, 3, 4],
        'milkOptions': ['Whole milk', 'Oat milk', 'Almond milk'],
        'isAvailable': true,
      },
      'cappuccino': {
        'itemName': 'Cappuccino',
        'basePrice': 4.25,
        'imageUrl': '',
        'availableSugars': [0, 1, 2, 3],
        'milkOptions': ['Whole milk', 'Oat milk'],
        'isAvailable': true,
      },
      'mocha': {
        'itemName': 'Mocha',
        'basePrice': 5.00,
        'imageUrl': '',
        'availableSugars': [0, 1, 2, 3, 4],
        'milkOptions': ['Whole milk', 'Oat milk', 'Almond milk'],
        'isAvailable': true,
      },
    };

    for (final entry in examples.entries) {
      batch.set(_menu.doc(entry.key), entry.value, SetOptions(merge: true));
    }
    await batch.commit();
  }

  Future<void> addItem({
    required String itemName,
    required double basePrice,
    required List<int> availableSugars,
    required List<String> milkOptions,
  }) {
    return _menu.add({
      'itemName': itemName,
      'basePrice': basePrice,
      'imageUrl': '',
      'availableSugars': availableSugars,
      'milkOptions': milkOptions,
      'isAvailable': true,
    });
  }

  Future<void> setAvailability(String itemId, bool isAvailable) {
    return _menu.doc(itemId).update({'isAvailable': isAvailable});
  }
}
