import 'package:flutter/material.dart';
import 'store.dart';
import 'theme.dart';
import 'main.dart' show store, toast;

/// Gruplu kategoriler: grup -> (kategori -> ikon)
const budgetGroups = <String, Map<String, IconData>>{
  'BARINMA': {
    'Kira / Konut kredisi': Icons.home_outlined,
    'Aidat': Icons.apartment_outlined,
    'Ev bakım / Tamir': Icons.handyman_outlined,
    'Ev eşyası': Icons.chair_outlined,
  },
  'FATURALAR': {
    'Elektrik': Icons.bolt_outlined,
    'Su': Icons.water_drop_outlined,
    'Doğalgaz': Icons.local_fire_department_outlined,
    'İnternet': Icons.wifi,
    'Telefon': Icons.smartphone_outlined,
  },
  'YEMEK & İÇME': {
    'Market': Icons.shopping_cart_outlined,
    'Dışarıda yemek': Icons.restaurant_outlined,
    'Kahve / Atıştırmalık': Icons.local_cafe_outlined,
    'Yemek siparişi': Icons.delivery_dining_outlined,
  },
  'ULAŞIM': {
    'Yakıt': Icons.local_gas_station_outlined,
    'Toplu taşıma': Icons.directions_bus_outlined,
    'Araç bakım / Sigorta / Vergi': Icons.car_repair_outlined,
    'Taksi': Icons.local_taxi_outlined,
  },
  'SAĞLIK & BAKIM': {
    'Sağlık / İlaç': Icons.medical_services_outlined,
    'Spor salonu': Icons.fitness_center,
    'Kişisel bakım / Kuaför': Icons.content_cut,
  },
  'GİYİM': {
    'Giyim': Icons.checkroom_outlined,
    'Ayakkabı / Aksesuar': Icons.hiking,
  },
  'AİLE': {
    'Çocuk / Okul': Icons.child_care_outlined,
    'Evcil hayvan': Icons.pets_outlined,
    'Hediye / Bağış': Icons.card_giftcard_outlined,
  },
  'GELİŞİM': {
    'Eğitim / Kurs': Icons.school_outlined,
    'Kitap': Icons.menu_book_outlined,
  },
  'KEYİF': {
    'Eğlence / Sinema': Icons.celebration_outlined,
    'Tatil / Gezi': Icons.flight_outlined,
    'Hobi': Icons.palette_outlined,
    'Abonelikler (dizi, müzik)': Icons.subscriptions_outlined,
  },
  'BORÇ': {
    'Kredi kartı borcu': Icons.credit_card,
    'Kredi taksidi': Icons.account_balance_outlined,
  },
  'DİĞER': {
    'Diğer': Icons.more_horiz,
  },
};

/// Düz liste (eski kodla uyumlu)
final budgetCats = <String, IconData>{for (final g in budgetGroups.values) ...g};

/// 50/30/20 kuralına göre gelirin yüzdesi (ihtiyaç %50, istek %30, birikim %20 ayrıca)
const _ratios = <String, double>{
  // İhtiyaçlar ~%50
  'Kira / Konut kredisi': .22, 'Aidat': .02, 'Elektrik': .02, 'Su': .01, 'Doğalgaz': .02,
  'İnternet': .01, 'Telefon': .01, 'Market': .10, 'Toplu taşıma': .02, 'Yakıt': .03,
  'Sağlık / İlaç': .02, 'Kredi taksidi': .02,
  // İstekler ~%30
  'Dışarıda yemek': .05, 'Kahve / Atıştırmalık': .02, 'Yemek siparişi': .02, 'Giyim': .04,
  'Ayakkabı / Aksesuar': .01, 'Kişisel bakım / Kuaför': .02, 'Spor salonu': .02,
  'Eğlence / Sinema': .03, 'Abonelikler (dizi, müzik)': .01, 'Hobi': .02, 'Kitap': .01,
  'Eğitim / Kurs': .02, 'Hediye / Bağış': .01, 'Ev eşyası': .01, 'Diğer': .01,
};

String tl(num v) {
  final s = v.round().abs().toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.');
  return '${v < 0 ? '-' : ''}$s ₺';
}

String monthKey([DateTime? d]) => dayKey(d ?? DateTime.now()).substring(0, 7);

