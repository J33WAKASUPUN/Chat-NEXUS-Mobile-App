import 'package:flutter/material.dart';
class FontSizes {
  static const extraSmall = 14.0;
  static const small = 16.0;
  static const standard = 18.0;
  static const large = 20.0;
  static const extraLarge = 24.0;
  static const doubleExtraLarge = 26.0;
}

ThemeData lightMode = ThemeData(
  brightness: Brightness.dark,
  appBarTheme: const AppBarTheme(
    shadowColor: Color.fromARGB(255, 17, 17, 17),
  ),
  colorScheme: const ColorScheme.dark(
      background: Color.fromARGB(255, 17, 17, 17),
      primary: Color.fromARGB(255, 255, 69, 69),
      secondary: Color.fromARGB(255, 48, 48, 48),
      tertiary: Color.fromARGB(70, 51, 51, 51),
  ),
  textTheme: const TextTheme(
      titleLarge: TextStyle(color: Color(0xffEEEEEE),),
      titleSmall: TextStyle(
        color: Color(0xff000000),
      ),
      bodyMedium: TextStyle(
          color: Color(0xffEEEEEE),
          fontSize: FontSizes.small
      ),
      bodySmall: TextStyle(
          color: Color(0xff000000),
          fontSize: FontSizes.small
      )
  ),
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.light,
  appBarTheme: const AppBarTheme(
    shadowColor: Color.fromARGB(255, 17, 17, 17),
  ),
  colorScheme: const ColorScheme.light(
      background: Color(0xffffffff),
      primary: Color.fromARGB(255, 255, 69, 69),
      secondary: Color(0xffEEEEEE),
      tertiary: Color(0xffEEEEEE),
  ),
  inputDecorationTheme: const InputDecorationTheme(
      labelStyle: TextStyle(color: Colors.blue)
  ),
  textTheme: const TextTheme(
      titleLarge: TextStyle(color: Color.fromARGB(255, 1, 1, 1),),
      titleSmall: TextStyle(
        color: Color(0xff000000),
      ),
      bodyMedium: TextStyle(
          color: Color(0xffEEEEEE),
          fontSize: FontSizes.small
      ),
      bodySmall: TextStyle(
          color: Color(0xff000000),
          fontSize: FontSizes.small
      )
  ),
);
