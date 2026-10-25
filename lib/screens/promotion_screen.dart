import 'package:flutter/material.dart';
import 'package:i_am_disiplin/services/xp_engine.dart';
import 'package:i_am_disiplin/theme/app_theme.dart';
import 'package:i_am_disiplin/widgets/common.dart';

class PromotionScreen extends StatefulWidget {
  final int rankIndex;
  const PromotionScreen({super.key, required this.rankIndex});

  @override
  State<PromotionScreen> createState() => _PromotionScreenState();
}

class _PromotionScreenState extends State<PromotionScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final i = widget.rankIndex.clamp(0, ranks.length - 1);
    final rank = ranks[i];
    final skin = skins[i.clamp(0, skins.length - 1)];
    return Scaffold(
      backgroundColor: Colors.black,
      body: FadeTransition(
        opacity: CurvedAnimation(parent: _c, curve: Curves.easeOut),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1).animate(_c),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                Text(
                  'TERFİ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: skin.gold,
                    letterSpacing: 6,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 36),
                  decoration: BoxDecoration(border: Border.all(color: skin.gold, width: 2)),
                  child: Column(
                    children: [
                      Icon(Icons.military_tech, color: skin.gold, size: 64),
                      const SizedBox(height: 12),
                      Text(
                        rank.name.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, letterSpacing: 2),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        skin.name,
                        style: TextStyle(color: skin.orange, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  rank.line,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, height: 1.35),
                ),
                const Spacer(),
                GoldButton(label: 'DEVAM', onTap: () => Navigator.of(context).pop()),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
