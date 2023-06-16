import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart' hide Response;
import 'package:shopping/main.dart';
import 'package:shopping/models/cart_item.dart';
import 'package:shopping/services/services.dart';

class CartController extends GetxController {
  final cartItems = <CartItem>[].obs;
  final CartService cartService;

  double get totalPrice =>
      cartItems.fold<double>(0, (sum, item) => sum + item.totalPrice);

  CartController({required this.cartService});

  void addItem(CartItem item) {
    final index = cartItems.indexWhere((i) => i.product.id == item.product.id);

    if (index == -1) {
      cartItems.add(item);
    } else {
      cartItems[index].increment();
    }

    Get.snackbar(
      'Success',
      'Product added to cart',
      duration: const Duration(seconds: 1),
      snackPosition: SnackPosition.BOTTOM,
      colorText: Colors.white,
      backgroundColor: Colors.green,
    );
  }

  void removeItem(CartItem item) {
    cartItems.remove(item);

    Get.snackbar(
      'Success',
      'Product removed from cart',
      duration: const Duration(seconds: 1),
      snackPosition: SnackPosition.BOTTOM,
      colorText: Colors.white,
      backgroundColor: Colors.green,
    );
  }

  void clear() {
    cartItems.clear();
  }

  void checkout(datas) async {
    EasyLoading.show();
    try {
      Response res = await cartService.checkout(datas);
      if (res.data['data'] == true) {
        EasyLoading.dismiss();
        clear();
        Get.offAll(const HomePage());
        Get.snackbar(
          'Order placed',
          '',
          snackPosition: SnackPosition.BOTTOM,
          colorText: Colors.white,
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        );
      }
    } catch (e) {
      EasyLoading.dismiss();
      Get.snackbar(
        'Error',
        e.toString() ?? '',
        snackPosition: SnackPosition.BOTTOM,
        colorText: Colors.white,
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      );
    }

    //
    // Dio.post(
    //   '/checkout',
    //   data: {
    //     'products': cartController.cartItems
    //         .map((item) => {'id': item.product.id})
    //         .toList(),
    //     'name': userController.user.name,
    //     'email': userController.user.email,
    //     'address': userController.user.address,
    //     'total_price': cartController.totalPrice,
    //   },
    //   beforeSend: () => EasyLoading.show(status: 'Loading…'),
    //   onSuccess: () {
    //     EasyLoading.dismiss();
    //     cartController.clear();
    //     Get.offAll(const HomePage());
    //     Get.snackbar(
    //       'Order placed',
    //       '',
    //       snackPosition: SnackPosition.BOTTOM,
    //       colorText: Colors.white,
    //       backgroundColor: Colors.green,
    //       duration: const Duration(seconds: 2),
    //     );
    //   },
    //   onError: (e) {
    //     EasyLoading.dismiss();
    //     Get.snackbar(
    //       'Error',
    //       e?.toString() ?? '',
    //       snackPosition: SnackPosition.BOTTOM,
    //       colorText: Colors.white,
    //       backgroundColor: Colors.red,
    //       duration: const Duration(seconds: 2),
    //     );
    //   },
    // );
  }
}
