import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';

import '../../providers/sudoku_provider.dart';
import '../../providers/timer_provider.dart';
import '../widgets/app_bar.dart';
import '../widgets/number_pad.dart';
import '../widgets/sudoku_grid.dart';

class SudokuScreen extends ConsumerStatefulWidget {
  const SudokuScreen({super.key});

  @override
  ConsumerState<SudokuScreen> createState() => _SudokuScreenState();
}

class _SudokuScreenState extends ConsumerState<SudokuScreen>
    with SingleTickerProviderStateMixin {
  bool _dialogShown = false;
  bool _startNewGame = true;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 5),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -10.0), weight: 5),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 5),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 5),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -10.0), weight: 5),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 5),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: 0.0), weight: 1),
    ]).animate(_shakeController);

    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sudokuBoard = ref.watch(sudokuProvider);

    if (sudokuBoard.cells.isEmpty) {
      // Puzzle is still loading
      return const Scaffold(
        appBar: SudokuAppBar(),
        body: Center(child: CircularProgressIndicator()),
      );
    }else{
      void showTopSnackBar(BuildContext context, String message) {
        final overlay = Overlay.of(context);
        final overlayEntry = OverlayEntry(
          builder: (context) => Positioned(
            top: 10.0,
            left: 16.0,
            right: 16.0,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Center(
                  child: Text(
                    message,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        );

        overlay.insert(overlayEntry);
        Future.delayed(const Duration(seconds: 2))
            .then((_) => overlayEntry.remove());
      }

      ref.listen<int>(mistakesProvider, (previous, next) {
        if (next > (previous ?? 0) && next < 3) {
          showTopSnackBar(context, 'Wrong move! ${3 - next} chances remaining.');
          _shakeController.forward(from: 0);
        }
      });

      ref.listen<bool>(mistakeLimitProvider, (previous, next) async {
        if (next == true && !_dialogShown) {
          _dialogShown = true;
          await showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Game Over'),
              content: const Text(
                  'You have made 3 mistakes. Please restart the game.'),
              actions: [
                TextButton(
                  onPressed: () {
                    _startNewGame = false;
                    ref.read(mistakeLimitProvider.notifier).state = false;
                    _dialogShown = false;
                    ref.read(sudokuProvider.notifier).restart(sameGame: true);
                    ref.read(timerProvider.notifier).resetTimer();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Play Same Game'),
                ),
                TextButton(
                  onPressed: () {
                    ref.read(mistakeLimitProvider.notifier).state = false;
                    _dialogShown = false;
                    _startNewGame = false;
                    ref.read(sudokuProvider.notifier).restart(sameGame: false);
                    ref.read(timerProvider.notifier).resetTimer();
                    Navigator.of(context).pop();
                  },
                  child: const Text('New Game'),
                ),
              ],
            ),
          );
          if (_startNewGame) {
            _dialogShown = false;
            ref.read(mistakeLimitProvider.notifier).state = false;
            ref.read(sudokuProvider.notifier).restart(sameGame: false);
            ref.read(timerProvider.notifier).resetTimer();
          }
        }
      });

      ref.listen<bool>(puzzleCompletedProvider, (previous, next) {
        if (next == true && !_dialogShown) {
          _dialogShown = true;

          _confettiController.play();

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Congratulations!'),
              content: const Text('You have successfully completed the puzzle!'),
              actions: [
                TextButton(
                  onPressed: () {
                    ref.read(puzzleCompletedProvider.notifier).state = false;
                    _dialogShown = false;
                    ref.read(sudokuProvider.notifier).restart(sameGame: false);
                    ref.read(timerProvider.notifier).resetTimer();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Play Again'),
                ),
              ],
            ),
          ).then((_) {
            _confettiController.stop();
          });
        }
      });

      return Scaffold(
        appBar: const SudokuAppBar(),
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _shakeController,
                      builder: (context, child) {
                        double offset = _shakeAnimation.value;
                        return Transform.translate(
                          offset: Offset(offset, 0),
                          child: child,
                        );
                      },
                      child: const SudokuGrid(),
                    ),
                  ),
                ),
                if (kIsWeb)
                  const SizedBox(
                    height: 50,
                  ),
                const NumberPad(),
                const SizedBox(
                  height: 50,
                ),
              ],
            ),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: true,
                colors: const [
                  Colors.blue,
                  Colors.red,
                  Colors.yellow,
                  Colors.green
                ],
              ),
            ),
          ],
        ),
      );
    }

  }
}
