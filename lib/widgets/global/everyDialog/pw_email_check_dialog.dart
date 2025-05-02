import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<void> PwEmailCheckDialog(BuildContext context) async {
  showDialog(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      title: Text('이메일 오류'),
      content: Text('해당 이메일로 가입된 계정이 없습니다.'),
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

