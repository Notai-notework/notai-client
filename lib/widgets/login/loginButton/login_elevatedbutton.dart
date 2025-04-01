// import 'package:flutter/material.dart';
// import '../../../utils/color/color.dart';
//
// class LoginElevatedButton extends StatelessWidget {
//   final VoidCallback onPressed;
//   final String buttonText;
//
//   const LoginElevatedButton({
//     Key? key,
//     required this.onPressed,
//     required this.buttonText,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(
//       onPressed: onPressed,
//       child: Text(buttonText),
//       style: ElevatedButton.styleFrom(
//         backgroundColor: threeColor,
//         fixedSize: Size(200, 30),
//         elevation: 5.0
//       ),
//     );
//   }
// }
//
//
//
import 'package:flutter/cupertino.dart';
import '../../../utils/color/color.dart';

class LoginElevatedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String buttonText;

  const LoginElevatedButton({
    Key? key,
    required this.onPressed,
    required this.buttonText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: onPressed,
      child: Text(
        buttonText,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
      color: threeColor,  // 버튼 색상
      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),  // 버튼 크기 조정
      borderRadius: BorderRadius.circular(10),  // 모서리 둥글게
      pressedOpacity: 0.6,
    );
  }
}
