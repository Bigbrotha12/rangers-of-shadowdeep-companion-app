import 'package:flutter/material.dart';
import 'router.dart';

class RangersApp extends StatelessWidget {
  const RangersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Rangers of Shadow Deep',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E4057),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E4057),
          brightness: Brightness.dark,
        ),
      ),
      routerConfig: appRouter,
    );
  }
}
