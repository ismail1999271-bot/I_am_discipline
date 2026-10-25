import 'package:flutter/material.dart';
import 'package:i_am_disiplin/services/store.dart';
import 'package:i_am_disiplin/services/xp_engine.dart';
import 'package:i_am_disiplin/theme/app_theme.dart';
import 'package:i_am_disiplin/widgets/common.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppStore.I,
      builder: (context, _) {
        final store = AppStore.I;
        return Scaffold(
          appBar: AppBar(title: const Text('AYARLAR')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SectionTitle('KİMLİK'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: GoldButton(
                      label: 'ERKEK',
                      filled: store.gender == 'erkek',
                      onTap: () => store.setGender('erkek'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GoldButton(
                      label: 'KADIN',
                      filled: store.gender == 'kadin',
                      onTap: () => store.setGender('kadin'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              const SectionTitle('TEMA'),
              const SizedBox(height: 8),
              Text(
                'Kilit rütbeyle açılır. Şu an: ${ranks[store.peakRank.clamp(0, ranks.length - 1)].name}',
                style: const TextStyle(color: Colors.white54),
              ),
              const SizedBox(height: 8),
              for (final skin in skins)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: skin.minRank <= store.peakRank ? () => store.setTheme(skin.id) : null,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: store.themeId == skin.id ? skin.gold : const Color(0xFF333333),
                          width: store.themeId == skin.id ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(width: 18, height: 18, color: skin.gold),
                          const SizedBox(width: 8),
                          Container(width: 18, height: 18, color: skin.orange),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(skin.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                          ),
                          Text(
                            skin.minRank <= store.peakRank ? 'AÇIK' : 'KİLİTLİ',
                            style: TextStyle(
                              color: skin.minRank <= store.peakRank ? skin.gold : Colors.white38,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 22),
              const SectionTitle('PREMIUM TEST'),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Kilidi aç', style: TextStyle(fontWeight: FontWeight.w800)),
                subtitle: const Text('Ödeme yok. Sadece kilit bayrağı.'),
                value: store.isPremium,
                onChanged: (v) => store.setPremium(v),
              ),
              const SizedBox(height: 22),
              GoldButton(
                label: 'HER ŞEYİ SIFIRLA',
                filled: false,
                onTap: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: const Color(0xFF0A0A0A),
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      title: const Text('SIFIRLA'),
                      content: const Text('Tüm yerel veri silinir. Geri alınmaz.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('VAZGEÇ')),
                        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('SİL')),
                      ],
                    ),
                  );
                  if (ok == true) {
                    await store.reset();
                    if (context.mounted) {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
