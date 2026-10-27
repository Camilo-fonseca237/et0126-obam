import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() => runApp(const ObamApp());

class ObamApp extends StatelessWidget {
  const ObamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OBAM',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
      ),
      home: const HomeScreen(),
    );
  }
}
