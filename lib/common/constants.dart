enum DifficultyLevel {
  easy,
  medium,
  difficult,
  extreme,
}

const Map<DifficultyLevel, int> difficultyEmptyCells = {
  DifficultyLevel.easy: 45,
  DifficultyLevel.medium: 50,
  DifficultyLevel.difficult: 55,
  DifficultyLevel.extreme: 60,
};

const Map<DifficultyLevel, String> difficultyNames = {
  DifficultyLevel.easy: 'Easy',
  DifficultyLevel.medium: 'Medium',
  DifficultyLevel.difficult: 'Difficult',
  DifficultyLevel.extreme: 'Extreme',
};
