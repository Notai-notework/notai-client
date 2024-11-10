import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<void> SignUpHttpErrorDialog(BuildContext context) async {
  showDialog(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      title: Text('연결실패'),
      content: Text('연결상태를 확인해주세요'),
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
