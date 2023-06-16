import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:shopping/controllers/controllers.dart';
import 'package:shopping/controllers/user_controller.dart';
import 'package:shopping/main.dart';
import 'package:shopping/services/services.dart';
import 'package:shopping/user_page.dart';

const baseUrl = 'https://example.com/api';
final dio = Dio(BaseOptions(baseUrl: baseUrl));

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    var handler = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails errorDetails) {
      if (errorDetails.exception is FormatException) {
        FlutterError.onError = handler;
      }
    };
  });

  setUpAll(() {
    final dioAdapter = DioAdapter(dio: dio, matcher: const UrlRequestMatcher());
    dio.httpClientAdapter = dioAdapter;
    dioAdapter.onGet(
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
              'name': 'Product 1',
              'image_url':
                  'https://fastly.picsum.photos/id/972/200/300.jpg?hmac=UMf5f6BV9GkLiz0Xz9kMwm1riiTtlpIG2jt0WrxZ51Q',
              'price': 58.9,
              'description':
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec auctor, nisl id aliquam ultricies, nunc nisl ultricies nunc'
            },
          ]
        }
      }),
    );

    dioAdapter.onPost(
      '/checkout',
      (request) => request.reply(200, {
        'message': 'Successfully checkout!',
        'data': true,
      }),
    );
  });

  group('App Test', () {
    // 测试是否可以正常显示产品列表。
    testWidgets('Displaying product list', (WidgetTester tester) async {
      await tester.pumpWidget(const _MyAppWrapper());

      // 页面重建
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // 查找包含产品列表的控件
      final listView = find.byType(ListView);

      // 确保找到了产品列表
      expect(listView, findsOneWidget);
    });

    // 测试是否可以将产品添加到购物车。
    testWidgets('Adding product to cart', (WidgetTester tester) async {
      await tester.pumpWidget(const _MyAppWrapper());

      // 页面重建
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // 模拟用户打开一个产品
      await tester.tap(find.byType(ListTile).first);

      // 等待应用程序进入产品页面
      await tester.pumpAndSettle();

      // 模拟用户点击添加到购物车的按钮
      await tester.tap(find.byIcon(Icons.add_shopping_cart));

      // 等待动画效果完成
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // 模拟用户点击返回按钮
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // 模拟用户进入购物车页面
      await tester.tap(find.byIcon(Icons.shopping_cart));
      await tester.pumpAndSettle();

      // 查找购物车列表项的控件
      final cartListTile = find.byType(ListTile);

      // 确保购物车中有添加的商品
      expect(cartListTile, findsOneWidget);
    });

    // 测试是否可以验证购物车并计算价格。
    testWidgets('Verifying cart and calculating prices',
        (WidgetTester tester) async {
      await tester.pumpWidget(const _MyAppWrapper());

      // 页面重建
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // 模拟点击产品列表加入购物车按钮，最后一个
      await tester.tap(find.byIcon(Icons.add_shopping_cart).last);
      await tester.pumpAndSettle();

      // 模拟用户打开一个产品页面
      await tester.tap(find.byType(ListTile).first);
      await tester.pumpAndSettle();

      // 模拟用户点击添加到购物车的按钮
      await tester.tap(find.byIcon(Icons.add_shopping_cart));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // 模拟用户点击返回按钮
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // 模拟用户进入购物车页面
      await tester.tap(find.byIcon(Icons.shopping_cart));
      await tester.pumpAndSettle();

      // 查找购物车列表项的控件
      final cartListTile = find.byType(ListTile);

      // 确保购物车中有添加的商品
      expect(cartListTile, findsNWidgets(2));

      // 计算应该付款的金额
      final cartController = Get.find<CartController>();
      final totalPrice = cartController.cartItems
          .map((item) => item.product.price)
          .reduce((a, b) => a + b);

      // 查找购物车总价的 Text 控件
      final priceTextFinder = find.byKey(const Key('cart-total-price'));
      // 确保找到了购物车总价 Text 控件
      expect(priceTextFinder, findsOneWidget);
      // 验证购物车总价是否正确
      final priceTextWidget = tester.widget(priceTextFinder) as Text;
      expect(priceTextWidget.data, 'Total: ¥$totalPrice');
    });

    // 测试是否可以验证用户信息表单的提交。
    testWidgets('Submitting user information form',
        (WidgetTester tester) async {
      await tester.pumpWidget(const _MyAppWrapper());

      // 页面重建
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // 模拟用户打开我的页面
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();

      // 模拟用户点击编辑按钮
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      // 查找用户信息表单
      final form = find.byType(Form);

      // 确保找到了用户信息表单
      expect(form, findsOneWidget);

      // 输入用户信息
      await tester.enterText(find.byKey(const Key('name-text-field')), 'Tom');
      await tester.enterText(find.byKey(const Key('email-text-field')),
          '[tom@gmail.com](mailto:tom@gmail.com)');
      await tester.enterText(
          find.byKey(const Key('address-text-field')), '123 Main St.');

      // 模拟用户点击提交按钮
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      // 验证用户信息是否正确
      final BuildContext context = tester.element(find.byType(UserPage));
      final userController =
          Provider.of<UserController>(context, listen: false);
      expect(userController.user.name, 'Tom');
      expect(
          userController.user.email, '[tom@gmail.com](mailto:tom@gmail.com)');
      expect(userController.user.address, '123 Main St.');
    });

    // 测试是否可以与 API 进行通信并获取正确的数据。
    testWidgets('Communicating with API and getting correct data',
        (WidgetTester tester) async {
      // 注册一个实例化 ProductService 的回调函数
      final productService = ProductService(dio);
      final productController =
          Get.put(ProductController(productService: productService));
      await tester.pumpWidget(const _MyAppWrapper());
      // 模拟用户打开产品列表页面
      productController.fetchProducts();
      await tester.pump(const Duration(seconds: 2));
      // 确保找到包含产品列表的控件
      final listView = find.byType(ListView);
      // 确保找到了产品列表
      expect(listView, findsOneWidget);
    });
  });

  tearDown(() {
    // 清空购物车
    final cartController = Get.find<CartController>();
    cartController.clear();
  });

  tearDownAll(() {
    // 清空购物车
    final cartController = Get.find<CartController>();
    cartController.clear();
  });
}

class _MyAppWrapper extends StatelessWidget {
  const _MyAppWrapper({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
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
}
