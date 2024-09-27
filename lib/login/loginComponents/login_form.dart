import 'package:flutter/material.dart';
import 'package:notai/login/loginButtonComponents/login_elevatedbutton.dart';
import '../../authorization/authorization.dart';
import '../../etc/color.dart';
import '../loginButtonComponents/rounded_button.dart';
import '../loginButtonComponents/rounded_input.dart';
import '../loginButtonComponents/rounded_password_input.dart';
import 'dart:convert';
// import 'package:http/http.dart' as http;

class LoginForm extends StatefulWidget {
  const LoginForm({
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
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final AuthService authService = AuthService();  // AuthService 인스턴스 생성

  Future<void> login() async {
    String? token = await authService.login(
      emailController.text,
      passwordController.text,
    );

    if (token != null) {
      print('Login successful!');
      // 성공 시 처리 (예: 새로운 화면으로 이동)
    } else {
      print('Login failed');
      // 실패 시 처리 (예: 에러 메시지 보여주기)
    }
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
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'NOTAI',
                  style: TextStyle(
                      color: titleColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 24),
                ),
                SizedBox(height: 40),
                // 이메일 입력 필드
                RoundedInput(
                  icon: Icons.mail,
                  hint: 'email',
                  controller: emailController,  // 컨트롤러 연결
                ),
                // 비밀번호 입력 필드
                RoundedPasswordInput(
                  hint: 'password',
                  controller: passwordController,  // 컨트롤러 연결
                ),
                SizedBox(height: 10),
                // 로그인 버튼 (분리된 컴포넌트 사용)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LoginElevatedButton(
                      onPressed: () {
                      },
                      buttonText: "회원가입",
                    ),
                    SizedBox(width: 20),
                    LoginElevatedButton(
                      onPressed: (){
                        login();
                      },
                      buttonText: "로그인",
                    ),
                    SizedBox(width: 20),
                    LoginElevatedButton(
                      onPressed: () {
                      },
                      buttonText: "아이디/비밀번호 찾기",
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

