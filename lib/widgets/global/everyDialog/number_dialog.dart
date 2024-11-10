import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void NumberDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      title: Text('nice연동'),
      content: Text('nice연동'),
      actions: [
        CupertinoDialogAction(
          child: Text('확인'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    ),
  );
}

