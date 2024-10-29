import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:notai/repositories/document_repository.dart';
import 'package:notai/screens/login/login_screen.dart';
import 'package:path_provider/path_provider.dart';

import '../../main.dart';

class ApiService {
  late Dio dio;
  final String? baseUrl = dotenv.env['API_BASE_URL'];
  Map<String, dynamic> fileForm = {};

  static final ApiService _instance = ApiService._internal();

  bool _isInitialized = false;

  ApiService._internal() {}

  factory ApiService() {
    return _instance;
  }

  Future<void> _init() async {
    if (!_isInitialized) {
      dio = Dio();
    }

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

        final response;
        if (options.data is FormData) {
          response = await uploadDocument(
              fileForm['id'], fileForm['content'], fileForm['tagName']);
        } else {
          response = await dio.fetch(options);
        }

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

  Future<Response> uploadDocument(
      int id, String content, String tagName) async {
    fileForm = {'id': id, 'content': content, 'tagName': tagName};

    FormData formData = await generateFormData(id, content, tagName);

    // 파일 업로드 요청 보내기
    Response response =
        await post("/api/documents", formData: formData, isFile: true);

    // 응답 처리
    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      print("파일 업로드 성공!");
    }

    return response;
  }

  // formData 생성
  Future<FormData> generateFormData(
      int id, String content, String tagName) async {
    try {
      final dr = await DocumentRepository();
      final found = await dr.findById(id);
      String name = found['name'];

      // 도큐먼트 폴더 경로 가져오기 (예시로 문서 폴더)
      Directory appDocDir = await getApplicationDocumentsDirectory();
      List files = Directory("${appDocDir.path}/$id/").listSync();

      // PDF 파일만 필터링하여 첫 번째 PDF 파일 경로 가져오기
      final pdfFile = files.firstWhere(
        (file) => file.path.endsWith('.pdf'),
        orElse: () => throw Exception("PDF 파일이 없습니다."),
      );

      String filePath = pdfFile.path;

      File file = File(filePath);

      if (!await file.exists()) {
        // print("파일이 존재하지 않습니다.");
        throw Exception("파일이 존재하지 않습니다");
      }

      // FormData에 파일과 함께 추가 데이터를 넣음
      FormData formData = FormData.fromMap({
        "documentFile":
            await MultipartFile.fromFile(filePath, filename: "$name.pdf"),
        "title": name, // 추가 데이터
        "content": content,
        "tagName": tagName
      });

      return formData;
    } catch (e) {
      throw Exception("FormData 생성 에러");
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
      FormData? formData,
      Map<String, dynamic>? queryParameters,
      bool? isFile}) async {
    await _ensureInitialized(); // 초기화 대기

    // if (isFile == true) {
    //   dio.options.headers[ "Content-Type"] = "multipart/form-data";
    // }

    return await dio.post(endpoint,
        data: formData != null ? formData : data,
        queryParameters: queryParameters);
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
