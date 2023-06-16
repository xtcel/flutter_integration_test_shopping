import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../controllers/user_controller.dart';

class UserPage extends StatelessWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userController = Provider.of<UserController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // 显示编辑表单
              userController.checkEditEable();
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: userController.editing
            ? editFrom(userController)
            : profile(userController),
      ),
    );
  }

  Widget profile(UserController userController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(
          height: 20,
        ),
        CircleAvatar(
          radius: 50.r,
          backgroundImage: NetworkImage(userController.user.avatarUrl),
        ),
        const SizedBox(
          height: 20,
        ),
        Text(
          userController.user.name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Text(
          userController.user.email,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Text(
          userController.user.address,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
          ),
        ),
      ],
    );
  }

  Widget editFrom(UserController userController) {
    return Form(
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
            validator: (value) =>
                value!.isEmpty ? 'Please enter your shipping address' : null,
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => userController.submitForm(),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
