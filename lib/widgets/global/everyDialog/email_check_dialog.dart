import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<void> EmailCheckDialog(BuildContext context) async {
  showDialog(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      title: Text('이메일 중복'),
      content: Text('다른 이메일을 사용해주세요.'),
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
