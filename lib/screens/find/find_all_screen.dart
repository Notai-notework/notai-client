import 'package:flutter/material.dart';

class FindAllScreen extends StatefulWidget {
  const FindAllScreen({super.key});

  @override
  State<FindAllScreen> createState() => _FindAllScreenState();
}

class _FindAllScreenState extends State<FindAllScreen> {
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
