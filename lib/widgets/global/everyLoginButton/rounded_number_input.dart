import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RoundedNumberInput extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final IconData icon;


  const RoundedNumberInput({
    super.key,
    required this.hint,
    required this.controller,
    required this.icon,

  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: EdgeInsets.fromLTRB(100, 10, 10, 10),
      // 휴대폰 인증 버튼 표시시 알맞는 패딩값.
      margin: EdgeInsets.fromLTRB(100, 10, 100, 10),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6, // 연한 회색 배경
        borderRadius: BorderRadius.circular(12),
      ),
      child: CupertinoTextField(
        controller: controller,
        inputFormatters: [PhoneNumberFormatter()], // 전화번호 형태 자동 변
        maxLength: 13,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        placeholder: hint,
        placeholderStyle: TextStyle(
          color: CupertinoColors.inactiveGray,
          fontWeight: FontWeight.w300,
        ),
        prefix: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Icon(icon, color: CupertinoColors.inactiveGray),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
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
