import 'dart:convert';

class Jwt {
  // JWT 디코드 함수
  Map<String, dynamic>? decodeJWT(String token) {
    // JWT는 '.'로 구분된 세 부분으로 나뉘어 있음
    List<String> parts = token.split(" ")[1].split(".");

    // JWT의 payload 부분은 두 번째 부분 (index 1)
    if (parts.length != 3) {
      return null; // 유효한 JWT가 아님
    }

    // Base64Url 디코딩
    String payload = parts[1];
    String normalizedPayload =
        payload.replaceAll('-', '+').replaceAll('_', '/'); // Base64Url 형식 변환
    switch (normalizedPayload.length % 4) {
      case 2:
        normalizedPayload += '==';
        break;
      case 3:
        normalizedPayload += '=';
        break;
    }

    // JSON 디코딩
    final decodedPayload = utf8.decode(base64.decode(normalizedPayload));
    return jsonDecode(decodedPayload); // JSON 형식으로 변환하여 반환
  }
}
