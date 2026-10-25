import 'package:flutter/material.dart';
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
            child: SharpCard(
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
          ),
        );
      },
    );
  }
}
