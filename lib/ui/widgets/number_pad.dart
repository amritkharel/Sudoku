import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/sudoku_provider.dart';

class NumberPad extends ConsumerWidget {
  const NumberPad({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sudokuBoard = ref.watch(sudokuProvider);
    final sudokuNotifier = ref.read(sudokuProvider.notifier);
    final numberUsage = sudokuBoard.numberUsage;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(6),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: List.generate(9, (index) {
          int number = index + 1;
          bool isUsedUp = numberUsage[number] >= 9;
          return SizedBox(
            width: 70,
            height: 55,
            child: ElevatedButton(
              onPressed:
                  isUsedUp ? null : () => sudokuNotifier.inputNumber(number),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    number.toString(),
                    style: const TextStyle(fontSize: 20),
                  ),
                  // Positioned(
                  //   right: 4,
                  //   top: 4,
                  //   child: Container(
                  //     padding: const EdgeInsets.all(2),
                  //     decoration: BoxDecoration(
                  //       color: Colors.redAccent,
                  //       shape: BoxShape.circle,
                  //     ),
                  //     constraints: const BoxConstraints(
                  //       minWidth: 16,
                  //       minHeight: 16,
                  //     ),
                  //     child: Text(
                  //       '${numberUsage[number]}',
                  //       style: const TextStyle(
                  //         color: Colors.white,
                  //         fontSize: 10,
                  //       ),
                  //       textAlign: TextAlign.end,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