class BudgetTab extends StatelessWidget {
  const BudgetTab({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final b = store.budget;
    if ((b['income'] ?? 0) == 0) {
      return ListView(padding: const EdgeInsets.all(20), children: [
        Text('AYLIK BÜTÇE', style: tt.headlineSmall),
        const SizedBox(height: 8),
        const Text('Paranı yönetmek de disiplindir. Gelirini ve hedefini gir, '
            'kategorileri 50/30/20 kuralına göre ben dağıtayım; istediğin gibi değiştirirsin.'),
        const SizedBox(height: 20),
        FilledButton(onPressed: () => editBudget(context), child: const Text('BÜTÇEMİ KUR')),
      ]);
    }
    final now = DateTime.now();
    final mk = monthKey();
    final exps = store.expenses.where((e) => (e['date'] as String).startsWith(mk)).toList();
    final income = (b['income'] as num).toDouble();
    final saving = ((b['saving'] ?? 0) as num).toDouble();
    final spent = exps.fold<double>(0, (a, e) => a + (e['amt'] as num));
    final spendable = income - saving;
    final left = spendable - spent;
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysLeft = daysInMonth - now.day + 1;
    final perDay = left / daysLeft;
    final limits = Map<String, num>.from(b['limits'] ?? {});
    final byCat = <String, double>{};
    for (final e in exps) {
      byCat[e['cat']] = (byCat[e['cat']] ?? 0) + (e['amt'] as num);
    }
    final prevKey = monthKey(DateTime(now.year, now.month - 1, 1));
    final prevSpent = store.expenses.where((e) => (e['date'] as String).startsWith(prevKey))
        .fold<double>(0, (a, e) => a + (e['amt'] as num));
    final ratio = spendable <= 0 ? 1.0 : (spent / spendable).clamp(0, 1).toDouble();
    final over = left < 0;

    return ListView(padding: const EdgeInsets.all(16), children: [
      Row(children: [
        Expanded(child: Text('${_monthName(now.month).toUpperCase()} ${now.year}', style: tt.headlineSmall)),
        IconButton(onPressed: () => editBudget(context), icon: const Icon(Icons.tune), tooltip: 'Bütçe ayarı'),
      ]),
      // Ana kart
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Iron.surface, border: Border.all(color: over ? Iron.blood : Iron.line),
            borderRadius: BorderRadius.circular(6)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(over ? 'BÜTÇEYİ AŞTIN' : 'BUGÜN HARCAYABİLECEĞİN', style: tt.labelMedium?.copyWith(color: over ? Iron.blood : Iron.fire)),
          Text(over ? tl(-left) : tl(perDay), style: tt.displaySmall?.copyWith(color: over ? Iron.blood : Iron.white)),
          Text(over ? 'Fazla harcandı. Kalan $daysLeft gün sadece zorunlu harcama.' : 'Ay sonuna $daysLeft gün · kalan ${tl(left)}',
              style: const TextStyle(color: Iron.steel)),
          const SizedBox(height: 14),
          LinearProgressIndicator(value: ratio, minHeight: 10, color: over ? Iron.blood : ratio > .85 ? Iron.ember : Iron.fire),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _stat('Gelir', tl(income))),
            Expanded(child: _stat('Harcanan', tl(spent))),
            Expanded(child: _stat('Birikim', tl(saving))),
          ]),
          if (prevSpent > 0) Padding(padding: const EdgeInsets.only(top: 10), child: Text(
              'Geçen ay bu zamana göre: ${tl(prevSpent)} toplam. '
              '${spent <= prevSpent * now.day / daysInMonth ? "Daha disiplinlisin 🔥" : "Bu ay daha hızlı harcıyorsun."}',
              style: const TextStyle(color: Iron.steel, fontSize: 12))),
        ]),
      ),
      const SizedBox(height: 12),
      SizedBox(height: 50, child: FilledButton.icon(onPressed: () => addExpense(context),
          icon: const Icon(Icons.add), label: const Text('HARCAMA EKLE'))),
      const SizedBox(height: 20),
      const SavingsSection(),
      const SizedBox(height: 20),
      Text('KATEGORİLER', style: tt.labelMedium),
      for (final g in budgetGroups.entries)
        if (g.value.keys.any((c) => (limits[c] ?? 0) > 0 || (byCat[c] ?? 0) > 0)) ...[
          Padding(padding: const EdgeInsets.only(top: 14, bottom: 8), child: Row(children: [
            Expanded(child: Text(g.key, style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2))),
            Text('${tl(g.value.keys.fold<double>(0, (a, c) => a + (byCat[c] ?? 0)))} / '
                '${tl(g.value.keys.fold<num>(0, (a, c) => a + (limits[c] ?? 0)))}',
                style: const TextStyle(color: Iron.steel, fontSize: 12)),
          ])),
          for (final c in g.value.keys)
            if ((limits[c] ?? 0) > 0 || (byCat[c] ?? 0) > 0)
          Builder(builder: (_) {
            final lim = (limits[c] ?? 0).toDouble(), sp = byCat[c] ?? 0;
            final r = lim == 0 ? 1.0 : (sp / lim);
            final col = r > 1 ? Iron.blood : r > .85 ? Iron.ember : Iron.fire;
            return Padding(padding: const EdgeInsets.only(bottom: 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(budgetCats[c], size: 18, color: Iron.steel),
                const SizedBox(width: 8),
                Expanded(child: Text(c, style: const TextStyle(fontWeight: FontWeight.w700))),
                Text('${tl(sp)} / ${tl(lim)}', style: TextStyle(color: col, fontWeight: FontWeight.w800)),
              ]),
              const SizedBox(height: 6),
              LinearProgressIndicator(value: r.clamp(0, 1).toDouble(), minHeight: 6, color: col),
            ]));
          }),
        ],
      const SizedBox(height: 8),
      Text('BU AYIN HARCAMALARI', style: tt.labelMedium),
      if (exps.isEmpty) const Padding(padding: EdgeInsets.symmetric(vertical: 16),
          child: Text('Henüz harcama yok. Her harcamayı anında yaz; disiplin buradan başlar.')),
      for (final e in exps.reversed)
        Dismissible(
          key: ValueKey(e['id']),
          background: Container(color: Iron.blood),
          onDismissed: (_) => store.removeExpense(e['id']),
          child: ListTile(contentPadding: EdgeInsets.zero, dense: true,
              leading: Icon(budgetCats[e['cat']] ?? Icons.more_horiz, color: Iron.steel),
              title: Text((e['note'] as String).isEmpty ? e['cat'] : e['note']),
              subtitle: Text('${e['date']} · ${e['cat']}'),
              trailing: Text(tl(e['amt']), style: const TextStyle(fontWeight: FontWeight.w800))),
        ),
      const SizedBox(height: 8),
      const Text('Silmek için kaydır. Bu bölüm finansal tavsiye değildir.', style: TextStyle(fontSize: 11, color: Iron.steel)),
      const SizedBox(height: 24),
    ]);
  }

  Widget _stat(String l, String v) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l.toUpperCase(), style: const TextStyle(fontSize: 10, color: Iron.steel, fontWeight: FontWeight.w800, letterSpacing: 1)),
        Text(v, style: const TextStyle(fontWeight: FontWeight.w900)),
      ]);
}

