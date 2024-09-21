import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final timerProvider = StateNotifierProvider<TimerNotifier, int>(
        (ref) => TimerNotifier());

class TimerNotifier extends StateNotifier<int> {
  TimerNotifier() : super(0) {
    startTimer();
  }

  Timer? _timer;

  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      state = state + 1;
    });
  }

  void resetTimer() {
    state = 0;
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
