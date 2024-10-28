import 'package:flutter/material.dart';
import '../../utils/color/color.dart';
import 'findPwButton/new_pw_change_clear_button.dart';
import 'findPwButton/new_pw_input.dart';
import 'findPwButton/new_pw_input_check.dart';

class FindPwForm extends StatefulWidget {
  const FindPwForm({
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
  _FindPwFormState createState() => _FindPwFormState();
}

class _FindPwFormState extends State<FindPwForm> {


  final TextEditingController newPwController = TextEditingController();
  final TextEditingController newPwCheckController = TextEditingController();


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
                  '비밀번호 찾기',
                  style: TextStyle(
                      color: titleColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 60),
                ),
                SizedBox(height: 30),
                NewPwInput(
                  hint: 'new password',
                  controller: newPwController, // 컨트롤러 연결
                ),
                NewPwInputCheck(
                  hint: 'new password check',
                  controller: newPwCheckController, // 컨트롤러 연결
                ),
                SizedBox(height: 30),
                NewPwChangeClearButton(
                  onPressed: () {},
                  buttonText: "",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


