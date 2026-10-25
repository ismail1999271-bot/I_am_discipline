import 'package:flutter/material.dart';

class Skin {
  final String id;
  final String name;
  final int minRank;
  final Color gold;
  final Color orange;
  final Color bg;

  const Skin(this.id, this.name, this.minRank, this.gold, this.orange, this.bg);
}

const skins = <Skin>[
  Skin('acemi', 'Acemi Siyah', 0, Color(0xFFE8A317), Color(0xFFFF6A00), Color(0xFF000000)),
  Skin('er', 'Er Altını', 1, Color(0xFFD4A017), Color(0xFFFF8500), Color(0xFF070600)),
  Skin('onbasi', 'Onbaşı Ateşi', 2, Color(0xFFE0A106), Color(0xFFFF6A00), Color(0xFF0A0700)),
  Skin('cavus', 'Çavuş Bakır', 3, Color(0xFFC9842A), Color(0xFFE85D04), Color(0xFF0C0804)),
  Skin('astsubay', 'Astsubay Bronz', 4, Color(0xFFB8860B), Color(0xFFFF7A00), Color(0xFF080604)),
  Skin('tegmen', 'Teğmen Işık', 5, Color(0xFFF0C14A), Color(0xFFFF6A00), Color(0xFF000000)),
  Skin('yuzbasi', 'Yüzbaşı Çelik', 6, Color(0xFFE6C35C), Color(0xFFFF8C32), Color(0xFF050505)),
  Skin('binbasi', 'Binbaşı Kor', 7, Color(0xFFE8A317), Color(0xFFFF4D00), Color(0xFF100800)),
  Skin('albay', 'Albay İmza', 8, Color(0xFFFFD56A), Color(0xFFE8A317), Color(0xFF000000)),
  Skin('komutan', 'Komutan', 9, Color(0xFFFFB000), Color(0xFFFF3300), Color(0xFF0A0000)),
  Skin('efsane', 'Efsane', 10, Color(0xFFFFF1C2), Color(0xFFE8A317), Color(0xFF000000)),
];

Skin skinById(String id) {
  for (final s in skins) {
    if (s.id == id) return s;
  }
  return skins.first;
}

ThemeData buildTheme(Skin skin) {
  const white = Colors.white;
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: skin.bg,
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    colorScheme: ColorScheme.dark(
      primary: skin.gold,
      secondary: skin.orange,
      surface: const Color(0xFF0A0A0A),
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: white,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: skin.bg,
      foregroundColor: skin.gold,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: skin.gold,
        fontSize: 22,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.4,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: skin.bg,
      indicatorColor: const Color(0x33E8A317),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final on = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
          color: on ? skin.gold : Colors.white38,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final on = states.contains(WidgetState.selected);
        return IconThemeData(color: on ? skin.gold : Colors.white38);
      }),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: Color(0xFF111111),
      contentTextStyle: TextStyle(color: white, fontWeight: FontWeight.w700),
      behavior: SnackBarBehavior.fixed,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF111111),
      labelStyle: TextStyle(color: skin.gold, fontWeight: FontWeight.w700),
      hintStyle: const TextStyle(color: Colors.white38),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: Color(0xFF333333)),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: Color(0xFF333333)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: skin.gold, width: 2),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w900,
        color: white,
        letterSpacing: 1,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: white,
      ),
      bodyMedium: TextStyle(color: white, fontSize: 15, height: 1.35),
    ),
    dividerColor: const Color(0xFF222222),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: skin.gold,
      linearTrackColor: const Color(0xFF222222),
    ),
  );
}
