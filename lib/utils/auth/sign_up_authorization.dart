import 'package:http/http.dart' as http;
import 'dart:convert';

class SignUpAuthorization {
  final String apiUrl = 'http://localhost:8080/login';

  Future<void> signUpUser({
    required String email,
    required String password,
    required String name,
    required String phone_number,
    required String nickname,
    required String address,
  }) async {
    Map<String, dynamic> userData = {
      "email": email,
      "password": password,
      "name": name,
      "phone_number": phone_number,
      "nickname": nickname,
      "address": address,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(userData),
      );

      if (response.statusCode == 200) {
        print("회원가입 성공!");
      } else {
        print("회원가입 실패: 상태 코드 ${response.statusCode}");
      }
    } catch (e) {
      print("오류 발생: $e");
    }
  }
}
