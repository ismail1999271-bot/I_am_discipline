import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i_am_disiplin/screens/gender_screen.dart';
import 'package:i_am_disiplin/screens/shell.dart';
import 'package:i_am_disiplin/screens/splash_screen.dart';
import 'package:i_am_disiplin/services/quotes.dart';
import 'package:i_am_disiplin/services/reminders.dart';
import 'package:i_am_disiplin/services/store.dart';
import 'package:i_am_disiplin/theme/app_theme.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR');
  await AppStore.I.load();
  await QuoteBook.load();
  try {
    await initReminders();
    await rescheduleAll(AppStore.I.habits);
  } catch (e) {
    debugPrint('hatirlatma yok: $e');
  }
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.black,
  ));
  runApp(const AppRoot());
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  @override
  void initState() {
    super.initState();
    AppStore.I.addListener(_onStore);
  }

  void _onStore() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    AppStore.I.removeListener(_onStore);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final skin = skinById(AppStore.I.themeId);
    return MaterialApp(
      navigatorKey: AppStore.navKey,
      title: 'Ben Disiplinim',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(skin),
      locale: const Locale('tr'),
      supportedLocales: const [Locale('tr'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const Gate(),
    );
  }
}

class Gate extends StatefulWidget {
  const Gate({super.key});

  @override
  State<Gate> createState() => _GateState();
}

class _GateState extends State<Gate> {
  bool _armed = false;
  int _token = 0;

  void _arm() {
    final store = AppStore.I;
    if (_armed || store.gender == null || store.splashDone) return;
    _armed = true;
    final token = ++_token;
    Future<void>.delayed(const Duration(milliseconds: 1600), () {
      if (!mounted || token != _token) return;
      _armed = false;
      if (AppStore.I.gender != null && !AppStore.I.splashDone) {
        AppStore.I.finishSplash();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppStore.I,
      builder: (context, _) {
        final store = AppStore.I;
        if (store.gender == null) {
          _armed = false;
          _token += 1;
          return const GenderScreen();
        }
        if (!store.splashDone) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _arm());
          return const SplashScreen();
        }
        return const Shell();
      },
    );
  }
}
