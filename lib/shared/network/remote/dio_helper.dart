import 'package:dio/dio.dart';

class DioHelper {
  static Dio? dio;

  static init() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'http://192.168.1.3:41654/',
        receiveDataWhenStatusError: true,
      ),
    );
  }

  static Future<Response?> getData({
    required String url,
    Map<String, dynamic>? query,
    String lang = 'en',
    String token = '',
  }) async {
    dio?.options.headers = {
      'lang': lang,
      'Content-Type': 'application/json',
      'Authorization': token.startsWith('Bearer ') ? token : 'Bearer $token',    };

    print('Requesting: ${dio?.options.baseUrl}$url');
    print('Token header: Bearer $token');

    return await dio?.get(url, queryParameters: query);
  }

  static Future<Response?> postData({
    required String url,
    Map<String, dynamic>? query,
    required Map<String, dynamic>? data,
    String lang = 'en',
    String token = '',
  }) async {
    dio?.options.headers = {
      'lang': lang,
      'Content-Type': 'application/json',
      'Authorization': token.startsWith('Bearer ') ? token : 'Bearer $token',};
    return dio?.post(url, queryParameters: query, data: data);
  }

  static Future<Response?> putData({
    required String url,
    Map<String, dynamic>? query,
    required Map<String, dynamic>? data,
    String lang = 'en',
    String token = '',
  }) async {
    dio?.options.headers = {
      'lang': lang,
      'Content-Type': 'application/json',
      'Authorization': token.startsWith('Bearer ') ? token : 'Bearer $token',};
    return dio?.put(url, queryParameters: query, data: data);
  }

}


