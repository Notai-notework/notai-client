import 'package:flutter/material.dart';
import '../../../screens/signup/sign_up_screen.dart';
import '../../../utils/color/color.dart';

class SignupElevatedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String buttonText;

  const SignupElevatedButton({q
    super.key,
    required this.onPressed,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: (){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>  SignUpScreen()),
        );      },
      style: ElevatedButton.styleFrom(
        backgroundColor: threeColor,
        fixedSize: const Size(200, 30),
        elevation: 5.0
      ),
      child: Text(buttonText),
    );
  }
}



