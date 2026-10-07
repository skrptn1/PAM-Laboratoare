import 'package:flutter/material.dart';

class AppColors {
  static const dark = Color(0xFF333333);
  static const text = Color(0xFF333333);
  static const grey = Color(0xFF8D8D98);
  static const lightGrey = Color(0xFFF8F8FA);
  static const divider = Color(0xFFEDEDED);
  static const green = Color(0xFF508A7B);
  static const red = Color(0xFFEB5757);
  static const peach = Color(0xFFFFFCFA);
}

ThemeData buildTheme() {
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.dark,
      primary: AppColors.dark,
      surface: Colors.white,
    ),
    textTheme: const TextTheme(bodyMedium: TextStyle(color: AppColors.text)),
    splashFactory: NoSplash.splashFactory,
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    hoverColor: Colors.transparent,
    focusColor: Colors.transparent,
  );
}
