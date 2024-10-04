import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/color/color.dart';
import '../../widgets/login/login_form.dart';
import '../../widgets/signup/signup_form.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  bool isLogin = true;
  late Animation<double> containerSize;
  AnimationController? animationController;
  Duration animationDuration = Duration(milliseconds: 270);

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(vsync: this, duration: animationDuration);
  }

  @override
  void dispose() {
    animationController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    double viewInset = MediaQuery.of(context)
        .viewInsets
        .bottom; // we are using this to determine Keyboard is opened or not
    double defaultLoginSize = size.height - (size.height * 0.2);
    double defaultRegisterSize = size.height - (size.height * 0.1);

    containerSize =
        Tween<double>(begin: size.height * 0.1, end: defaultRegisterSize)
            .animate(CurvedAnimation(
            parent: animationController!, curve: Curves.linear));

    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // Lets add some decorations
            Positioned(
                top: 100,
                right: -50,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: kPrimaryColor),
                )),

            Positioned(
                top: -50,
                left: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: kPrimaryColor),
                )),


            SignUpForm(
                isLogin: isLogin,
                animationDuration: animationDuration,
                size: size,
                defaultLoginSize: defaultLoginSize),

          ],
        ),
      ),
    );
  }

}

