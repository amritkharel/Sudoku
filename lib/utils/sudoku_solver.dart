class SudokuSolver {
  int solutionCount = 0;
  int maxSolutions = 2;

  bool solve(List<List<int>> grid) {
    int? row, col;
    int minCandidates = 10;

    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if (grid[i][j] == 0) {
          List<int> candidates = getCandidates(grid, i, j);
          if (candidates.length < minCandidates) {
            minCandidates = candidates.length;
            row = i;
            col = j;
            if (minCandidates == 1) break;
          }
        }
      }
      if (minCandidates == 1) break;
    }

    if (row == null || col == null) {
      return true;
    }

    List<int> candidates = getCandidates(grid, row, col);
    for (int num in candidates) {
      grid[row][col] = num;
      if (solve(grid)) {
        return true;
      }
      grid[row][col] = 0;
    }

    return false;
  }

  int countSolutions(List<List<int>> grid) {
    solutionCount = 0;
    _solveAndCount(grid);
    return solutionCount;
  }

  void _solveAndCount(List<List<int>> grid) {
    if (solutionCount >= maxSolutions) {
      return;
    }

    int? row, col;
    int minCandidates = 10;

    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if (grid[i][j] == 0) {
          List<int> candidates = getCandidates(grid, i, j);
          if (candidates.length < minCandidates) {
            minCandidates = candidates.length;
            row = i;
            col = j;
            if (minCandidates == 1) break;
          }
        }
      }
      if (minCandidates == 1) break;
    }

    if (row == null || col == null) {
      solutionCount++;
      return;
    }

    List<int> candidates = getCandidates(grid, row, col);
    for (int num in candidates) {
      grid[row][col] = num;
      _solveAndCount(grid);
      grid[row][col] = 0;

      if (solutionCount >= maxSolutions) {
        return;
      }
    }
  }

  List<int> getCandidates(List<List<int>> grid, int row, int col) {
    Set<int> used = {};

    for (int i = 0; i < 9; i++) {
      if (grid[row][i] != 0) used.add(grid[row][i]);
      if (grid[i][col] != 0) used.add(grid[i][col]);
    }

    int startRow = row - row % 3;
    int startCol = col - col % 3;
    for (int i = startRow; i < startRow + 3; i++) {
      for (int j = startCol; j < startCol + 3; j++) {
        if (grid[i][j] != 0) used.add(grid[i][j]);
      }
    }

    List<int> candidates = [];
    for (int num = 1; num <= 9; num++) {
      if (!used.contains(num)) {
        candidates.add(num);
      }
    }

    return candidates;
  }
}