String _monthName(int m) => const ['Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', 'Temmuz',
  'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'][m - 1];

Future<void> addExpense(BuildContext context) async {
  final amt = TextEditingController(), note = TextEditingController();
  var cat = 'Market';
  await showModalBottomSheet(context: context, isScrollControlled: true, useSafeArea: true,
    builder: (ctx) => StatefulBuilder(builder: (ctx, set) => SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
        Text('HARCAMA', style: Theme.of(ctx).textTheme.headlineSmall),
        TextField(controller: amt, autofocus: true, keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: Theme.of(ctx).textTheme.displaySmall,
            decoration: const InputDecoration(hintText: '0', suffixText: '₺')),
        const SizedBox(height: 12),
        for (final g in budgetGroups.entries) ...[
          Padding(padding: const EdgeInsets.only(top: 10, bottom: 4),
              child: Text(g.key, style: Theme.of(ctx).textTheme.labelMedium)),
          Wrap(spacing: 6, runSpacing: 6, children: [
            for (final c in g.value.entries)
              ChoiceChip(avatar: Icon(c.value, size: 16), label: Text(c.key), selected: cat == c.key,
                  onSelected: (_) => set(() => cat = c.key)),
          ]),
        ],
        TextField(controller: note, decoration: const InputDecoration(labelText: 'Not (isteğe bağlı)', hintText: 'örn. Haftalık market')),
        const SizedBox(height: 16),
        SizedBox(height: 50, child: FilledButton(onPressed: () {
          final v = num.tryParse(amt.text.replaceAll('.', '').replaceAll(',', '.'));
          if (v == null || v <= 0) return;
          store.addExpense({'id': DateTime.now().microsecondsSinceEpoch.toString(), 'date': dayKey(DateTime.now()),
            'amt': v, 'cat': cat, 'note': note.text.trim()});
          Navigator.pop(ctx);
        }, child: const Text('KAYDET'))),
      ]))));
}

