import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/constants.dart';

class DifficultyLevelNotifier extends StateNotifier<DifficultyLevel> {
  DifficultyLevelNotifier() : super(DifficultyLevel.easy) {
    _loadDifficultyLevel();
  }

  Future<void> _loadDifficultyLevel() async {
    final prefs = await SharedPreferences.getInstance();
    final levelString = prefs.getString('difficulty_level');
    if (levelString != null) {
      state = DifficultyLevel.values.firstWhere(
          (e) => e.toString() == levelString,
          orElse: () => DifficultyLevel.easy);
    }else{
      state = DifficultyLevel.easy;
    }
  }

  Future<void> setDifficultyLevel(DifficultyLevel newLevel) async {
    state = newLevel;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('difficulty_level', newLevel.toString());
  }
}

final difficultyLevelProvider =
    StateNotifierProvider<DifficultyLevelNotifier, DifficultyLevel>(
  (ref) => DifficultyLevelNotifier(),
);
