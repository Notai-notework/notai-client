import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notai/widgets/signup/signupButton/email_auth_elevatedButton.dart';
import 'package:notai/widgets/signup/signupButton/rounded_email_imput.dart';
import '../../utils/color/color.dart';
import '../../utils/http/api_service.dart';
import '../global/everyDialog/email_check_dialog.dart';
import '../global/everyDialog/email_dialog.dart';
import '../global/everyDialog/sign_up_http_error.dart';
import '../global/everyLoginButton/rounded_input.dart';
import '../global/everyLoginButton/rounded_name_input.dart';
import '../global/everyLoginButton/rounded_number_input.dart';
import '../global/everyLoginButton/rounded_password_input.dart';
import 'findAllButton/find_elevatedbutton.dart';
import 'findIdButton/find_id_elevatedbutton.dart';
import 'findPwButton/find_pw_elevatedbutton.dart';

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

  void onEmailAuthLocked() async {
    await EmailCheck();
  }

  void onEmailAuthSuccess() {
    setState(() {
      isEmailLocked = true; // 이메일 인증 후 입력창 잠금
    });
  }

  Future<void> EmailCheck() async {
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

      if (response.statusCode == 200) {
        await EmailAuth(); // 중복된 이메일이 없는 경우 이메일 인증 진행
      } else if (response.statusCode == 409) {
        await EmailCheckDialog(context); // 이메일 중복 시 알림
      } else {
        print("다른 상태 코드가 반환되었습니다: ${response.statusCode}");
      }
    } on DioException catch (e) {
      // API 오류 구분
      if (e.response != null) {
        // 서버로부터의 응답이 있는 경우 상태 코드 체크
        switch (e.response!.statusCode) {
          case 409:
            emailController.clear();
            await EmailCheckDialog(context); // 이메일 중복 시 알림
            break;
          default:
            print("알 수 없는 상태 코드: ${e.response!.statusCode}");
            break;
        }
      } else {
        // 서버 응답이 없고 네트워크 오류 등인 경우
        print("네트워크 오류 발생 또는 서버 연결 불가: ${e.message}");
        await SignUpHttpErrorDialog(context); // 네트워크 오류에 대한 알림
      }
    } catch (e) {
      // 그 외의 오류 처리
      print("예기치 못한 오류 발생: $e");
    }
  }

  Future<void> EmailAuth() async {
    final api = await ApiService();
    showDialog(
      context: context,
      barrierDismissible: true, // 다른 부분을 눌러도 안 닫: false
      builder: (context) => Center(child: CircularProgressIndicator()),
    ); //로딩화면
    try {
      Response response = await api.post("/email-code",
          queryParameters: {"email": emailController.text});
      Navigator.pop(context);

      if (response.statusCode == 200) {
        print("이메일요청 완료");
        setState(() {
          isEmailLocked = true;
        });
        EmailDialog(context, onEmailAuthSuccess);
      } else {
        print("실패: ${response.statusCode}");
      }
    } catch (e) {
      Navigator.pop(context); // 로딩 화면 닫기
      print("API 요청 오류: $e");
      showDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text("네트워크 오류"),
          content: Text("네트워크 혹은 이메일을 다시 확인해주세요."),
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
                        'Find Password',
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
                  hint: '비밀번호',
                  controller: passwordController, // 컨트롤러 연결
                ),
                RoundedNameInput(
                  icon: Icons.abc_outlined,
                  hint: '이름',
                  controller: nameController, // 컨트롤러 연결
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      flex: 3, // 전체 공간에서 3/4 크기 할당
                      child: RoundedNumberInput(
                        icon: Icons.phone_iphone_outlined,
                        hint: '전화번호 (- 제외하고 입력)',
                        controller: phoneNumberController, // 컨트롤러 연결
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CupertinoButton(
                      onPressed: () {},
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
