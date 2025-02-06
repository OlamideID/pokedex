import 'package:dio/dio.dart';

class HttpService {
  HttpService();
  final _dio = Dio();

  Future<Response?> get(String path) async {
    try {
      Response? response = await _dio.get(path);
      return response;
    } catch (e) {
      print('Error: $e');
    }
    return null;
  }
}
