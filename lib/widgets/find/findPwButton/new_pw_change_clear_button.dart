import 'package:flutter/material.dart';
import '../../../screens/login/login_screen.dart';
import '../../../utils/color/color.dart';

class NewPwChangeClearButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String buttonText;

  const NewPwChangeClearButton({
    Key? key,
    required this.onPressed,
    required this.buttonText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(100, 10, 100, 10),
      // child: IconButton(
      //   onPressed: onPressed,
      //   icon: Icon(Icons.check_circle_sharp),
      //   iconSize: 35,
      //   color: threeColor,
      // )
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => LoginScreen()),
            // 비밀번호 변경하면 변경완료 모달창 뜨고 로그인 화면으로 이동.
            // 버튼 누르면 비밀번호 변경되도록 코드 추가
          );
        },
        child: Text(
          "변경 완료",
          style: TextStyle(
            fontSize: 13,
            // fontWeight: FontWeight.bold,
            // color: Colors.grey,
          ),
        ),
        style: ElevatedButton.styleFrom(
            backgroundColor: threeColor,
            fixedSize: Size(200, 30),
            elevation: 5.0),
      ),
    );
  }
}
