// import 'package:flutter/material.dart';
// import 'color.dart';
// import 'input_container.dart';
//
//
//
// class RoundedPasswordInput extends StatelessWidget {
//    RoundedPasswordInput({
//     Key? key,
//     required this.hint,
//   }) : super(key: key);
//
//   final String hint;
//
//   @override
//   Widget build(BuildContext context) {
//     return InputContainer(
//       child: TextField(
//         cursorColor: kPrimaryColor,
//         obscureText: true,
//         decoration: InputDecoration(
//           icon: Icon(Icons.lock, color: kPrimaryColor),
//           hintText: hint,
//           border: InputBorder.none
//         ),
//       ));
//   }
// }


import 'package:flutter/material.dart';
import 'color.dart';
import 'input_container.dart';

class RoundedPasswordInput extends StatelessWidget {
  final String hint;
  final TextEditingController controller;

  const RoundedPasswordInput({
    Key? key,
    required this.hint,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(29),
      ),
      child: TextField(
        controller: controller,
        obscureText: true, // 비밀번호 입력 시 텍스트 숨김 처리
        decoration: InputDecoration(
          icon: Icon(Icons.lock, color: Colors.grey),
          hintText: hint,
          border: InputBorder.none,
        ),
      ),
    );
  }
}
