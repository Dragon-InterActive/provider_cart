import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../cart/providers/cart_provider.dart';

class CartBadge extends StatelessWidget {
  final VoidCallback onTap;

  const CartBadge({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: "Warenkorb öffnen",
      onPressed: onTap,
      icon: Consumer<CartModel>(
        builder: (context, cart, child) {
          final cartCount = cart.count;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              child!,
              if (cartCount > 0)
                Positioned(
                  right: -6,
                  top: -6,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minHeight: 18,
                      minWidth: 18,
                    ),
                    child: Center(
                      child: Text(
                        "$cartCount",
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
        child: const Icon(Icons.shopping_cart),
      ),
    );
  }
}
