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
    ChangeNotifierProvider(create: (_) => CartModel(), child: const MyApp()),
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
// 3) Provider State (CartModel)
//
// - Klasse CartModel extends ChangeNotifier
// - private Liste _items
// - Getter für items, count, total
// - Methoden: add(Product), removeAt(index), clear()
// - notifyListeners() in jeder Methode
// ---------------------------------------------------------------------------

class CartModel extends ChangeNotifier {
  final List<Product> _items = [];

  //Lesezugriff
  List<Product> get items => List.unmodifiable(_items);
  int get count => _items.length;
  double get total => _items.fold(0.0, (sum, p) => sum + p.price);

  //Schreibzugriff
  void add(Product p) {
    _items.add(p);
    notifyListeners();
  }

  //Löschen
  void removeAt(int index) {
    if (index < 0 || index >= _items.length) return;
    _items.removeAt(index);
    notifyListeners();
  }

  //Clear
  void clear() {
    _items.clear();
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
    //final cartCount = context.watch<CartModel>().count;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Shop"),
        actions: [
          IconButton(
            onPressed: () => _openCart(context),
            icon: Icon(Icons.shopping_cart),
          ),
        ],
      ),
      //Produktliste
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (_, i) {
          final p = products[i];
          return ListTile(
            title: Text(p.name),
            subtitle: Text("${p.price.toStringAsFixed(2)} €"),
            trailing: IconButton(
              tooltip: "Hinzufügen",
              onPressed: () => context.read<CartModel>().add(p),
              icon: const Icon(Icons.add_shopping_cart),
            ),
          );
        },
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

    return Scaffold(
      appBar: AppBar(
        title: const Text("Warenkorb"),
        actions: [
          if (cart.count > 0)
            TextButton(
              onPressed: () => context.read<CartModel>().clear(),
              child: Text("Liste leeren"),
            ),
        ],
      ),

      body: cart._items.isEmpty
          ? const Center(child: Text("Warenkorb ist leer"))
          : ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (_, i) {
                final item = cart._items[i];
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text("${item.price.toStringAsFixed(2)} €"),
                  trailing: IconButton(
                    onPressed: () => context.read<CartModel>().removeAt(i),
                    icon: const Icon(Icons.delete),
                  ),
                );
              },
            ),
    );
  }
}
