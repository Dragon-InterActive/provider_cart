import 'package:provider_cart/features/shop/data/models/product.dart';

class ProductRepository {
  List<Product> getProducts() {
    return const <Product>[
      Product("Kaffee", 3.50),
      Product("Tee", 2.80),
      Product("Kakao", 3.20),
    ];
  }
}
