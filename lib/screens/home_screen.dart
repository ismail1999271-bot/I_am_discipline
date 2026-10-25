import 'package:flutter/material.dart';
import 'package:i_am_disiplin/models/app_models.dart';
import 'package:i_am_disiplin/services/store.dart';
import 'package:i_am_disiplin/services/xp_engine.dart';
import 'package:i_am_disiplin/widgets/common.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppStore.I,
      builder: (context, _) {
        final store = AppStore.I;
        final view = store.result;
        final peak = store.peakRank.clamp(0, ranks.length - 1);
        final rank = ranks[peak];
        final xp = view.xp;
        final floorXp = rank.xp;
        final nextXp = peak + 1 < ranks.length ? ranks[peak + 1].xp : rank.xp;
        final span = nextXp - floorXp;
        final progress = span <= 0 ? 1.0 : ((xp - floorXp) / span).clamp(0.0, 1.0);
        final kalan = nextXp > xp ? nextXp - xp : 0;
        final today = store.habitsOn(DateTime.now());
        final dropped = rankIndexFor(xp) < peak;
        return Scaffold(
          appBar: AppBar(title: const Text('ANA')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Text(
                rank.name.toUpperCase(),
                style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900, letterSpacing: 1.2),
              ),
              const SizedBox(height: 6),
              Text(
                'XP $xp   ·   seri ${view.streak} gün   ·   ${multLabel(view.streak)}',
                style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 14),
              SharpProgress(value: progress),
              const SizedBox(height: 8),
              Text(
                peak + 1 >= ranks.length ? 'Son rütbe. Durmak yasak.' : 'Sonraki rütbe için kalan XP: $kalan',
                style: TextStyle(color: gold(context), fontWeight: FontWeight.w800),
              ),
              if (dropped)
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text('XP düştü. Rütbe korunur.', style: TextStyle(color: Colors.white54)),
                ),
              const SizedBox(height: 18),
              const SectionTitle('BUGÜN'),
              const SizedBox(height: 10),
              if (today.isEmpty)
                const Text('Bugün planlı alışkanlık yok.', style: TextStyle(color: Colors.white54))
              else
                ...today.map((h) => _Row(habit: h)),
              if (view.todayTotal > 0 && view.todayDone == view.todayTotal)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text('GÜN TAMAM. +50 işlendi.', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _Row extends StatelessWidget {
  final Habit habit;
  const _Row({required this.habit});

  @override
  Widget build(BuildContext context) {
    final on = AppStore.I.isChecked(habit.id);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => AppStore.I.toggleHabit(habit.id),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(border: Border.all(color: const Color(0xFF2A2A2A))),
          child: Row(
            children: [
              Icon(iconOf(habit.icon), color: gold(context)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  habit.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    decoration: on ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              if (habit.hard)
                Text('ZOR', style: TextStyle(color: accent(context), fontWeight: FontWeight.w900, fontSize: 12)),
              const SizedBox(width: 8),
              Icon(on ? Icons.check_box : Icons.check_box_outline_blank, color: gold(context)),
            ],
          ),
        ),
      ),
    );
  }
}
