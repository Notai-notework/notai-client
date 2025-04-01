// import 'package:flutter/material.dart';
// import '../../../screens/find/find_all_screen.dart';
// import '../../../utils/color/color.dart';
//
// class FindElevatedButton extends StatelessWidget {
//   final VoidCallback onPressed;
//   final String buttonText;
//
//   const FindElevatedButton({
//     super.key,
//     required this.onPressed,
//     required this.buttonText,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(
//       onPressed: (){
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => FindAllScreen()),
//         );      },
//       style: ElevatedButton.styleFrom(
//           backgroundColor: threeColor,
//           fixedSize: const Size(200, 30),
//           elevation: 5.0
//       ),
//       child: Text(buttonText),
//     );
//   }
// }
//
import 'package:flutter/cupertino.dart';
import '../../../screens/find/find_all_screen.dart';
import '../../../utils/color/color.dart';

class FindElevatedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String buttonText;

  const FindElevatedButton({
    super.key,
    required this.onPressed,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: (){
        Navigator.push(
          context,
          CupertinoPageRoute(builder: (context) => FindAllScreen()),
        );
      },
      color: threeColor,  // 버튼 색상
      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),  // 버튼 크기 조정
      borderRadius: BorderRadius.circular(10),  // 모서리 둥글게
      child: Text(
        buttonText,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
      pressedOpacity: 0.6,
    );
  }
}
