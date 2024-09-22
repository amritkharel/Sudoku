class SudokuCell {
  final int row;
  final int col;
  int value;
  bool isInitial;
  bool isSelected;
  bool isError;

  SudokuCell({
    required this.row,
    required this.col,
    this.value = 0,
    this.isInitial = false,
    this.isSelected = false,
    this.isError = false,
  });
}

class SudokuBoard {
  List<List<SudokuCell>> cells;
  List<int> numberUsage;
  int selectedRow;
  int selectedCol;

  SudokuBoard({
    required this.cells,
    required this.numberUsage,
    this.selectedRow = -1,
    this.selectedCol = -1,
  });
}