Future<void> editBudget(BuildContext context) async {
  final b = store.budget;
  final income = TextEditingController(text: '${b['income'] ?? ''}'),
      saving = TextEditingController(text: '${b['saving'] ?? ''}');
  final limits = <String, TextEditingController>{
    for (final c in budgetCats.keys) c: TextEditingController(text: '${(b['limits'] ?? {})[c] ?? ''}'),
  };
  void auto(StateSetter set) {
    final inc = num.tryParse(income.text) ?? 0;
    if (inc <= 0) return;
    // 50/30/20: ihtiyaç %50, istek %30, birikim %20
    set(() {
      saving.text = '${(inc * .2).round()}';
      for (final c in limits.keys) {
        final r = _ratios[c] ?? 0;
        limits[c]!.text = r == 0 ? '' : '${((inc * r) / 50).round() * 50}';
      }
    });
  }

  await showModalBottomSheet(context: context, isScrollControlled: true, useSafeArea: true,
    builder: (ctx) => StatefulBuilder(builder: (ctx, set) => SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
        Text('BÜTÇE PLANI', style: Theme.of(ctx).textTheme.headlineSmall),
        Row(children: [
          Expanded(child: TextField(controller: income, keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Aylık net gelir', suffixText: '₺'))),
          const SizedBox(width: 12),
          Expanded(child: TextField(controller: saving, keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Birikim hedefi', suffixText: '₺'))),
        ]),
        const SizedBox(height: 12),
        OutlinedButton.icon(onPressed: () => auto(set), icon: const Icon(Icons.auto_fix_high),
            label: const Text('50/30/20 kuralıyla otomatik dağıt')),
        const SizedBox(height: 4),
        const Text('%50 ihtiyaçlar · %30 istekler · %20 birikim', style: TextStyle(fontSize: 12, color: Iron.steel)),
        const SizedBox(height: 12),
        for (final g in budgetGroups.entries) ...[
          Padding(padding: const EdgeInsets.only(top: 14, bottom: 4),
              child: Text(g.key, style: Theme.of(ctx).textTheme.labelMedium)),
          for (final c in g.value.entries)
            Row(children: [
              Icon(c.value, size: 18, color: Iron.steel),
              const SizedBox(width: 10),
              Expanded(child: Text(c.key)),
              SizedBox(width: 110, child: TextField(controller: limits[c.key], keyboardType: TextInputType.number,
                  textAlign: TextAlign.right, decoration: const InputDecoration(suffixText: '₺', isDense: true))),
            ]),
        ],
        const SizedBox(height: 16),
        SizedBox(height: 50, child: FilledButton(onPressed: () {
          final inc = num.tryParse(income.text);
          if (inc == null || inc <= 0) return;
          final sv = num.tryParse(saving.text) ?? 0;
          final lim = <String, num>{for (final e in limits.entries) if ((num.tryParse(e.value.text) ?? 0) > 0) e.key: num.parse(e.value.text)};
          final total = lim.values.fold<num>(0, (a, v) => a + v) + sv;
          store.setBudget({'income': inc, 'saving': sv, 'limits': lim});
          Navigator.pop(ctx);
          if (total > inc) toast(context, 'Dikkat: limitler + birikim gelirini ${tl(total - inc)} aşıyor.');
        }, child: const Text('KAYDET'))),
      ]))));
}


// ======================= BİRİKİM HESABI =======================
/// Birden fazla birikim hedefi: acil durum fonu, tatil, araba...
class SavingsSection extends StatelessWidget {
  const SavingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final goals = store.savingsGoals;
    final total = goals.fold<num>(0, (a, g) => a + (g['saved'] as num));
    // Acil durum fonu önerisi: 3 aylık zorunlu gider
    final limits = Map<String, num>.from(store.budget['limits'] ?? {});
    const essentials = ['BARINMA', 'FATURALAR', 'YEMEK & İÇME', 'ULAŞIM', 'BORÇ'];
    final monthlyNeeds = essentials.fold<num>(0, (a, g) =>
        a + budgetGroups[g]!.keys.fold<num>(0, (b, c) => b + (limits[c] ?? 0)));
    final hasEmergency = goals.any((g) => g['name'] == 'Acil durum fonu');

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        Expanded(child: Text('BİRİKİM HESABI', style: tt.labelMedium)),
        Text(tl(total), style: tt.titleLarge?.copyWith(color: Iron.fire)),
      ]),
      const SizedBox(height: 8),
      if (!hasEmergency && monthlyNeeds > 0)
        Card(child: ListTile(
          leading: const Icon(Icons.shield_outlined, color: Iron.ember),
          title: const Text('Önce acil durum fonu'),
          subtitle: Text('3 aylık zorunlu giderin kadar: ${tl(monthlyNeeds * 3)}. İş kaybı, hastalık gibi durumlarda seni korur.'),
          trailing: TextButton(child: const Text('EKLE'), onPressed: () => store.addSavingsGoal(
              {'id': 'emg', 'name': 'Acil durum fonu', 'target': monthlyNeeds * 3, 'saved': 0})),
        )),
      for (final g in goals) _GoalCard(g),
      OutlinedButton.icon(onPressed: () => _newGoal(context), icon: const Icon(Icons.add), label: const Text('Yeni birikim hedefi')),
    ]);
  }

  Future<void> _newGoal(BuildContext context) async {
    final name = TextEditingController(), target = TextEditingController();
    final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Birikim hedefi'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Wrap(spacing: 6, children: [
          for (final s in ['Tatil', 'Araba', 'Ev peşinatı', 'Telefon', 'Düğün', 'Eğitim'])
            ActionChip(label: Text(s), onPressed: () => name.text = s),
        ]),
        TextField(controller: name, decoration: const InputDecoration(labelText: 'Ad')),
        TextField(controller: target, keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Hedef tutar', suffixText: '₺')),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Vazgeç')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Ekle')),
      ],
    ));
    final t = num.tryParse(target.text);
    if (ok != true || name.text.trim().isEmpty || t == null || t <= 0) return;
    store.addSavingsGoal({'id': DateTime.now().microsecondsSinceEpoch.toString(), 'name': name.text.trim(), 'target': t, 'saved': 0});
  }
}

