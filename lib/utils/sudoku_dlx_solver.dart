// sudoku_dlx_solver.dart

import '../core/models/dancing_link_model.dart';

class SudokuDLXSolver {
  static const int size = 9;
  static const int subgridSize = 3;
  static const int constraintCount = 4 * size * size;

  late ColumnNode root;
  List<DLXNode> solution = [];

  // Solve the Sudoku puzzle
  List<List<int>> solve(List<List<int>> grid) {
    _buildDLXMatrix(grid);
    bool solved = _search(0);
    if (solved) {
      return _extractSolution();
    } else {
      throw Exception('No solution found');
    }
  }

  void _buildDLXMatrix(List<List<int>> grid) {
    root = ColumnNode(name: 'root');
    List<ColumnNode> columns = [];

    // Create column headers
    for (int i = 0; i < constraintCount; i++) {
      ColumnNode column = ColumnNode(name: 'C$i');
      columns.add(column);
      root = _linkColumns(root, column);
    }

    // Generate possible candidates
    for (int row = 0; row < size; row++) {
      for (int col = 0; col < size; col++) {
        if (grid[row][col] != 0) {
          int num = grid[row][col];
          _addNode(row, col, num, columns);
        } else {
          for (int num = 1; num <= size; num++) {
            _addNode(row, col, num, columns);
          }
        }
      }
    }
  }

  ColumnNode _linkColumns(ColumnNode root, ColumnNode column) {
    column.left = root.left;
    column.right = root;
    root.left!.right = column;
    root.left = column;
    return root;
  }

  void _addNode(int row, int col, int num, List<ColumnNode> columns) {
    // Calculate constraint indices
    int rowColConstraint = row * size + col;
    int rowNumConstraint = size * size + row * size + (num - 1);
    int colNumConstraint = 2 * size * size + col * size + (num - 1);
    int boxNumConstraint = 3 * size * size +
        ((row ~/ subgridSize) * subgridSize + (col ~/ subgridSize)) * size +
        (num - 1);

    List<int> constraintIndices = [
      rowColConstraint,
      rowNumConstraint,
      colNumConstraint,
      boxNumConstraint
    ];

    DLXNode? firstNode;
    DLXNode? prevNode;

    for (int constraintIndex in constraintIndices) {
      ColumnNode column = columns[constraintIndex];
      DLXNode newNode = DLXNode(column: column, rowID: row, columnID: col);

      // Link into column
      newNode.down = column;
      newNode.up = column.up;
      column.up!.down = newNode;
      column.up = newNode;
      column.size++;

      // Link row nodes
      if (firstNode == null) {
        firstNode = newNode;
      } else {
        newNode.left = prevNode;
        newNode.right = firstNode;
        prevNode!.right = newNode;
        firstNode.left = newNode;
      }
      prevNode = newNode;
    }
  }

  bool _search(int k) {
    if (root.right == root) {
      return true; // Solution found
    }

    // Choose the column with the smallest size
    ColumnNode column = _selectColumnNodeHeuristic();

    _cover(column);

    for (DLXNode rowNode = column.down!;
    rowNode != column;
    rowNode = rowNode.down!) {
      solution.add(rowNode);

      for (DLXNode rightNode = rowNode.right!;
      rightNode != rowNode;
      rightNode = rightNode.right!) {
        _cover(rightNode.column!);
      }

      if (_search(k + 1)) {
        return true;
      }

      solution.removeLast();

      for (DLXNode leftNode = rowNode.left!;
      leftNode != rowNode;
      leftNode = leftNode.left!) {
        _uncover(leftNode.column!);
      }
    }

    _uncover(column);
    return false;
  }

  ColumnNode _selectColumnNodeHeuristic() {
    int minSize = double.infinity.toInt();
    ColumnNode? chosenColumn;

    for (ColumnNode col = root.right as ColumnNode;
    col != root;
    col = col.right as ColumnNode) {
      if (col.size < minSize) {
        minSize = col.size;
        chosenColumn = col;
      }
    }

    return chosenColumn!;
  }

  void _cover(ColumnNode column) {
    column.right!.left = column.left;
    column.left!.right = column.right;

    for (DLXNode rowNode = column.down!;
    rowNode != column;
    rowNode = rowNode.down!) {
      for (DLXNode rightNode = rowNode.right!;
      rightNode != rowNode;
      rightNode = rightNode.right!) {
        rightNode.down!.up = rightNode.up;
        rightNode.up!.down = rightNode.down;
        rightNode.column!.size--;
      }
    }
  }

  void _uncover(ColumnNode column) {
    for (DLXNode rowNode = column.up!;
    rowNode != column;
    rowNode = rowNode.up!) {
      for (DLXNode leftNode = rowNode.left!;
      leftNode != rowNode;
      leftNode = leftNode.left!) {
        leftNode.column!.size++;
        leftNode.down!.up = leftNode;
        leftNode.up!.down = leftNode;
      }
    }
    column.right!.left = column;
    column.left!.right = column;
  }

  List<List<int>> _extractSolution() {
    List<List<int>> result = List.generate(size, (_) => List.filled(size, 0));

    for (DLXNode n in solution) {
      int row = n.rowID;
      int col = n.columnID;
      int num = 0;

      for (DLXNode node = n;
      node.right != n;
      node = node.right!) {
        if (node.column!.name.startsWith('C')) {
          int constraintIndex =
          int.parse(node.column!.name.substring(1));
          if (constraintIndex >= size * size &&
              constraintIndex < 2 * size * size) {
            num = (constraintIndex % size) + 1;
            break;
          }
        }
      }

      result[row][col] = num;
    }

    return result;
  }
}
