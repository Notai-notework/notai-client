import 'package:flutter/material.dart';
import '../../../screens/login/login_screen.dart';
import '../../../utils/color/color.dart';

class SignUpClearElevatedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String buttonText;

  const SignUpClearElevatedButton({
    super.key,
    required this.onPressed,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => LoginScreen()), //회원가입완료하면 폴더 화면으로 이동하기.
        );
      },
      style: ElevatedButton.styleFrom(
          backgroundColor: threeColor,
          fixedSize: const Size(200, 30),
          elevation: 5.0),
      child: Text(buttonText),
    );
  }
}
