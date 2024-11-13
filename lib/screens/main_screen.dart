import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:notai/screens/community/community_screen.dart';
import 'package:notai/screens/document/document_list_screen.dart';
import 'package:notai/screens/login/login_screen.dart';
import 'package:notai/utils/auth/auth_management.dart';
import 'package:notai/utils/color/color.dart';
import 'package:notai/widgets/global/global_appbar.dart';
import 'package:path_provider/path_provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreen();
}

class _MainScreen extends State<MainScreen> {
  int _selectedIndex = 0;
  bool isLoggedIn = false;

  // 바텀 네비게이션 탭에 대한 페이지 리스트
  static final List<Widget> _pages = <Widget>[
    const DocumentListScreen(),
    const CommunityScreen(),
    const Center(child: Text('bookmark')),
  ];

  late List<GlobalKey<NavigatorState>> _navigatorKeyList;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _navigatorKeyList =
        List.generate(_pages.length, (index) => GlobalKey<NavigatorState>());
    // logout();
    // initDocument();
    checkLoggedIn();
  }

  // 도큐먼트 초기화용
  Future<void> initDocument() async {
    Directory directory = await getApplicationDocumentsDirectory();
    var files = directory.listSync();
    try {
      for (var file in files) {
        await file.delete(recursive: true);
      }
    } catch (e) {}
  }

  // 강제 로그아웃용
  Future<void> logout() async {
    final a = await FlutterSecureStorage();
    await a.delete(key: "Authorization");
    a.write(key: "isLoggedIn", value: "false");
  }

  // 로그인 체크
  Future<void> checkLoggedIn() async {
    isLoggedIn = await AuthManagement().isLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: GlobalAppbar(leading: Container()),
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            if (!isLoggedIn && index == 1) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => LoginScreen()));
              return;
            }

            setState(() {
              _selectedIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.file_copy_rounded), label: '문서'),
            BottomNavigationBarItem(icon: Icon(Icons.chat), label: '커뮤니티'),
            // BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: '즐겨찾기'),
          ],
          selectedItemColor: titleColor,
        ));
  }
}
