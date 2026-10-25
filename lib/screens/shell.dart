import 'package:flutter/material.dart';
import 'package:i_am_disiplin/screens/agenda_screen.dart';
import 'package:i_am_disiplin/screens/habit_screen.dart';
import 'package:i_am_disiplin/screens/home_screen.dart';
import 'package:i_am_disiplin/screens/life_screen.dart';
import 'package:i_am_disiplin/screens/more_screen.dart';
import 'package:i_am_disiplin/screens/promotion_screen.dart';
import 'package:i_am_disiplin/services/store.dart';

class Shell extends StatefulWidget {
  const Shell({super.key});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int index = 0;
  bool _opening = false;

  @override
  void initState() {
    super.initState();
    AppStore.I.addListener(_promo);
    WidgetsBinding.instance.addPostFrameCallback((_) => _promo());
  }

  @override
  void dispose() {
    AppStore.I.removeListener(_promo);
    super.dispose();
  }

  void _promo() {
    if (_opening || !mounted) return;
    final rank = AppStore.I.pendingPromotion;
    if (rank == null) return;
    _opening = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      AppStore.I.ackPromo();
      Navigator.of(context)
          .push(MaterialPageRoute<void>(
            fullscreenDialog: true,
            builder: (_) => PromotionScreen(rankIndex: rank),
          ))
          .then((_) {
        _opening = false;
        _promo();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const HomeScreen(),
      const HabitScreen(),
      const AgendaScreen(),
      const LifeScreen(),
      const MoreScreen(),
    ];
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        height: 68,
        backgroundColor: Colors.black,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.shield_outlined), selectedIcon: Icon(Icons.shield), label: 'Ana'),
          NavigationDestination(icon: Icon(Icons.check_box_outlined), selectedIcon: Icon(Icons.check_box), label: 'Alışkanlık'),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: 'Ajanda'),
          NavigationDestination(icon: Icon(Icons.flag_outlined), selectedIcon: Icon(Icons.flag), label: 'Plan'),
          NavigationDestination(icon: Icon(Icons.menu), label: 'Menü'),
        ],
      ),
    );
  }
}
