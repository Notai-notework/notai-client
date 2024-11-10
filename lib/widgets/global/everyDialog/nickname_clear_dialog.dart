import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<void> NickNameClearDialog(BuildContext context) async {
  showDialog(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      title: Text('중복없음'),
      content: Text('사용가능한 닉네임.'),
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
