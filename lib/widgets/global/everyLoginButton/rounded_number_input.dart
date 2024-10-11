import 'package:flutter/material.dart';

class RoundedNumberInput extends StatelessWidget {
  final String hint;
  final TextEditingController controller;

  const RoundedNumberInput({
    super.key,
    required this.hint,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: EdgeInsets.symmetric(vertical: 10),
      margin: EdgeInsets.fromLTRB(200, 10, 200, 10),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          icon: Icon(Icons.phone_android_sharp, color: Colors.grey),
          hintText: hint,
          border: InputBorder.none,
        ),
      ),
    );
  }
}
