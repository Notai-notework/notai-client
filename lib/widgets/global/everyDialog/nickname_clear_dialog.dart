import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<void> NickNameClearDialog(BuildContext context, void Function() onNickNameLocked) async {
  showDialog(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      title: Text('확인 클릭시 닉네임 선택'),
      content: Text('닉네임 변경을 원하면 취소'),
      actions: [
        CupertinoDialogAction(
          child: Text('확인'),
          onPressed: () {
            Navigator.pop(context);
            onNickNameLocked();
          },
        ),
        CupertinoDialogAction(
          child: Text('취소'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    ),
  );
}
