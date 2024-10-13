import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../screens/login/login_screen.dart';
import '../../utils/color/color.dart';

class GlobalAppbar extends StatefulWidget implements PreferredSizeWidget {
  final Widget? leading;

  const GlobalAppbar({super.key, this.leading});

  @override
  State<GlobalAppbar> createState() => _GlobalAppbarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _GlobalAppbarState extends State<GlobalAppbar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: titleColor,
      leading: widget.leading ??
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              // 기본 뒤로가기 버튼 동작
              Navigator.of(context).pop();
            },
          ),
      title: const Text(
        'NOTAI',
        style: TextStyle(
            fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white),
      ),
      actions: [
        Padding(
            padding: EdgeInsets.all(10),
            child: TextButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => LoginScreen()));
                },
                child: const Text('로그인',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600))))
      ],
    );
  }
}
