import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notai/widgets/global/everyDialog/email_dialog.dart';
import 'package:notai/widgets/global/everyDialog/nickname_error_dialog.dart';
import 'package:notai/widgets/signup/signupButton/email_auth_elevatedButton.dart';
import 'package:notai/widgets/signup/signupButton/rounded_email_imput.dart';
import 'package:notai/widgets/signup/signupButton/rounded_address_input.dart';
import 'package:notai/widgets/signup/signupButton/rounded_nickname_input.dart';
import 'package:notai/widgets/signup/signupButton/sign_up_clear_elevatedButton.dart';
import 'package:notai/widgets/signup/signupButton/nickname_check_button.dart';
import '../../utils/color/color.dart';
import '../../utils/http/api_service.dart';
import '../global/everyDialog/email_check_dialog.dart';
import '../global/everyDialog/email_locked_dialog.dart';
import '../global/everyDialog/nickname_clear_dialog.dart';
import '../global/everyDialog/nickname_locked_dialog.dart';
import '../global/everyDialog/sign_up_clear_dialog.dart';
import '../global/everyDialog/sign_up_error_dialog.dart';
import '../global/everyDialog/sign_up_http_error.dart';
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
  bool isEmailLocked = false;
  bool isNickNameLocked = false;

  void onEmailAuthSuccess() {
    setState(() {
      isEmailLocked = true; // 이메일 인증 후 입력창 잠금
    });
  }

  void onNickNameLocked() {
    setState(() {
      isNickNameLocked = true;
    });
  }

  Future<void> NickNameCheck() async {
    final api = await ApiService();
    try {
      Response response = await api
          .post("/nickname-check", data: {"nickname": nickNameController.text});

      if (response.statusCode == 200) {
        await NickNameClearDialog(context, onNickNameLocked);
      } else if (response.statusCode == 409) {
        await NickNameErrorDialog(context);
      } else {
        print("다른 상태 코드가 반환되었습니다: ${response.statusCode}");
      }
    } on DioException catch (e) {
      // API 오류 구분
      if (e.response != null) {
        // 서버로부터의 응답이 있는 경우 상태 코드 체크
        switch (e.response!.statusCode) {
          case 409:
            await NickNameErrorDialog(context); // 이메일 중복 시 알림
            break;
          default:
            print("알 수 없는 상태 코드: ${e.response!.statusCode}");
            break;
        }
      } else {
        // 서버 응답이 없고 네트워크 오류 등인 경우
        print("네트워크 오류 발생 또는 서버 연결 불가: ${e.message}");
        await SignUpHttpErrorDialog(context); // 네트워크 오류에 대한 알림
      }
    } catch (e) {
      // 그 외의 오류 처리
      print("예기치 못한 오류 발생: $e");
    }
  }

  Future<void> SignUp() async {
    if (!isEmailLocked) {
      print("이메일 중복은 필수!");
      await EmailLockedDialog(context);
    }
    if (!isNickNameLocked) {
      print("닉네임 중복은 필수!");
      await NicknameLockedDialog(context);
    }

    final api = await ApiService();

    try {
      Response response = await api.post("/register", data: {
        "email": emailController.text,
        "password": passwordController.text,
        "name": nameController.text,
        "phoneNumber": phoneNumberController.text,
        "nickname": nickNameController.text,
        "address": addressController.text,
      });

      if (response.statusCode == 201) {
        print("회원가입 성공");
        await SignUpClearDialog(context);
      } else if (response.statusCode == 400) {
        await SignUpHttpErrorDialog(context);
      }
    } catch (e) {
      print("API 요청 오류: $e");
      await SignUpErrorDialog(context);
      //if 조건문 false시 else 조건문이 실행이 안 되는 이유:
      // 회원정보 기입 안 하면 try문에서 오류가 발생하기 때문에 if문으로 안 넘어가고 catch로 예외처리함
      //그래서 catch에 dialog 넣음.
    }
  }

  //회원가입완료 버튼
  //이것도 api랑 그 외 오류처리 하면 될 것 같기는 함

  Future<void> EmailCheck() async {
    final api = await ApiService();
    try {
      Response response = await api.post("/email-check", data: {
        "email": emailController.text,
      });

      if (response.statusCode == 200) {
        await EmailAuth(); // 중복된 이메일이 없는 경우 이메일 인증 진행
      } else if (response.statusCode == 409) {
        await EmailCheckDialog(context); // 이메일 중복 시 알림
      } else {
        print("다른 상태 코드가 반환되었습니다: ${response.statusCode}");
      }
    } on DioException catch (e) {
      // API 오류 구분
      if (e.response != null) {
        // 서버로부터의 응답이 있는 경우 상태 코드 체크
        switch (e.response!.statusCode) {
          case 409:
            await EmailCheckDialog(context); // 이메일 중복 시 알림
            break;
          default:
            print("알 수 없는 상태 코드: ${e.response!.statusCode}");
            break;
        }
      } else {
        // 서버 응답이 없고 네트워크 오류 등인 경우
        print("네트워크 오류 발생 또는 서버 연결 불가: ${e.message}");
        await SignUpHttpErrorDialog(context); // 네트워크 오류에 대한 알림
      }
    } catch (e) {
      // 그 외의 오류 처리
      print("예기치 못한 오류 발생: $e");
    }
  }

  //이메일 중복 확인 후 인증 진행
  //try-catch 사용시 try 오류 발생하면 무조건 catc처리가 되어 조건문 실행이 안됨
  //그래서 DioException 이용해서 api 오류랑 그 외의 오류 처리 분리함

  Future<void> EmailAuth() async {
    final api = await ApiService();
    showDialog(
      context: context,
      barrierDismissible: true, // 다른 부분을 눌러도 안 닫: false
      builder: (context) => Center(child: CircularProgressIndicator()),
    ); //로딩화면
    try {
      Response response = await api.post("/email-code",
          queryParameters: {"email": emailController.text});
      Navigator.pop(context);

      if (response.statusCode == 200) {
        print("이메일요청 완료");
        EmailDialog(context, onEmailAuthSuccess);
      } else {
        print("실패: ${response.statusCode}");
      }
    } catch (e) {
      print("API 요청 오류: $e");
    }
  }

  //이메일 인증코드 및 이메일 인증 완료

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
                        controller: emailController,
                        islocked: isEmailLocked, // 컨트롤러 연결
                      ),
                    ),
                    Flexible(
                      child: EmailAuthElevatedButton(
                        onPressed: EmailCheck,
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
                        hint: 'phone number(010-xxxx-xxxx)',
                        controller: phoneNumberController, // 컨트롤러 연결
                      ),
                    ),
                    // Flexible(
                    //   child: NumberAuthElevatedButton(
                    //     onPressed: () {
                    //       NumberDialog(context);
                    //     },
                    //     buttonText: '',
                    //   ),
                    // ),
                    // 휴대폰 인증 버튼
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
                        controller: nickNameController,
                        islokced: isNickNameLocked,
                      ),
                    ),
                    Expanded(
                      flex: 1, // 전체 공간에서 1/4 크기 할당
                      child: NickNameCheckButton(
                        onPressed: NickNameCheck,
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
                  onPressed: SignUp,
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
