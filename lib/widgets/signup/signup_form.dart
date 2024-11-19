import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notai/widgets/global/everyDialog/email_dialog.dart';
import 'package:notai/widgets/global/everyDialog/nickname_error_dialog.dart';
import 'package:notai/widgets/signup/signupButton/address_search_Button.dart';
import 'package:notai/widgets/signup/signupButton/email_auth_elevatedButton.dart';
import 'package:notai/widgets/signup/signupButton/postcode_input.dart';
import 'package:notai/widgets/signup/signupButton/rounded_email_imput.dart';
import 'package:notai/widgets/signup/signupButton/rounded_address_input.dart';
import 'package:notai/widgets/signup/signupButton/rounded_nickname_input.dart';
import 'package:notai/widgets/signup/signupButton/sign_up_clear_elevatedButton.dart';
import 'package:notai/widgets/signup/signupButton/nickname_check_button.dart';
import 'package:remedi_kopo/remedi_kopo.dart';
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
import 'package:flutter/cupertino.dart';

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

final GlobalKey<FormState> formKey = GlobalKey<FormState>();
Map<String, String> formData = {};

class _SignUpFormState extends State<SignUpForm> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordCheckController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController nickNameController = TextEditingController();

  // final TextEditingController addressController = TextEditingController();
  final TextEditingController postcodeController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController detailAddressController = TextEditingController();
  bool isEmailLocked = false;
  bool isNickNameLocked = false;

  // 입력 폼 모두 입력 여부
  bool isFormComplete() {
    return !emailController.text.isEmpty ||
        !passwordController.text.isEmpty ||
        !passwordCheckController.text.isEmpty ||
        !nameController.text.isEmpty ||
        !phoneNumberController.text.isEmpty ||
        !nickNameController.text.isEmpty ||
        !postcodeController.text.isEmpty ||
        !addressController.text.isEmpty ||
        !detailAddressController.text.isEmpty;
  }

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

  void onEmailAuthLocked() async {
    await EmailCheck();
  }

  void onNickNameAuthLocked() async {
    await NickNameCheck();
  }

  Future<void> NickNameCheck() async {
    final api = await ApiService();
    if (nickNameController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text("닉네임 입력"),
          content: Text("닉네임을 입력해 주세요."),
          actions: [
            CupertinoDialogAction(
              child: Text('확인'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
      return;
    }
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
    if (isFormComplete() == false) {
      await SignUpErrorDialog(context);
      return;
    }

    if (!isEmailLocked) {
      print("이메일 중복 확인은 필수!");
      await EmailLockedDialog(context);
      return;
    }
    if (!isNickNameLocked) {
      print("닉네임 중복 확인은 필수!");
      await NicknameLockedDialog(context);
      return;
    }

    final api = await ApiService();

    try {
      Response response = await api.post("/register", data: {
        "email": emailController.text,
        "password": passwordController.text,
        "name": nameController.text,
        "phoneNumber": phoneNumberController.text,
        "nickname": nickNameController.text,
        "address": addressController.text + " " + detailAddressController.text,
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

  Future<void> EmailCheck() async {
    final api = await ApiService();
    if (emailController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text("이메일 입력"),
          content: Text("이메일을 입력해 주세요."),
          actions: [
            CupertinoDialogAction(
              child: Text('확인'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
      return;
    }
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
            emailController.clear();
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
        setState(() {
          isEmailLocked = true;
        });
        EmailDialog(context, onEmailAuthSuccess);
      } else {
        print("실패: ${response.statusCode}");
      }
    } catch (e) {
      Navigator.pop(context); // 로딩 화면 닫기
      print("API 요청 오류: $e");
      showDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text("네트워크 오류"),
          content: Text("네트워크 혹은 이메일을 다시 확인해주세요."),
          actions: [
            CupertinoDialogAction(
              child: Text('확인'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    }
  }

  //이메일 인증코드 및 이메일 인증 완료

  void searchAddress(BuildContext context) async {
    KopoModel? model = await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => RemediKopo(),
      ),
    );

    if (model != null) {
      final postcode = model.zonecode ?? '';
      postcodeController.value = TextEditingValue(
        text: postcode,
      );
      formData['postcode'] = postcode;

      final address = model.address ?? '';
      addressController.value = TextEditingValue(
        text: address,
      );
      formData['address'] = address;

      final buildingName = model.buildingName ?? '';
      detailAddressController.value = TextEditingValue(
        text: buildingName,
      );
      formData['address_detail'] = buildingName;
    }
  }

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
                        hint: '이메일',
                        controller: emailController,
                        islocked: isEmailLocked, // 컨트롤러 연결
                      ),
                    ),
                    Flexible(
                      child: EmailAuthElevatedButton(
                        onPressed: isEmailLocked ? () {} : onEmailAuthLocked,
                        // 인증 완료되면 버튼 비활성화
                        buttonText: isEmailLocked ? '인증 완료' : '이메일 인증',
                      ),
                    ),
                  ],
                ),
                RoundedPasswordInput(
                  hint: '비밀번호',
                  controller: passwordController, // 컨트롤러 연결
                ),
                SizedBox(height: 10),
                RoundedNameInput(
                  hint: '이름',
                  controller: nameController, // 컨트롤러 연결
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      flex: 3, // 전체 공간에서 3/4 크기 할당
                      child: RoundedNumberInput(
                        hint: '전화번호 (- 제외하고 입력)',
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
                        hint: '별명',
                        controller: nickNameController,
                        islokced: isNickNameLocked,
                      ),
                    ),
                    Expanded(
                      flex: 1, // 전체 공간에서 1/4 크기 할당
                      child: NickNameCheckButton(
                        onPressed:
                            isNickNameLocked ? () {} : onNickNameAuthLocked,
                        buttonText: isNickNameLocked ? '인증 완료' : '중복 확인',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 3, // 전체 공간에서 3/4 크기 할당
                      child: PostcodeInput(
                        hint: '우편번호',
                        controller: postcodeController, // 컨트롤러 연결
                      ),
                    ),
                    Expanded(
                      flex: 1, // 전체 공간에서 1/4 크기 할당
                      child: AddressSearchButton(
                        onPressed: () => searchAddress(context),
                        buttonText: '주소검색',
                      ),
                    ),
                  ],
                ),
                RoundedAddressInput(
                  hint: '기본주소',
                  controller: addressController, // 컨트롤러 연결
                ),
                RoundedAddressInput(
                  hint: '상세주소',
                  controller: detailAddressController, // 컨트롤러 연결
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
