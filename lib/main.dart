import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notai/utils/color/color.dart';
import 'screens/login/login_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NTAOIo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primaryColor: kPrimaryColor,
          textTheme: GoogleFonts.robotoTextTheme(Theme.of(context).textTheme)),
      home: LoginScreen(),
    );
  }
}
