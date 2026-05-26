import 'package:flutter/material.dart';

class AppColors {
  static const Color red = Color(0xFFE53722); // Approx. red in logo
  static const Color blue = Color(0xFF0054A6); // Approx. blue in logo
  static const Color gray = Color(0xFF7F7F7F); // Light gray like "IMPIANTI"
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color transparent = Colors.transparent;

  static Color lightPrimary(BuildContext context) => red;
  static Color darkPrimary(BuildContext context) => red;

  static Color lightSecondary(BuildContext context) => blue;
  static Color darkSecondary(BuildContext context) => blue;

  static Color unavailableColor = Colors.grey;
  static Color unconfirmedColor = Colors.yellow;

  static Color background(BuildContext context) => white;

  static Color cardTitle(BuildContext context) => red;

  static Color icon(BuildContext context) => blue;

  static Color dialog(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? black : white;

  static Color container(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? Colors.grey[700]!
      : Colors.grey[300]!;

  static Color text(BuildContext context) {
    // print(Theme.of(context).brightness);
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black87;
  }

  static Color textHint(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? Colors.white54
      : Colors.black54;

  static Color gradient(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? black : white;

  static Color error(BuildContext context) => Colors.red;

  static Color accent(BuildContext context) => red;

  static IconData themeIcon(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? Icons.dark_mode
      : Icons.light_mode;
}

extension ColorOpacityExtension on Color {
  Color opaque(double opacity) {
    assert(opacity >= 0 && opacity <= 1, 'Opacity must be between 0 and 1');
    return withAlpha((opacity * 255).toInt());
  }
}
