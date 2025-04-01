import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../utils/color/color.dart';

class AddressSearchButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String buttonText;
  final Color backgroundColor;

  const AddressSearchButton({
    Key? key,
    required this.onPressed,
    required this.buttonText,
    this.backgroundColor = threeColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 40,
      margin: EdgeInsets.fromLTRB(0, 10, 100, 10),
      child: CupertinoButton(
        onPressed: onPressed,
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12), // 둥근 모서리 조절 가능
        pressedOpacity: 0.6,
        child: Text(
          buttonText,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
