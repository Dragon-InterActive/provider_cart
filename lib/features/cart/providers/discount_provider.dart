//DiscountModel (Rabatte)
import 'package:flutter/material.dart';

class DiscountModel extends ChangeNotifier {
  double _percent = 0.0;
  double get percent => _percent;

  void applyCode(String code) {
    final c = code.trim().toUpperCase();
    if (c == "SAVE10") {
      _percent = 0.10;
    } else if (c == "SAVE20") {
      _percent = 0.20;
    } else {
      _percent = 0.0;
    }
    notifyListeners();
  }

  double discountedTotal(double subtotal) => subtotal * (1 - _percent);
}
