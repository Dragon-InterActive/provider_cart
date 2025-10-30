import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../features/cart/providers/cart_provider.dart';
import '../../../features/cart/providers/discount_provider.dart';
import '../../../services/stripe_service.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  bool _isProcessing = false;

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);

    final cart = context.read<CartModel>();
    final discount = context.read<DiscountModel>();

    // Gesamtbetrag mit Rabatt berechnen
    final total = discount.discountedTotal(cart.subtotal);

    // Zahlung über Firebase Cloud Function durchführen
    final success = await StripeService.processPayment(
      totalAmount: total,
      currency: 'eur',
    );

    if (!mounted) return;

    setState(() => _isProcessing = false);

    if (success) {
      // Erfolg: Warenkorb & Rabatt leeren
      cart.clear();
      discount.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Zahlung erfolgreich!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Zurück zur Shop-Seite
      Navigator.popUntil(context, (route) => route.isFirst);
    } else {
      // Fehler
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Zahlung fehlgeschlagen'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartModel>();
    final discount = context.watch<DiscountModel>();

    final subtotal = cart.subtotal;
    final total = discount.discountedTotal(subtotal);
    final hasDiscount = discount.percent > 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bestellübersicht',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Artikel-Übersicht
            Expanded(
              child: ListView.builder(
                itemCount: cart.items.length,
                itemBuilder: (context, index) {
                  final item = cart.items[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('${item.qty}x ${item.product.name}'),
                    trailing: Text(
                      '${(item.product.price * item.qty).toStringAsFixed(2)} €',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  );
                },
              ),
            ),

            const Divider(height: 32),

            // Preisübersicht
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Zwischensumme:'),
                    Text('${subtotal.toStringAsFixed(2)} €'),
                  ],
                ),
                if (hasDiscount) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rabatt (${(discount.percent * 100).round()}%):',
                        style: const TextStyle(color: Colors.green),
                      ),
                      Text(
                        '-${(subtotal - total).toStringAsFixed(2)} €',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Gesamt:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${total.toStringAsFixed(2)} €',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Bezahlen Button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isProcessing ? null : _processPayment,
                child: _isProcessing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Jetzt bezahlen'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
