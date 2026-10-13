import 'package:flutter/material.dart';

/// "Güç" teması: simsiyah zemin, ateş turuncusu vurgu, kalın büyük harf başlıklar.
class Iron {
  static const bg = Color(0xFF000000);
  static const surface = Color(0xFF111111);
  static const surface2 = Color(0xFF1C1C1C);
  static const line = Color(0xFF2A2A2A);
  static const fire = Color(0xFFFF5A1F); // ana vurgu
  static const ember = Color(0xFFFFB020); // minimum / ikincil
  static const steel = Color(0xFF9A9A9A); // ikincil metin
  static const blood = Color(0xFFE5302B); // hata
  static const white = Color(0xFFF5F5F5);
}

ThemeData ironTheme() {
  const cs = ColorScheme(
    brightness: Brightness.dark,
    primary: Iron.fire, onPrimary: Colors.black,
    primaryContainer: Color(0xFF3A1708), onPrimaryContainer: Iron.fire,
    secondary: Iron.ember, onSecondary: Colors.black,
    secondaryContainer: Color(0xFF2E2208), onSecondaryContainer: Iron.ember,
    tertiary: Iron.ember, onTertiary: Colors.black,
    tertiaryContainer: Color(0xFF2E2208), onTertiaryContainer: Iron.ember,
    error: Iron.blood, onError: Colors.white,
    errorContainer: Color(0xFF3A0C0B), onErrorContainer: Iron.blood,
    surface: Iron.bg, onSurface: Iron.white,
    surfaceContainerLowest: Iron.bg, surfaceContainerLow: Iron.surface,
    surfaceContainer: Iron.surface, surfaceContainerHigh: Iron.surface2,
    surfaceContainerHighest: Iron.line,
    onSurfaceVariant: Iron.steel, outline: Color(0xFF444444), outlineVariant: Iron.line,
  );
  final base = ThemeData(useMaterial3: true, colorScheme: cs, scaffoldBackgroundColor: Iron.bg);
  final t = base.textTheme;
  TextStyle? heavy(TextStyle? s, {double ls = .5}) =>
      s?.copyWith(fontWeight: FontWeight.w900, letterSpacing: ls, color: Iron.white);
  return base.copyWith(
    textTheme: t.copyWith(
      displaySmall: heavy(t.displaySmall, ls: -1),
      headlineMedium: heavy(t.headlineMedium, ls: -.5),
      headlineSmall: heavy(t.headlineSmall, ls: -.3),
      titleLarge: heavy(t.titleLarge),
      titleMedium: t.titleMedium?.copyWith(fontWeight: FontWeight.w800),
      labelLarge: t.labelLarge?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 1.2),
      labelMedium: t.labelMedium?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 1.5, color: Iron.fire),
      labelSmall: t.labelSmall?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.2, color: Iron.steel),
    ),
    cardTheme: const CardThemeData(
      color: Iron.surface, elevation: 0, margin: EdgeInsets.symmetric(vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6)),
          side: BorderSide(color: Iron.line)),
    ),
    filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(
      backgroundColor: Iron.fire, foregroundColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      textStyle: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2),
    )),
    outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(
      foregroundColor: Iron.white, side: const BorderSide(color: Color(0xFF444444)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      textStyle: const TextStyle(fontWeight: FontWeight.w800),
    )),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: Iron.surface, selectedColor: Iron.fire,
      side: const BorderSide(color: Iron.line),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      labelStyle: const TextStyle(fontWeight: FontWeight.w700),
      secondaryLabelStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900),
      checkmarkColor: Colors.black,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Iron.surface, indicatorColor: Iron.fire,
      iconTheme: WidgetStateProperty.resolveWith((s) =>
          IconThemeData(color: s.contains(WidgetState.selected) ? Colors.black : Iron.steel)),
      labelTextStyle: WidgetStateProperty.resolveWith((s) => TextStyle(
          fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: .8,
          color: s.contains(WidgetState.selected) ? Iron.fire : Iron.steel)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(backgroundColor: Iron.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(10)))),
    dialogTheme: const DialogThemeData(backgroundColor: Iron.surface),
    inputDecorationTheme: const InputDecorationTheme(
      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF444444))),
      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Iron.fire, width: 2)),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: Iron.fire, linearTrackColor: Iron.line),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Iron.fire, foregroundColor: Colors.black, shape: RoundedRectangleBorder()),
    dividerColor: Iron.line,
  );
}
