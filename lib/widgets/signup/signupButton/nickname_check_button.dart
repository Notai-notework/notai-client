import 'package:flutter/material.dart';
import '../../../utils/color/color.dart';

class NickNameCheckButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String buttonText;

  const NickNameCheckButton({
    Key? key,
    required this.onPressed,
    required this.buttonText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 10, 100, 10),
      // child: IconButton(
      //   onPressed: onPressed,
      //   icon: Icon(Icons.check_circle_sharp),
      //   iconSize: 35,
      //   color: threeColor,
      // )
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(
          "중복확인",
          style: TextStyle(
            fontSize: 13,
            // fontWeight: FontWeight.bold,
            // color: Colors.grey,
          ),
        ),
        style: ElevatedButton.styleFrom(
            backgroundColor: threeColor,
            fixedSize: Size(200, 30),
            elevation: 5.0),
      ),
    );
  }
}
