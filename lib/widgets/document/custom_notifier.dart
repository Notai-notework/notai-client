import 'package:flutter/cupertino.dart';
import 'package:scribble/scribble.dart';

class CustomNotifier extends ScribbleNotifier {
  CustomNotifier(List<double> widths, ScribblePointerMode mode)
      : super(widths: widths, allowedPointersMode: mode);

  // 고유한 GlobalKey를 생성
  // final GlobalKey _uniqueRepaintBoundaryKey = UniqueKey();

  // @override
  // GlobalKey get repaintBoundaryKey => _uniqueRepaintBoundaryKey;

  void setWidths(List<double> widths) {
    this.widths[0] = widths[0];
    this.widths[1] = widths[1];
    this.widths[2] = widths[2];
  }
}
