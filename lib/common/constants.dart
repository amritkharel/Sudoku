enum DifficultyLevel {
  easy,
  medium,
  difficult,
  extreme,
}

const Map<DifficultyLevel, int> difficultyEmptyCells = {
  DifficultyLevel.easy: 43,
  DifficultyLevel.medium: 47,
  DifficultyLevel.difficult: 53,
  DifficultyLevel.extreme: 60,
};

const Map<DifficultyLevel, String> difficultyNames = {
  DifficultyLevel.easy: 'Easy',
  DifficultyLevel.medium: 'Medium',
  DifficultyLevel.difficult: 'Difficult',
  DifficultyLevel.extreme: 'Extreme',
};
