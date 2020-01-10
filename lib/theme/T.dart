import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class T {
  // Colors
  // Color scheme -> https://mycolor.space/?hex=%231AD592&sub=1
  static final Color COLOR_PRIMARY = Color(0xFF196378);
  static final Color COLOR_SECONDARY = Color(0xff007F90);
  static final Color COLOR_BLACK = Color(0xFF282828);

  // Others
  static final BoxDecoration TEXTFIELD_DECORATION = BoxDecoration(borderRadius: BorderRadius.circular(4), color: Colors.white, border: Border.all(color: COLOR_SECONDARY));
  static final BoxDecoration CART_DECORATION = BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.white, border: Border.all(color: COLOR_SECONDARY));
}
