import 'package:flutter/material.dart';
import 'package:i_am_disiplin/data/foods.dart';
import 'package:i_am_disiplin/models/app_models.dart';
import 'package:i_am_disiplin/services/store.dart';
import 'package:i_am_disiplin/services/xp_engine.dart';
import 'package:i_am_disiplin/widgets/common.dart';
import 'package:i_am_disiplin/widgets/premium_gate.dart';

class CalorieScreen extends StatefulWidget {
  const CalorieScreen({super.key});

  @override
  State<CalorieScreen> createState() => _CalorieScreenState();
}

class _CalorieScreenState extends State<CalorieScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final shown = q.isEmpty ? foods : foods.where((f) => f.name.toLowerCase().contains(q)).toList();
    return PremiumGate(
      title: 'KALORİ',
      child: AnimatedBuilder(
        animation: AppStore.I,
        builder: (context, _) {
          final logs = AppStore.I.foodsOn(DateTime.now());
          var kcal = 0.0, p = 0.0, c = 0.0, f = 0.0;
          for (final item in logs) {
            kcal += item.kcal;
            p += item.protein;
            c += item.carb;
            f += item.fat;
          }
          final diet = AppStore.I.diet;
          return Scaffold(
            appBar: AppBar(title: const Text('KALORİ')),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('${kcal.toStringAsFixed(0)} / ${diet.kcal.toStringAsFixed(0)} kcal',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                SharpProgress(value: diet.kcal <= 0 ? 0 : kcal / diet.kcal),
                const SizedBox(height: 12),
                Text('Protein ${p.toStringAsFixed(0)} g   ·   Karbonhidrat ${c.toStringAsFixed(0)} g   ·   Yağ ${f.toStringAsFixed(0)} g'),
                const SizedBox(height: 16),
                const SectionTitle('BUGÜN'),
                if (logs.isEmpty) const Text('Kayıt yok.', style: TextStyle(color: Colors.white54)),
                for (final item in logs)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                    subtitle: Text('${item.kcal.toStringAsFixed(0)} kcal'),
                    trailing: IconButton(
                      onPressed: () => AppStore.I.deleteFood(item.id),
                      icon: const Icon(Icons.close),
                    ),
                  ),
                const SizedBox(height: 8),
                const SectionTitle('300 YEMEK'),
                const SizedBox(height: 8),
                TextField(
                  decoration: const InputDecoration(labelText: 'ARA'),
                  onChanged: (v) => setState(() => _query = v),
                ),
                const SizedBox(height: 8),
                if (shown.isEmpty) const Text('Sonuç yok.', style: TextStyle(color: Colors.white54)),
                for (final food in shown)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(food.name),
                    subtitle: Text('${food.portion} · ${food.kcal.toStringAsFixed(0)} kcal'),
                    trailing: Icon(Icons.add, color: gold(context)),
                    onTap: () => AppStore.I.addFood(FoodLog(
                      id: newId(),
                      date: dateKey(DateTime.now()),
                      name: food.name,
                      kcal: food.kcal,
                      protein: food.p,
                      carb: food.c,
                      fat: food.f,
                    )),
                  ),
                GoldButton(label: 'ÖZEL YEMEK', filled: false, onTap: () => _custom(context)),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _custom(BuildContext context) async {
    final name = await askText(context, title: 'YEMEK', hint: 'Ad');
    if (name == null || name.isEmpty || !context.mounted) return;
    final kcal = await askText(context, title: 'KALORİ', hint: 'kcal');
    if (kcal == null || !context.mounted) return;
    await AppStore.I.addFood(FoodLog(
      id: newId(),
      date: dateKey(DateTime.now()),
      name: name,
      kcal: double.tryParse(kcal.replaceAll(',', '.')) ?? 0,
      protein: 0,
      carb: 0,
      fat: 0,
    ));
  }
}
