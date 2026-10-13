import 'dart:convert';
import 'package:http/http.dart' as http;

/// Yerel Ollama koçu. Android emülatöründe host = 10.0.2.2, gerçek cihazda bilgisayarın IP'si.
class Coach {
  Future<String> advise(String summary, {required String host, required String model}) async {
    final prompt = '''Sen kısa ve net konuşan bir alışkanlık koçusun. Türkçe yaz.
Veride T=tam hedef, M=minimum, 0=kaçırılan gün, -=planlı olmayan gün (soldan sağa eskiden yeniye).
En fazla 3 madde ver: bir desen tespiti, bir somut ayarlama önerisi, bir kimlik cümlesi.
Veri:
$summary''';
    try {
      final r = await http.post(Uri.parse('$host/api/generate'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'model': model, 'prompt': prompt, 'stream': false}))
          .timeout(const Duration(seconds: 90));
      if (r.statusCode != 200) return 'Koç yanıt vermedi (${r.statusCode}).';
      return (jsonDecode(utf8.decode(r.bodyBytes))['response'] as String).trim();
    } catch (e) {
      return 'Ollama\'ya ulaşılamadı. "ollama serve" çalışıyor mu? ($e)';
    }
  }
}
