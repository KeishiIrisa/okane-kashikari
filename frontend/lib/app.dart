import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'router.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ShadApp.router(
      title: 'お金貸し借り',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ja', 'JP'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ja', 'JP'),
      ],
      theme: ShadThemeData(
        brightness: Brightness.light,
        colorScheme: const ShadColorScheme(
          primary: Color(0xFF007AFF), // 貸しベースの青
          background: Colors.white,
          foreground: Color(0xFF1F1F1F),
          card: Colors.white,
          cardForeground: Color(0xFF1F1F1F),
          popover: Colors.white,
          popoverForeground: Color(0xFF1F1F1F),
          primaryForeground: Colors.white,
          secondary: Color(0xFFF5F5F5),
          secondaryForeground: Color(0xFF1F1F1F),
          muted: Color(0xFFF5F5F5),
          mutedForeground: Color(0xFF737373),
          accent: Color(0xFFF5F5F5),
          accentForeground: Color(0xFF1F1F1F),
          destructive: Color(0xFFEF4444), // 借りベースの赤
          destructiveForeground: Colors.white,
          border: Color(0xFFE5E5E5),
          input: Color(0xFFE5E5E5),
          ring: Color(0xFF007AFF),
          selection: Color(0xFF007AFF),
        ),
        radius: BorderRadius.circular(16.0), 
      ),
      routerConfig: goRouter,
    );
  }
}
