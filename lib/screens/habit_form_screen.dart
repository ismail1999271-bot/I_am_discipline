import 'package:flutter/material.dart';
import 'package:i_am_disiplin/models/app_models.dart';
import 'package:i_am_disiplin/services/store.dart';
import 'package:i_am_disiplin/services/xp_engine.dart';
import 'package:i_am_disiplin/widgets/common.dart';

class HabitFormScreen extends StatefulWidget {
  final Habit? existing;
  const HabitFormScreen({super.key, this.existing});

  @override
  State<HabitFormScreen> createState() => _HabitFormScreenState();
}

class _HabitFormScreenState extends State<HabitFormScreen> {
  late final TextEditingController _name;
  late String _icon;
  late bool _hard;
  late List<int> _days;
  String? _reminder;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? '');
    _icon = e?.icon ?? 'flag';
    _hard = e?.hard ?? false;
    _days = List<int>.from(e?.days ?? const [1, 2, 3, 4, 5, 6, 7]);
    _reminder = e?.reminder;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final parts = (_reminder ?? '08:00').split(':');
    final initial = TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 8,
      minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
    );
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;
    setState(() {
      final h = picked.hour.toString().padLeft(2, '0');
      final m = picked.minute.toString().padLeft(2, '0');
      _reminder = '$h:$m';
    });
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      toast(context, 'Ad boş olmaz.');
      return;
    }
    if (_days.isEmpty) {
      toast(context, 'En az bir gün seç.');
      return;
    }
    final habit = Habit(
      id: widget.existing?.id ?? newId(),
      name: name,
      icon: _icon,
      hard: _hard,
      days: List<int>.from(_days)..sort(),
      reminder: _reminder,
      created: widget.existing?.created ?? dateKey(DateTime.now()),
    );
    await AppStore.I.saveHabit(habit);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.existing == null ? 'ALIŞKANLIK' : 'DÜZENLE')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _name,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            decoration: const InputDecoration(labelText: 'Ad'),
          ),
          const SizedBox(height: 18),
          const SectionTitle('İKON'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final key in iconKeys)
                InkWell(
                  onTap: () => setState(() => _icon = key),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _icon == key ? gold(context) : const Color(0xFF333333),
                        width: _icon == key ? 2 : 1,
                      ),
                    ),
                    child: Icon(iconOf(key), color: gold(context)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: GoldButton(
                  label: 'NORMAL',
                  filled: !_hard,
                  onTap: () => setState(() => _hard = false),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GoldButton(
                  label: 'ZOR',
                  filled: _hard,
                  onTap: () => setState(() => _hard = true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _hard ? 'Zor: +20 XP' : 'Normal: +10 XP',
            style: const TextStyle(color: Colors.white54),
          ),
          const SizedBox(height: 18),
          const SectionTitle('GÜNLER'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              for (var i = 1; i <= 7; i++)
                FilterChip(
                  label: Text(dayLabels[i - 1]),
                  selected: _days.contains(i),
                  showCheckmark: false,
                  selectedColor: gold(context),
                  backgroundColor: Colors.black,
                  labelStyle: TextStyle(
                    color: _days.contains(i) ? Colors.black : Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                  side: BorderSide(color: gold(context)),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  onSelected: (v) {
                    setState(() {
                      if (v) {
                        _days.add(i);
                      } else {
                        _days.remove(i);
                      }
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 18),
          GoldButton(
            label: _reminder == null ? 'HATIRLATMA SAATİ' : 'SAAT $_reminder',
            filled: false,
            onTap: _pickTime,
          ),
          if (_reminder != null) ...[
            const SizedBox(height: 8),
            GoldButton(
              label: 'SAATİ KALDIR',
              filled: false,
              onTap: () => setState(() => _reminder = null),
            ),
          ],
          const SizedBox(height: 18),
          GoldButton(label: 'KAYDET', onTap: _save),
          if (widget.existing != null) ...[
            const SizedBox(height: 8),
            GoldButton(
              label: 'SİL',
              filled: false,
              onTap: () async {
                await AppStore.I.deleteHabit(widget.existing!.id);
                if (!context.mounted) return;
                Navigator.pop(context);
              },
            ),
          ],
        ],
      ),
    );
  }
}
