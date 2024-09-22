import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:suduko/utils/sudoku_solver.dart';

class SudokuPuzzle {
  final List<List<int>> puzzle;
  final List<List<int>> solution;

  SudokuPuzzle({required this.puzzle, required this.solution});
}


class SudokuGenerator {
  final Random _random = Random();
  final SudokuSolver _solver = SudokuSolver();

  Future<SudokuPuzzle> generatePuzzle({required int emptyCells}) async {
    List<List<int>> solution = _generateCompleteGrid();
    List<List<int>> puzzle = solution.map((row) => List<int>.from(row)).toList();
    _removeNumbers(puzzle, emptyCells);
    return SudokuPuzzle(puzzle: puzzle, solution: solution);
  }

  List<List<int>> _generateCompleteGrid() {
    List<List<int>> grid = List.generate(9, (_) => List.filled(9, 0));
    _fillGrid(grid);
    return grid;
  }

  bool _fillGrid(List<List<int>> grid) {
    int? row, col;
    int minCandidates = 10;
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if (grid[i][j] == 0) {
          List<int> candidates = _solver.getCandidates(grid, i, j);
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

    List<int> candidates = _solver.getCandidates(grid, row, col);
    candidates.shuffle(_random);

    for (int num in candidates) {
      grid[row][col] = num;
      if (_fillGrid(grid)) {
        return true;
      }
      grid[row][col] = 0;
    }

    return false;
  }

  void _removeNumbers(List<List<int>> grid, int emptyCells) {
    int totalCells = 81;
    int cellsToRemove = emptyCells;
    List<int> positions = List.generate(totalCells, (index) => index);
    positions.shuffle(_random);

    for (int pos in positions) {
      int row = pos ~/ 9;
      int col = pos % 9;
      int backup = grid[row][col];
      grid[row][col] = 0;

      if (!_hasUniqueSolution(grid)) {
        grid[row][col] = backup;
      } else {
        cellsToRemove--;
        if (cellsToRemove == 0) {
          break;
        }
      }
    }
  }

  bool _hasUniqueSolution(List<List<int>> grid) {
    SudokuSolver solver = SudokuSolver();
    solver.maxSolutions = 2;
    int numSolutions = solver.countSolutions(grid.map((row) => List<int>.from(row)).toList());
    return numSolutions == 1;
  }
}
