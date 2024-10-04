import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginAuthService {
  final String apiUrl = 'http://localhost:8080/login'; // Spring Boot 서버 URL

  Future<String?> login(String email, String password) async {

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      print('Email: $email');
      print('Password: $password');

      if (response.statusCode == 200) {
        // 서버에서 토큰을 받는다고 가정
        String? token = response.headers['authorization'];
        print('Login successful! Token: $token');
        return token;  // 토큰 반환
      } else {
        print('Login failed with status: ${response.statusCode}');
        return null;
      }

    }
  }

