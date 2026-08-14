import 'package:flutter/widgets.dart';

class AppColors {
  AppColors._();

  static const Color primaryColor = Color.fromARGB(255, 33, 128, 230);
  static const Color secondaryColor = Color(0xFF0078B5);
  static const Color onBoardingSurface = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF7F8FA);
  static const Color greyDeemed = Color(0xFFEDEDED);
  static const Color border = Color(0xFFEDEDED);
  static const Color text = Color(0xFF202020);
  static const Color secondaryText = Color.fromRGBO(74, 74, 74, 1);
  static const Color blackDeemed = Color(0xFFEDEDED);
  static const Color info = Color(0xFF0078B5);
  static const Color greenish = Color(0xFFDFFFE3);
  static const Color green = Color(0xFF2E8B57);
  static const Color red = Color(0xFFC62828);
  static const Color warning = Color.fromRGBO(234, 154, 0, 1);
  static const LinearGradient redGradient = LinearGradient(
    colors: [Color(0xFFF9EAEA), Color(0xFFC62828)],
  );
}
