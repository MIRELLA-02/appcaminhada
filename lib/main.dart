import 'package:flutter/material.dart';

import 'splash_page.dart';

final temaNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: temaNotifier,
      builder: (context, modo, _) {
        return MaterialApp(
          title: 'Caminhadas',
          debugShowCheckedModeBanner: false,
          themeMode: modo,

          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 1, 67, 160),
            ),
            useMaterial3: true,
          ),

          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 94, 136, 221),
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),

          home: const SplashPage(),
        );
      },
    );
  }
}
