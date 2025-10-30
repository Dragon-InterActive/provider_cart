import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_cart/features/cart/providers/cart_provider.dart';
import 'package:provider_cart/features/cart/providers/discount_provider.dart';
import 'package:provider_cart/features/cart/widgets/discount_input.dart';
import 'package:provider_cart/features/checkout/checkout_page.dart';
import 'package:provider_cart/features/shop/providers/inventory_provider.dart';
//import 'package:provider_cart/main.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartModel>();
    final discount = context.watch<DiscountModel>();

    final subtotal = cart.subtotal;
    final total = discount.discountedTotal(subtotal);
    final hasDiscount = discount.percent > 0;

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text("Warenkorb"),
        actions: [
          if (cart.count > 0)
            TextButton(
              onPressed: () => context.read<CartModel>().clear(),
              child: Text("Liste leeren"),
            ),
        ],
      ),

      body: cart.items.isEmpty
          ? const Center(child: Text("Warenkorb ist leer"))
          : ScrollConfiguration(
              behavior: ScrollConfiguration.of(
                context,
              ).copyWith(overscroll: false),
              child: ListView.builder(
                itemCount: cart.items.length,
                itemBuilder: (_, i) {
                  final item = cart.items[i];
                  return ListTile(
                    title: Text("${item.qty}x ${item.product.name}"),
                    subtitle: Text(
                      "${item.product.price.toStringAsFixed(2)} € ",
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            context.read<CartModel>().decrement(item.product);
                            context.read<InventoryModel>().putBack(
                              item.product,
                            );
                          },
                          icon: const Icon(Icons.remove),
                        ),
                        IconButton(
                          onPressed: () {
                            final ok = context.read<InventoryModel>().take(
                              item.product,
                            );
                            if (ok) {
                              context.read<CartModel>().increment(item.product);
                            }
                          },
                          icon: const Icon(Icons.add),
                        ),
                        IconButton(
                          onPressed: () {
                            context.read<InventoryModel>().putBack(
                              item.product,
                              item.qty,
                            );
                            context.read<CartModel>().removeProduct(
                              item.product,
                            );
                          },
                          icon: const Icon(Icons.delete),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
      bottomNavigationBar: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DiscountInput(
              onSubmit: (code) => context.read<DiscountModel>().applyCode(code),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Zwischensumme: ${subtotal.toStringAsFixed(2)} €"),
                        if (hasDiscount)
                          Text(
                            "Rabatt (${discount.percent * 100.round()}%): -${(subtotal - total).toStringAsFixed(2)} €",
                            style: const TextStyle(color: Colors.green),
                          ),
                        Text(
                          "Gesamt: ${total.toStringAsFixed(2)} €",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FilledButton(
                    onPressed: cart.count == 0
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const CheckoutPage(), // Zum Checkout
                              ),
                            );
                          },
                    child: const Text("Zur Kasse"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
