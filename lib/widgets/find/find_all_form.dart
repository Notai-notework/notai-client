import 'package:flutter/material.dart';
import 'package:notai/widgets/signup/signupButton/email_auth_elevatedButton.dart';
import 'package:notai/widgets/signup/signupButton/rounded_email_imput.dart';
import '../../utils/auth/login_authorization.dart';
import '../../utils/color/color.dart';
import '../global/everyLoginButton/rounded_name_input.dart';
import '../global/everyLoginButton/rounded_number_input.dart';
import '../signup/signupButton/number_auth_elevatedButton.dart';
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
  final TextEditingController passwordCheckController = TextEditingController();
  final TextEditingController findidnameController = TextEditingController();
  final TextEditingController findpwnameController = TextEditingController();
  final TextEditingController findidphoneNumberController = TextEditingController();
  final TextEditingController findpwphoneNumberController = TextEditingController();
  final TextEditingController nickNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  // final LoginAuthService authService =ㄷ
  //     LoginAuthService(); // AuthService 인스턴스 생성

  // Future<void> login() async {
  //   String? token = await authService.login(
  //     emailController.text,
  //     passwordController.text,
  //   );
  // }

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
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context); // 뒤로 가기
                    },
                  ),
                ),
                Text(
                  '아이디 찾기',
                  style: TextStyle(
                      color: titleColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 60),
                ),
                RoundedNameInput(
                  hint: 'name',
                  controller: findidnameController, // 컨트롤러 연결
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      flex: 3, // 전체 공간에서 3/4 크기 할당
                      child: RoundedNumberInput(
                        hint: 'phone number',
                        controller: findidphoneNumberController, // 컨트롤러 연결
                      ),
                    ),
                    // Flexible(
                    //   child: NumberAuthElevatedButton(
                    //     onPressed: () {},
                    //     buttonText: '',
                    //   ),
                    // ),
                  ],
                ),
                FindIdElevatedButton(
                  onPressed: () {},
                  buttonText: "아이디 찾기",
                ),
                SizedBox(height: 50),
                Text(
                  '비밀번호 찾기',
                  style: TextStyle(
                      color: titleColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 60),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      flex: 3, // 전체 공간에서 3/4 크기 할당
                      child: RoundedEmailInput(
                        icon: Icons.mail,
                        hint: 'email',
                        controller: emailController, // 컨트롤러 연결
                      ),
                    ),
                    Flexible(
                      child: EmailAuthElevatedButton(
                        onPressed: () {},
                        buttonText: '',
                      ),
                    ),
                  ],
                ),
                RoundedNameInput(
                  hint: 'name',
                  controller: findpwnameController, // 컨트롤러 연결
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      flex: 3, // 전체 공간에서 3/4 크기 할당
                      child: RoundedNumberInput(
                        hint: 'phone number',
                        controller: findpwphoneNumberController, // 컨트롤러 연결
                      ),
                    ),
                    // Flexible(
                    //   child: NumberAuthElevatedButton(
                    //     onPressed: () {},
                    //     buttonText: '',
                    //   ),
                    // ),
                  ],
                ),
                FindPwElevatedButton(
                  onPressed: () {},
                  buttonText: "비밀번호 찾기",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
