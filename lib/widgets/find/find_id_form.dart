import 'package:flutter/material.dart';
import '../../utils/auth/login_authorization.dart';
import '../../utils/color/color.dart';
import '../global/everyLoginButton/rounded_name_input.dart';
import '../global/everyLoginButton/rounded_number_input.dart';
import '../login/loginButton/login_elevatedbutton.dart';
import '../signup/signupButton/number_auth_elevatedButton.dart';
import '../signup/signupButton/sign_up_clear_elevatedButton.dart';
import 'findIdButton/find_id_login_elevatedbutton.dart';
import 'findIdButton/find_id_output.dart';
import 'findPwButton/find_pw_elevatedbutton.dart';

class FindIdForm extends StatefulWidget {
  const FindIdForm({
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
  _FindIdFormState createState() => _FindIdFormState();
}

class _FindIdFormState extends State<FindIdForm> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordCheckController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController nickNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

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
                      fontSize: 65),
                ),
                SizedBox(height: 30),
                FindIdOutput(),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 20),
                    FindIdLoginElevatedButton(
                      onPressed: () {},
                      buttonText: "로그인",
                    ),
                    SizedBox(width: 20),
                    FindPwElevatedButton(
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
