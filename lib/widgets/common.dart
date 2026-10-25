import 'package:flutter/material.dart';
import 'package:i_am_disiplin/models/app_models.dart';

Color gold(BuildContext context) => Theme.of(context).colorScheme.primary;

Color accent(BuildContext context) => Theme.of(context).colorScheme.secondary;

class SharpCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const SharpCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: const Color(0xFF0C0C0C),
        border: Border.all(color: gold(context)),
      ),
      child: child,
    );
  }
}

class GoldButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool filled;
  const GoldButton({
    super.key,
    required this.label,
    required this.onTap,
    this.filled = true,
  });

  @override
  Widget build(BuildContext context) {
    final g = gold(context);
    return Material(
      color: filled ? g : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(border: Border.all(color: g)),
          child: Text(
            label,
            style: TextStyle(
              color: filled ? Colors.black : g,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.4,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: gold(context),
        fontSize: 22,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
      ),
    );
  }
}

class SharpProgress extends StatelessWidget {
  final double value;
  const SharpProgress({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: value.clamp(0, 1),
      minHeight: 8,
      backgroundColor: const Color(0xFF222222),
      color: gold(context),
      borderRadius: BorderRadius.zero,
    );
  }
}

void toast(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}

IconData iconOf(String key) {
  switch (key) {
    case 'alarm':
      return Icons.alarm;
    case 'fitness':
      return Icons.fitness_center;
    case 'run':
      return Icons.directions_run;
    case 'book':
      return Icons.menu_book;
    case 'language':
      return Icons.translate;
    case 'self':
      return Icons.self_improvement;
    case 'water':
      return Icons.water_drop;
    case 'bed':
      return Icons.bedtime;
    case 'edit':
      return Icons.edit;
    case 'psych':
      return Icons.psychology;
    case 'sun':
      return Icons.wb_sunny_outlined;
    case 'bolt':
      return Icons.bolt;
    case 'air':
      return Icons.air;
    default:
      return Icons.flag;
  }
}

Future<String?> askText(
  BuildContext context, {
  required String title,
  String initial = '',
  String hint = '',
  int maxLines = 1,
}) async {
  final box = TextEditingController(text: initial);
  final result = await showDialog<String>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        backgroundColor: const Color(0xFF0A0A0A),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Text(title, style: TextStyle(color: gold(ctx), fontWeight: FontWeight.w900)),
        content: TextField(
          controller: box,
          maxLines: maxLines,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(hintText: hint),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('VAZGEÇ')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, box.text.trim()),
            child: const Text('KAYDET'),
          ),
        ],
      );
    },
  );
  box.dispose();
  return result;
}

String kindName(String kind) => kindLabels[kind] ?? kind;

String catName(String cat) => categoryLabels[cat] ?? cat;
