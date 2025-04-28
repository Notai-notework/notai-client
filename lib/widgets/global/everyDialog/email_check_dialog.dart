import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<void> EmailCheckDialog(BuildContext context, {String customMessage = "이미 사용 중인 이메일입니다."}) async {
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

