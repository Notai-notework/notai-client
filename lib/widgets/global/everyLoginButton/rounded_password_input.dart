import 'package:flutter/material.dart';

class RoundedPasswordInput extends StatelessWidget {
  final String hint;
  final TextEditingController controller;

  const RoundedPasswordInput({
    super.key,
    required this.hint,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: EdgeInsets.symmetric(vertical: 10),
      margin: EdgeInsets.fromLTRB(100, 10, 100, 10),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
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
