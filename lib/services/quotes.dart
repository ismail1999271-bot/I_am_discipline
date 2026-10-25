import 'dart:convert';

import 'package:flutter/services.dart';

class QuoteBook {
  static List<String> lines = const [
    'Bahane bitti.',
    'Kalk. Konuşma.',
    'Disiplin bir duygu değil, karardır.',
  ];

  static Future<void> load() async {
    try {
      final raw = await rootBundle.loadString('assets/sozler.json');
      final data = jsonDecode(raw);
      if (data is List && data.isNotEmpty) {
        lines = data.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList();
      }
    } on Object {
      return;
    }
  }

  static String today() {
    if (lines.isEmpty) return 'Söz bitti. Sıra sende.';
    final n = DateTime.now();
    final start = DateTime(n.year, 1, 1);
    final day = n.difference(start).inDays;
    return lines[day.abs() % lines.length];
  }
}
