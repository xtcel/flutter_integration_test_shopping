import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'controllers/cart_controller.dart';
import 'controllers/user_controller.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();
    final userController = Provider.of<UserController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Form(
          key: userController.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                key: const Key('name-text-field'),
                decoration: const InputDecoration(labelText: 'Name'),
                initialValue: userController.user.name,
                onSaved: (value) => userController.user.name = value!,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your name' : null,
              ),
              TextFormField(
                key: const Key('email-text-field'),
                decoration: const InputDecoration(labelText: 'Email'),
                initialValue: userController.user.email,
                onSaved: (value) => userController.user.email = value!,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your email address' : null,
              ),
              TextFormField(
                key: const Key('address-text-field'),
                decoration: const InputDecoration(labelText: 'Address'),
                initialValue: userController.user.address,
                onSaved: (value) => userController.user.address = value!,
                validator: (value) => value!.isEmpty
                    ? 'Please enter your shipping address'
                    : null,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  if (userController.formKey.currentState!.validate()) {
                    userController.formKey.currentState!.save();
                    Map<String, dynamic> datas = {
                      'products': cartController.cartItems
                          .map((item) => {'id': item.product.id})
                          .toList(),
                      'name': userController.user.name,
                      'email': userController.user.email,
                      'address': userController.user.address,
                      'total_price': cartController.totalPrice,
                    };
                    cartController.checkout(datas);
                  }
                },
                child: const Text('Place order'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
