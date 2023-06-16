import 'package:get/get.dart';
import 'package:shopping/models/product.dart';

class ProductController extends GetxController {
  final productService;
  final products = <Product>[].obs;
  final isLoading = true.obs;

  ProductController({required this.productService});

  @override
  void onInit() {
    fetchProducts();
    super.onInit();
  }

  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;
      final List<Product> resProducts = await productService.getProducts();
      products.assignAll(resProducts);
    } finally {
      isLoading.value = false;
    }
  }
}
