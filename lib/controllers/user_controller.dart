import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../models/user.dart';

class UserController extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  bool editing = false;
  final user = User(name: '', email: '', address: '');

  void submitForm() {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      Get.snackbar(
        'Success',
        'User information submitted successfully',
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.BOTTOM,
        colorText: Colors.white,
        backgroundColor: Colors.green,
      );
    }
  }

  void checkEditEable() {
    editing = !editing;
    notifyListeners();
  }
}
