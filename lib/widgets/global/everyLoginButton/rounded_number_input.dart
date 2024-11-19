import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RoundedNumberInput extends StatelessWidget {
  final String hint;
  final TextEditingController controller;

  const RoundedNumberInput({
    super.key,
    required this.hint,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: EdgeInsets.fromLTRB(100, 10, 10, 10),
      // 휴대폰 인증 버튼 표시시 알맞는 패딩값.
      margin: EdgeInsets.fromLTRB(100, 10, 100, 10),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
            icon: Icon(Icons.phone_android_sharp, color: Colors.grey),
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey.withOpacity(0.5), // 투명도 설정
              fontWeight: FontWeight.w300, // 가벼운 폰트 두께
              fontStyle: FontStyle.italic, // 기울임꼴 (선택 사항)
            ),
            border: InputBorder.none,
            counterText: ''),
        inputFormatters: [PhoneNumberFormatter()], // 전화번호 형태 자동 변
        maxLength: 13,
      ),
    );
  }
}

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll('-', ''); // 기존 하이픈 제거

    // 입력된 텍스트가 없을 경우 그대로 반환
    if (text.isEmpty) {
      return newValue.copyWith(
          text: '', selection: TextSelection.collapsed(offset: 0));
    }

    // 최대 길이 제한 (11자리까지만)
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i == 3 || i == 7) buffer.write('-'); // 3번째와 7번째에 하이픈 추가
      buffer.write(text[i]);
    }

    // 새로 만들어진 텍스트
    final formattedText = buffer.toString();

    // 새로운 텍스트와 커서 위치 업데이트
    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
