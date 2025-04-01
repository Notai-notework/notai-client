/*
import 'package:flutter/material.dart';

class RoundedEmailInput extends StatelessWidget {
  final IconData icon;
  final String hint;
  final TextEditingController controller;
  final bool islocked;

  const RoundedEmailInput({
    Key? key,
    required this.icon,
    required this.hint,
    required this.controller,
    this.islocked = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: EdgeInsets.symmetric(vertical: 10),
      margin: EdgeInsets.fromLTRB(100, 10, 10, 10),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        enabled: !islocked,
        controller: controller,
        decoration: InputDecoration(
          icon: Icon(icon, color: Colors.grey),
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
*/
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RoundedEmailInput extends StatelessWidget {
  final IconData icon;
  final String hint;
  final TextEditingController controller;
  final bool islocked;

  const RoundedEmailInput({
    Key? key,
    required this.icon,
    required this.hint,
    required this.controller,
    this.islocked = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 800,
      height: 40,
      margin: const EdgeInsets.fromLTRB(100, 10, 10, 10),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6, // 연한 회색 배경
        borderRadius: BorderRadius.circular(12), // 더 작은 radius
      ),
      child: CupertinoTextField(
        enabled: !islocked,
        controller: controller,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        placeholder: hint,
        placeholderStyle: TextStyle(
          color: CupertinoColors.inactiveGray,
          fontWeight: FontWeight.w300,
        ),
        prefix: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Icon(icon, color: CupertinoColors.inactiveGray),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
