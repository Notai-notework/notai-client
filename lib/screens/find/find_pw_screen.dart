import 'package:flutter/material.dart';

class FindPwScreen extends StatefulWidget {
  const FindPwScreen({super.key});

  @override
  State<FindPwScreen> createState() => _FindPwScreenState();
}

class _FindPwScreenState extends State<FindPwScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("sss"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // 뒤로 가기
          },
        ),
      ),
      body: Center(
        child: Text("dd"),
      ),
    );
  }
}
