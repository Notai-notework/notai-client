import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:notai/screens/main_screen.dart';
import 'package:notai/utils/http/api_service.dart';
import 'package:notai/utils/jwt/jwt.dart';

import '../../screens/login/login_screen.dart';
import '../../utils/color/color.dart';

class GlobalAppbar extends StatefulWidget implements PreferredSizeWidget {
  final Widget? leading;
  final List<Widget>? actions;
  final Widget? title;

  const GlobalAppbar({super.key, this.leading, this.actions, this.title});

  @override
  State<GlobalAppbar> createState() => _GlobalAppbarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _GlobalAppbarState extends State<GlobalAppbar> {
  bool isLoggedIn = false;
  Map<String, dynamic> payload = {};

  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  Future<void> _checkUser() async {
    var storage = await FlutterSecureStorage();
    final check = await storage.read(key: "isLoggedIn");

    isLoggedIn = check == "true";

    if (isLoggedIn) {
      String? access = await storage.read(key: 'Authorization');
      payload = Jwt().decodeJWT(access!)!; // 데이터 업데이트
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: titleColor,
      // leading: widget.leading ??
      //     IconButton(
      //       icon: Icon(Icons.arrow_back),
      //       onPressed: () {
      //         // 기본 뒤로가기 버튼 동작
      //         Navigator.of(context).pop();
      //       },
      //     ),
      title: widget.title ??
          const Padding(
              padding: EdgeInsets.fromLTRB(200, 0, 0, 0),
              child: Center(
                  child: Text(
                'NOTAI',
                style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: Colors.white),
              ))),
      actions: widget.actions ??
          [
            if (isLoggedIn)
              Padding(
                  padding: EdgeInsets.all(10),
                  child: TextButton(
                      onPressed: () async {
                        if (isLoggedIn) {
                          final storage = await FlutterSecureStorage();
                          await storage.delete(key: "Authorization");
                          await storage.delete(key: "refresh");
                          await storage.write(
                              key: "isLoggedIn", value: "false");

                          final api = await ApiService();
                          api.init();

                          setState(() {
                            isLoggedIn = false;
                          });

                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MainScreen()));
                        }
                      },
                      child: Text('로그아웃',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600)))),
            Padding(
                padding: EdgeInsets.all(10),
                child: TextButton(
                    onPressed: () {
                      if (!isLoggedIn)
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()));
                    },
                    child: Text(isLoggedIn ? "${payload['name']} 님" : '로그인',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600)))),
          ],
    );
  }
}
