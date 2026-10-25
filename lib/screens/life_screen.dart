import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:i_am_disiplin/models/app_models.dart';
import 'package:i_am_disiplin/services/store.dart';
import 'package:i_am_disiplin/services/xp_engine.dart';
import 'package:i_am_disiplin/widgets/common.dart';

class LifeScreen extends StatelessWidget {
  const LifeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppStore.I,
      builder: (context, _) {
        final store = AppStore.I;
        final now = DateTime.now();
        final month = '${now.year}-${now.month.toString().padLeft(2, '0')}';
        final monthMoves = store.money.where((m) => m.date.startsWith(month)).toList();
        var income = 0.0;
        var expense = 0.0;
        for (final m in monthMoves) {
          if (m.income) {
            income += m.amount;
          } else {
            expense += m.amount;
          }
        }
        return Scaffold(
          appBar: AppBar(title: const Text('YAŞAM PLANI')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              const SectionTitle('HEDEFLER'),
              const SizedBox(height: 8),
              Text(
                'Aylık hedef tutunca +500 XP. Rütbe düşmez.',
                style: TextStyle(color: gold(context).withValues(alpha: 0.8), fontSize: 12),
              ),
              const SizedBox(height: 10),
              if (store.goals.isEmpty)
                const Text('Hedef yok.', style: TextStyle(color: Colors.white54))
              else
                _GoalChart(goals: store.goals),
              const SizedBox(height: 10),
              for (final g in store.goals) _GoalTile(goal: g),
              const SizedBox(height: 8),
              GoldButton(label: 'HEDEF EKLE', onTap: () => _addGoal(context)),
              const SizedBox(height: 28),
              const SectionTitle('BU AY BÜTÇE'),
              const SizedBox(height: 8),
              Text('Gelir ${income.toStringAsFixed(0)}   ·   Gider ${expense.toStringAsFixed(0)}   ·   Net ${(income - expense).toStringAsFixed(0)}'),
              const SizedBox(height: 12),
              SizedBox(
                height: 160,
                child: BarChart(
                  BarChartData(
                    maxY: (income > expense ? income : expense) <= 0 ? 10 : (income > expense ? income : expense) * 1.2,
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, _) {
                            final t = v.toInt() == 0 ? 'Gelir' : 'Gider';
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(t, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            );
                          },
                        ),
                      ),
                    ),
                    barGroups: [
                      BarChartGroupData(x: 0, barRods: [
                        BarChartRodData(toY: income, width: 28, color: gold(context), borderRadius: BorderRadius.zero),
                      ]),
                      BarChartGroupData(x: 1, barRods: [
                        BarChartRodData(toY: expense, width: 28, color: accent(context), borderRadius: BorderRadius.zero),
                      ]),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: GoldButton(label: 'GELİR', onTap: () => _money(context, true))),
                  const SizedBox(width: 8),
                  Expanded(child: GoldButton(label: 'GİDER', filled: false, onTap: () => _money(context, false))),
                ],
              ),
              const SizedBox(height: 10),
              for (final m in monthMoves.reversed)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(m.note.isEmpty ? (m.income ? 'Gelir' : 'Gider') : m.note),
                  subtitle: Text(m.date),
                  trailing: Text(
                    '${m.income ? '+' : '-'}${m.amount.toStringAsFixed(0)}',
                    style: TextStyle(color: m.income ? gold(context) : accent(context), fontWeight: FontWeight.w900),
                  ),
                  onLongPress: () => store.deleteMoney(m.id),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addGoal(BuildContext context) async {
    final title = TextEditingController();
    final target = TextEditingController();
    final unit = TextEditingController(text: 'TL');
    var kind = 'birikim';
    var horizon = 'aylik';
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          backgroundColor: const Color(0xFF0A0A0A),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          title: Text('HEDEF', style: TextStyle(color: gold(ctx), fontWeight: FontWeight.w900)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: title, decoration: const InputDecoration(labelText: 'Başlık')),
                TextField(controller: target, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Hedef rakam')),
                TextField(controller: unit, decoration: const InputDecoration(labelText: 'Birim')),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: [
                    for (final k in kindLabels.keys)
                      ChoiceChip(
                        label: Text(kindName(k)),
                        selected: kind == k,
                        showCheckmark: false,
                        onSelected: (_) => setLocal(() => kind = k),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: [
                    ChoiceChip(label: const Text('Aylık'), selected: horizon == 'aylik', showCheckmark: false, onSelected: (_) => setLocal(() => horizon = 'aylik')),
                    ChoiceChip(label: const Text('Yıllık'), selected: horizon == 'yillik', showCheckmark: false, onSelected: (_) => setLocal(() => horizon = 'yillik')),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('VAZGEÇ')),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('KAYDET')),
          ],
        ),
      ),
    );
    final name = title.text.trim();
    final goal = double.tryParse(target.text.replaceAll(',', '.')) ?? 0;
    final u = unit.text.trim();
    title.dispose();
    target.dispose();
    unit.dispose();
    if (ok != true || name.isEmpty || goal <= 0) return;
    await AppStore.I.saveGoal(LifeGoal(
      id: newId(),
      kind: kind,
      horizon: horizon,
      title: name,
      target: goal,
      current: 0,
      unit: u,
    ));
  }

  Future<void> _money(BuildContext context, bool income) async {
    final amount = await askText(context, title: income ? 'GELİR' : 'GİDER', hint: 'Tutar');
    if (amount == null) return;
    final value = double.tryParse(amount.replaceAll(',', '.')) ?? 0;
    if (value <= 0) return;
    if (!context.mounted) return;
    final note = await askText(context, title: 'NOT', hint: 'isteğe bağlı');
    await AppStore.I.addMoney(MoneyMove(
      id: newId(),
      date: dateKey(DateTime.now()),
      income: income,
      amount: value,
      note: note ?? '',
    ));
  }
}

class _GoalChart extends StatelessWidget {
  final List<LifeGoal> goals;
  const _GoalChart({required this.goals});

  @override
  Widget build(BuildContext context) {
    final maxY = 100.0;
    return SizedBox(
      height: 160,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i < 0 || i >= goals.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(kindName(goals[i].kind), style: const TextStyle(color: Colors.white54, fontSize: 10)),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < goals.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: goals[i].ratio * 100,
                    width: 16,
                    color: gold(context),
                    borderRadius: BorderRadius.zero,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _GoalTile extends StatelessWidget {
  final LifeGoal goal;
  const _GoalTile({required this.goal});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SharpCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${kindName(goal.kind)} · ${goal.horizon == 'yillik' ? 'Yıllık' : 'Aylık'}',
                style: TextStyle(color: gold(context), fontSize: 12, fontWeight: FontWeight.w800)),
            Text(goal.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            SharpProgress(value: goal.ratio),
            const SizedBox(height: 6),
            Text('${goal.current.toStringAsFixed(0)} / ${goal.target.toStringAsFixed(0)} ${goal.unit}'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: GoldButton(
                    label: 'İLERLEME',
                    filled: false,
                    onTap: () async {
                      final raw = await askText(context, title: 'GÜNCEL', initial: goal.current.toStringAsFixed(0));
                      if (raw == null) return;
                      final v = double.tryParse(raw.replaceAll(',', '.'));
                      if (v == null) return;
                      await AppStore.I.saveGoal(goal.copyWith(current: v));
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(onPressed: () => AppStore.I.deleteGoal(goal.id), icon: const Icon(Icons.delete_outline)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
