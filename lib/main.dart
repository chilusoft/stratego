import 'package:flutter/material.dart';
import 'widgets/game_screen.dart';

void main() => runApp(const ReversiApp());

class ReversiApp extends StatelessWidget {
  const ReversiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reversi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFe94560),
          brightness: Brightness.dark,
        ),
      ),
      home: const GameScreen(),
    );
  }
}
