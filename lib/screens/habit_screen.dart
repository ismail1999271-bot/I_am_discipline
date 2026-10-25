import 'package:flutter/material.dart';
import 'package:i_am_disiplin/data/catalog.dart';
import 'package:i_am_disiplin/models/app_models.dart';
import 'package:i_am_disiplin/screens/habit_form_screen.dart';
import 'package:i_am_disiplin/services/store.dart';
import 'package:i_am_disiplin/services/xp_engine.dart';
import 'package:i_am_disiplin/widgets/common.dart';

class HabitScreen extends StatelessWidget {
  const HabitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppStore.I,
      builder: (context, _) {
        final store = AppStore.I;
        final today = DateTime.now();
        return Scaffold(
          appBar: AppBar(
            title: const Text('ALIŞKANLIK'),
            actions: [
              IconButton(
                onPressed: () => _packs(context),
                icon: const Icon(Icons.inventory_2_outlined),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: gold(context),
            foregroundColor: Colors.black,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const HabitFormScreen()),
            ),
            child: const Icon(Icons.add),
          ),
          body: store.habits.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Liste boş. Paket seç veya kendin ekle.', textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        GoldButton(label: 'HAZIR PAKET', onTap: () => _packs(context)),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  itemCount: store.habits.length,
                  itemBuilder: (context, i) {
                    final h = store.habits[i];
                    final onDay = scheduledOn(h, today);
                    final checked = store.isChecked(h.id, today);
                    final streak = habitStreak(h, store.checks, today);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(builder: (_) => HabitFormScreen(existing: h)),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(border: Border.all(color: const Color(0xFF2A2A2A))),
                          child: Row(
                            children: [
                              Icon(iconOf(h.icon), color: gold(context)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(h.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                                    Text(
                                      'seri $streak${h.reminder == null ? '' : '  ·  ${h.reminder}'}',
                                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              if (h.hard)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Text('ZOR', style: TextStyle(color: accent(context), fontWeight: FontWeight.w900, fontSize: 12)),
                                ),
                              if (!onDay)
                                const Text('bugün yok', style: TextStyle(color: Colors.white38, fontSize: 12))
                              else
                                IconButton(
                                  onPressed: () => store.toggleHabit(h.id),
                                  icon: Icon(
                                    checked ? Icons.check_box : Icons.check_box_outline_blank,
                                    color: gold(context),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  void _packs(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF0A0A0A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (ctx) {
        final list = packList();
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SectionTitle('PAKETLER'),
            const SizedBox(height: 12),
            for (final p in list) ...[
              SharpCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text(p.detail, style: const TextStyle(color: Colors.white70)),
                    const SizedBox(height: 6),
                    Text(p.habits.map((h) => h.name).join(' · '), style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    const SizedBox(height: 12),
                    GoldButton(
                      label: 'EKLE',
                      onTap: () async {
                        await AppStore.I.addPackHabits(p.habits);
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ],
        );
      },
    );
  }
}
