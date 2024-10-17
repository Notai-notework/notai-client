import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:notai/screens/login/login_screen.dart';

import '../../main.dart';

class ApiService {
  late final Dio dio;
  final String? baseUrl = dotenv.env['API_BASE_URL'];

  static final ApiService _instance = ApiService._internal();

  bool _isInitialized = false;

  ApiService._internal() {}

  factory ApiService() {
    return _instance;
  }

  Future<void> _init() async {
    dio = Dio(); // dio 초기화

    // 로깅
    dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));

    // 토큰 인터셉터
    dio.interceptors.add(InterceptorsWrapper(
        onResponse: (Response response, ResponseInterceptorHandler handler) {
      return handler.next(response);
    }, onError: (DioException e, ErrorInterceptorHandler handler) async {
      // 상태 코드 확인
      if (e.response?.statusCode == 401) {
        // 토큰 문제
        print(e.response?.data['message']);

        await _refreshToken();

        // 재요청
        final storage = await FlutterSecureStorage();
        final access = await storage.read(key: 'Authorization');
        final refresh = await storage.read(key: 'refresh');

        final options = e.response!.requestOptions;
        options.headers['Authorization'] = access;
        options.headers['refresh'] = refresh;

        final response = await dio.fetch(options);
        return handler.resolve(response);
      }
      return handler.next(e);
    }));

    dio.options.baseUrl = baseUrl!;

    // 토큰 헤더 세팅
    var storage = const FlutterSecureStorage();

    String? access = await storage.read(key: 'Authorization');
    String? refresh = await storage.read(key: 'refresh');

    if (access != null) {
      dio.options.headers['Authorization'] = access;
    }

    if (refresh != null) {
      dio.options.headers['refresh'] = refresh;
    }

    _isInitialized = true;
  }

  // 액세트 토큰 재발급 요청
  Future<void> _refreshToken() async {
    final response = await post('/refresh-token');

    if (response.statusCode == 200) {
      print('토큰 재발급 성공');

      final storage = await FlutterSecureStorage();
      await storage.write(
          key: 'Authorization', value: response.headers.value('Authorization'));
      await storage.write(
          key: 'refresh', value: response.headers.value('refresh'));

      dio.options.headers['Authorization'] =
          response.headers.value('Authorization');
      dio.options.headers['refresh'] = response.headers.value('refresh');
    }
  }

  // 초기화 대기
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await _init();
    }
  }

  // GET 요청
  Future<Response> get(String endpoint,
      {Map<String, dynamic>? queryParameters}) async {
    await _ensureInitialized(); // 초기화 대기
    return await dio.get(endpoint, queryParameters: queryParameters);
  }

  // POST 요청
  Future<Response> post(String endpoint,
      {Map<String, dynamic>? data,
      Map<String, dynamic>? queryParameters}) async {
    await _ensureInitialized(); // 초기화 대기
    return await dio.post(endpoint,
        data: data, queryParameters: queryParameters);
  }

  // PUT 요청
  Future<Response> put(String endpoint,
      {Map<String, dynamic>? data,
      Map<String, dynamic>? queryParameters}) async {
    await _ensureInitialized(); // 초기화 대기
    return await dio.put(endpoint,
        data: data, queryParameters: queryParameters);
  }

  // PATCH 요청
  Future<Response> patch(String endpoint,
      {Map<String, dynamic>? data,
      Map<String, dynamic>? queryParameters}) async {
    await _ensureInitialized(); // 초기화 대기
    return await dio.patch(endpoint,
        data: data, queryParameters: queryParameters);
  }

  // DELETE 요청
  Future<Response> delete(String endpoint,
      {Map<String, dynamic>? queryParameters}) async {
    await _ensureInitialized(); // 초기화 대기
    return await dio.delete(endpoint, queryParameters: queryParameters);
  }
}
