import 'package:flutter/material.dart';
import 'package:notai/screens/document/document_list_screen.dart';
import 'package:notai/screens/login/login_screen.dart';
import 'package:notai/utils/color/color.dart';
import 'package:notai/widgets/global/global_appbar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreen();
}

class _MainScreen extends State<MainScreen> {
  int _selectedIndex = 0;

  // 바텀 네비게이션 탭에 대한 페이지 리스트
  static final List<Widget> _pages = <Widget>[
    const DocumentListScreen(),
    const Center(child: Text('community')),
    const Center(child: Text('bookmark')),
  ];

  late List<GlobalKey<NavigatorState>> _navigatorKeyList;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _navigatorKeyList =
        List.generate(_pages.length, (index) => GlobalKey<NavigatorState>());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const GlobalAppbar(),
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.file_copy_rounded), label: '문서'),
            BottomNavigationBarItem(icon: Icon(Icons.chat), label: '커뮤니티'),
            BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: '즐겨찾기'),
          ],
          selectedItemColor: titleColor,
        ));
  }
}
