import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RoundedNameInput extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final IconData icon;


  const RoundedNameInput({
    super.key,
    required this.hint,
    required this.controller,
    required this.icon,

  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1000,
      height: 40,
      margin: const EdgeInsets.fromLTRB(100, 10, 100, 10),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6, // 연한 회색 배경
        borderRadius: BorderRadius.circular(12), // 더 작은 radius
      ),
      child: CupertinoTextField(
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
