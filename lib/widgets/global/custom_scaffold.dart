import 'package:flutter/material.dart';
import 'package:notai/screens/document/document_list_screen.dart';
import 'package:notai/screens/login/login_screen.dart';
import 'package:notai/utils/color/color.dart';

class CustomScaffold extends StatefulWidget {
  final Widget body;
  final Widget appBarTitle;

  const CustomScaffold({
    super.key,
    required this.body, // Scaffold appBarTitle (위젯)
    required this.appBarTitle, // Scaffold body
  });

  @override
  State<CustomScaffold> createState() => _CustomScaffoldState();
}

class My extends StatelessWidget {
  const My({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => LoginScreen()));
          },
          child: Text('to')),
    );
  }
}

class _CustomScaffoldState extends State<CustomScaffold> {
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
        appBar: AppBar(title: widget.appBarTitle),
        body: IndexedStack(
          index: _selectedIndex,
          children: _pages.map((page) {
            int index = _pages.indexOf(page);
            return Navigator(
              key: _navigatorKeyList[index],
              onGenerateRoute: (_) {
                return MaterialPageRoute(builder: (context) => page);
              },
            );
          }).toList(),
        ),
        bottomNavigationBar: Container(
            child: BottomNavigationBar(
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
        )));
  }
}
