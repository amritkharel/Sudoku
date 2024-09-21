enum DifficultyLevel {
  easy,
  medium,
  difficult,
  extreme,
}

const Map<DifficultyLevel, int> difficultyEmptyCells = {
  DifficultyLevel.easy: 40,
  DifficultyLevel.medium: 40,
  DifficultyLevel.difficult: 40,
  DifficultyLevel.extreme: 40,
};

const Map<DifficultyLevel, String> difficultyNames = {
  DifficultyLevel.easy: 'Easy',
  DifficultyLevel.medium: 'Medium',
  DifficultyLevel.difficult: 'Difficult',
  DifficultyLevel.extreme: 'Extreme',
};
