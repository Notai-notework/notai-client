import 'package:flutter/material.dart';
import 'package:notai/widgets/signup/signupButton/email_auth_elevatedButton.dart';
import 'package:notai/widgets/signup/signupButton/number_auth_elevatedButton.dart';
import 'package:notai/widgets/signup/signupButton/rounded_email_imput.dart';
import 'package:notai/widgets/signup/signupButton/rounded_address_input.dart';
import 'package:notai/widgets/signup/signupButton/rounded_nickname_input.dart';
import 'package:notai/widgets/signup/signupButton/rounded_pw_check_input.dart';
import 'package:notai/widgets/signup/signupButton/sign_up_clear_elevatedButton.dart';
import 'package:notai/widgets/signup/signupButton/nickname_check_button.dart';
import '../../utils/auth/sign_up_authorization.dart';
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
  final SignUpAuthorization signUpService = SignUpAuthorization();


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
                  '회원가입',
                  style: TextStyle(
                      color: titleColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 60),
                ),
                SizedBox(height: 30),
                // SvgPicture.asset('utils/images/login.svg'),
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
                RoundedPasswordInput(
                  hint: 'password',
                  controller: passwordController, // 컨트롤러 연결
                ),
                SizedBox(height: 10),
                RoundedPwCheckInput(
                  hint: 'password check',
                  controller: passwordCheckController, // 컨트롤러 연결
                ),
                SizedBox(height: 10),
                RoundedNameInput(
                  hint: 'name',
                  controller: nameController, // 컨트롤러 연결
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      flex: 3, // 전체 공간에서 3/4 크기 할당
                      child: RoundedNumberInput(
                        hint: 'phone number',
                        controller: phoneNumberController, // 컨트롤러 연결
                      ),
                    ),
                    Flexible(
                      child: NumberAuthElevatedButton(
                        onPressed: () {},
                        buttonText: '',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 3, // 전체 공간에서 3/4 크기 할당
                      child: RoundedNicknameInput(
                        hint: 'nickname',
                        controller: nickNameController, // 컨트롤러 연결
                      ),
                    ),
                    Expanded(
                      flex: 1, // 전체 공간에서 1/4 크기 할당
                      child: NickNameCheckButton(
                        onPressed: () {},
                        buttonText: '',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                RoundedAddressInput(
                  hint: 'address',
                  controller: addressController, // 컨트롤러 연결
                ),
                SizedBox(height: 10),
                SignUpClearElevatedButton(
                  onPressed: () {signUpService.signUpUser(
                    email: emailController.text,
                    password: passwordController.text,
                    name: nameController.text,
                    phone_number: phoneNumberController.text,
                    nickname: nickNameController.text,
                    address: addressController.text,
                  );},
                  buttonText: "회원가입완료",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
