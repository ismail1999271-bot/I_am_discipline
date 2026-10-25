import 'package:flutter/material.dart';
import 'package:i_am_disiplin/data/campaigns.dart';
import 'package:i_am_disiplin/services/store.dart';
import 'package:i_am_disiplin/widgets/common.dart';

class PremiumGate extends StatelessWidget {
  final String title;
  final Widget child;
  const PremiumGate({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppStore.I,
      builder: (context, _) {
        if (AppStore.I.isPremium) return child;
        return Scaffold(
          appBar: AppBar(title: Text(title)),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
             const CampaignBanner(),
             SharpCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock, color: gold(context), size: 48),
                  const SizedBox(height: 12),
                  const Text('PREMIUM KİLİTLİ', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  const Text(
                    'Ödeme yok. Kilit tek bayraktan kontrol edilir. Ayarlardan test anahtarını aç.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            ]),
          ),
        );
      },
    );
  }
}

/// Aktif özel gün indirimi varsa altın banner gösterir.
class CampaignBanner extends StatelessWidget {
  const CampaignBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final c = activeCampaign();
    if (c == null) return const SizedBox.shrink();
    final left = c.daysLeft(DateTime.now());
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      color: gold(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${c.title}  •  %${c.discount} İNDİRİM',
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
          const SizedBox(height: 4),
          Text(c.message, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(left == 0 ? 'SON GÜN' : 'Son $left gün',
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}