class _GoalCard extends StatelessWidget {
  final Map<String, dynamic> g;
  const _GoalCard(this.g);

  Future<void> _move(BuildContext context, bool add) async {
    final c = TextEditingController();
    final v = await showDialog<num>(context: context, builder: (ctx) => AlertDialog(
      title: Text(add ? '${g['name']} · para ekle' : '${g['name']} · para çek'),
      content: TextField(controller: c, autofocus: true, keyboardType: TextInputType.number,
          decoration: const InputDecoration(suffixText: '₺')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Vazgeç')),
        FilledButton(onPressed: () => Navigator.pop(ctx, num.tryParse(c.text)), child: const Text('Tamam')),
      ],
    ));
    if (v == null || v <= 0) return;
    store.moveSavings(g['id'], add ? v : -v);
    if (add && context.mounted) toast(context, '+${tl(v)} birikime. Gelecekteki sen teşekkür ediyor.');
  }

  @override
  Widget build(BuildContext context) {
    final saved = (g['saved'] as num).toDouble(), target = (g['target'] as num).toDouble();
    final r = target == 0 ? 0.0 : (saved / target).clamp(0, 1).toDouble();
    final done = saved >= target;
    return Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Text(g['name'], style: const TextStyle(fontWeight: FontWeight.w900))),
        Text('%${(r * 100).round()}', style: TextStyle(color: done ? Iron.ember : Iron.fire, fontWeight: FontWeight.w900)),
      ]),
      const SizedBox(height: 8),
      LinearProgressIndicator(value: r, minHeight: 8, color: done ? Iron.ember : Iron.fire),
      const SizedBox(height: 6),
      Text(done ? 'HEDEF TAMAM 🏆 ${tl(saved)}' : '${tl(saved)} / ${tl(target)} · kalan ${tl(target - saved)}',
          style: const TextStyle(color: Iron.steel, fontSize: 12)),
      Row(children: [
        TextButton.icon(onPressed: () => _move(context, true), icon: const Icon(Icons.add), label: const Text('Ekle')),
        TextButton.icon(onPressed: saved <= 0 ? null : () => _move(context, false), icon: const Icon(Icons.remove), label: const Text('Çek')),
        const Spacer(),
        IconButton(icon: const Icon(Icons.delete_outline, size: 20), onPressed: () => store.removeSavingsGoal(g['id'])),
      ]),
    ])));
  }
}
