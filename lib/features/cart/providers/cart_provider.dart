//CartModel (Warenkorb)
import 'package:flutter/material.dart';
import 'package:provider_cart/features/shop/data/models/product.dart';

class CartItem {
  final Product product;
  int qty;
  CartItem({required this.product, this.qty = 1});
}

class CartModel extends ChangeNotifier {
  final Map<String, CartItem> _byName = {};

  //Lesezugriff
  List<CartItem> get items => _byName.values.toList(growable: false);
  int get count => _byName.values.fold(
    0,
    (sum, it) => sum + it.qty,
  ); //Summe weil Mengenangabe
  double get subtotal =>
      //_byName.values.fold(0.0, (sum, it) => (it.product.price * it.qty));
      _byName.values.fold(0.0, (sum, it) => sum + (it.product.price * it.qty));
  //fold addiert nicht auf den vorherigen Wert sonden gibt nur den letzten zurück.
  double get total => subtotal; //wird mit Discount verrechenet

  //Schreibzugriff
  void add(Product p) {
    final key = p.name;
    if (_byName.containsKey(key)) {
      _byName[key]!.qty++;
    } else {
      _byName[key] = CartItem(product: p, qty: 1);
    }
    notifyListeners();
  }

  void increment(Product p) {
    add(p);
  }

  void decrement(Product p) {
    final key = p.name;
    if (!_byName.containsKey(key)) return;
    final item = _byName[key]!;
    if (item.qty > 1) {
      item.qty--;
    } else {
      _byName.remove(key);
    }
    notifyListeners();
  }

  void removeProduct(Product p) {
    _byName.remove(p.name);
    notifyListeners();
  }

  //Clear
  void clear() {
    _byName.clear();
    notifyListeners();
  }
}
