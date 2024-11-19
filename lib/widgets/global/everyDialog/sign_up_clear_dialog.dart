import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../screens/login/login_screen.dart';

Future<void> SignUpClearDialog(BuildContext context) async{
  showDialog(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      title: Text('회원가입완료'),
      content: Text('로그인 화면으로 이동합니다.'),
      actions: [
        CupertinoDialogAction(
          child: Text('확인'),
          onPressed: () {
            Navigator.pop(context); // 다이얼로그 닫기
            Navigator.pop(context); // 회원가입 페이지 닫기
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => LoginScreen()),
            // );
          },

        ),
      ],
    ),
  );
}
