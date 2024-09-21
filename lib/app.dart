import 'package:flutter/material.dart';
import 'package:suduko/ui/screens/sudoku_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
        title: 'Sudoku',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const SudokuScreen());
  }
}
