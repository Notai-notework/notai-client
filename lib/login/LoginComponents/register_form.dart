import 'package:flutter/material.dart';
import '../ButtonComponents/rounded_button.dart';
import '../ButtonComponents/rounded_input.dart';
import '../ButtonComponents/rounded_password_input.dart';
import 'package:http/http.dart' as http;

// import 'package:flutter_svg/flutter_svg.dart';


class RegisterForm extends StatelessWidget {
   /*const*/ RegisterForm({
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
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isLogin ? 0.0 : 1.0,
      duration: animationDuration * 5,
      child: Visibility(
        visible: !isLogin,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: size.width,
            height: defaultLoginSize,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  SizedBox(height: 10),

                  Text(
                    'Welcome',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24
                    ),
                  ),

                  SizedBox(height: 40),

                  // SvgPicture.asset('assets/images/register.svg'),

                  SizedBox(height: 40),

                  RoundedInput(icon: Icons.mail, hint: 'Username', controller: emailController),

                  RoundedInput(icon: Icons.face_rounded, hint: 'Name', controller: emailController),

                  RoundedPasswordInput(hint: 'Password', controller: passwordController),

                  SizedBox(height: 10),

                  RoundedButton(title: 'SIGN UP', onPressed: () {},),

                  SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}