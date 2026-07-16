import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';
import 'ui/core/theme/color_schemes.dart';
import 'ui/core/theme/preferences.dart';

class RangersApp extends ConsumerWidget {
  const RangersApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeModePref = ref.watch(themeModeNotifier);
    final themeMode = switch (themeModePref) {
      ThemeModePref.light => ThemeMode.light,
      ThemeModePref.dark => ThemeMode.dark,
      ThemeModePref.system => ThemeMode.system,
    };

    return MaterialApp.router(
      title: 'Rangers of Shadow Deep',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ColorSchemes.light,
      darkTheme: ColorSchemes.dark,
      routerConfig: appRouter,
    );
  }
}
