// import 'package:flutter/material.dart';
// import '../../../screens/signup/sign_up_screen.dart';
// import '../../../utils/color/color.dart';
//
// class SignupElevatedButton extends StatelessWidget {
//   final VoidCallback onPressed;
//   final String buttonText;
//
//   const SignupElevatedButton({
//     super.key,
//     required this.onPressed,
//     required this.buttonText,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(
//       onPressed: (){
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) =>  SignUpScreen()),
//         );      },
//       style: ElevatedButton.styleFrom(
//         backgroundColor: threeColor,
//         fixedSize: const Size(200, 30),
//         elevation: 5.0
//       ),
//       child: Text(buttonText),
//     );
//   }
// }
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../screens/signup/sign_up_screen.dart';
import '../../../utils/color/color.dart';

class SignupElevatedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String buttonText;
  final Color backgroundColor;

  const SignupElevatedButton({
    super.key,
    required this.onPressed,
    required this.buttonText,
    this.backgroundColor = threeColor, // 기본값 설정
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: () {
        Navigator.push(
          context,
          CupertinoPageRoute(builder: (context) => SignUpScreen()),
        );
      },
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
      color: backgroundColor,
      borderRadius: BorderRadius.circular(10), // 둥근 모서리 조절 가능
      pressedOpacity: 0.6,
      child: Text(
        buttonText,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
    );
  }
}

