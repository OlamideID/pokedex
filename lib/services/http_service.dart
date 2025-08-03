import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class HttpService {
  HttpService();
  final _dio = Dio();

  Future<Response?> get(String path) async {
    try {
      Response? response = await _dio.get(path);
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }
    return null;
  }
}
