import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RoundedInput extends StatelessWidget {
  final IconData icon;
  final String hint;
  final TextEditingController controller;

  const RoundedInput({
    Key? key,
    required this.icon,
    required this.hint,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
          fontStyle: FontStyle.italic,
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
