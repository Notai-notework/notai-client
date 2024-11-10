import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<void> NickNameErrorDialog(BuildContext context)async {
  showDialog(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      title: Text('닉네임 중복'),
      content: Text('다른 닉네임을 사용해주세요.'),
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

