import 'package:flutter/material.dart';

class RoundedAddressInput extends StatelessWidget {
  final String hint;
  final TextEditingController controller;

  const RoundedAddressInput({
    Key? key,
    required this.hint,
    required this.controller,
  }) : super(key: key);

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
        decoration: InputDecoration(
          icon: Icon(Icons.home, color: Colors.grey),
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey.withOpacity(0.5), // 투명도 설정
            fontWeight: FontWeight.w300, // 가벼운 폰트 두께
            fontStyle: FontStyle.italic, // 기울임꼴 (선택 사항)
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
