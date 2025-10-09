// ----------------------------------------------------------------------------
// Struktur:
// 1) Provider Setup (main & App)
// 2) Domain (Produktmodell + Demodaten)
// 3) Provider State (CartModel)
// 4) Shop-Seite (Produkte + Warenkorb-Badge)
// 5) Warenkorb-Seite (Items + Summe)
// ----------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_cart/features/cart/providers/cart_provider.dart';
import 'package:provider_cart/features/cart/providers/discount_provider.dart';
import 'package:provider_cart/features/shop/providers/inventory_provider.dart';
import 'package:provider_cart/features/shop/screens/shop_page.dart';

// ---------------------------------------------------------------------------
// 1) Provider Setup
//
// - runApp() → ChangeNotifierProvider um die App legen
// - MyApp → MaterialApp mit Shop-Seite als Startpunkt
// ---------------------------------------------------------------------------

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartModel()),
        ChangeNotifierProvider(create: (_) => DiscountModel()),
        ChangeNotifierProvider(create: (_) => InventoryModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: ShopPage());
  }
}
