import 'package:flutter/material.dart';
import 'package:i_am_disiplin/data/catalog.dart';
import 'package:i_am_disiplin/widgets/common.dart';
import 'package:i_am_disiplin/widgets/premium_gate.dart';

class TrainerScreen extends StatelessWidget {
  const TrainerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PremiumGate(
      title: 'ANTRENÖR',
      child: Scaffold(
        appBar: AppBar(title: const Text('ANTRENÖR')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              height: 140,
              alignment: Alignment.center,
              decoration: BoxDecoration(border: Border.all(color: gold(context))),
              child: const Text(
                '3D ANİMASYON YAKINDA',
                style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2),
              ),
            ),
            const SizedBox(height: 18),
            const SectionTitle('PROGRAMLAR'),
            const SizedBox(height: 8),
            for (final p in programs)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SharpCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 4),
                      Text(p.detail, style: const TextStyle(color: Colors.white70)),
                      const SizedBox(height: 6),
                      Text(p.moves.join(' · '), style: TextStyle(color: gold(context), fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            const SectionTitle('EGZERSİZLER'),
            const SizedBox(height: 8),
            for (final m in moves)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SharpCard(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text('Kas: ${m.muscle}'),
                      Text('Ekipman: ${m.gear}   ·   Seviye: ${m.level}', style: const TextStyle(color: Colors.white54)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
