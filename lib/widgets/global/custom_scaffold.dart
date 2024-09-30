import 'package:flutter/material.dart';
import 'package:notai/screens/document/document_list_screen.dart';

class CustomScaffold extends StatefulWidget {
  final Widget appBarTitle;
  final Widget body;

  const CustomScaffold({
    Key? key,
    required this.appBarTitle,
    required this.body,
  }) : super(key: key);

  @override
  State<CustomScaffold> createState() => _CustomScaffoldState();
}

class _CustomScaffoldState extends State<CustomScaffold> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: widget.appBarTitle),
        body: widget.body,
        bottomNavigationBar: Container(
            child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            if (_currentIndex == index) return;
            setState(() {
              _currentIndex = index;
            });
            switch (index) {
              case 0:
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DocumentListScreen()));
                break;
              // case 1:
              //   Navigator.pushReplacement(
              //       context, MaterialPageRoute(builder: (context) => Screen()));
              //   break;
              // case 2:
              //   Navigator.pushReplacement(
              //       context, MaterialPageRoute(builder: (context) => Screen()));
              //   break;
            }
          },
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.file_copy_rounded), label: '문서'),
            BottomNavigationBarItem(icon: Icon(Icons.chat), label: '커뮤니티'),
            BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: '즐겨찾기'),
          ],
          selectedItemColor: Colors.red,
        )));
  }
}
