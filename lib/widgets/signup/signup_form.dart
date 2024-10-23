import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:notai/widgets/signup/signupButton/email_auth_elevatedButton.dart';
import 'package:notai/widgets/signup/signupButton/rounded_email_imput.dart';
import 'package:notai/widgets/signup/signupButton/rounded_address_input.dart';
import 'package:notai/widgets/signup/signupButton/rounded_nickname_input.dart';
import 'package:notai/widgets/signup/signupButton/rounded_pw_check_input.dart';
import '../../utils/auth/login_authorization.dart';
import '../../utils/color/color.dart';
import '../global/everyLoginButton/rounded_name_input.dart';
import '../global/everyLoginButton/rounded_number_input.dart';
import '../global/everyLoginButton/rounded_password_input.dart';


class SignUpForm extends StatefulWidget {
  const SignUpForm({
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
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordCheckController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController nickNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  final LoginAuthService authService = LoginAuthService(); // AuthService 인스턴스 생성

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
                  'Sign Up',
                  style: TextStyle(
                      color: titleColor,
                      fontWeight: FontWeight.w800,
                      fontSize:65),
                ),
                SizedBox(height: 50),
                SvgPicture.asset('utils/images/login.svg'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 3,  // 전체 공간에서 3/4 크기 할당
                      child: RoundedEmailInput(
                        icon: Icons.mail,
                        hint: 'email',
                        controller: emailController, // 컨트롤러 연결
                      ),
                    ),
                    Expanded(
                      flex: 1,  // 전체 공간에서 1/4 크기 할당
                      child: EmailAuthElevatedButton(
                        onPressed: () {},
                        buttonText: "check",
                      ),
                    ),
                  ],
                ),
                RoundedPasswordInput(
                  hint: 'password',
                  controller: passwordController, // 컨트롤러 연결
                ),
                SizedBox(height: 10),
                RoundedPwCheckInput(
                  hint: 'password check',
                  controller: passwordCheckController,  // 컨트롤러 연결
                ),
                SizedBox(height: 10),
                RoundedNameInput(
                  hint: 'name',
                  controller: nameController, // 컨트롤러 연결
                ),
                SizedBox(height: 10),
                RoundedNumberInput(
                  hint: 'phone number',
                  controller: phoneNumberController,  // 컨트롤러 연결
                ),
                SizedBox(height: 10),
                RoundedNicknameInput(
                  hint: 'nickname',
                  controller: nickNameController,  // 컨트롤러 연결
                ),
                SizedBox(height: 10),
                RoundedAddressInput(
                  hint: 'address',
                  controller: addressController,  // 컨트롤러 연결
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}