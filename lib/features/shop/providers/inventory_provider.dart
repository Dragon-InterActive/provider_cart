//InventoryModel (Lagerbestand)
import 'package:flutter/material.dart';
import 'package:provider_cart/features/shop/data/models/product.dart';

class InventoryModel extends ChangeNotifier {
  final Map<String, int> _stockByName = {"Kaffee": 2, "Tee": 0, "Kakao": 5};

  int stockFor(Product p) => _stockByName[p.name] ?? 0;

  //Verringen vom Lagerbestand
  bool take(Product p) {
    final current = stockFor(p);
    if (current <= 0) return false;
    _stockByName[p.name] = current - 1;
    notifyListeners();
    return true;
  }

  void putBack(Product p, [int qty = 1]) {
    final current = stockFor(p);
    _stockByName[p.name] = current + qty;
    notifyListeners();
  }
}
