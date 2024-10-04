import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../utils/auth/login_authorization.dart';
import '../../utils/color/color.dart';
import '../find/findButton/find_elevatedbutton.dart';
import '../global/everyLoginButton/rounded_input.dart';
import '../global/everyLoginButton/rounded_password_input.dart';
import '../signup/signupButton/signup_elevatedbutton.dart';
import 'loginButton/login_elevatedbutton.dart';

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

  final LoginAuthService authService =
      LoginAuthService(); // AuthService 인스턴스 생성

  Future<void> login() async {
    String? token = await authService.login(
      emailController.text,
      passwordController.text,
    );
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
                  'login',
                  style: TextStyle(
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          // Choose the color of the shadow
                          blurRadius: 2.0,
                          // Adjust the blur radius for the shadow effect
                          offset: Offset(2.0,
                              2.0), // Set the horizontal and vertical offset for the shadow
                        ),
                      ],
                      color: titleColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 65),
                ),
                SizedBox(height: 50),
                SvgPicture.asset('utils/images/login.svg'),
                // 이메일 입력 필드
                RoundedInput(
                  icon: Icons.mail,
                  hint: 'email',
                  controller: emailController, // 컨트롤러 연결
                ),
                // 비밀번호 입력 필드
                RoundedPasswordInput(
                  hint: 'password',
                  controller: passwordController, // 컨트롤러 연결
                ),
                SizedBox(height: 30),
                // 로그인 버튼 (분리된 컴포넌트 사용)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SignupElevatedButton(
                      onPressed: () {},
                      buttonText: "회원가입",
                    ),
                    SizedBox(width: 20),
                    LoginElevatedButton(
                      onPressed: () {
                        login();
                      },
                      buttonText: "로그인",
                    ),
                    SizedBox(width: 20),
                    FindElevatedButton(
                      onPressed: () {},
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
