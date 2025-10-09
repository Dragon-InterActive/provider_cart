import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_cart/features/cart/providers/cart_provider.dart';
import 'package:provider_cart/features/cart/screens/cart_page.dart';
import 'package:provider_cart/features/shop/providers/inventory_provider.dart';
import 'package:provider_cart/features/shop/widgets/cart_badge.dart';
import '../data/repositories/product_repository.dart';

class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  void _openCart(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CartPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final products = ProductRepository().getProducts();
    //watch
    final cartCount = context.watch<CartModel>().count;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Shop"),
        actions: [CartBadge(onTap: () => _openCart(context))],
      ),
      //Produktliste
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (_, i) {
          final p = products[i];
          final stock = context.watch<InventoryModel>().stockFor(p);
          return ListTile(
            title: Text(p.name),
            subtitle: Text("${p.price.toStringAsFixed(2)} € - Bestand: $stock"),
            trailing: IconButton(
              tooltip: stock == 0 ? "Nicht Verfügbar" : "Hinzufügen",
              onPressed: stock == 0
                  ? null
                  : () {
                      final ok = context.read<InventoryModel>().take(p);
                      if (ok) {
                        context.read<CartModel>().add(p);
                      }
                    },
              icon: const Icon(Icons.add_shopping_cart),
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: FilledButton(
            onPressed: () => _openCart(context),
            child: const Text("Zum Warenkorb"),
          ),
        ),
      ),
    );
  }
}
