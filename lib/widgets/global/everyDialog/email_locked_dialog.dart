import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<void> EmailLockedDialog(BuildContext context)async {
  showDialog(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      title: Text('중복 확인'),
      content: Text('이메일 중복 확인은 필수입니다.'),
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

