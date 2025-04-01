import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RoundedNicknameInput extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final bool islokced;
  final IconData icon;


  const RoundedNicknameInput({
    super.key,
    required this.hint,
    required this.controller,
    required this.icon,
    this.islokced = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 800,
      height: 40,
      // margin: EdgeInsets.symmetric(vertical: 10),
      margin: EdgeInsets.fromLTRB(100, 10, 10, 10),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6, // 연한 회색 배경
        borderRadius: BorderRadius.circular(12),
      ),
      child: CupertinoTextField(
        enabled: !islokced,
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
