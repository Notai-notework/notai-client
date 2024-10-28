import 'package:flutter/material.dart';
import 'package:notai/utils/color/color.dart';

class FindIdOutput extends StatelessWidget {
  const FindIdOutput({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    // 화면 크기 정보 가져오기

    return Center(
      child: SizedBox(
        width: screenWidth * 0.8, // 화면 너비의 80%
        height: screenHeight * 0.5, // 화면 높이의 50%
        //화면 너비 지정하고 지정한 너비의 화면 크기에 따라 margin과 padding 설정
        child: Container(
          // margin: EdgeInsets.symmetric(vertical: screenHeight * 0.02, horizontal: screenWidth * 0.1),
          // padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1, vertical: screenHeight * 0.1),
          // 화면 크기에 따라 margin과 padding 설정
          margin: EdgeInsets.symmetric(
            vertical: screenHeight * 0.02,
            horizontal: screenWidth * 0.1,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.1,
            vertical: screenHeight * 0.1,
          ),
          decoration: BoxDecoration(
            color: threeColor,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("회원님의 아이디는 다음과 같습니다"),
              Text("data"), // db에서 id 출력
            ],
          ),
        ),
      ),
    );
  }
}
