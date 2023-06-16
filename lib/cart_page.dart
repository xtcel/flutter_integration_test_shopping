import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'checkout_page.dart';
import 'controllers/cart_controller.dart';

class CartPage extends StatelessWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
      ),
      body: ListView.builder(
        itemCount: cartController.cartItems.length,
        itemBuilder: (_, index) {
          final cartItem = cartController.cartItems[index];

          return Dismissible(
            key: ValueKey(cartItem.product.id),
            direction: DismissDirection.endToStart,
            onDismissed: (_) => cartController.removeItem(cartItem),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              child: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            child: ListTile(
              leading: Image.network(
                cartItem.product.imageUrl,
                width: 50.w,
                height: 50.h,
                fit: BoxFit.cover,
              ),
              title: Text(cartItem.product.name),
              subtitle: Text(
                  'Quantity: ${cartItem.quantity} - Total: ¥${cartItem.totalPrice}'),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: 20.w,
          vertical: 10.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              key: const Key('cart-total-price'),
              'Total: ¥${cartController.totalPrice}',
              style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 15,
            ),
            ElevatedButton(
              onPressed: () => Get.to(
                const CheckoutPage(),
              ),
              child: const Text('Checkout'),
            ),
          ],
        ),
      ),
    );
  }
}
