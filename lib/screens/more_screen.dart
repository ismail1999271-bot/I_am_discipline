import 'package:flutter/material.dart';
import 'package:i_am_disiplin/screens/film_screen.dart';
import 'package:i_am_disiplin/screens/settings_screen.dart';
import 'package:i_am_disiplin/widgets/common.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MENÜ')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _link(context, 'FİLMLER', const FilmScreen()),
          _link(context, 'AYARLAR', const SettingsScreen()),
        ],
      ),
    );
  }

  Widget _link(BuildContext context, String label, Widget page) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GoldButton(
        label: label,
        filled: false,
        onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page)),
      ),
    );
  }
}
