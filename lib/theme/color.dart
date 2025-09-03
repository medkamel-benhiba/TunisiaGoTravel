import 'package:flutter/material.dart';

class AppColorstatic {
  static ThemeData themeData = ThemeData(
      useMaterial3: true,
      brightness:
          AppColorstatic.isDarkMode ? Brightness.dark : Brightness.light);
  static bool isDarkMode = false;
  static const primary = Color(0xFF2C5BA1);
  static const secondary = Color(0xFF15A5DF);
  static const primaryblue = Color(0xFF2C5BA1);
  static const mainColor = Color(0xFF000000);
  static const darker = Color(0xFF3E4249);
  static const appBgColor = Color(0xFFF7F7F7);
  static const primary85 = Color(0xD82C5BA1);
  static const buttonbg = Color(0xFF162C50);

  static const primary2 = Color(0xfffb9504);

  static const white80 = Color(0xE4F7F7F7);
  static const lightTextColor = Color(0xFFF7F7F7);
  static const bottomBarColor = Colors.white;
  static const inActiveColor = Colors.grey;
  static const shadowColor = Colors.black87;
  static const textBoxColor = Colors.white;
  static const textColor = Color(0xFF333333);
  static const labelColor = Color(0xFF8A8989);

  static const actionColor = Color(0xFFe54140);
  static const buttonColor = Color(0xFFcdacf9);
  static const cardColor = Colors.white;

  static const yellow = Color(0xFFffcb66);
  static const green = Color(0xFFa2e1a6);
  static const pink = Color(0xFFf5bde8);
  static const purple = Color(0xFFcdacf9);
  static const red = Color(0xFFf77080);
  static const orange = Color(0xFFf5ba92);
  static const sky = Color(0xFFABDEE6);
  static const blue = Color(0xFF509BE4);
  static const cyan = Color(0xFF4ac2dc);
  static const darkerGreen = Color(0xFFb0d96d);
  static const darkerYellow = Color(0xffd5b70d);


  static const listColors = [
    green,
    purple,
    yellow,
    orange,
    sky,
    secondary,
    red,
    blue,
    pink,
    yellow,
  ];
}
