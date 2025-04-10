import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lottie/lottie.dart';
import '../../screens/main_screen.dart';
import '../../utils/auth/login_authorization.dart';
import '../../utils/color/color.dart';
import '../../utils/http/api_service.dart';
import '../find/findAllButton/find_elevatedbutton.dart';
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
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 300), () {
      setState(() {
        _opacity = 1.0; // 로그인 텍스트 서서히 나타나기
      });
    });
  }

  Future<void> login() async {
    final api = await ApiService();
    try {
      Response response = await api.post("/login", data: {
        "email": emailController.text,
        "password": passwordController.text
      });

      if (response.statusCode == 200) {
        String? access = response.headers['Authorization']![0];
        String? refresh = response.headers['refresh']![0];

        final storage = await FlutterSecureStorage();
        await storage.write(key: "Authorization", value: access);
        await storage.write(key: "refresh", value: refresh);
        await storage.write(key: "isLoggedIn", value: "true");

        // Navigator.pushReplacement(
        //     context, MaterialPageRoute(builder: (context) => MainScreen()));
        Navigator.pop(context);
      }
    } on DioException catch (e) {
      showDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text('로그인 오류'),
          content: Text('입력 정보를 확인해주세요.'),
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

    api.init();
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
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context); // 뒤로 가기
                    },
                  ),
                ),
                SizedBox(height: 90),
                AnimatedOpacity(
                  opacity: _opacity,
                  duration: Duration(seconds: 1), // 서서히 나타나도록 설정
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 100),
                      child: Text(
                        'Welcome',
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
                  duration: Duration(seconds: 1), // 서서히 나타나도록 설정
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 100),
                      child: Text(
                        'To The NOTAI',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontFamily: "bold",
                          color: titleColor,
                          fontWeight: FontWeight.w300,
                          fontSize: 60,
                          letterSpacing: 1,
                          wordSpacing: 5,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                // 이메일 입력 필드
                RoundedInput(
                  icon: Icons.mail,
                  hint: '이메일',
                  controller: emailController, // 컨트롤러 연결
                ),
                // 비밀번호 입력 필드
                RoundedPasswordInput(
                  icon: Icons.lock,
                  hint: '비밀번호',
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
                      onPressed: login,
                      buttonText: "로그인",
                    ),
                    SizedBox(width: 20),
                    FindElevatedButton(
                      onPressed: () {},
                      buttonText: "비밀번호 찾기",
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
