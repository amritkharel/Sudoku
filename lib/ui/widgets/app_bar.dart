import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/constants.dart';
import '../../providers/sudoku_provider.dart';
import '../../providers/timer_provider.dart';
import '../../providers/difficulty_level_provider.dart';

class SudokuAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const SudokuAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sudokuNotifier = ref.watch(sudokuProvider.notifier);
    final timer = ref.watch(timerProvider);
    final difficultyLevel = ref.watch(difficultyLevelProvider);
    final difficultyLevelNotifier = ref.read(difficultyLevelProvider.notifier);

    String formatTime(int seconds) {
      final minutes = seconds ~/ 60;
      final secs = seconds % 60;
      return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }

    return AppBar(
      centerTitle: true,
      leadingWidth: 120,
      leading: Padding(
        padding: const EdgeInsets.only(left: 30),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<DifficultyLevel>(
            value: difficultyLevel,
            onChanged: (DifficultyLevel? newLevel) async {
              if (newLevel != null) {
                await difficultyLevelNotifier.setDifficultyLevel(newLevel);
                sudokuNotifier.restart();
                ref.read(timerProvider.notifier).resetTimer();
              }
            },
            items: DifficultyLevel.values.map((level) {
              return DropdownMenuItem<DifficultyLevel>(
                value: level,
                child: Text(
                  difficultyNames[level]!,
                  style: const TextStyle(color: Colors.black),
                ),
              );
            }).toList(),
            iconEnabledColor: Colors.grey,
            dropdownColor: Colors.white,
            style: const TextStyle(color: Colors.black),
          ),
        ),
      )
      ,
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Sudoku'),
          Text(
            formatTime(timer),
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Restart',
          onPressed: () {
            sudokuNotifier.restart();
            ref.read(timerProvider.notifier).resetTimer();
          },
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
