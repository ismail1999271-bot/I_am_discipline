import 'package:flutter/material.dart';
import 'package:i_am_disiplin/models/app_models.dart';
import 'package:i_am_disiplin/services/store.dart';
import 'package:i_am_disiplin/widgets/common.dart';
import 'package:i_am_disiplin/widgets/premium_gate.dart';

class DietScreen extends StatelessWidget {
  const DietScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PremiumGate(
      title: 'DİYETİSYEN',
      child: AnimatedBuilder(
        animation: AppStore.I,
        builder: (context, _) {
          final d = AppStore.I.diet;
          final meals = <(String, double)>[
            ('Kahvaltı', 0.25),
            ('Öğle', 0.35),
            ('Akşam', 0.30),
            ('Ara öğün', 0.10),
          ];
          return Scaffold(
            appBar: AppBar(title: const Text('DİYETİSYEN')),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SectionTitle('GÜNLÜK HEDEF'),
                const SizedBox(height: 8),
                Text('${d.kcal.toStringAsFixed(0)} kcal', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
                Text('P ${d.protein.toStringAsFixed(0)}   C ${d.carb.toStringAsFixed(0)}   F ${d.fat.toStringAsFixed(0)}'),
                const SizedBox(height: 12),
                GoldButton(label: 'HEDEFİ DEĞİŞTİR', onTap: () => _edit(context, d)),
                const SizedBox(height: 22),
                const SectionTitle('ÖĞÜN PLANI'),
                const SizedBox(height: 10),
                for (final meal in meals)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: SharpCard(
                      child: Row(
                        children: [
                          Expanded(child: Text(meal.$1, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18))),
                          Text('${(d.kcal * meal.$2).toStringAsFixed(0)} kcal',
                              style: TextStyle(color: gold(context), fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ),
                  ),
                const Text(
                  'Kalori hedefinin %25 kahvaltı, %35 öğle, %30 akşam, %10 ara öğün.',
                  style: TextStyle(color: Colors.white54),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _edit(BuildContext context, DietTargets d) async {
    final kcal = await askText(context, title: 'KALORİ HEDEFİ', initial: d.kcal.toStringAsFixed(0));
    if (kcal == null || !context.mounted) return;
    final p = await askText(context, title: 'PROTEİN g', initial: d.protein.toStringAsFixed(0));
    if (p == null || !context.mounted) return;
    final c = await askText(context, title: 'KARBONHİDRAT g', initial: d.carb.toStringAsFixed(0));
    if (c == null || !context.mounted) return;
    final f = await askText(context, title: 'YAĞ g', initial: d.fat.toStringAsFixed(0));
    if (f == null) return;
    double n(String s, double fallback) => double.tryParse(s.replaceAll(',', '.')) ?? fallback;
    await AppStore.I.setDiet(DietTargets(
      kcal: n(kcal, d.kcal),
      protein: n(p, d.protein),
      carb: n(c, d.carb),
      fat: n(f, d.fat),
    ));
  }
}
