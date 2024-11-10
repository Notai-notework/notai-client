import 'package:flutter/material.dart';
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
        onPressed();
      },
      style: ElevatedButton.styleFrom(
          backgroundColor: threeColor,
          fixedSize: const Size(200, 30),
          elevation: 5.0),
      child: Text(buttonText),
    );
  }
}
