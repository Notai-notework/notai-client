import 'package:flutter/material.dart';
import '../../../utils/color/color.dart';

class EmailAuthElevatedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String buttonText;

  const EmailAuthElevatedButton({
    Key? key,
    required this.onPressed,
    required this.buttonText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(10, 10, 200, 10),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(Icons.check_circle_sharp),
        iconSize: 35,
        color: threeColor,
      )
      // child: ElevatedButton(
      //   onPressed: onPressed,
      //   child: Text(buttonText),
      //   style: ElevatedButton.styleFrom(
      //       backgroundColor: threeColor,
      //       fixedSize: Size(200, 30),
      //       elevation: 5.0
      //   ),
      // ),
    );
  }
}



