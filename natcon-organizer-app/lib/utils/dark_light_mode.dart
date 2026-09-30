
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Colors.dart';

class ColorNotifier with ChangeNotifier {

  bool _isDark = false;
  set setIsDark(value) {
    _isDark = value;
    notifyListeners();
  }
  get background => _isDark ? BlackColor : WhiteColor;
  get textColor => _isDark ? WhiteColor : BlackColor;
  get containerColor => _isDark ? boxcolor : bgcolor;
  get containerColor2 => _isDark ? WhiteColor : appcolor;
  get buttonText => _isDark ? WhiteColor : appcolor;
  get button => _isDark ? BlackColor : appcolor.withOpacity(0.1);
  get border => _isDark ? Colors.white24 : Colors.grey.shade200;

}
