import 'package:dio/dio.dart';
import 'package:shopping/models/product.dart';

class ProductService {
  final Dio dio;

  ProductService(this.dio);

  Future<List<Product>> getProducts() async {
    const path = '/products';

    try {
      final res = await dio.get(path);
      final products =
          List<Map<String, dynamic>>.from(res.data['data']['products']);
      return products.map((p) {
        return Product(
          id: p['id'],
          name: p['name'],
          imageUrl: p['image_url'],
          price: p['price'].toDouble(),
          description: p['description'],
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }
}
