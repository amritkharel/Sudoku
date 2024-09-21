// utils/sudoku_generator.dart

import 'dart:math';
import 'package:flutter/foundation.dart';

class SudokuPuzzle {
  final List<List<int>> puzzle;
  final List<List<int>> solution;

  SudokuPuzzle({required this.puzzle, required this.solution});
}

class SudokuGenerator {
  static final List<List<int>> _baseGrid = [
    [1, 2, 3, 4, 5, 6, 7, 8, 9],
    [4, 5, 6, 7, 8, 9, 1, 2, 3],
    [7, 8, 9, 1, 2, 3, 4, 5, 6],
    [2, 3, 1, 5, 6, 4, 8, 9, 7],
    [5, 6, 4, 8, 9, 7, 2, 3, 1],
    [8, 9, 7, 2, 3, 1, 5, 6, 4],
    [3, 1, 2, 6, 4, 5, 9, 7, 8],
    [6, 4, 5, 9, 7, 8, 3, 1, 2],
    [9, 7, 8, 3, 1, 2, 6, 4, 5],
  ];

  static Future<SudokuPuzzle> generatePuzzle({required int emptyCells}) async {
    SudokuPuzzle puzzle = await compute(_generatePuzzle, emptyCells);
    return puzzle;
  }

  static SudokuPuzzle _generatePuzzle(int emptyCells) {
    List<List<int>> grid = _baseGrid.map((row) => List<int>.from(row)).toList();
    _shuffleGrid(grid);
    List<List<int>> solution = grid.map((row) => List<int>.from(row)).toList();
    _removeNumbers(grid, emptyCells);
    return SudokuPuzzle(puzzle: grid, solution: solution);
  }

  static void _shuffleGrid(List<List<int>> grid) {
    Random random = Random();

    // Swap rows within blocks
    for (int block = 0; block < 3; block++) {
      int row1 = block * 3 + random.nextInt(3);
      int row2 = block * 3 + random.nextInt(3);
      _swapRows(grid, row1, row2);
    }

    // Swap columns within blocks
    for (int block = 0; block < 3; block++) {
      int col1 = block * 3 + random.nextInt(3);
      int col2 = block * 3 + random.nextInt(3);
      _swapColumns(grid, col1, col2);
    }

    // Swap row blocks
    int blockRow1 = random.nextInt(3);
    int blockRow2 = random.nextInt(3);
    for (int i = 0; i < 3; i++) {
      _swapRows(grid, blockRow1 * 3 + i, blockRow2 * 3 + i);
    }

    // Swap column blocks
    int blockCol1 = random.nextInt(3);
    int blockCol2 = random.nextInt(3);
    for (int i = 0; i < 3; i++) {
      _swapColumns(grid, blockCol1 * 3 + i, blockCol2 * 3 + i);
    }
  }

  static void _swapRows(List<List<int>> grid, int row1, int row2) {
    var temp = grid[row1];
    grid[row1] = grid[row2];
    grid[row2] = temp;
  }

  static void _swapColumns(List<List<int>> grid, int col1, int col2) {
    for (int i = 0; i < 9; i++) {
      var temp = grid[i][col1];
      grid[i][col1] = grid[i][col2];
      grid[i][col2] = temp;
    }
  }

  static void _removeNumbers(List<List<int>> grid, int emptyCells) {
    Random random = Random();
    int attempts = 0;
    int maxAttempts = emptyCells * 5; // Limit attempts
    int removed = 0;

    while (removed < emptyCells && attempts < maxAttempts) {
      int row = random.nextInt(9);
      int col = random.nextInt(9);

      if (grid[row][col] != 0) {
        int backup = grid[row][col];
        grid[row][col] = 0;

        if (!_hasUniqueSolution(grid)) {
          grid[row][col] = backup; // Restore number
        } else {
          removed++;
        }
      }
      attempts++;
    }
  }

  static bool _hasUniqueSolution(List<List<int>> puzzle) {
    int solutions = 0;
    return _solveAndCount(puzzle, solutions);
  }

  static bool _solveAndCount(List<List<int>> grid, int solutions) {
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (grid[row][col] == 0) {
          for (int num = 1; num <= 9; num++) {
            if (_isValid(grid, row, col, num)) {
              grid[row][col] = num;
              if (!_solveAndCount(grid, solutions)) {
                grid[row][col] = 0;
                return false; // More than one solution
              }
              grid[row][col] = 0;
            }
          }
          return true; // Continue searching
        }
      }
    }
    solutions++;
    return solutions == 1; // Return false if more than one solution
  }

  static bool _isValid(List<List<int>> grid, int row, int col, int num) {
    for (int x = 0; x < 9; x++) {
      if (grid[row][x] == num || grid[x][col] == num) {
        return false;
      }
    }

    int startRow = row - row % 3;
    int startCol = col - col % 3;

    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (grid[startRow + i][startCol + j] == num) {
          return false;
        }
      }
    }

    return true;
  }
}
