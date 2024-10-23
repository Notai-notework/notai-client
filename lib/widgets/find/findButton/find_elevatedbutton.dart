import 'package:flutter/material.dart';
import '../../../screens/find/find_all_screen.dart';
import '../../../utils/color/color.dart';

class FindElevatedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String buttonText;

  const FindElevatedButton({
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
          MaterialPageRoute(builder: (context) => const FindAllScreen()),
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



