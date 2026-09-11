import 'package:flutter/material.dart';

class NutriTheme {
  static const green = Color(0xFF176B45);
  static const greenDark = Color(0xFF0E4D32);
  static const mint = Color(0xFFE8F5EE);
  static const cream = Color(0xFFF7FAF8);

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(seedColor: green, brightness: Brightness.light);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme.copyWith(primary: green, onPrimary: Colors.white, surface: cream),
      scaffoldBackgroundColor: cream,
      fontFamily: 'sans',
      appBarTheme: const AppBarTheme(backgroundColor: cream, elevation: 0, centerTitle: false),
      cardTheme: CardThemeData(elevation: 0, margin: EdgeInsets.zero, color: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22))),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: scheme.outlineVariant)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: green, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
      filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(54), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), textStyle: const TextStyle(fontWeight: FontWeight.w700))),
      outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)))),
      chipTheme: ChipThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), side: BorderSide(color: scheme.outlineVariant), backgroundColor: Colors.white),
    );
  }
}

class NutrIABadge extends StatelessWidget {
  final String text;
  final IconData icon;
  const NutrIABadge({super.key, required this.text, this.icon = Icons.auto_awesome});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(color: NutriTheme.mint, borderRadius: BorderRadius.circular(30)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 16, color: NutriTheme.green), const SizedBox(width: 7), Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: NutriTheme.green))]),
  );
}

class NutrIACard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const NutrIACard({super.key, required this.child, this.padding = const EdgeInsets.all(20)});
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: padding, child: child));
}
