import 'package:flutter/material.dart';
import 'package:notai/screens/find/find_pw_screen.dart';
import '../../../utils/color/color.dart';

class FindPwElevatedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String buttonText;

  const FindPwElevatedButton({
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
          MaterialPageRoute(builder: (context) => FindPwScreen()),
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



