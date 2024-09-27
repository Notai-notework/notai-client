import 'package:flutter/material.dart';

class CustomScaffold extends Scaffold {
  CustomScaffold({
    Key? key,
    required Widget body, // Scaffold body
    required Widget appBarTitle, // Scaffold appBarTitle (위젯)
  }) : super(
            key: key,
            appBar: AppBar(
              title: appBarTitle,
            ),
            body: body,
            bottomNavigationBar: Container(
                child: BottomNavigationBar(
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
                BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'What')
              ],
              selectedItemColor: Colors.red,
            )));
}
