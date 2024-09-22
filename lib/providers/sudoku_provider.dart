import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/constants.dart';
import '../core/models/sudoku_model.dart';
import '../utils/sudoku.dart';
import 'difficulty_level_provider.dart';

final sudokuProvider = StateNotifierProvider<SudokuNotifier, SudokuBoard>(
        (ref) => SudokuNotifier(ref));

final mistakeLimitProvider = StateProvider<bool>((ref) => false);

final mistakesProvider = StateProvider<int>((ref) => 0);

final puzzleCompletedProvider = StateProvider<bool>((ref) => false);

class SudokuNotifier extends StateNotifier<SudokuBoard> {
  SudokuNotifier(this.ref)
      : super(
    SudokuBoard(
      cells: [],
      numberUsage: List.filled(10, 0),
      selectedRow: -1,
      selectedCol: -1,
    ),
  ) {
    _initializePuzzle();
  }

  final Ref ref;
  late SudokuBoard _initialBoard;
  int selectedRow = -1;
  int selectedCol = -1;
  int _mistakes = 0;

  late List<List<int>> _solutionGrid;

  int get mistakes => _mistakes;

  void _initializePuzzle() async {
    final difficultyLevel = ref.read(difficultyLevelProvider);
    final emptyCells = difficultyEmptyCells[difficultyLevel]!;

    var sudokuPuzzle = await SudokuGenerator().generatePuzzle(emptyCells: emptyCells);
    _solutionGrid = sudokuPuzzle.solution;

    List<List<SudokuCell>> cells = List.generate(9, (row) {
      return List.generate(9, (col) {
        int value = sudokuPuzzle.puzzle[row][col];
        return SudokuCell(
          row: row,
          col: col,
          value: value,
          isInitial: value != 0,
        );
      });
    });

    state = SudokuBoard(
      cells: cells,
      numberUsage: List.filled(10, 0),
      selectedRow: -1,
      selectedCol: -1,
    );

    _initialBoard = _cloneBoard(state);
    _initializeNumberUsage();
  }
  void _initializeNumberUsage() {
    for (var row in state.cells) {
      for (var cell in row) {
        if (cell.value != 0) {
          state.numberUsage[cell.value]++;
        }
      }
    }
  }

  void selectCell(int row, int col) {
    for (var r in state.cells) {
      for (var c in r) {
        c.isSelected = false;
      }
    }

    selectedRow = row;
    selectedCol = col;
    state.cells[row][col].isSelected = true;

    state = SudokuBoard(
      cells: state.cells,
      numberUsage: state.numberUsage,
      selectedRow: selectedRow,
      selectedCol: selectedCol,
    );
  }

  void inputNumber(int number) {
    if (selectedRow == -1 || selectedCol == -1) return;

    var cell = state.cells[selectedRow][selectedCol];
    if (cell.isInitial) return;

    int correctNumber = _solutionGrid[selectedRow][selectedCol];
    if (number != correctNumber) {
      _mistakes++;
      ref.read(mistakesProvider.notifier).state = _mistakes;

      if (_mistakes >= 3) {
        ref.read(mistakeLimitProvider.notifier).state = true;
      }

      return;
    }

    // Update number usage
    if (cell.value != 0) {
      state.numberUsage[cell.value]--;
    }
    cell.value = number;
    state.numberUsage[number]++;

    state = SudokuBoard(
      cells: state.cells,
      numberUsage: state.numberUsage,
      selectedRow: selectedRow,
      selectedCol: selectedCol,
    );

    _checkForCompletion();
  }

  void _checkForCompletion() {
    for (var row in state.cells) {
      for (var cell in row) {
        if (cell.value == 0) {
          return;
        }
      }
    }

    // Puzzle completed
    ref.read(puzzleCompletedProvider.notifier).state = true;
  }

  void restart({bool sameGame = false}) {
    if (sameGame) {
      // Reset the current board to initial state
      state = _cloneBoard(_initialBoard);
    } else {
      // Generate a new puzzle and solution
      _initializePuzzle();
    }
    selectedRow = -1;
    selectedCol = -1;
    _mistakes = 0;
    ref.read(mistakesProvider.notifier).state = _mistakes;
    ref.read(puzzleCompletedProvider.notifier).state = false;
    _initializeNumberUsage();
  }

  SudokuBoard _cloneBoard(SudokuBoard board) {
    var newCells = board.cells
        .map((row) => row
        .map((cell) => SudokuCell(
      row: cell.row,
      col: cell.col,
      value: cell.value,
      isInitial: cell.isInitial,
      isSelected: cell.isSelected,
      isError: cell.isError,
    ))
        .toList())
        .toList();

    var newNumberUsage = List<int>.from(board.numberUsage);

    return SudokuBoard(
      cells: newCells,
      numberUsage: newNumberUsage,
      selectedRow: board.selectedRow,
      selectedCol: board.selectedCol,
    );
  }
}
