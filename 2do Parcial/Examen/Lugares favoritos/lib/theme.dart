import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        cardTheme: const CardThemeData(
          elevation: 2,
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),
      );

  static ThemeData dark() => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        cardTheme: const CardThemeData(
          elevation: 2,
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),
      );
}

class CategoryHelper {
  static const Map<String, IconData> icons = {
    'casa': Icons.home,
    'gym': Icons.fitness_center,
    'cafe': Icons.local_cafe,
    'universidad': Icons.school,
    'mirador': Icons.landscape,
    'cancha': Icons.sports_soccer,
    'comida': Icons.restaurant,
    'estudio': Icons.menu_book,
    'diversion': Icons.celebration,
    'otros': Icons.place,
  };

  static IconData iconFor(String cat) => icons[cat] ?? Icons.place;

  static const List<String> all = [
    'casa', 'gym', 'cafe', 'universidad', 'mirador',
    'cancha', 'comida', 'estudio', 'diversion', 'otros',
  ];
}