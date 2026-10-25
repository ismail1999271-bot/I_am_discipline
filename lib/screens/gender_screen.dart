import 'package:flutter/material.dart';
import 'package:i_am_disiplin/services/store.dart';
import 'package:i_am_disiplin/widgets/common.dart';

class GenderScreen extends StatelessWidget {
  const GenderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 72),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'KİM GİRİYOR',
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: 1.5),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Text(
              'Heykel buna göre açılır. Sonra ayardan değiştirirsin.',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
              child: GoldButton(
                label: 'ERKEK',
                onTap: () => AppStore.I.setGender('erkek'),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              child: GoldButton(
                label: 'KADIN',
                filled: false,
                onTap: () => AppStore.I.setGender('kadin'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
