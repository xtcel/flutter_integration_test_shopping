import 'package:dio/dio.dart';

class CartService {
  final Dio dio;

  CartService(this.dio);

  Future<Response> checkout(Map<String, dynamic> datas) async {
    const path = '/checkout';
    try {
      final res = await dio.post(path, data: datas);
      return res;
    } catch (e) {
      rethrow;
    }
  }
}
