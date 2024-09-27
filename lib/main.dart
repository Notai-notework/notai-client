import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login/login.dart';
import '../../etc/color.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NTAOIog',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primaryColor: kPrimaryColor,
          textTheme: GoogleFonts.robotoTextTheme(Theme.of(context).textTheme)
      ),
      home: LoginScreen(),
    );
  }
}

