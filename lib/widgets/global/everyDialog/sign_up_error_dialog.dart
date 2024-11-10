import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<void> SignUpErrorDialog(BuildContext context) async {
  showDialog(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      title: Text('회원가입실패'),
      content: Text('형식에 맞게 입력해주세요'),
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
