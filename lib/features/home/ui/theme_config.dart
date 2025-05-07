// lib/features/home/ui/theme_config.dart

import 'package:flutter/material.dart';

/// Configuration for different game themes
class ThemeConfig {
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final Color titleColor;
  final Color buttonColor;
  final Color secondaryButtonColor;
  final Color tertiaryButtonColor;
  final Color buttonTextColor;
  final Color levelSelectionColor;
  final List<Color> tubeColors;
  final bool useGlassEffect; // For glass-like tube effect

  ThemeConfig({
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.titleColor,
    required this.buttonColor,
    required this.secondaryButtonColor,
    required this.tertiaryButtonColor,
    required this.buttonTextColor,
    required this.levelSelectionColor,
    required this.tubeColors,
    this.useGlassEffect = false,
  });

  /// Get the theme configuration based on the theme index
  static ThemeConfig getTheme(int themeIndex) {
    switch (themeIndex) {
      case 1: // Ocean theme
        return ThemeConfig(
          primaryColor: Colors.blue[700]!,
          secondaryColor: Colors.lightBlue[300]!,
          backgroundColor: Colors.blueGrey[50]!,
          titleColor: Colors.white,
          buttonColor: Colors.blue[600]!,
          secondaryButtonColor: Colors.blue[400]!,
          tertiaryButtonColor: Colors.blueGrey[600]!,
          buttonTextColor: Colors.white,
          levelSelectionColor: Colors.blue[500]!,
          tubeColors: [
            Colors.blue[300]!,
            Colors.blue[400]!,
            Colors.lightBlue[200]!,
            Colors.lightBlue[400]!,
            Colors.cyan[300]!,
            Colors.cyan[400]!,
            Colors.teal[300]!,
            Colors.teal[400]!,
          ],
          useGlassEffect: true,
        );

      case 2: // Neon theme
        return ThemeConfig(
          primaryColor: Colors.purple[900]!,
          secondaryColor: Colors.pink[400]!,
          backgroundColor: Colors.black87,
          titleColor: Colors.pink[300]!,
          buttonColor: Colors.purple[500]!,
          secondaryButtonColor: Colors.pink[500]!,
          tertiaryButtonColor: Colors.deepPurple[500]!,
          buttonTextColor: Colors.white,
          levelSelectionColor: Colors.deepPurple[500]!,
          tubeColors: [
            Colors.pink[300]!,
            Colors.purple[300]!,
            Colors.deepPurple[300]!,
            Colors.indigo[300]!,
            Colors.blue[300]!,
            Colors.cyan[300]!,
            Colors.teal[300]!,
            Colors.green[300]!,
          ],
          useGlassEffect: true,
        );

      case 3: // Pastel theme
        return ThemeConfig(
          primaryColor: Colors.pink[100]!,
          secondaryColor: Colors.purple[100]!,
          backgroundColor: Colors.grey[100]!,
          titleColor: Colors.pink[400]!,
          buttonColor: Colors.pink[300]!,
          secondaryButtonColor: Colors.purple[200]!,
          tertiaryButtonColor: Colors.blue[200]!,
          buttonTextColor: Colors.white,
          levelSelectionColor: Colors.pink[200]!,
          tubeColors: [
            Colors.pink[100]!,
            Colors.purple[100]!,
            Colors.indigo[100]!,
            Colors.blue[100]!,
            Colors.cyan[100]!,
            Colors.teal[100]!,
            Colors.green[100]!,
            Colors.amber[100]!,
          ],
          useGlassEffect: false,
        );

      default: // Classic theme
        return ThemeConfig(
          primaryColor: Colors.blue[700]!,
          secondaryColor: Colors.orange[500]!,
          backgroundColor: Colors.grey[100]!,
          titleColor: Colors.white,
          buttonColor: Colors.green[600]!,
          secondaryButtonColor: Colors.orange[600]!,
          tertiaryButtonColor: Colors.blue[600]!,
          buttonTextColor: Colors.white,
          levelSelectionColor: Colors.blue[600]!,
          tubeColors: [
            Colors.red,
            Colors.blue,
            Colors.green,
            Colors.yellow,
            Colors.purple,
            Colors.orange,
            Colors.pink,
            Colors.teal,
          ],
          useGlassEffect: false,
        );
    }
  }
}
