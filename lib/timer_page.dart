import 'dart:async';
import 'package:flutter/material.dart';
import 'models.dart';
import 'main.dart' show store;

/// Süre bazlı alışkanlıklar için sayaç. Bitince süreyi kaydeder.
class TimerPage extends StatefulWidget {
  final Habit h;
  const TimerPage(this.h, {super.key});
  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  Timer? _t;
  int sec = 0;
  bool get running => _t != null;

  void toggle() => setState(() {
        if (running) { _t!.cancel(); _t = null; }
        else { _t = Timer.periodic(const Duration(seconds: 1), (_) => setState(() => sec++)); }
      });

  void finish() {
    _t?.cancel();
    final min = (sec / 60).round();
    if (min > 0) store.mark(widget.h, min >= widget.h.goal ? 2 : 1, min);
    Navigator.pop(context);
  }

  @override
  void dispose() { _t?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final goalSec = widget.h.goal * 60;
    final miniSec = widget.h.mini * 60;
    final mm = (sec ~/ 60).toString().padLeft(2, '0'), ss = (sec % 60).toString().padLeft(2, '0');
    final label = sec >= goalSec ? 'Hedef tamam!' : sec >= miniSec ? 'Minimum geçti, devam' : 'Minimuma ${((miniSec - sec) / 60).ceil()} dk';
    return Scaffold(
      appBar: AppBar(title: Text(widget.h.name)),
      body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(width: 220, height: 220, child: Stack(alignment: Alignment.center, children: [
          SizedBox.expand(child: CircularProgressIndicator(value: (sec / goalSec).clamp(0, 1).toDouble(), strokeWidth: 10)),
          Text('$mm:$ss', style: Theme.of(context).textTheme.displayMedium),
        ])),
        const SizedBox(height: 16),
        Text(label),
        const SizedBox(height: 24),
        Row(mainAxisSize: MainAxisSize.min, children: [
          FilledButton.icon(onPressed: toggle, icon: Icon(running ? Icons.pause : Icons.play_arrow),
              label: Text(running ? 'Duraklat' : 'Başlat')),
          const SizedBox(width: 12),
          OutlinedButton(onPressed: sec >= 60 ? finish : null, child: const Text('Bitir ve kaydet')),
        ]),
      ])),
    );
  }
}
