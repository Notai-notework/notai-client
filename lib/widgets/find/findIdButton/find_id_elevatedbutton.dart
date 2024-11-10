import 'package:flutter/material.dart';
import '../../../screens/find/find_id_screen.dart';
import '../../../utils/color/color.dart';

class FindIdElevatedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String buttonText;

  const FindIdElevatedButton({
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
          // MaterialPageRoute(builder: (context) => FindIdScreen(email: "dd")),
          MaterialPageRoute(builder: (context) => FindIdScreen()),
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



