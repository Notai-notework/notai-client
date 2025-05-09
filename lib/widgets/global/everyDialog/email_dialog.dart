import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../utils/http/api_service.dart';

void EmailDialog(BuildContext context, String email, void Function() onEmailAuthSuccess) {
  TextEditingController emailController = TextEditingController();
  TextEditingController emailAuthNumberController = TextEditingController();

  Future<void> EmailNumberAuth() async {
    final api = await ApiService();
    try {
      Response response = await api.post("/email-code-check", data: {
        "email": email,
        "code": emailAuthNumberController.text
      });

      if (response.statusCode == 200) {
        print("이메일인증 완료");
        Navigator.of(context).pop(); // 첫 번째 pop

        await showDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
                  content: Text("인증되었습니다!"),
                  actions: [
                    CupertinoDialogAction(
                        child: Text('확인'),
                        onPressed: () {
                          Navigator.of(context).pop(); // 첫 번째 pop
                          onEmailAuthSuccess(); // 성공 콜백 실행

                        })
                  ],
                ));
      } else {
        print("실패: ${response.statusCode}");
        showDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: Text("인증 실패"),
            content: Text("인증번호가 올바르지 않습니다."),
            actions: [
              CupertinoDialogAction(
                child: Text('확인'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print("API 요청 오류: $e");
    }
  }

  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) => CupertinoAlertDialog(
      title: Text('이메일 인증'),
      content: Column(
        children: [
          SizedBox(height: 10),
          // CupertinoTextField(
          //   controller: emailController,
          //   keyboardType: TextInputType.emailAddress,
          //   placeholder: '이메일',
          // ),
          SizedBox(height: 10),
          CupertinoTextField(
            controller: emailAuthNumberController,
            placeholder: '인증번호',
          ),
        ],
      ),
      actions: [
        CupertinoDialogAction(
          child: Text('확인'),
          onPressed: () {
            EmailNumberAuth();
          },
        ),
      ],
    ),
  );
}
