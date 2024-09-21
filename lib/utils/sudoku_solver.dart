class SudokuSolver {
  bool solve(List<List<int>> grid) {
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (grid[row][col] == 0) {
          for (int num = 1; num <= 9; num++) {
            if (isValid(grid, row, col, num)) {
              grid[row][col] = num;
              if (solve(grid)) {
                return true;
              }
              grid[row][col] = 0; // Backtrack
            }
          }
          return false; // Trigger backtracking
        }
      }
    }
    return true; // Solved
  }

  bool isValid(List<List<int>> grid, int row, int col, int num) {
    for (int i = 0; i < 9; i++) {
      if (grid[row][i] == num || grid[i][col] == num) {
        return false;
      }
    }

    int startRow = row - row % 3;
    int startCol = col - col % 3;
    for (int i = startRow; i < startRow + 3; i++) {
      for (int j = startCol; j < startCol + 3; j++) {
        if (grid[i][j] == num) {
          return false;
        }
      }
    }

    return true;
  }
}