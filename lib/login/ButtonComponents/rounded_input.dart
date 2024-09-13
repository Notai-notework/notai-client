// import 'package:flutter/material.dart';
// import 'color.dart';
// import 'input_container.dart';
//
// class RoundedInput extends StatelessWidget {
//    RoundedInput({
//     Key? key,
//     required this.icon,
//     required this.hint,
//
//   }) : super(key: key);
//
//   final IconData icon;
//   final String hint;
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return InputContainer(
//       child: TextField(
//         cursorColor: kPrimaryColor,
//         decoration: InputDecoration(
//           icon: Icon(icon, color: kPrimaryColor),
//           hintText: hint,
//           border: InputBorder.none
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'color.dart';
import 'input_container.dart';

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
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(29),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          icon: Icon(icon, color: Colors.grey),
          hintText: hint,
          border: InputBorder.none,
        ),
      ),
    );
  }
}
