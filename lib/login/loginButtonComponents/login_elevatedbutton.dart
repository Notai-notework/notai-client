import 'package:flutter/material.dart';
import '../../etc/color.dart';

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
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(buttonText),
      style: ElevatedButton.styleFrom(
        backgroundColor: threeColor,
        fixedSize: Size(200, 30),
        elevation: 5.0
      ),
    );
  }
}



