import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notai/widgets/signup/signupButton/email_auth_elevatedButton.dart';
import 'package:notai/widgets/signup/signupButton/rounded_email_imput.dart';
import '../../utils/color/color.dart';
import '../../utils/http/api_service.dart';
import '../global/everyDialog/email_check_dialog.dart';
import '../global/everyDialog/email_dialog.dart';
import '../global/everyDialog/pw_email_check_dialog.dart';
import '../global/everyDialog/sign_up_http_error.dart';
import '../global/everyLoginButton/rounded_password_input.dart';

class FindAllForm extends StatefulWidget {
  const FindAllForm({
    Key? key,
    required this.isLogin,
    required this.animationDuration,
    required this.size,
    required this.defaultLoginSize,
  }) : super(key: key);

  final bool isLogin;
  final Duration animationDuration;
  final Size size;
  final double defaultLoginSize;

  @override
  _FindAllFormState createState() => _FindAllFormState();
}

class _FindAllFormState extends State<FindAllForm> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  double _opacity = 0.0;
  bool isEmailLocked = false;

  void onEmailAuthSuccess() {
    setState(() {
      isEmailLocked = true; // 이메일 인증 후 입력창 잠금
    });
  }

  void onEmailAuthLocked() async {
    await PwEmailCheck();
  }

  Future<void> PwEmailCheck() async {
    final api = await ApiService();

    if (emailController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text("이메일 입력"),
          content: Text("이메일을 입력해 주세요."),
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
      return;
    }

    try {
      Response response = await api.post("/email-check", data: {
        "email": emailController.text,
      });

      if (response.statusCode == 409) {
        //409 = 이메일 중복 = 이메일 이미 존재 = 인증 진행
        await EmailAuth();
      } else if (response.statusCode == 200) {
        //200 = 가입 가능 이메일 = 가입되지 않은 이메일 = 비밀번호 찾기 불가
        await PwEmailCheckDialog(context);
      } else {
        print("다른 상태 코드가 반환되었습니다: ${response.statusCode}");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        switch (e.response!.statusCode) {
          case 409:
            await EmailAuth(); // 이미 가입된 이메일 → 인증
            break;
          default:
            print("알 수 없는 상태 코드: ${e.response!.statusCode}");
            break;
        }
      } else {
        print("네트워크 오류: ${e.message}");
        await SignUpHttpErrorDialog(context);
      }
    } catch (e) {
      print("예외 발생: $e");
    }
  }

  Future<void> EmailAuth() async {
    final api = await ApiService();
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );
    try {
      Response response = await api.post(
        "/email-code",
        queryParameters: {"email": emailController.text},
      );
      Navigator.pop(context);

      if (response.statusCode == 200) {
        print("이메일 인증 코드 전송 성공");
        EmailDialog(context, emailController.text, onEmailAuthSuccess); // 인증 코드 입력 받기
      } else {
        print("인증 요청 실패: ${response.statusCode}");
      }
    } catch (e) {
      Navigator.pop(context);
      print("API 오류: $e");
      showDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text("네트워크 오류"),
          content: Text("이메일 인증 중 문제가 발생했습니다."),
          actions: [
            CupertinoDialogAction(
              child: Text('확인'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  Future<void> changePassword() async {
    final api = await ApiService();
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text("입력 오류"),
          content: Text("이메일과 변경할 비밀번호를 모두 입력해 주세요.",
              style: TextStyle(
                fontSize: 17,
              )),
          actions: [
            CupertinoDialogAction(
              child: Text('확인'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      Response response = await api.patch("/password-change", data: {
        "email" : emailController.text,
        "password": passwordController.text, //새로운 비밀번호
      });

      Navigator.pop(context); // 로딩창 닫기

      if (response.statusCode == 200) {
        await showDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: Text("성공"),
            content: Text("비밀번호가 성공적으로 변경되었습니다."),
            actions: [
              CupertinoDialogAction(
                child: Text('확인'),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context); // 비밀번호 변경 화면도 닫기
                },
              ),
            ],
          ),
        );
      } else {
        print("비밀번호 변경 실패: ${response.statusCode}");
      }
    } on DioException catch (e) {
      Navigator.pop(context); // 로딩창 닫기
      print("Dio 오류: ${e.message}");
      await showDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text("에러"),
          content: Text("네트워크 오류가 발생했습니다. 다시 시도해주세요."),
          actions: [
            CupertinoDialogAction(
              child: Text('확인'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      print("예기치 못한 오류: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _opacity = 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: widget.isLogin ? 1.0 : 0.0,
      duration: widget.animationDuration * 4,
      child: Align(
        alignment: Alignment.center,
        child: Container(
          width: widget.size.width,
          height: widget.defaultLoginSize,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // 뒤로가기 버튼
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(height: 90),
                AnimatedOpacity(
                  opacity: _opacity,
                  duration: const Duration(seconds: 1),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 100),
                      child: Text(
                        'Change',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontFamily: "bold",
                          color: titleColor,
                          fontWeight: FontWeight.w300,
                          fontSize: 80,
                          letterSpacing: 3,
                        ),
                      ),
                    ),
                  ),
                ),
                AnimatedOpacity(
                  opacity: _opacity,
                  duration: const Duration(seconds: 1),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 100),
                      child: Text(
                        'Password',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontFamily: "bold",
                          color: titleColor,
                          fontWeight: FontWeight.w300,
                          fontSize: 80,
                          letterSpacing: 3,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                AnimatedOpacity(
                  opacity: _opacity,
                  duration: const Duration(seconds: 1),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 100),
                      child: Text(
                        'In The NOTAI',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontFamily: "bold",
                          color: titleColor,
                          fontWeight: FontWeight.w300,
                          fontSize: 80,
                          letterSpacing: 3,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      flex: 3, // 전체 공간에서 3/4 크기 할당
                      child: RoundedEmailInput(
                        icon: Icons.mail,
                        hint: '이메일',
                        controller: emailController,
                        islocked: isEmailLocked, // 컨트롤러 연결
                      ),
                    ),
                    Flexible(
                      child: EmailAuthElevatedButton(
                        onPressed: isEmailLocked ? () {} : onEmailAuthLocked,
                        // 인증 완료되면 버튼 비활성화
                        buttonText: isEmailLocked ? '인증 완료' : '이메일 인증',
                      ),
                    ),
                  ],
                ),
                RoundedPasswordInput(
                  icon: Icons.lock,
                  hint: '변경할 비밀번호',
                  controller: passwordController, // 컨트롤러 연결
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CupertinoButton(
                      onPressed: changePassword,
                      color: threeColor,
                      // 버튼 색상
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                      // 버튼 크기 조정
                      borderRadius: BorderRadius.circular(10),
                      // 모서리 둥글게
                      child: Text("비밀번호 변경"),
                      pressedOpacity: 0.6,
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
