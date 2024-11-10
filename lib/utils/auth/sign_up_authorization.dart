// // import 'package:dio/dio.dart';
// // import '../http/api_service.dart';
// //
// // Future<void> SignUp() async {
// //   final api = await ApiService();
// //   var email;
// //   var password;
// //   var name;
// //   var phone_number;
// //   var nickname;
// //   var address;
// //   Response response = await api.post("/resgister", data: {
// //     "email": email,
// //     "password": password,
// //     "name": name,
// //     "phone_number": phone_number,
// //     "nickname": nickname,
// //     "address": address,
// //   });
// //
// //   if (response.statusCode == 200) {
// //     print("완료");
// //   } else {
// //     print("실패");
// //   }
// // }
//
//
// import 'package:dio/dio.dart';
// import '../http/api_service.dart';
//
// Future<void> SignUp() async {
//   final api = await ApiService();
//
//   var email;
//   var password;
//   var name;
//   var phone_number;
//   var nickname;
//   var address;
//
//   try {
//     Response response = await api.post("/register", data: {
//       "email": email,
//       "password": password,
//       "name": name,
//       "phone_number": phone_number,
//       "nickname": nickname,
//       "address": address,
//     });
//
//     if (response.statusCode == 200) {
//       print("회원가입 성공");
//     } else {
//       print("실패: ${response.statusCode}");
//     }
//   } catch (e) {
//     print("API 요청 오류: $e");
//   }
// }
