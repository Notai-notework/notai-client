// //import 'dart:convert';
// //import 'package:http/http.dart' as http;
//
// // class LoginAuthService {
// //   final String apiUrl = 'http://localhost:8080/login'; // Spring Boot 서버 URL
// //
// //   Future<String?> login(String email, String password) async {
// //
// //       final response = await http.post(
// //         Uri.parse(apiUrl),
// //         headers: <String, String>{
// //           'Content-Type': 'application/json; charset=UTF-8',
// //         },
// //         body: jsonEncode(<String, String>{
// //           'email': email,
// //           'password': password,
// //         }),
// //       );
// //
// //       print('Email: $email');
// //       print('Password: $password');
// //
// //       if (response.statusCode == 200) {
// //         String? token = response.headers['authorization'];
// //         print('Login successful! Token: $token');
// //         return token;
// //       } else {
// //         print('Login failed with status: ${response.statusCode}');
// //         return null;
// //       }
// //
// //     }
// //   }
// import 'package:dio/dio.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
//
// import '../http/api_service.dart';
//
// Future<void> login() async {
//   final api = await ApiService();
//   Response response = await api.post("/login", data: {"email": "", "password": "1234"});
//
//   if (response.statusCode == 200) {
//     String? access = response.headers['Authorization']![0];
//     String? refresh = response.headers['refresh']![0];
//
//     final storage = await FlutterSecureStorage();
//     await storage.write(key: "Authorization", value: access);
//     await storage.write(key: "refresh", value: refresh);
//   }
// }