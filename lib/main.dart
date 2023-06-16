import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:dio/dio.dart';
import 'package:shopping/models/models.dart';
import 'package:shopping/user_page.dart';

import 'cart_page.dart';
import 'controllers/controllers.dart';
import 'controllers/user_controller.dart';
import 'product_page.dart';
import 'services/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    const baseUrl = 'https://example.com/api';
    final dio = Dio(BaseOptions(baseUrl: baseUrl));
    setHttpMockData(dio);

    return MultiProvider(
      providers: [
        Provider<ProductService>(
          create: (_) => ProductService(dio),
        ),
        ChangeNotifierProvider<UserController>(
          create: (_) => UserController(),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(750, 1334),
        builder: (context, widget) => GetMaterialApp(
          title: 'Flutter Demo',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          initialBinding: BindingsBuilder(() {
            Get.put(CartController(cartService: CartService(dio)));
          }),
          home: const HomePage(),
          builder: EasyLoading.init(),
        ),
      ),
    );
  }

  void setHttpMockData(dio) {
    final dioAdapter = DioAdapter(
      dio: dio,
      matcher: const UrlRequestMatcher(),
    );
    dio.httpClientAdapter = dioAdapter;
    dioAdapter
      ..onGet(
        '/products',
        (request) => request.reply(200, {
          'message': 'Successfully mocked GET!',
          'data': {
            'products': [
              {
                'id': 1,
                'name': 'Product 1',
                'image_url':
                    'https://fastly.picsum.photos/id/756/200/300.jpg?hmac=kojqQY60yVD4KaSEFOEw62LRuwfiOR2f-6ZdnEgKhxM',
                'price': 100,
                'description':
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec auctor, nisl id aliquam ultricies, nunc nisl ultricies nunc'
              },
              {
                'id': 2,
                'name': 'Product 2',
                'image_url':
                    'https://fastly.picsum.photos/id/33/200/300.jpg?hmac=qR8hcN554jbCl8H5FeRXTKkBc7X5FsPX4CWR8WAQnko',
                'price': 29.9,
                'description':
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec auctor, nisl id aliquam ultricies, nunc nisl ultricies nunc'
              },
              {
                'id': 3,
                'name': 'Product 3',
                'image_url':
                    'https://fastly.picsum.photos/id/972/200/300.jpg?hmac=UMf5f6BV9GkLiz0Xz9kMwm1riiTtlpIG2jt0WrxZ51Q',
                'price': 58.9,
                'description':
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec auctor, nisl id aliquam ultricies, nunc nisl ultricies nunc'
              },
            ]
          }
        }),
      )
      ..onPost(
        '/checkout',
        (request) => request.reply(200, {
          'message': 'Successfully checkout!',
          'data': true,
        }),
      );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productService = Provider.of<ProductService>(context);
    final productController = Get.put(
      ProductController(productService: productService),
    );
    final cartController = Get.find<CartController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Virtual Shop'),
        leading: IconButton(
          icon: const Icon(Icons.person),
          onPressed: () => Get.to(
            const UserPage(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => Get.to(
              const CartPage(),
            ),
          ),
        ],
      ),
      body: Obx(
        () => productController.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: productController.products.length,
                itemBuilder: (_, index) {
                  final product = productController.products[index];

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      onTap: () => Get.to(
                        ProductPage(product: product),
                      ),
                      leading: Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                      ),
                      title: Text(product.name),
                      subtitle: Text(product.price.toString()),
                      trailing: IconButton(
                        icon: const Icon(Icons.add_shopping_cart),
                        onPressed: () =>
                            cartController.addItem(CartItem(product: product)),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
