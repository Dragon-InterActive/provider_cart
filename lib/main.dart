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

// ---------------------------------------------------------------------------
// 2) Domain
//
// - Product-Klasse (name, price)
// - Demo-Produktliste (Kaffee, Tee, Kakao)
// ---------------------------------------------------------------------------

class Product {
  final String name;
  final double price;
  const Product(this.name, this.price);
}

const products = <Product>[
  Product("Kaffee", 3.50),
  Product("Tee", 2.80),
  Product("Kakao", 3.20),
];

// ---------------------------------------------------------------------------
// 3) Provider State (CartModel, DiscountModel, InventoryModel)
//
// - Klasse CartModel extends ChangeNotifier
// - private Liste _items
// - Getter für items, count, total
// - Methoden: add(Product), removeAt(index), clear()
// - notifyListeners() in jeder Methode
// ---------------------------------------------------------------------------

//CartModel (Warenkorb)
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
      _byName.values.fold(0.0, (sum, it) => (it.product.price * it.qty));
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

//DiscountModel (Rabatte)
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

//InventoryModel (Lagerbestand)
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

// ---------------------------------------------------------------------------
// 4) Shop-Seite
//
// - AppBar mit Warenkorb-Icon + Badge (cart.count)
// - ListView über Produkte
//   - Titel + Preis
//   - IconButton "add_shopping_cart"
//   - onPressed: context.read<CartModel>().add(product)
// - NavigationBar: Button zum Warenkorb
// ---------------------------------------------------------------------------

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
    //watch
    final cartCount = context.watch<CartModel>().count;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Shop"),
        actions: [
          IconButton(
            tooltip: "Warenkorb öffnen",
            onPressed: () => _openCart(context),
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.shopping_cart),
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
            ),
          ),
        ],
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

// ---------------------------------------------------------------------------
// 5) Warenkorb-Seite
//
// - watch<CartModel>() → cart-Objekt
// - Wenn leer: Placeholder
// - Sonst: ListView über cart.items
//   - Entfernen-Button (read().removeAt(i))
// - AppBar: "Leeren"-Button
// - Unten: Summe über cart.total anzeigen
// ---------------------------------------------------------------------------

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
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: const InputDecoration(
                  labelText: "Gutscheincode eingeben",
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: (code) =>
                    context.read<DiscountModel>().applyCode(code),
              ),
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
                    onPressed: cart.count == 0 ? null : () {},
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
