import 'package:flutter/material.dart';
import 'package:i_am_disiplin/models/app_models.dart';
import 'package:i_am_disiplin/screens/notebook_screen.dart';
import 'package:i_am_disiplin/services/store.dart';
import 'package:i_am_disiplin/services/xp_engine.dart';
import 'package:i_am_disiplin/widgets/common.dart';
import 'package:table_calendar/table_calendar.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  DateTime _focused = DateTime.now();
  DateTime _selected = DateTime.now();
  String _filter = 'hepsi';

  @override
  Widget build(BuildContext context) {
    final g = gold(context);
    return AnimatedBuilder(
      animation: AppStore.I,
      builder: (context, _) {
        final all = AppStore.I.eventsOn(_selected);
        final shown = _filter == 'hepsi' ? all : all.where((e) => e.category == _filter).toList();
        return Scaffold(
          appBar: AppBar(
            title: const Text('AJANDA'),
            actions: [
              IconButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const NotebookListScreen()),
                ),
                icon: const Icon(Icons.menu_book),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: g,
            foregroundColor: Colors.black,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            onPressed: () => _edit(context, null),
            child: const Icon(Icons.add),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 96),
            children: [
              TableCalendar<AgendaItem>(
                locale: 'tr_TR',
                firstDay: DateTime(2020),
                lastDay: DateTime(2036),
                focusedDay: _focused,
                selectedDayPredicate: (d) => dateOnly(d) == dateOnly(_selected),
                startingDayOfWeek: StartingDayOfWeek.monday,
                calendarFormat: CalendarFormat.month,
                availableGestures: AvailableGestures.horizontalSwipe,
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(color: g, fontWeight: FontWeight.w900, fontSize: 16),
                  leftChevronIcon: Icon(Icons.chevron_left, color: g),
                  rightChevronIcon: Icon(Icons.chevron_right, color: g),
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: Colors.white54, fontWeight: FontWeight.w700),
                  weekendStyle: TextStyle(color: Colors.white38, fontWeight: FontWeight.w700),
                ),
                calendarStyle: CalendarStyle(
                  defaultTextStyle: const TextStyle(color: Colors.white),
                  weekendTextStyle: const TextStyle(color: Colors.white70),
                  outsideTextStyle: const TextStyle(color: Colors.white24),
                  todayDecoration: BoxDecoration(border: Border.all(color: g)),
                  todayTextStyle: TextStyle(color: g, fontWeight: FontWeight.w900),
                  selectedDecoration: BoxDecoration(color: g),
                  selectedTextStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900),
                  markerDecoration: BoxDecoration(color: accent(context)),
                ),
                eventLoader: (day) => AppStore.I.eventsOn(day),
                onDaySelected: (selected, focused) {
                  setState(() {
                    _selected = selected;
                    _focused = focused;
                  });
                },
                onPageChanged: (focused) => _focused = focused,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final c in ['hepsi', 'spor', 'yemek', 'uyku', 'is'])
                    ChoiceChip(
                      label: Text(c == 'hepsi' ? 'Tümü' : catName(c)),
                      selected: _filter == c,
                      showCheckmark: false,
                      selectedColor: g,
                      backgroundColor: Colors.black,
                      labelStyle: TextStyle(
                        color: _filter == c ? Colors.black : Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                      side: BorderSide(color: g),
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      onSelected: (_) => setState(() => _filter = c),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (shown.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('Bu günde kayıt yok.', style: TextStyle(color: Colors.white54)),
                ),
              for (final e in shown)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () => _edit(context, e),
                    child: SharpCard(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${catName(e.category)}${e.time == null ? '' : '  ·  ${e.time}'}',
                                    style: TextStyle(color: g, fontWeight: FontWeight.w800, fontSize: 12)),
                                Text(e.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                                if (e.note.isNotEmpty)
                                  Text(e.note, style: const TextStyle(color: Colors.white70)),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => AppStore.I.deleteEvent(e.id),
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _edit(BuildContext context, AgendaItem? existing) async {
    final title = TextEditingController(text: existing?.title ?? '');
    final note = TextEditingController(text: existing?.note ?? '');
    var cat = existing?.category ?? 'is';
    var time = existing?.time;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            return AlertDialog(
              backgroundColor: const Color(0xFF0A0A0A),
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              title: Text(existing == null ? 'KAYIT' : 'DÜZENLE', style: TextStyle(color: gold(ctx), fontWeight: FontWeight.w900)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: title, decoration: const InputDecoration(labelText: 'Başlık')),
                    const SizedBox(height: 8),
                    TextField(controller: note, decoration: const InputDecoration(labelText: 'Not'), maxLines: 2),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      children: [
                        for (final c in ['spor', 'yemek', 'uyku', 'is'])
                          ChoiceChip(
                            label: Text(catName(c)),
                            selected: cat == c,
                            showCheckmark: false,
                            onSelected: (_) => setLocal(() => cat = c),
                          ),
                      ],
                    ),
                    TextButton(
                      onPressed: () async {
                        final picked = await showTimePicker(context: ctx, initialTime: TimeOfDay.now());
                        if (picked == null) return;
                        setLocal(() {
                          time = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                        });
                      },
                      child: Text(time == null ? 'SAAT EKLE' : 'SAAT $time'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('VAZGEÇ')),
                TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('KAYDET')),
              ],
            );
          },
        );
      },
    );
    final name = title.text.trim();
    final body = note.text.trim();
    title.dispose();
    note.dispose();
    if (ok != true || name.isEmpty) return;
    await AppStore.I.saveEvent(AgendaItem(
      id: existing?.id ?? newId(),
      date: dateKey(_selected),
      category: cat,
      title: name,
      note: body,
      time: time,
    ));
  }
}
